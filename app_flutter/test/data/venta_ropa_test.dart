import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mirame/data/local/database.dart';
import 'package:mirame/data/repositories/business_repository.dart';
import 'package:mirame/data/repositories/ropa_repository.dart';
import 'package:mirame/data/sync/sync_engine.dart';
import 'package:mirame/domain/entities/ropa.dart' as dom;

void main() {
  late MirameDb db;
  late RopaRepository repo;
  late BusinessRepository negocio;
  late String depositoId;
  late String proveedorId;

  /// Crea una prenda con una variante y stock, y devuelve el id de la variante.
  Future<String> prenda({
    required String nombre,
    num precio = 20000,
    num pctSalon = 30,
    int stock = 5,
  }) async {
    final pid = await repo.guardarProducto(
      nombre: nombre,
      proveedorId: proveedorId,
      precio: precio,
      pctSalon: pctSalon,
      variantes: [(id: null, talle: 'M', color: 'Negro')],
    );
    final v = await repo.verVariantes().first;
    final vid = v.firstWhere((x) => x.productoId == pid).id;
    await repo.ajustarStock(
      varianteId: vid,
      depositoId: depositoId,
      delta: stock,
      motivo: dom.MotivoStock.ingreso,
    );
    return vid;
  }

  setUp(() async {
    db = MirameDb.paraTest(NativeDatabase.memory());
    final sync = SyncEngine(db);
    negocio = BusinessRepository(db, sync, 't1');
    repo = RopaRepository(db, sync, 't1', negocio);

    depositoId = await repo.guardarDeposito(nombre: 'Salón', esPrincipal: true);
    proveedorId = await repo.guardarProveedor(nombre: 'Prov', pctSalon: 30);
  });

  tearDown(() => db.close());

  test('una venta descuenta el stock', () async {
    final vid = await prenda(nombre: 'Vestido', stock: 5);

    await repo.registrarVenta(
      depositoId: depositoId,
      items: [
        ItemParaVender(varianteId: vid, precioUnit: 20000, pctSalon: 30, cantidad: 2),
      ],
    );

    final stock = await repo.verStockPorVariante().first;
    expect(stock[vid], 3);
  });

  test('la venta entra en la CAJA por el total, no por la parte del salón',
      () async {
    // Es lo que refleja la plata real: ella cobra todo y después le paga al
    // proveedor. Anotar solo su parte haría que la caja no cuadre con el
    // efectivo que tiene en la mano al cerrar el día.
    final vid = await prenda(nombre: 'Vestido');

    await repo.registrarVenta(
      depositoId: depositoId,
      items: [
        ItemParaVender(varianteId: vid, precioUnit: 20000, pctSalon: 30),
      ],
    );

    final movs = await (db.select(db.transactions)).get();
    expect(movs, hasLength(1));
    expect(movs.single.monto, 20000);
    expect(movs.single.tipo, 'income');
    expect(movs.single.categoria, 'ropa');
  });

  test('guarda el reparto congelado en cada ítem', () async {
    final vid = await prenda(nombre: 'Vestido');

    await repo.registrarVenta(
      depositoId: depositoId,
      items: [
        ItemParaVender(varianteId: vid, precioUnit: 20000, pctSalon: 30),
      ],
    );

    final items = await (db.select(db.ventaItems)).get();
    expect(items.single.montoProveedor, 14000);
    expect(items.single.montoSalon, 6000);
    // El porcentaje queda guardado: cambiarle el % al proveedor mañana no
    // puede mover una venta que ya se hizo.
    expect(items.single.pctSalon, 30);
  });

  test('el descuento se reparte entre los ítems según cuánto pesa cada uno',
      () async {
    // Cargarlo entero al primero deformaría la liquidación de ese proveedor y
    // dejaría bien la de los demás.
    final caro = await prenda(nombre: 'Caro', precio: 30000);
    final barato = await prenda(nombre: 'Barato', precio: 10000);

    await repo.registrarVenta(
      depositoId: depositoId,
      descuento: 4000,
      items: [
        ItemParaVender(varianteId: caro, precioUnit: 30000, pctSalon: 30),
        ItemParaVender(varianteId: barato, precioUnit: 10000, pctSalon: 30),
      ],
    );

    final venta = (await db.select(db.ventas).get()).single;
    // 40.000 − 4.000 de descuento.
    expect(venta.total, 36000);

    final items = await (db.select(db.ventaItems)).get();
    final sumaProveedor =
        items.fold<double>(0, (a, i) => a + i.montoProveedor);
    // El proveedor cobra sobre LISTA (default): 70% de 40.000.
    expect(sumaProveedor, 28000);
    // Y el descuento sale del salón: 12.000 − 4.000.
    final sumaSalon = items.fold<double>(0, (a, i) => a + i.montoSalon);
    expect(sumaSalon, 8000);
  });

  test('el movimiento de stock queda con su motivo', () async {
    final vid = await prenda(nombre: 'Vestido', stock: 5);
    await repo.registrarVenta(
      depositoId: depositoId,
      items: [ItemParaVender(varianteId: vid, precioUnit: 20000, pctSalon: 30)],
    );

    final movs = await (db.select(db.movimientosStock)
          ..orderBy([(m) => OrderingTerm.asc(m.createdAt)]))
        .get();
    // El ingreso inicial y la venta.
    expect(movs.map((m) => m.motivo).toList(), ['ingreso', 'venta']);
    expect(movs.last.delta, -1);
  });

  test('el stock nunca queda negativo', () async {
    final vid = await prenda(nombre: 'Vestido', stock: 1);
    await repo.ajustarStock(
      varianteId: vid,
      depositoId: depositoId,
      delta: -10,
    );
    final stock = await repo.verStockPorVariante().first;
    expect(stock[vid], 0);
  });

  test('sacar una variante la marca borrada, no la elimina', () async {
    // Una venta vieja apunta a ella y tiene que seguir siendo legible.
    final pid = await repo.guardarProducto(
      nombre: 'Remera',
      variantes: [
        (id: null, talle: 'S', color: null),
        (id: null, talle: 'M', color: null),
      ],
    );
    var vs = (await repo.verVariantes().first)
        .where((v) => v.productoId == pid)
        .toList();
    expect(vs, hasLength(2));

    await repo.guardarProducto(
      id: pid,
      nombre: 'Remera',
      variantes: [(id: vs.first.id, talle: 'S', color: null)],
    );

    vs = (await repo.verVariantes().first)
        .where((v) => v.productoId == pid)
        .toList();
    expect(vs, hasLength(1), reason: 'la vista solo trae las vivas');

    final todas = await (db.select(db.productoVariantes)
          ..where((v) => v.productoId.equals(pid)))
        .get();
    expect(todas, hasLength(2), reason: 'la fila sigue en la base');
    expect(todas.where((v) => v.deletedAt != null), hasLength(1));
  });

  test('solo un depósito puede ser el principal', () async {
    // Con dos principales, el formulario de venta elegiría uno al azar.
    final b = await repo.guardarDeposito(nombre: 'Casa', esPrincipal: true);
    final deps = await repo.verDepositos().first;
    expect(deps.where((d) => d.esPrincipal).map((d) => d.id).toList(), [b]);
  });
}
