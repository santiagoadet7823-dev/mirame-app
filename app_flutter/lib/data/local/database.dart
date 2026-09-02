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

// NOTA: en Postgres esta tabla tiene además `activo`, y `proveedores` tiene
// `tenant_proveedor_id`. Acá no están, y hasta la v4 eso hacía que el pull de
// las dos fallara fila por fila con "no such column" —en silencio, tapado por
// el try/catch de `_traerTabla`—. Lo resuelve el filtro de columnas
// desconocidas de `_aplicar`, no una columna nueva: la app no usa ninguna de
// las dos. Si algún día hace falta `activo`, se agrega acá con su migración.
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


// ═══════════════════════════════════════════════════════════════════════════
// ROPA — consignación
// ═══════════════════════════════════════════════════════════════════════════

/// Quien entrega la mercadería a consignación.
class Proveedores extends Table with _Sincronizable {
  TextColumn get nombre => text()();
  TextColumn get telefono => text().nullable()();
  TextColumn get email => text().nullable()();

  /// Porcentaje que se queda EL SALÓN. Es el default de sus productos.
  RealColumn get pctSalon => real().withDefault(const Constant(30))();

  /// Si el salón hace un descuento, ¿lo absorbe solo o lo comparte el
  /// proveedor? Lo habitual en consignación es que lo absorba el salón.
  BoolColumn get descuentoLoAbsorbeSalon =>
      boolean().withDefault(const Constant(true))();
  TextColumn get notas => text().nullable()();
  BoolColumn get activo => boolean().withDefault(const Constant(true))();
}

class Depositos extends Table with _Sincronizable {
  TextColumn get nombre => text()();
  TextColumn get direccion => text().nullable()();
  BoolColumn get esPrincipal => boolean().withDefault(const Constant(false))();
}

class Productos extends Table with _Sincronizable {
  TextColumn get proveedorId => text().nullable()();
  TextColumn get nombre => text()();
  TextColumn get descripcion => text().nullable()();
  TextColumn get categoria => text().nullable()();

  /// Código corto tipo `MIR-042`, para buscarla al instante y para que la
  /// clienta la nombre por WhatsApp sin describirla.
  TextColumn get codigo => text().nullable()();
  RealColumn get precio => real().withDefault(const Constant(0))();

  /// Pisa el del proveedor cuando este producto tiene otro acuerdo.
  RealColumn get pctSalon => real().nullable()();

  /// `ropa` | `arbell` | `insumos`. El salón no vende solo ropa.
  ///
  /// Texto y no enum a propósito: agregar un rubro nuevo no puede exigir una
  /// migración de esquema.
  TextColumn get rubro => text().withDefault(const Constant('ropa'))();
  BoolColumn get publicado => boolean().withDefault(const Constant(false))();
  BoolColumn get destacado => boolean().withDefault(const Constant(false))();
}

/// Talle × color. Es lo que de verdad se vende y se cuenta.
class ProductoVariantes extends Table with _Sincronizable {
  TextColumn get productoId => text()();
  TextColumn get talle => text().nullable()();
  TextColumn get color => text().nullable()();
  TextColumn get sku => text().nullable()();
}

/// Cuánto hay de cada variante EN CADA DEPÓSITO.
class StockVariantes extends Table with _Sincronizable {
  TextColumn get varianteId => text()();
  TextColumn get depositoId => text()();
  IntColumn get cantidad => integer().withDefault(const Constant(0))();
}

class ProductoFotos extends Table with _Sincronizable {
  TextColumn get productoId => text()();

  /// Foto de un color puntual. Null = del producto en general.
  TextColumn get varianteId => text().nullable()();

  /// Ruta en el bucket `productos` de Supabase Storage.
  TextColumn get path => text()();
  IntColumn get orden => integer().withDefault(const Constant(0))();

  /// La foto vive primero en el teléfono y se sube después. Mientras esto sea
  /// true, la ficha muestra "falta subir" en vez de una imagen rota: una
  /// imagen no se puede encolar como una fila de texto.
  BoolColumn get pendienteDeSubir =>
      boolean().withDefault(const Constant(false))();

  /// Dónde está el archivo local mientras no se subió.
  TextColumn get rutaLocal => text().nullable()();
}

class Ventas extends Table with _Sincronizable {
  TextColumn get depositoId => text().nullable()();

  /// Quién vendió. Null = la dueña desde su propia cuenta.
  TextColumn get vendedorId => text().nullable()();

  /// Alimenta el "total gastado" que ya muestra la ficha de clienta.
  TextColumn get clientId => text().nullable()();
  TextColumn get fecha => text()(); // YYYY-MM-DD local
  RealColumn get total => real().withDefault(const Constant(0))();
  RealColumn get descuento => real().withDefault(const Constant(0))();
  TextColumn get metodo => text().withDefault(const Constant('efectivo'))();

  /// `completada` | `anulada`
  TextColumn get estado => text().withDefault(const Constant('completada'))();
  TextColumn get notas => text().nullable()();
}

/// Los porcentajes van CONGELADOS acá.
///
/// Guardar solo una referencia al proveedor haría que cambiarle el porcentaje
/// recalculara ventas viejas, y las liquidaciones ya pagadas dejarían de
/// cuadrar. Es el mismo error de fondo que el legacy cometía al vincular los
/// servicios de un turno por NOMBRE.
class VentaItems extends Table with _Sincronizable {
  TextColumn get ventaId => text()();
  TextColumn get varianteId => text().nullable()();

  /// Denormalizado a propósito: si mañana se borra el producto, la venta vieja
  /// tiene que seguir siendo legible.
  TextColumn get descripcion => text().nullable()();
  IntColumn get cantidad => integer().withDefault(const Constant(1))();
  RealColumn get precioUnit => real().withDefault(const Constant(0))();
  RealColumn get pctSalon => real().withDefault(const Constant(0))();
  RealColumn get pctVendedor => real().withDefault(const Constant(0))();
  RealColumn get montoProveedor => real().withDefault(const Constant(0))();
  RealColumn get montoSalon => real().withDefault(const Constant(0))();
  RealColumn get montoVendedor => real().withDefault(const Constant(0))();

  /// Se marca al incluirlo en una liquidación, para no pagarlo dos veces.
  TextColumn get liquidacionId => text().nullable()();
}

class Reservas extends Table with _Sincronizable {
  TextColumn get codigo => text()();
  TextColumn get nombre => text()();
  TextColumn get telefono => text().nullable()();

  /// `pendiente` | `confirmada` | `entregada` | `cancelada`
  TextColumn get estado => text().withDefault(const Constant('pendiente'))();
  DateTimeColumn get venceAt => dateTime()();
  TextColumn get notas => text().nullable()();
}

class ReservaItems extends Table with _Sincronizable {
  TextColumn get reservaId => text()();
  TextColumn get varianteId => text()();
  IntColumn get cantidad => integer().withDefault(const Constant(1))();
}

class Liquidaciones extends Table with _Sincronizable {
  /// `proveedor` | `vendedor`
  TextColumn get tipo => text()();
  TextColumn get destinatarioId => text()();
  TextColumn get periodoDesde => text()();
  TextColumn get periodoHasta => text()();
  RealColumn get total => real().withDefault(const Constant(0))();

  /// `borrador` | `pagada`
  TextColumn get estado => text().withDefault(const Constant('borrador'))();
  DateTimeColumn get pagadaAt => dateTime().nullable()();
  TextColumn get notas => text().nullable()();
}

/// La fuente de verdad del inventario. `StockVariantes.cantidad` es el saldo;
/// esto es el detalle de cómo se llegó a ese número.
class MovimientosStock extends Table with _Sincronizable {
  TextColumn get varianteId => text()();
  TextColumn get depositoId => text()();
  IntColumn get delta => integer()();

  /// `ingreso` | `venta` | `devolucion_proveedor` | `transferencia` |
  /// `ajuste` | `anulacion`
  TextColumn get motivo => text()();
  TextColumn get referenciaId => text().nullable()();
  TextColumn get notas => text().nullable()();
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
    // Ropa
    Proveedores,
    Depositos,
    Productos,
    ProductoVariantes,
    StockVariantes,
    ProductoFotos,
    Ventas,
    VentaItems,
    Reservas,
    ReservaItems,
    Liquidaciones,
    MovimientosStock,
  ],
)
/// Convierte un valor suelto en el `Variable` que espera `customUpdate`.
///
/// `customStatement` acepta `List<dynamic>`; `customUpdate` no, y es el precio
/// de que ademas invalide los streams.
Variable variablePara(Object? v) {
  if (v == null) return const Variable<String>(null);
  if (v is int) return Variable<int>(v);
  if (v is double) return Variable<double>(v);
  if (v is bool) return Variable<bool>(v);
  if (v is Uint8List) return Variable<Uint8List>(v);
  return Variable<String>(v.toString());
}

class MirameDb extends _$MirameDb {
  MirameDb() : super(_abrir());

  MirameDb.paraTest(super.e);

  /// La tabla de Drift que corresponde a un nombre SQL.
  ///
  /// Sirve para decirle a `customUpdate` qué streams invalidar. Sin esto una
  /// escritura por SQL crudo no refresca ninguna pantalla.
  TableInfo<Table, dynamic>? tablaPorNombre(String nombre) {
    for (final t in allTables) {
      if (t.actualTableName == nombre) return t;
    }
    return null;
  }

  @override
  int get schemaVersion => 4;

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
          await _indicesRopa(this);
        },
        // v2 · módulo de ropa. Las tablas se crean vacías: no hay datos que
        // migrar porque la funcionalidad no existía.
        onUpgrade: (m, desde, hasta) async {
          if (desde < 2) {
            // El tipo va explicito: sin el, Dart infiere el supertipo comun
            // (`_Sincronizable`, el mixin) en vez de `TableInfo`, y
            // `createTable` no lo acepta.
            for (final t in <TableInfo<Table, dynamic>>[
              proveedores, depositos, productos, productoVariantes,
              stockVariantes, productoFotos, ventas, ventaItems,
              reservas, reservaItems, liquidaciones, movimientosStock,
            ]) {
              await m.createTable(t);
            }
            await _indicesRopa(this);
          }
          // v3 · rubro. Las prendas que ya estaban son ropa, que es el default
          // de la columna: no hay nada que rellenar a mano.
          if (desde < 3) {
            await m.addColumn(productos, productos.rubro);
          }
          // v4 · recrea `appointment_services`.
          if (desde < 4) {
            // `appointment_services` nació con el mixin `_Sincronizable`, o
            // sea con `id` y `tenant_id` NOT NULL. Después se le sacó el mixin
            // y se le puso PK compuesta, pero SIN subir `schemaVersion`: los
            // teléfonos que ya la tenían se quedaron con la tabla vieja, y el
            // pull moría en cada ciclo con
            //   NOT NULL constraint failed: appointment_services.id
            // porque el insert de hoy manda solo tres columnas.
            //
            // Se RECREA en vez de parchear `id`: la tabla vieja también tiene
            // `tenant_id` NOT NULL, así que arreglar una columna sola deja el
            // mismo error corrido un renglón. Tirarla no pierde nada: es una
            // tabla puente sin escritura local propia, que el pull vuelve a
            // bajar entera en cada ciclo (`_traerServiciosDeTurnos`).
            await m.deleteTable('appointment_services');
            await m.createTable(appointmentServices);
            // El índice vivía en `onCreate` y `deleteTable` se lo llevó.
            await customStatement(
              'create index if not exists ix_appt_srv_appt '
              'on appointment_services (appointment_id)',
            );
          }
        },
        beforeOpen: (details) async {
          // Sin esto SQLite ignora las foreign keys en silencio.
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );
}

/// Índices del módulo de ropa. Se llaman desde `onCreate` y desde `onUpgrade`
/// para que una instalación nueva y una actualizada terminen igual — que se
/// desincronicen es un clásico que solo aparece cuando la base ya creció.
Future<void> _indicesRopa(MirameDb db) async {
  const ix = [
    'create index if not exists ix_prod_tenant on productos (tenant_id) '
        'where deleted_at is null',
    'create index if not exists ix_var_prod on producto_variantes '
        '(producto_id) where deleted_at is null',
    'create index if not exists ix_stockvar on stock_variantes '
        '(variante_id, deposito_id)',
    'create index if not exists ix_fotos_prod on producto_fotos '
        '(producto_id, orden) where deleted_at is null',
    'create index if not exists ix_ventas_fecha on ventas (tenant_id, fecha) '
        'where deleted_at is null',
    'create index if not exists ix_vitems_venta on venta_items (venta_id)',
    'create index if not exists ix_mov_var on movimientos_stock (variante_id)',
  ];
  for (final s in ix) {
    await db.customStatement(s);
  }
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
