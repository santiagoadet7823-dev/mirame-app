/// Las cantidades por talle tienen que llegar a la base.
///
/// Se escribió después de un bug reportado desde el uso real: la usuaria
/// cargaba las cantidades, guardaba, y no pasaba nada. El formulario resolvía
/// el depósito en `initState` con un provider `autoDispose` que todavía no
/// había emitido, así que llegaba en `null` — y el repositorio, sin depósito,
/// se salteaba el stock **en silencio**.
library;

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mirame/data/local/database.dart';
import 'package:mirame/data/repositories/business_repository.dart';
import 'package:mirame/data/repositories/ropa_repository.dart';
import 'package:mirame/data/sync/sync_engine.dart';

void main() {
  late MirameDb db;
  late RopaRepository repo;
  late String depositoId;

  /// El stock que quedó de una variante, sumando depósitos.
  Future<int> stockDe(String varianteId) async {
    final filas = await repo.verStockPorVariante().first;
    return filas[varianteId] ?? 0;
  }

  Future<String> primeraVariante(String productoId) async {
    final v = await repo.verVariantes().first;
    return v.firstWhere((x) => x.productoId == productoId).id;
  }

  setUp(() async {
    db = MirameDb.paraTest(NativeDatabase.memory());
    final sync = SyncEngine(db);
    repo = RopaRepository(db, sync, 't1', BusinessRepository(db, sync, 't1'));
    depositoId = await repo.guardarDeposito(nombre: 'Salón', esPrincipal: true);
  });

  tearDown(() => db.close());

  test('las cantidades que se escriben quedan guardadas', () async {
    final pid = await repo.guardarProducto(
      nombre: 'Remera',
      precio: 18000,
      depositoId: depositoId,
      variantes: [const VarianteParaGuardar(talle: 'M', stock: 4)],
    );

    expect(await stockDe(await primeraVariante(pid)), 4);
  });

  test('el stock es un absoluto: al corregirlo se aplica la diferencia',
      () async {
    final pid = await repo.guardarProducto(
      nombre: 'Remera',
      precio: 18000,
      depositoId: depositoId,
      variantes: [const VarianteParaGuardar(talle: 'M', stock: 4)],
    );
    final vid = await primeraVariante(pid);

    // La usuaria ve 4 y escribe 7: se suman 3, no se pisan con 7.
    await repo.guardarProducto(
      id: pid,
      nombre: 'Remera',
      precio: 18000,
      depositoId: depositoId,
      variantes: [VarianteParaGuardar(id: vid, talle: 'M', stock: 7)],
    );

    expect(await stockDe(vid), 7);
    // Y quedó el rastro de los dos ingresos, no de uno solo de 7.
    final movs = await db.select(db.movimientosStock).get();
    expect(movs.map((m) => m.delta).toList(), [4, 3]);
  });

  test('sin depósito el stock se descarta — por eso el formulario garantiza uno',
      () async {
    final pid = await repo.guardarProducto(
      nombre: 'Remera',
      precio: 18000,
      // depositoId ausente: es exactamente lo que pasaba con el bug.
      variantes: [const VarianteParaGuardar(talle: 'M', stock: 4)],
    );

    expect(await stockDe(await primeraVariante(pid)), 0,
        reason: 'sin depósito no hay dónde ponerlo; el formulario crea uno');
  });

  test('cada talle lleva su propia cantidad', () async {
    final pid = await repo.guardarProducto(
      nombre: 'Chino',
      precio: 27000,
      depositoId: depositoId,
      variantes: const [
        VarianteParaGuardar(talle: '38', color: 'Azul', stock: 2),
        VarianteParaGuardar(talle: '40', color: 'Verde', stock: 1),
        VarianteParaGuardar(talle: '42', color: 'Beige', stock: 0),
      ],
    );

    final vs = (await repo.verVariantes().first)
        .where((x) => x.productoId == pid)
        .toList()
      ..sort((a, b) => a.talle!.compareTo(b.talle!));

    expect([
      await stockDe(vs[0].id),
      await stockDe(vs[1].id),
      await stockDe(vs[2].id),
    ], [2, 1, 0]);
  });
}
