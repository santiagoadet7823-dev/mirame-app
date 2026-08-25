/// Base local. **Es la fuente de verdad de la UI**: ningún widget consulta
/// Supabase directamente.
///
/// Reglas que valen para toda tabla de negocio (ver `05-OFFLINE-SYNC.md`):
///  - `id` es un uuid v7 generado en el cliente. No hay autoincrement: con
///    autoincrement dos dispositivos offline crean el mismo id y al
///    sincronizar uno pisa al otro.
///  - `tenantId` en todas. Sin eso, cambiar de salón mostraría datos mezclados.
///  - `deletedAt` en vez de borrar (tombstone). Un DELETE local no se puede
///    propagar: el otro dispositivo nunca se entera de que la fila existió.
///  - `updatedAt` es el reloj del last-write-wins y el cursor del pull.
library;

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'database.g.dart';

/// Columnas comunes a toda tabla que sincroniza.
mixin _Sincronizable on Table {
  TextColumn get id => text()();
  TextColumn get tenantId => text()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Professionals extends Table with _Sincronizable {
  TextColumn get nombre => text()();
  TextColumn get telefono => text().nullable()();
}

class Services extends Table with _Sincronizable {
  TextColumn get nombre => text()();
  // `real` y no texto: en el legacy los precios venían de `input.value` y se
  // guardaban como string, así que sumarlos concatenaba.
  RealColumn get precio => real().withDefault(const Constant(0))();
  IntColumn get duracionMin => integer().withDefault(const Constant(60))();
  IntColumn get retoqueDias => integer().nullable()();
  IntColumn get mantenimientoDias => integer().nullable()();
  TextColumn get notas => text().nullable()();
}

class Clients extends Table with _Sincronizable {
  TextColumn get nombre => text()();
  TextColumn get telefono => text().nullable()();
  TextColumn get email => text().nullable()();
  DateTimeColumn get cumple => dateTime().nullable()();
  // Booleano de verdad. En el legacy era el string 'true'/'false' y cualquier
  // comparación descuidada daba siempre verdadero.
  BoolColumn get vip => boolean().withDefault(const Constant(false))();
  TextColumn get notas => text().nullable()();
}

class Appointments extends Table with _Sincronizable {
  TextColumn get clientId => text().nullable()();
  TextColumn get professionalId => text().nullable()();
  /// Fecha local `YYYY-MM-DD`. Se guarda como texto y NO como DateTime a
  /// propósito: el legacy usaba `toISOString()` y después de las 21:00 (UTC-3)
  /// el turno saltaba al día siguiente.
  TextColumn get fecha => text()();
  /// Hora local `HH:MM`.
  TextColumn get hora => text()();
  RealColumn get precio => real().withDefault(const Constant(0))();
  /// `confirmed` | `pending` | `done` | `cancelled` — enum `turno_estado`
  /// del servidor. El default del original tambien es 'confirmed'.
  TextColumn get estado =>
      text().withDefault(const Constant('confirmed'))();
  TextColumn get notas => text().nullable()();
}

/// Servicios de un turno. Vínculo por **id**: el legacy guardaba el nombre, y
/// por eso renombrar un servicio rompía en silencio los recordatorios.
///
/// A diferencia del resto, NO lleva `id`, `tenant_id` ni `deleted_at`: en
/// Postgres es una tabla puente pura con clave compuesta, y el esquema local
/// tiene que coincidir o el sync empuja columnas que el servidor no conoce.
class AppointmentServices extends Table {
  TextColumn get appointmentId => text()();
  TextColumn get serviceId => text()();
  RealColumn get precio => real().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {appointmentId, serviceId};
}

class Transactions extends Table with _Sincronizable {
  /// `income` | `expense` — los valores EXACTOS del enum `tx_tipo` de
  /// Postgres. No 'ingreso'/'gasto': el servidor rechaza cualquier otra cosa
  /// y la fila se queda dando vueltas en el outbox hasta agotar reintentos,
  /// sin que nadie se entere.
  TextColumn get tipo => text()();
  RealColumn get monto => real().withDefault(const Constant(0))();
  TextColumn get descripcion => text().nullable()();
  TextColumn get categoria => text().nullable()();
  TextColumn get fecha => text()(); // YYYY-MM-DD local
  TextColumn get metodo => text().nullable()();
  /// En el legacy el CRM leía este campo pero nadie lo escribía, así que el
  /// total gastado por clienta salía siempre $0.
  TextColumn get clientId => text().nullable()();
  TextColumn get appointmentId => text().nullable()();
}

class StockItems extends Table with _Sincronizable {
  TextColumn get nombre => text()();
  TextColumn get categoria => text().nullable()();
  IntColumn get cantidad => integer().withDefault(const Constant(0))();
  IntColumn get minimo => integer().withDefault(const Constant(0))();
  TextColumn get unidad => text().nullable()();
}

class Settings extends Table {
  TextColumn get tenantId => text()();
  TextColumn get clave => text()();
  TextColumn get valor => text().nullable()();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {tenantId, clave};
}

/// Cola de escrituras pendientes de subir.
///
/// Toda escritura va primero a la tabla local y además deja una fila acá. El
/// motor la drena cuando hay red. Si la app se cierra en el medio, la cola
/// sobrevive: por eso está en SQLite y no en memoria.
class Outbox extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get tenantId => text()();
  TextColumn get tabla => text()();
  TextColumn get filaId => text()();
  /// `upsert` | `delete` | `delta`
  TextColumn get operacion => text()();
  /// JSON con los campos a mandar.
  TextColumn get payload => text()();
  IntColumn get intentos => integer().withDefault(const Constant(0))();
  TextColumn get ultimoError => text().nullable()();
  DateTimeColumn get creadoAt =>
      dateTime().withDefault(currentDateAndTime)();
  /// Cuándo volver a intentar. Alimenta el backoff exponencial.
  DateTimeColumn get reintentarAt => dateTime().nullable()();
}

/// Hasta dónde se bajó cada tabla. El pull siguiente arranca de acá.
class SyncState extends Table {
  TextColumn get tenantId => text()();
  TextColumn get tabla => text()();
  DateTimeColumn get cursor => dateTime().nullable()();
  DateTimeColumn get ultimoPull => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {tenantId, tabla};
}

/// Cache del acceso, para poder abrir la app sin red.
///
/// Guarda el JSON crudo de perfil, membresías, salones y licencias. Es lo que
/// el `SessionController` lee cuando Supabase no responde: sin esto, quedarse
/// sin señal manda al login aunque la sesión sea válida.
class AccessCache extends Table {
  TextColumn get clave => text()();
  TextColumn get json => text()();
  DateTimeColumn get guardadoAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {clave};
}

@DriftDatabase(
  tables: [
    Professionals,
    Services,
    Clients,
    Appointments,
    AppointmentServices,
    Transactions,
    StockItems,
    Settings,
    Outbox,
    SyncState,
    AccessCache,
  ],
)
class MirameDb extends _$MirameDb {
  MirameDb() : super(_abrir());

  MirameDb.paraTest(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          // Los índices que importan de verdad: toda consulta de la UI filtra
          // por tenant y descarta tombstones. Sin esto, cada pantalla hace un
          // scan completo apenas el salón tenga algo de historia.
          await customStatement(
            'create index if not exists ix_appt_tenant_fecha '
            'on appointments (tenant_id, fecha) where deleted_at is null',
          );
          await customStatement(
            'create index if not exists ix_tx_tenant_fecha '
            'on transactions (tenant_id, fecha) where deleted_at is null',
          );
          await customStatement(
            'create index if not exists ix_clients_tenant '
            'on clients (tenant_id) where deleted_at is null',
          );
          await customStatement(
            'create index if not exists ix_appt_srv_appt '
            'on appointment_services (appointment_id)',
          );
          await customStatement(
            'create index if not exists ix_outbox_pendiente '
            'on outbox (tenant_id, reintentar_at)',
          );
        },
        beforeOpen: (details) async {
          // Sin esto SQLite ignora las foreign keys en silencio.
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );
}

QueryExecutor _abrir() => driftDatabase(
      name: 'mirame',
      // Obligatorio en web: sin esto la PWA no arranca y muestra
      // "When compiling to the web, the `web` parameter needs to be set".
      // Los dos archivos van en `web/` y salen del paquete drift, para que
      // siempre correspondan a la version que compila la app.
      web: DriftWebOptions(
        sqlite3Wasm: Uri.parse('sqlite3.wasm'),
        driftWorker: Uri.parse('drift_worker.js'),
      ),
    );
