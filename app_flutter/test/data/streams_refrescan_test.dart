/// Las escrituras por SQL crudo tienen que refrescar la pantalla.
///
/// Se escribió después de dos bugs reportados el mismo día: "no me deja
/// eliminar el artículo" y "actualizo las cantidades y no se ve". En los dos
/// casos la base SÍ tenía el cambio —el producto estaba marcado como borrado y
/// el stock había llegado al servidor— pero la lista no se enteraba.
///
/// La causa era `customStatement`, que ejecuta el SQL y **no** invalida los
/// streams de Drift. Estos tests fallan si alguien lo vuelve a usar para
/// escribir.
library;

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mirame/data/local/database.dart';
import 'package:mirame/data/repositories/business_repository.dart';
import 'package:mirame/data/repositories/ropa_repository.dart';
import 'package:mirame/data/sync/sync_engine.dart';

void main() {
  late MirameDb db;
  late RopaRepository ropa;
  late BusinessRepository negocio;
  late String depositoId;

  setUp(() async {
    db = MirameDb.paraTest(NativeDatabase.memory());
    final sync = SyncEngine(db);
    negocio = BusinessRepository(db, sync, 't1');
    ropa = RopaRepository(db, sync, 't1', negocio);
    depositoId = await ropa.guardarDeposito(nombre: 'Salón', esPrincipal: true);
  });

  tearDown(() => db.close());

  test('borrar una prenda la saca de la lista sin recargar', () async {
    final id = await ropa.guardarProducto(nombre: 'Remera', precio: 18000);
    expect((await ropa.verProductos().first).length, 1);

    // `expectLater` sobre el stream: si el borrado no invalida, esto se cuelga
    // hasta el timeout en vez de pasar.
    final emite = expectLater(
      ropa.verProductos(),
      emitsThrough(isEmpty),
    );
    await ropa.borrar('productos', id);
    await emite;
  });

  test('ajustar el stock de una prenda se ve en el acto', () async {
    final pid = await ropa.guardarProducto(
      nombre: 'Remera',
      precio: 18000,
      variantes: [const VarianteParaGuardar(talle: 'M')],
    );
    final vid =
        (await ropa.verVariantes().first).firstWhere((v) => v.productoId == pid).id;

    final emite = expectLater(
      ropa.verStockPorVariante(),
      emitsThrough(containsPair(vid, 5)),
    );
    await ropa.ajustarStock(varianteId: vid, depositoId: depositoId, delta: 5);
    await emite;

    // Y la correccion tambien: es la que hacia parecer que no se guardaba.
    final sube = expectLater(
      ropa.verStockPorVariante(),
      emitsThrough(containsPair(vid, 8)),
    );
    await ropa.ajustarStock(varianteId: vid, depositoId: depositoId, delta: 3);
    await sube;
  });

  test('borrar del lado del negocio también refresca', () async {
    final id = await negocio.guardarStock(nombre: 'Adhesivo', cantidad: 2);
    expect((await negocio.verStock().first).length, 1);

    final emite = expectLater(negocio.verStock(), emitsThrough(isEmpty));
    await negocio.borrar('stock_items', id);
    await emite;
  });

  test('el ajuste de stock del salón también refresca', () async {
    final id = await negocio.guardarStock(nombre: 'Adhesivo', cantidad: 2);

    final emite = expectLater(
      negocio.verStock(),
      emitsThrough(predicate<List<StockItem>>(
          (l) => l.length == 1 && l.first.cantidad == 5)),
    );
    await negocio.ajustarStock(id, 3);
    await emite;
  });

  test('tablaPorNombre encuentra las tablas que usa `borrar`', () {
    for (final t in ['productos', 'clients', 'appointments', 'transactions',
                     'stock_items', 'producto_variantes', 'producto_fotos']) {
      expect(db.tablaPorNombre(t), isNotNull, reason: 'falta $t');
    }
    expect(db.tablaPorNombre('no_existe'), isNull);
  });
}
