import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mirame/data/local/database.dart';
import 'package:mirame/data/repositories/business_repository.dart';
import 'package:mirame/data/sync/sync_engine.dart';

void main() {
  late MirameDb db;
  late BusinessRepository repo;

  setUp(() {
    db = MirameDb.paraTest(NativeDatabase.memory());
    repo = BusinessRepository(db, SyncEngine(db), 't1');
  });

  tearDown(() => db.close());

  test('un turno guarda sus servicios', () async {
    final id = await repo.guardarTurno(
      fecha: DateTime(2026, 6, 5),
      hora: '09:30',
      serviceIds: const ['sv1', 'sv2'],
    );
    final puente = await repo.verServiciosDeTurnos().first;
    expect(puente[id], ['sv1', 'sv2']);
  });

  test('editar un turno REEMPLAZA sus servicios, no los suma', () async {
    final id = await repo.guardarTurno(
      fecha: DateTime(2026, 6, 5),
      hora: '09:30',
      serviceIds: const ['sv1', 'sv2'],
    );
    await repo.guardarTurno(
      id: id,
      fecha: DateTime(2026, 6, 5),
      hora: '09:30',
      serviceIds: const ['sv2'],
    );
    final puente = await repo.verServiciosDeTurnos().first;
    expect(puente[id], ['sv2']);
  });

  test('null NO toca los servicios; lista vacía SÍ los borra', () async {
    // La distinción que costó 16 turnos de la dueña: al restaurar un backup
    // viejo que no trae servicios, "vacío" no significa "no tenía ninguno".
    final id = await repo.guardarTurno(
      fecha: DateTime(2026, 6, 5),
      hora: '09:30',
      serviceIds: const ['sv1', 'sv2'],
    );

    // Guardar sin opinar sobre los servicios los deja intactos.
    await repo.guardarTurno(id: id, fecha: DateTime(2026, 6, 5), hora: '10:00');
    expect((await repo.verServiciosDeTurnos().first)[id], ['sv1', 'sv2']);

    // Una lista vacía sí los saca: es lo que hace el formulario al
    // deseleccionarlos todos.
    await repo.guardarTurno(
      id: id,
      fecha: DateTime(2026, 6, 5),
      hora: '10:00',
      serviceIds: const [],
    );
    final puente = await repo.verServiciosDeTurnos().first;
    expect(puente[id], anyOf(isNull, isEmpty));
  });

  test('sin servicios no deja filas colgadas', () async {
    final id = await repo.guardarTurno(
      fecha: DateTime(2026, 6, 5),
      hora: '09:30',
    );
    final puente = await repo.verServiciosDeTurnos().first;
    expect(puente[id], anyOf(isNull, isEmpty));
  });
}
