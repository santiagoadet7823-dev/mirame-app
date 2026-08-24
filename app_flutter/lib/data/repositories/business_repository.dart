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
import '../sync/sync_engine.dart';

/// uuid **v7**: lleva el tiempo adelante, así que ordena por creación y los
/// índices de SQLite no se fragmentan como con el v4. Se genera en el cliente
/// para poder crear sin red.
final _uuid = Uuid();
String nuevoId() => _uuid.v7();

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

String claveFecha(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-'
    '${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';

class BusinessRepository {
  const BusinessRepository(this._db, this._sync, this._tenantId);

  final MirameDb _db;
  final SyncEngine _sync;
  final String _tenantId;

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
  /// El gasto sale de las TRANSACCIONES de tipo ingreso con `client_id`, igual
  /// que `renderClients` del original.
  Stream<Map<String, ({int turnos, double gastado})>> verResumenClientes() {
    final consulta = '''
      select c.id as cid,
             (select count(*) from appointments a
               where a.client_id = c.id and a.deleted_at is null) as turnos,
             (select coalesce(sum(t.monto), 0) from transactions t
               where t.client_id = c.id and t.tipo = 'ingreso'
                 and t.deleted_at is null) as gastado
      from clients c
      where c.tenant_id = ? and c.deleted_at is null
    ''';
    return _db
        .customSelect(
          consulta,
          variables: [Variable.withString(_tenantId)],
          readsFrom: {_db.clients, _db.appointments, _db.transactions},
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
    String estado = 'pendiente',
    String? notas,
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
