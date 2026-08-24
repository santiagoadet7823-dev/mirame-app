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

  group('claveFecha', () {
    test('usa la fecha LOCAL, sin pasar por UTC', () {
      // El bug del legacy: a las 22:00 de Argentina, toIso8601String() sobre
      // UTC devolvía el día siguiente y el turno se agendaba mal.
      expect(claveFecha(DateTime(2026, 8, 24, 22, 30)), '2026-08-24');
      expect(claveFecha(DateTime(2026, 1, 5, 0, 1)), '2026-01-05');
    });

    test('rellena con ceros', () {
      expect(claveFecha(DateTime(2026, 3, 7)), '2026-03-07');
    });
  });

  group('nuevoId', () {
    test('genera ids distintos', () {
      expect(nuevoId(), isNot(nuevoId()));
    });

    test('v7 ordena por momento de creación', () async {
      // Es la razón de usar v7 y no v4: el índice de SQLite no se fragmenta.
      // Se compara entre milisegundos distintos: DENTRO del mismo, el resto
      // del uuid es aleatorio y el orden no está garantizado.
      final ids = <String>[];
      for (var i = 0; i < 5; i++) {
        ids.add(nuevoId());
        await Future<void>.delayed(const Duration(milliseconds: 3));
      }
      final ordenados = [...ids]..sort();
      expect(ordenados, ids);
    });
  });

  group('escrituras', () {
    test('guardar deja la fila local Y la encola, juntas', () async {
      final id = await repo.guardarCliente(nombre: 'Ana');
      final filas = await db.select(db.clients).get();
      expect(filas.single.nombre, 'Ana');
      // Si se guardara sin encolar, el cambio quedaría en este dispositivo
      // para siempre, invisible.
      final cola = await db.select(db.outbox).get();
      expect(cola.single.filaId, id);
      expect(cola.single.tabla, 'clients');
    });

    test('borrar es un tombstone, no un DELETE', () async {
      final id = await repo.guardarCliente(nombre: 'Ana');
      await repo.borrar('clients', id);
      final fila = await db.select(db.clients).getSingle();
      // La fila SIGUE: un borrado real no se puede propagar al otro
      // dispositivo, que nunca se enteraría de que existió.
      expect(fila.deletedAt, isNotNull);
      final cola = await db.select(db.outbox).get();
      expect(cola.last.operacion, 'delete');
    });

    test('las lecturas no devuelven lo borrado', () async {
      final id = await repo.guardarCliente(nombre: 'Ana');
      await repo.guardarCliente(nombre: 'Bea');
      await repo.borrar('clients', id);
      expect((await repo.verClientes().first).map((c) => c.nombre), ['Bea']);
    });

    test('ajustarStock encola un delta, no un valor absoluto', () async {
      final id = await repo.guardarStock(nombre: 'Pinzas', cantidad: 10);
      await repo.ajustarStock(id, -1);
      final item = await db.select(db.stockItems).getSingle();
      expect(item.cantidad, 9);
      final ultimo = (await db.select(db.outbox).get()).last;
      // Con 'upsert' de un absoluto, dos dispositivos offline restando uno
      // cada uno terminarían en 9 en vez de 8.
      expect(ultimo.operacion, 'delta');
    });

    test('el stock no baja de cero', () async {
      final id = await repo.guardarStock(nombre: 'Pinzas', cantidad: 1);
      await repo.ajustarStock(id, -5);
      expect((await db.select(db.stockItems).getSingle()).cantidad, 0);
    });

    test('un delta de cero no ensucia la cola', () async {
      final id = await repo.guardarStock(nombre: 'Pinzas');
      await repo.ajustarStock(id, 0);
      final cola = await db.select(db.outbox).get();
      expect(cola.where((o) => o.operacion == 'delta'), isEmpty);
    });
  });

  group('aislamiento por salón', () {
    test('no se ven las clientas de otro salón', () async {
      await repo.guardarCliente(nombre: 'Ana');
      await db.into(db.clients).insert(
            ClientsCompanion.insert(
              id: 'x', tenantId: 'OTRO', nombre: 'Ajena',
            ),
          );
      final vistas = await repo.verClientes().first;
      expect(vistas.map((c) => c.nombre), ['Ana']);
    });
  });

  group('resumen del CRM', () {
    test('el gasto sale de los turnos, no de las transacciones', () async {
      final ana = await repo.guardarCliente(nombre: 'Ana');
      final bea = await repo.guardarCliente(nombre: 'Bea');
      await repo.guardarTurno(
          clientId: ana, fecha: DateTime(2026, 8, 1), hora: '10:00',
          precio: 5000);
      await repo.guardarTurno(
          clientId: ana, fecha: DateTime(2026, 8, 2), hora: '11:00',
          precio: 5000);
      await repo.guardarTurno(
          clientId: bea, fecha: DateTime(2026, 8, 3), hora: '12:00',
          precio: 7000);
      // Una transacción con la misma clienta NO cuenta: en los datos reales
      // ese campo nunca se escribió y por eso el total daba siempre 0.
      await repo.guardarMovimiento(
          tipo: 'ingreso', monto: 99999, fecha: DateTime(2026, 8, 1),
          clientId: ana);

      final r = await repo.verResumenClientes().first;
      expect(r[ana]?.turnos, 2);
      // 2 turnos de 5000 cargados abajo.
      expect(r[ana]?.gastado, 10000);
      expect(r[bea]?.turnos, 1);
      expect(r[bea]?.gastado, 7000);
    });

    test('un turno borrado deja de contar', () async {
      final ana = await repo.guardarCliente(nombre: 'Ana');
      final t = await repo.guardarTurno(
          clientId: ana, fecha: DateTime(2026, 8, 1), hora: '10:00',
          precio: 5000);
      await repo.borrar('appointments', t);
      final r = await repo.verResumenClientes().first;
      expect(r[ana]?.turnos, 0);
      expect(r[ana]?.gastado, 0);
    });

    test('un turno cancelado no suma plata', () async {
      final ana = await repo.guardarCliente(nombre: 'Ana');
      await repo.guardarTurno(
          clientId: ana, fecha: DateTime(2026, 8, 1), hora: '10:00',
          precio: 5000, estado: 'cancelled');
      // Sigue contando como turno agendado, pero no como plata que entró.
      expect((await repo.verResumenClientes().first)[ana]?.gastado, 0);
    });
  });
}
