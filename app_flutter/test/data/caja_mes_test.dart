import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mirame/data/local/database.dart';
import 'package:mirame/data/repositories/business_repository.dart';
import 'package:mirame/data/sync/sync_engine.dart';

void main() {
  late MirameDb db;
  late BusinessRepository repo;

  setUp(() async {
    db = MirameDb.paraTest(NativeDatabase.memory());
    repo = BusinessRepository(db, SyncEngine(db), 't1');
    // Un movimiento en cada borde del mes y en los meses vecinos.
    for (final f in [
      DateTime(2026, 7, 31),
      DateTime(2026, 8, 1),
      DateTime(2026, 8, 15),
      DateTime(2026, 8, 31),
      DateTime(2026, 9, 1),
    ]) {
      await repo.guardarMovimiento(
        tipo: 'income', monto: 1000, fecha: f, descripcion: '${f.day}/${f.month}',
      );
    }
  });

  tearDown(() => db.close());

  test('el mes trae sus dos bordes y ninguno de los vecinos', () async {
    final agosto = await repo
        .verMovimientosEntre(DateTime(2026, 8, 1), DateTime(2026, 9, 0))
        .first;
    // Del más nuevo al más viejo, que es como los lista la caja.
    expect(agosto.map((m) => m.descripcion).toList(), ['31/8', '15/8', '1/8']);
  });

  test('DateTime(2026, 9, 0) es el 31 de agosto', () {
    // El truco que usa la caja para no tener que saber cuántos días tiene el
    // mes. Si Dart lo normalizara distinto, agosto perdería su último día.
    expect(DateTime(2026, 9, 0).day, 31);
    expect(DateTime(2026, 9, 0).month, 8);
  });
}
