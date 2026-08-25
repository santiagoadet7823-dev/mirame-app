/// Lecturas y escrituras de negocio. **Todo pasa por acá**: ningún widget
/// toca Drift ni Supabase directamente.
///
/// Las lecturas son `Stream` (`watch`) para que la UI se actualice sola cuando
/// el sync baja algo. Las escrituras van a la tabla local y al outbox **en la
/// misma transacción**: si se guardara el dato y fallara el encolado, el
/// cambio quedaría solo en este dispositivo, invisible y para siempre.
library;

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../features/auth/session_controller.dart';
import '../local/database.dart';
import '../../domain/rules/period.dart';
import '../sync/sync_engine.dart';

/// uuid **v7**: lleva el tiempo adelante, así que ordena por creación y los
/// índices de SQLite no se fragmentan como con el v4. Se genera en el cliente
/// para poder crear sin red.
final _uuid = Uuid();
String nuevoId() => _uuid.v7();

/// Namespace DNS de RFC 4122. Es el mismo que usa `scripts/migrar-backup.py`,
/// y tiene que seguir siéndolo.
const _nsLegacy = '6ba7b810-9dad-11d1-80b4-00c04fd430c8';

/// uuid5 determinista para un registro que viene de la app vieja.
///
/// [clave] es `'<prefijo>:<id viejo>'` — `c:12`, `sv:3`, `a:47`. Los prefijos
/// son los MISMOS que usa el script de migración, y el tenant va adentro para
/// que dos salones que importen backups distintos no colisionen.
///
/// Que sea determinista es lo que permite restaurar el mismo archivo dos veces
/// —o en dos teléfonos— sin duplicar nada: cae siempre en el mismo id y el
/// upsert lo pisa. También hace que un backup ya migrado por SQL coincida fila
/// por fila con lo que ya está en el servidor.
String idDesdeLegacy(String tenantId, String clave) =>
    _uuid.v5(_nsLegacy, '$tenantId:$clave');

/// Fecha local `YYYY-MM-DD`.
///
/// Nunca `toIso8601String()` sobre un DateTime en UTC: el legacy hacía eso y
/// después de las 21:00 (UTC-3) el turno saltaba al día siguiente.
/// Drift guarda `DateTime` como **segundos epoch (entero)**, no como texto.
///
/// Hace falta al escribir con SQL crudo: pasar un `toIso8601String()` deja la
/// columna con un texto que después NO se puede leer — el mapeo hace
/// `int.parse` y lanza `FormatException`, tumbando la consulta entera. Lo
/// encontró un test, después de que un `borrar()` dejara la lista de clientas
/// sin poder abrirse.
int aEpoch(DateTime d) => d.millisecondsSinceEpoch ~/ 1000;

class BusinessRepository {
  const BusinessRepository(this._db, this._sync, this._tenantId);

  final MirameDb _db;
  final SyncEngine _sync;
  final String _tenantId;

  /// Lo necesita la restauración de backups para calcular los ids legacy.
  String get tenantId => _tenantId;

  // ── Lecturas ─────────────────────────────────────────────────────────────

  Stream<List<Client>> verClientes() => (_db.select(_db.clients)
        ..where((c) => c.tenantId.equals(_tenantId))
        // Los tombstones se filtran en TODA lectura. Si se olvida en una, esa
        // pantalla muestra lo borrado y parece que el borrado no funcionó.
        ..where((c) => c.deletedAt.isNull())
        ..orderBy([(c) => OrderingTerm.asc(c.nombre)]))
      .watch();

  Stream<List<Appointment>> verTurnosDe(DateTime dia) =>
      (_db.select(_db.appointments)
            ..where((a) => a.tenantId.equals(_tenantId))
            ..where((a) => a.deletedAt.isNull())
            ..where((a) => a.fecha.equals(claveFecha(dia)))
            ..orderBy([(a) => OrderingTerm.asc(a.hora)]))
          .watch();

  Stream<List<Appointment>> verTurnosEntre(DateTime desde, DateTime hasta) =>
      (_db.select(_db.appointments)
            ..where((a) => a.tenantId.equals(_tenantId))
            ..where((a) => a.deletedAt.isNull())
            ..where((a) => a.fecha.isBetweenValues(
                claveFecha(desde), claveFecha(hasta)))
            ..orderBy([
              (a) => OrderingTerm.asc(a.fecha),
              (a) => OrderingTerm.asc(a.hora),
            ]))
          .watch();

  /// Historial de una clienta, del turno más nuevo al más viejo.
  Stream<List<Appointment>> verTurnosDeCliente(String clienteId) =>
      (_db.select(_db.appointments)
            ..where((a) => a.tenantId.equals(_tenantId))
            ..where((a) => a.deletedAt.isNull())
            ..where((a) => a.clientId.equals(clienteId))
            ..orderBy([
              (a) => OrderingTerm.desc(a.fecha),
              (a) => OrderingTerm.desc(a.hora),
            ]))
          .watch();

  Stream<List<Transaction>> verMovimientosEntre(
    DateTime desde,
    DateTime hasta,
  ) =>
      (_db.select(_db.transactions)
            ..where((t) => t.tenantId.equals(_tenantId))
            ..where((t) => t.deletedAt.isNull())
            ..where((t) => t.fecha
                .isBetweenValues(claveFecha(desde), claveFecha(hasta)))
            ..orderBy([(t) => OrderingTerm.desc(t.fecha)]))
          .watch();

  Stream<List<StockItem>> verStock() => (_db.select(_db.stockItems)
        ..where((s) => s.tenantId.equals(_tenantId))
        ..where((s) => s.deletedAt.isNull())
        ..orderBy([(s) => OrderingTerm.asc(s.nombre)]))
      .watch();

  /// Turnos de los últimos 90 días: alcanza para los recordatorios de retoque
  /// (que miran como mucho 30 días atrás) sin traer todo el historial.
  Stream<List<Appointment>> verTurnosRecientes() {
    final desde = DateTime.now().subtract(const Duration(days: 90));
    return (_db.select(_db.appointments)
          ..where((a) => a.tenantId.equals(_tenantId))
          ..where((a) => a.deletedAt.isNull())
          ..where((a) => a.fecha.isBiggerOrEqualValue(claveFecha(desde))))
        .watch();
  }

  /// `appointment_id` → los `service_id` de ese turno.
  ///
  /// Va aparte y no dentro del turno porque vive en la tabla puente. Sin esto
  /// los recordatorios de retoque no tienen con qué calcular.
  Stream<Map<String, List<String>>> verServiciosDeTurnos() =>
      _db.select(_db.appointmentServices).watch().map((filas) {
        final m = <String, List<String>>{};
        for (final f in filas) {
          (m[f.appointmentId] ??= []).add(f.serviceId);
        }
        return m;
      });

  Stream<List<Service>> verServicios() => (_db.select(_db.services)
        ..where((s) => s.tenantId.equals(_tenantId))
        ..where((s) => s.deletedAt.isNull())
        ..orderBy([(s) => OrderingTerm.asc(s.nombre)]))
      .watch();

  Stream<List<Professional>> verProfesionales() =>
      (_db.select(_db.professionals)
            ..where((p) => p.tenantId.equals(_tenantId))
            ..where((p) => p.deletedAt.isNull())
            ..orderBy([(p) => OrderingTerm.asc(p.nombre)]))
          .watch();

  /// Turnos y gasto acumulado por clienta, para la lista del CRM.
  ///
  /// Se resuelve con dos agregados en SQL y no trayendo todos los turnos y
  /// movimientos a memoria: la lista de clientas se abre seguido y el
  /// historial solo crece.
  ///
  /// El gasto se suma de los **turnos**, no de las transacciones.
  ///
  /// `renderClients` del original lo sacaba de las transacciones con
  /// `client_id`, pero ese campo NUNCA se escribía: el total daba siempre \$0.
  /// Los turnos sí tienen clienta y precio — es lo que hace `topClients`, con
  /// esta misma nota en el original. Se descartan los cancelados: un turno que
  /// no ocurrió no es plata que entró.
  Stream<Map<String, ({int turnos, double gastado})>> verResumenClientes() {
    final consulta = '''
      select c.id as cid,
             (select count(*) from appointments a
               where a.client_id = c.id and a.deleted_at is null) as turnos,
             (select coalesce(sum(a.precio), 0) from appointments a
               where a.client_id = c.id and a.deleted_at is null
                 and a.estado <> 'cancelled') as gastado
      from clients c
      where c.tenant_id = ? and c.deleted_at is null
    ''';
    return _db
        .customSelect(
          consulta,
          variables: [Variable.withString(_tenantId)],
          readsFrom: {_db.clients, _db.appointments},
        )
        .watch()
        .map((filas) => {
              for (final f in filas)
                f.read<String>('cid'): (
                  turnos: f.read<int>('turnos'),
                  gastado: f.read<double>('gastado'),
                ),
            });
  }

  // ── Escrituras ───────────────────────────────────────────────────────────

  /// Guarda una clienta (nueva o existente) y la encola.
  Future<String> guardarCliente({
    String? id,
    required String nombre,
    String? telefono,
    String? email,
    DateTime? cumple,
    bool vip = false,
    String? notas,
  }) async {
    final filaId = id ?? nuevoId();
    final ahora = DateTime.now();
    await _db.transaction(() async {
      await _db.into(_db.clients).insertOnConflictUpdate(
            ClientsCompanion.insert(
              id: filaId,
              tenantId: _tenantId,
              nombre: nombre,
              telefono: Value(telefono),
              email: Value(email),
              cumple: Value(cumple),
              vip: Value(vip),
              notas: Value(notas),
              updatedAt: Value(ahora),
            ),
          );
      await _sync.encolar(
        tenantId: _tenantId,
        tabla: 'clients',
        filaId: filaId,
        operacion: 'upsert',
        payload: {
          'id': filaId,
          'tenant_id': _tenantId,
          'nombre': nombre,
          'telefono': telefono,
          'email': email,
          'cumple': cumple == null ? null : claveFecha(cumple),
          'vip': vip,
          'notas': notas,
          'updated_at': ahora.toUtc().toIso8601String(),
        },
      );
    });
    return filaId;
  }

  Future<String> guardarTurno({
    String? id,
    String? clientId,
    String? professionalId,
    required DateTime fecha,
    required String hora,
    double precio = 0,
    String estado = 'confirmed',
    String? notas,
    /// `null` significa **no tocar** los servicios del turno; una lista los
    /// reemplaza por completo, incluso si viene vacía.
    ///
    /// La distinción no es un detalle: al restaurar un backup viejo que no
    /// trae servicios, tratar "vacío" como "borrá todos" destruyó datos que
    /// estaban bien. El formulario siempre manda una lista; quien no sabe,
    /// manda `null`.
    List<String>? serviceIds,
  }) async {
    final filaId = id ?? nuevoId();
    final ahora = DateTime.now();
    final f = claveFecha(fecha);
    await _db.transaction(() async {
      await _db.into(_db.appointments).insertOnConflictUpdate(
            AppointmentsCompanion.insert(
              id: filaId,
              tenantId: _tenantId,
              fecha: f,
              hora: hora,
              clientId: Value(clientId),
              professionalId: Value(professionalId),
              precio: Value(precio),
              estado: Value(estado),
              notas: Value(notas),
              updatedAt: Value(ahora),
            ),
          );
      await _sync.encolar(
        tenantId: _tenantId,
        tabla: 'appointments',
        filaId: filaId,
        operacion: 'upsert',
        payload: {
          'id': filaId,
          'tenant_id': _tenantId,
          'client_id': clientId,
          'professional_id': professionalId,
          'fecha': f,
          'hora': hora,
          'precio': precio,
          'estado': estado,
          'notas': notas,
          'updated_at': ahora.toUtc().toIso8601String(),
        },
      );

      // Los servicios del turno viven en una tabla puente. Se reemplazan
      // enteros en vez de hacer un diff: editar un turno para SACARLE un
      // servicio es tan común como agregarle uno, y un upsert solo agrega.
      //
      // Sin esto, un turno creado en la app queda sin servicios y la clienta
      // nunca aparece en los recordatorios de retoque.
      if (serviceIds == null) return;

      await (_db.delete(_db.appointmentServices)
            ..where((f) => f.appointmentId.equals(filaId)))
          .go();
      for (final sid in serviceIds) {
        await _db.into(_db.appointmentServices).insertOnConflictUpdate(
              AppointmentServicesCompanion.insert(
                appointmentId: filaId,
                serviceId: sid,
              ),
            );
      }
      await _sync.encolar(
        tenantId: _tenantId,
        tabla: 'appointment_services',
        filaId: filaId,
        // El servidor recibe la lista completa y reemplaza: es la unica forma
        // de que un servicio quitado desaparezca tambien alla.
        operacion: 'servicios',
        payload: {'appointment_id': filaId, 'service_ids': serviceIds},
      );
    });
    return filaId;
  }

  Future<String> guardarMovimiento({
    String? id,
    required String tipo,
    required double monto,
    required DateTime fecha,
    String? descripcion,
    String? categoria,
    String? metodo,
    String? clientId,
    String? appointmentId,
  }) async {
    final filaId = id ?? nuevoId();
    final ahora = DateTime.now();
    final f = claveFecha(fecha);
    await _db.transaction(() async {
      await _db.into(_db.transactions).insertOnConflictUpdate(
            TransactionsCompanion.insert(
              id: filaId,
              tenantId: _tenantId,
              tipo: tipo,
              fecha: f,
              monto: Value(monto),
              descripcion: Value(descripcion),
              categoria: Value(categoria),
              metodo: Value(metodo),
              // Se escribe de verdad. En el legacy el CRM lo leía y nadie lo
              // guardaba, así que el gastado por clienta era siempre $0.
              clientId: Value(clientId),
              appointmentId: Value(appointmentId),
              updatedAt: Value(ahora),
            ),
          );
      await _sync.encolar(
        tenantId: _tenantId,
        tabla: 'transactions',
        filaId: filaId,
        operacion: 'upsert',
        payload: {
          'id': filaId,
          'tenant_id': _tenantId,
          'tipo': tipo,
          'monto': monto,
          'descripcion': descripcion,
          'categoria': categoria,
          'fecha': f,
          'metodo': metodo,
          'client_id': clientId,
          'appointment_id': appointmentId,
          'updated_at': ahora.toUtc().toIso8601String(),
        },
      );
    });
    return filaId;
  }

  Future<String> guardarStock({
    String? id,
    required String nombre,
    int cantidad = 0,
    int minimo = 0,
    String? categoria,
    String? unidad,
  }) async {
    final filaId = id ?? nuevoId();
    final ahora = DateTime.now();
    await _db.transaction(() async {
      await _db.into(_db.stockItems).insertOnConflictUpdate(
            StockItemsCompanion.insert(
              id: filaId,
              tenantId: _tenantId,
              nombre: nombre,
              cantidad: Value(cantidad),
              minimo: Value(minimo),
              categoria: Value(categoria),
              unidad: Value(unidad),
              updatedAt: Value(ahora),
            ),
          );
      await _sync.encolar(
        tenantId: _tenantId,
        tabla: 'stock_items',
        filaId: filaId,
        // Alta y edición van como upsert: acá se fija un valor absoluto a
        // propósito. Los deltas son solo para el +1/-1 del uso diario.
        operacion: 'upsert',
        payload: {
          'id': filaId,
          'tenant_id': _tenantId,
          'nombre': nombre,
          'categoria': categoria,
          'cantidad': cantidad,
          'minimo': minimo,
          'unidad': unidad,
          'updated_at': ahora.toUtc().toIso8601String(),
        },
      );
    });
    return filaId;
  }

  /// Ajusta el stock **por diferencia**, no por valor absoluto.
  ///
  /// Es la única excepción al last-write-wins de todo el sistema. Dos
  /// dispositivos offline que descuentan uno cada uno: con LWW gana el último
  /// y queda -1 en vez de -2. Con deltas el servidor suma los dos.
  Future<void> ajustarStock(String itemId, int delta) async {
    if (delta == 0) return;
    await _db.transaction(() async {
      await _db.customStatement(
        'update stock_items set cantidad = max(0, cantidad + ?), '
        'updated_at = ? where id = ? and tenant_id = ?',
        [delta, aEpoch(DateTime.now()), itemId, _tenantId],
      );
      await _sync.encolar(
        tenantId: _tenantId,
        tabla: 'stock_items',
        filaId: itemId,
        operacion: 'delta',
        payload: {'delta': delta},
      );
    });
  }

  /// Alta y edición de un servicio del catálogo.
  ///
  /// `retoqueDias` es el campo que alimenta los recordatorios: si queda en
  /// null, ese servicio simplemente no genera aviso de retoque.
  Future<String> guardarServicio({
    String? id,
    required String nombre,
    num precio = 0,
    int duracionMin = 60,
    int? retoqueDias,
    int? mantenimientoDias,
    String? notas,
  }) async {
    final filaId = id ?? nuevoId();
    final ahora = DateTime.now();
    await _db.transaction(() async {
      await _db.into(_db.services).insertOnConflictUpdate(
            ServicesCompanion.insert(
              id: filaId,
              tenantId: _tenantId,
              nombre: nombre,
              precio: Value(precio.toDouble()),
              duracionMin: Value(duracionMin),
              retoqueDias: Value(retoqueDias),
              mantenimientoDias: Value(mantenimientoDias),
              notas: Value(notas),
              updatedAt: Value(ahora),
            ),
          );
      await _sync.encolar(
        tenantId: _tenantId,
        tabla: 'services',
        filaId: filaId,
        operacion: 'upsert',
        payload: {
          'id': filaId,
          'tenant_id': _tenantId,
          'nombre': nombre,
          'precio': precio,
          'duracion_min': duracionMin,
          'retoque_dias': retoqueDias,
          'mantenimiento_dias': mantenimientoDias,
          'notas': notas,
          'updated_at': ahora.toUtc().toIso8601String(),
        },
      );
    });
    return filaId;
  }

  Future<String> guardarProfesional({
    String? id,
    required String nombre,
    String? telefono,
  }) async {
    final filaId = id ?? nuevoId();
    final ahora = DateTime.now();
    await _db.transaction(() async {
      await _db.into(_db.professionals).insertOnConflictUpdate(
            ProfessionalsCompanion.insert(
              id: filaId,
              tenantId: _tenantId,
              nombre: nombre,
              telefono: Value(telefono),
              updatedAt: Value(ahora),
            ),
          );
      await _sync.encolar(
        tenantId: _tenantId,
        tabla: 'professionals',
        filaId: filaId,
        operacion: 'upsert',
        payload: {
          'id': filaId,
          'tenant_id': _tenantId,
          'nombre': nombre,
          'telefono': telefono,
          'updated_at': ahora.toUtc().toIso8601String(),
        },
      );
    });
    return filaId;
  }

  /// Lee TODO de una vez, para el backup.
  ///
  /// Es una lectura puntual y no un stream: el backup es una foto, y un stream
  /// abierto sobre las seis tablas mientras se arma el JSON solo agregaría
  /// reconstrucciones a mitad de camino.
  ///
  /// Los servicios de cada turno NO vienen acá: viven en la tabla puente y se
  /// piden aparte con `verServiciosDeTurnos()`. Quien arme el backup tiene que
  /// unirlos, o restauraría turnos sin servicio y se perderían los
  /// recordatorios de retoque.
  Future<({
    List<Appointment> turnos,
    List<Client> clientas,
    List<Transaction> movimientos,
    List<StockItem> stock,
    List<Professional> profesionales,
    List<Service> servicios,
  })> leerTodoParaBackup() async {
    Future<List<T>> vivos<T extends DataClass>(
      TableInfo<Table, T> tabla,
      GeneratedColumn<String> tenant,
      GeneratedColumn<DateTime> borrado,
    ) =>
        (_db.select(tabla)
              ..where((_) => tenant.equals(_tenantId) & borrado.isNull()))
            .get();

    return (
      turnos: await vivos(_db.appointments, _db.appointments.tenantId,
          _db.appointments.deletedAt),
      clientas: await vivos(
          _db.clients, _db.clients.tenantId, _db.clients.deletedAt),
      movimientos: await vivos(_db.transactions, _db.transactions.tenantId,
          _db.transactions.deletedAt),
      stock: await vivos(
          _db.stockItems, _db.stockItems.tenantId, _db.stockItems.deletedAt),
      profesionales: await vivos(_db.professionals,
          _db.professionals.tenantId, _db.professionals.deletedAt),
      servicios: await vivos(
          _db.services, _db.services.tenantId, _db.services.deletedAt),
    );
  }

  /// Borrado lógico. Ver `deletedAt` en `database.dart`.
  Future<void> borrar(String tabla, String filaId) async {
    final ahora = DateTime.now();
    await _db.transaction(() async {
      await _db.customStatement(
        'update $tabla set deleted_at = ?, updated_at = ? '
        'where id = ? and tenant_id = ?',
        [aEpoch(ahora), aEpoch(ahora), filaId, _tenantId],
      );
      await _sync.encolar(
        tenantId: _tenantId,
        tabla: tabla,
        filaId: filaId,
        operacion: 'delete',
        payload: const {},
      );
    });
  }
}

/// El repositorio del salón activo. `null` si todavía no se eligió uno.
final businessRepoProvider = Provider<BusinessRepository?>((ref) {
  final tenant = ref.watch(tenantActivoProvider);
  if (tenant == null) return null;
  return BusinessRepository(
    ref.watch(dbProvider),
    ref.watch(syncEngineProvider),
    tenant.id,
  );
});
