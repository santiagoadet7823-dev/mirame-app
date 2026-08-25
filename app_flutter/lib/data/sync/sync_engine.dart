/// Motor de sincronización: sube el outbox y baja los cambios del servidor.
///
/// La UI nunca lo espera. Escribe local, encola, y sigue. Si una pantalla
/// muestra un spinner aguardando a Supabase, está mal escrita.
library;

import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../local/database.dart';
import '../remote/supabase_client.dart';

/// Tablas que sincronizan, en **orden de dependencia**.
///
/// El orden importa al subir: un `appointment_services` que llega antes que su
/// turno viola la foreign key del servidor y se rechaza. Al bajar da igual,
/// pero se mantiene el mismo orden para no tener dos listas.
/// `appointment_services` NO está: en Postgres es una tabla puente pura, sin
/// `tenant_id` ni `updated_at`, así que no se puede paginar por cursor ni
/// filtrar por salón como las demás. Se sincroniza junto con su turno cuando
/// se implemente la edición de servicios (pendiente).
/// Nombre interno de la tabla puente. No entra en `tablasSync` porque su pull
/// es distinto (ver `_traerServiciosDeTurnos`).
const _tablaServicios = 'appointment_services';

const tablasSync = <String>[
  'professionals',
  'services',
  'clients',
  'appointments',
  'transactions',
  'stock_items',
];

enum EstadoSync { inactivo, sincronizando, sinRed, error }

class SyncStatus {
  const SyncStatus({
    this.estado = EstadoSync.inactivo,
    this.pendientes = 0,
    this.ultimoOk,
    this.error,
  });

  final EstadoSync estado;

  /// Cuántas escrituras esperan en la cola. Es lo que la UI muestra como
  /// "faltan N por subir".
  final int pendientes;
  final DateTime? ultimoOk;
  final String? error;

  SyncStatus copyWith({
    EstadoSync? estado,
    int? pendientes,
    DateTime? ultimoOk,
    String? error,
    bool limpiarError = false,
  }) =>
      SyncStatus(
        estado: estado ?? this.estado,
        pendientes: pendientes ?? this.pendientes,
        ultimoOk: ultimoOk ?? this.ultimoOk,
        error: limpiarError ? null : (error ?? this.error),
      );
}

/// Cuánto esperar antes de reintentar, según cuántas veces ya falló.
///
/// Backoff exponencial con techo: sin techo, tras unos pocos fallos la fila
/// quedaría programada para dentro de días y no se subiría nunca más. Sin
/// backoff, una fila que el servidor rechaza siempre haría girar la rueda
/// consumiendo batería y datos.
Duration esperaDeReintento(int intentos) {
  if (intentos <= 0) return Duration.zero;
  // El clamp solo evita que el corrimiento se desborde; el techo real lo pone
  // la linea de abajo. Una version anterior clampeaba en 8, con lo cual el
  // maximo efectivo eran 21 minutos y la comparacion contra 3600 nunca se
  // cumplia: el techo declarado no era el techo real. Lo encontro un test.
  final segundos = 5 * (1 << (intentos - 1).clamp(0, 20));
  const techo = 3600;
  return Duration(seconds: segundos > techo ? techo : segundos);
}

/// Cuántos fallos antes de dejar de reintentar y pedir intervención.
///
/// Una fila que falló 8 veces no falla por la red: falla por su contenido
/// (una foreign key rota, un campo que el servidor no acepta). Seguir
/// intentando no la arregla y tapa la cola de las que sí podrían subir.
const kMaxIntentos = 8;

class SyncEngine {
  SyncEngine(this._db);

  final MirameDb _db;

  /// Encola una escritura. **Siempre** se llama dentro de la misma transacción
  /// que escribe la tabla local: si se guardara el dato y fallara el encolado,
  /// el cambio quedaría solo en este dispositivo, invisible y para siempre.
  Future<void> encolar({
    required String tenantId,
    required String tabla,
    required String filaId,
    required String operacion,
    required Map<String, dynamic> payload,
  }) =>
      _db.into(_db.outbox).insert(
            OutboxCompanion.insert(
              tenantId: tenantId,
              tabla: tabla,
              filaId: filaId,
              operacion: operacion,
              payload: jsonEncode(payload),
              reintentarAt: Value(DateTime.now()),
            ),
          );

  Future<int> pendientes(String tenantId) async {
    final q = _db.selectOnly(_db.outbox)
      ..addColumns([_db.outbox.id.count()])
      ..where(_db.outbox.tenantId.equals(tenantId));
    final fila = await q.getSingle();
    return fila.read(_db.outbox.id.count()) ?? 0;
  }

  /// Sube lo encolado. Devuelve cuántas filas se subieron bien.
  Future<int> empujar(String tenantId) async {
    final ahora = DateTime.now();
    final filas = await (_db.select(_db.outbox)
          ..where((o) => o.tenantId.equals(tenantId))
          ..where((o) =>
              o.reintentarAt.isNull() |
              o.reintentarAt.isSmallerOrEqualValue(ahora))
          ..where((o) => o.intentos.isSmallerThanValue(kMaxIntentos))
          // Por id: es el orden en que ocurrieron. Reordenar la cola puede
          // mandar la edición de un turno antes que su creación.
          ..orderBy([(o) => OrderingTerm.asc(o.id)])
          ..limit(200))
        .get();

    var subidas = 0;
    for (final fila in filas) {
      try {
        await _subir(fila);
        await (_db.delete(_db.outbox)..where((o) => o.id.equals(fila.id)))
            .go();
        subidas++;
      } catch (e) {
        final intentos = fila.intentos + 1;
        await (_db.update(_db.outbox)..where((o) => o.id.equals(fila.id)))
            .write(
          OutboxCompanion(
            intentos: Value(intentos),
            ultimoError: Value('$e'),
            reintentarAt:
                Value(DateTime.now().add(esperaDeReintento(intentos))),
          ),
        );
        // No se corta el bucle: una fila trabada no puede bloquear a las
        // demás. Ese fue exactamente el modo de falla del legacy.
      }
    }
    return subidas;
  }

  Future<void> _subir(OutboxData fila) async {
    final payload = jsonDecode(fila.payload) as Map<String, dynamic>;
    switch (fila.operacion) {
      case 'delta':
        // El stock NO usa last-write-wins. Dos ajustes concurrentes de +1
        // resueltos por LWW dan +1 y se pierde uno; con deltas el servidor
        // suma y quedan los dos.
        await sb.rpc('ajustar_stock', params: {
          'p_item': fila.filaId,
          'p_delta': payload['delta'],
        });
      case 'servicios':
        // Reemplazo completo de la tabla puente de un turno: primero se borra
        // lo que habia y despues se inserta la lista nueva. Un upsert solo no
        // alcanza, porque no elimina el servicio que la usuaria saco.
        await sb
            .from('appointment_services')
            .delete()
            .eq('appointment_id', fila.filaId);
        final ids = (payload['service_ids'] as List).cast<String>();
        if (ids.isNotEmpty) {
          await sb.from('appointment_services').insert([
            for (final sid in ids)
              {'appointment_id': fila.filaId, 'service_id': sid},
          ]);
        }
      case 'delete':
        // Tombstone, no DELETE: un borrado real no se puede propagar porque
        // el otro dispositivo nunca se entera de que la fila existió.
        await sb.from(fila.tabla).update({
          'deleted_at': DateTime.now().toUtc().toIso8601String(),
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        }).eq('id', fila.filaId);
      default:
        await sb.from(fila.tabla).upsert(payload);
    }
  }

  /// Baja lo que cambió desde el último cursor de cada tabla.
  Future<int> traer(String tenantId) async {
    var total = 0;
    Object? primerError;

    // Cada tabla se baja por separado y un fallo NO corta el resto.
    //
    // Antes era un `for` pelado, y eso significaba que una sola fila rara en
    // `appointments` dejaba a la usuaria sin caja y sin stock: el bucle moría
    // ahí y las tablas siguientes nunca se pedían. Se veía como "la app perdió
    // mis movimientos", que es lo peor que puede parecer.
    for (final tabla in [...tablasSync, _tablaServicios]) {
      try {
        total += tabla == _tablaServicios
            ? await _traerServiciosDeTurnos(tenantId)
            : await _traerTabla(tenantId, tabla);
      } catch (e) {
        debugPrint('sync: falló el pull de $tabla ($e)');
        primerError ??= e;
      }
    }

    // Se relanza DESPUÉS de intentarlas todas, para que el estado siga
    // mostrándose como "con problemas" y se reintente, pero sin perder lo que
    // sí se pudo bajar.
    if (primerError != null) throw primerError;
    return total;
  }

  /// `appointment_services` va aparte del resto.
  ///
  /// Es una tabla puente pura: sin `id`, sin `tenant_id` y sin `updated_at`,
  /// así que no tiene cursor con el que hacer un pull incremental. Se baja
  /// entera y se reemplaza.
  ///
  /// Eso alcanza porque son pocas filas (una por servicio de cada turno) y
  /// porque saltearla tiene una consecuencia cara: sin los servicios de cada
  /// turno, los recordatorios de retoque no encuentran los días y no avisan
  /// nunca. La usuaria lo vería como "la app dejó de avisarme".
  Future<int> _traerServiciosDeTurnos(String tenantId) async {
    // Sin filtro de tenant a propósito: la tabla no tiene la columna, y la RLS
    // del servidor ya devuelve solo los turnos que a esta persona le
    // corresponden.
    final filas = await sb.from('appointment_services').select() as List;

    await _db.transaction(() async {
      // Los turnos de OTROS salones no se tocan: en el panel de plataforma un
      // superadmin puede tener varios abiertos.
      await _db.customStatement(
        'delete from appointment_services where appointment_id in '
        '(select id from appointments where tenant_id = ?)',
        [tenantId],
      );
      for (final f in filas) {
        await _aplicar('appointment_services', f as Map<String, dynamic>);
      }
    });
    return filas.length;
  }

  Future<int> _traerTabla(String tenantId, String tabla) async {
    final estado = await (_db.select(_db.syncState)
          ..where((s) => s.tenantId.equals(tenantId) & s.tabla.equals(tabla)))
        .getSingleOrNull();

    var q = sb.from(tabla).select().eq('tenant_id', tenantId);
    final cursor = estado?.cursor;
    if (cursor != null) {
      // `gt` y no `gte`: con `gte` se vuelve a bajar la última fila en cada
      // pull, para siempre.
      q = q.gt('updated_at', cursor.toUtc().toIso8601String());
    }
    final filas = await q.order('updated_at').limit(500) as List;
    if (filas.isEmpty) return 0;

    DateTime? maximo;
    for (final f in filas) {
      final fila = f as Map<String, dynamic>;
      await _aplicar(tabla, fila);
      final u = DateTime.tryParse('${fila['updated_at']}');
      if (u != null && (maximo == null || u.isAfter(maximo))) maximo = u;
    }

    await _db.into(_db.syncState).insertOnConflictUpdate(
          SyncStateCompanion.insert(
            tenantId: tenantId,
            tabla: tabla,
            cursor: Value(maximo ?? cursor),
            ultimoPull: Value(DateTime.now()),
          ),
        );
    return filas.length;
  }

  /// Escribe una fila del servidor en la tabla local.
  ///
  /// Se hace con SQL crudo y no con la API tipada de Drift para no repetir
  /// once bloques idénticos que solo cambian en el nombre de la tabla. Los
  /// nombres de columna vienen del esquema, no del usuario.
  /// Columnas que Drift guarda como DateTime, es decir como **entero epoch**.
  /// El servidor las manda en ISO: hay que convertirlas o la fila queda
  /// ilegible y la próxima lectura lanza `FormatException`.
  static const _columnasFecha = {'created_at', 'updated_at', 'deleted_at',
      'cumple'};

  Future<void> _aplicar(String tabla, Map<String, dynamic> fila) async {
    final columnas = <String, dynamic>{};
    fila.forEach((k, v) {
      if (v is Map || v is List) return; // relaciones anidadas, no columnas
      if (v == null) {
        columnas[k] = null;
      } else if (_columnasFecha.contains(k) && v is String) {
        final d = DateTime.tryParse(v);
        // Una fecha que no parsea se descarta en vez de guardarse cruda: mejor
        // perder ese campo que dejar la fila entera sin poder leerse.
        if (d != null) columnas[k] = d.millisecondsSinceEpoch ~/ 1000;
      } else {
        columnas[k] = v is bool ? (v ? 1 : 0) : v;
      }
    });
    if (columnas.isEmpty) return;

    final nombres = columnas.keys.toList();
    final marcas = List.filled(nombres.length, '?').join(', ');
    await _db.customStatement(
      'insert or replace into $tabla (${nombres.join(', ')}) '
      'values ($marcas)',
      nombres.map((n) => columnas[n]).toList(),
    );
  }

  /// Un ciclo completo: primero sube, después baja.
  ///
  /// Ese orden no es casual. Bajando primero, un cambio local todavía sin
  /// subir sería pisado por la versión vieja del servidor y se perdería sin
  /// dejar rastro.
  Future<void> ciclo(String tenantId) async {
    await empujar(tenantId);
    await traer(tenantId);
  }
}

final dbProvider = Provider<MirameDb>((ref) {
  final db = MirameDb();
  ref.onDispose(db.close);
  return db;
});

final syncEngineProvider =
    Provider<SyncEngine>((ref) => SyncEngine(ref.watch(dbProvider)));

/// Estado visible del sync, para la barrita de la UI.
class SyncController extends Notifier<SyncStatus> {
  Timer? _periodico;
  StreamSubscription<List<ConnectivityResult>>? _red;
  String? _tenant;

  @override
  SyncStatus build() {
    ref.onDispose(() {
      _periodico?.cancel();
      _red?.cancel();
    });
    return const SyncStatus();
  }

  /// Arranca el sync para un salón. Idempotente: llamarlo dos veces con el
  /// mismo salón no duplica timers.
  void arrancar(String tenantId) {
    if (_tenant == tenantId && _periodico != null) return;
    _tenant = tenantId;
    _periodico?.cancel();
    _red?.cancel();

    unawaited(sincronizar());

    // Recuperar la señal es el momento en que más urge drenar la cola.
    _red = Connectivity().onConnectivityChanged.listen((r) {
      if (!r.contains(ConnectivityResult.none)) unawaited(sincronizar());
    });

    // Red de seguridad: `connectivity_plus` avisa que hay interfaz, no que
    // haya internet. Un wifi de bar sin salida no dispara ningún evento.
    _periodico = Timer.periodic(
      const Duration(minutes: 3),
      (_) => unawaited(sincronizar()),
    );
  }

  void detener() {
    _periodico?.cancel();
    _red?.cancel();
    _periodico = null;
    _tenant = null;
    state = const SyncStatus();
  }

  Future<void> sincronizar() async {
    final tenant = _tenant;
    if (tenant == null || state.estado == EstadoSync.sincronizando) return;

    final engine = ref.read(syncEngineProvider);
    state = state.copyWith(
        estado: EstadoSync.sincronizando, limpiarError: true);
    try {
      await engine.ciclo(tenant);
      state = SyncStatus(
        estado: EstadoSync.inactivo,
        pendientes: await engine.pendientes(tenant),
        ultimoOk: DateTime.now(),
      );
    } catch (e) {
      // Sin red NO es un error: es un estado normal de una app local-first.
      // Mostrarlo como error entrena a ignorar los avisos de verdad.
      final sinRed = await Connectivity()
          .checkConnectivity()
          .then((r) => r.contains(ConnectivityResult.none))
          .catchError((_) => false);
      state = state.copyWith(
        estado: sinRed ? EstadoSync.sinRed : EstadoSync.error,
        pendientes: await engine.pendientes(tenant),
        error: sinRed ? null : '$e',
      );
    }
  }
}

final syncProvider =
    NotifierProvider<SyncController, SyncStatus>(SyncController.new);
