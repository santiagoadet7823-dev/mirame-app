import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mirame/data/local/database.dart';
import 'package:mirame/data/sync/sync_engine.dart';

void main() {
  group('esperaDeReintento', () {
    test('crece exponencialmente', () {
      expect(esperaDeReintento(1), const Duration(seconds: 5));
      expect(esperaDeReintento(2), const Duration(seconds: 10));
      expect(esperaDeReintento(3), const Duration(seconds: 20));
      expect(esperaDeReintento(4), const Duration(seconds: 40));
    });

    test('tiene techo de una hora', () {
      // Sin techo, al décimo intento la fila quedaría programada para dentro
      // de días y no se subiría nunca más.
      expect(esperaDeReintento(20), const Duration(hours: 1));
      expect(esperaDeReintento(99), const Duration(hours: 1));
    });

    test('sin intentos no espera', () {
      expect(esperaDeReintento(0), Duration.zero);
    });
  });

  group('outbox', () {
    late MirameDb db;
    late SyncEngine engine;

    setUp(() {
      db = MirameDb.paraTest(NativeDatabase.memory());
      engine = SyncEngine(db);
    });

    tearDown(() => db.close());

    test('encolar deja la fila y la cuenta', () async {
      await engine.encolar(
        tenantId: 't1',
        tabla: 'clients',
        filaId: 'c1',
        operacion: 'upsert',
        payload: {'id': 'c1', 'nombre': 'Ana'},
      );
      expect(await engine.pendientes('t1'), 1);
    });

    test('la cola está separada por salón', () async {
      await engine.encolar(
        tenantId: 't1',
        tabla: 'clients',
        filaId: 'c1',
        operacion: 'upsert',
        payload: const {},
      );
      // Si las colas se mezclaran, entrar a otro salón subiría datos ajenos
      // con el tenant equivocado.
      expect(await engine.pendientes('t2'), 0);
    });

    test('el payload sobrevive el viaje por JSON', () async {
      await engine.encolar(
        tenantId: 't1',
        tabla: 'appointments',
        filaId: 'a1',
        operacion: 'upsert',
        payload: {'precio': 15000.5, 'notas': 'con acento: ñ á', 'vip': true},
      );
      final fila = await db.select(db.outbox).getSingle();
      final vuelto = jsonDecode(fila.payload) as Map<String, dynamic>;
      expect(vuelto['precio'], 15000.5);
      expect(vuelto['notas'], 'con acento: ñ á');
      expect(vuelto['vip'], true);
    });

    test('conserva el orden en que ocurrieron', () async {
      for (final id in ['a', 'b', 'c']) {
        await engine.encolar(
          tenantId: 't1',
          tabla: 'clients',
          filaId: id,
          operacion: 'upsert',
          payload: const {},
        );
      }
      final filas = await db.select(db.outbox).get();
      // Reordenar la cola puede mandar la edición de un turno antes que su
      // creación, y el servidor la rechaza.
      expect(filas.map((f) => f.filaId).toList(), ['a', 'b', 'c']);
    });

    test('empujar ignora las que superaron el máximo de intentos', () async {
      await engine.encolar(
        tenantId: 't1',
        tabla: 'clients',
        filaId: 'rota',
        operacion: 'upsert',
        payload: const {},
      );
      await db.update(db.outbox).write(
            const OutboxCompanion(intentos: Value(kMaxIntentos)),
          );
      // Sin Supabase inicializado, subir lanzaría. Que devuelva 0 sin
      // explotar prueba que ni siquiera intentó tocar la red.
      expect(await engine.empujar('t1'), 0);
      // Y la fila sigue ahí: no se descarta en silencio, queda para revisar.
      expect(await engine.pendientes('t1'), 1);
    });
  });

  group('tablasSync', () {
    test('las dependencias van antes que quien las usa', () {
      // Subir un appointment_services antes que su turno viola la foreign key
      // del servidor y la fila se rechaza.
      expect(
        tablasSync.indexOf('clients'),
        lessThan(tablasSync.indexOf('appointments')),
      );
      expect(
        tablasSync.indexOf('professionals'),
        lessThan(tablasSync.indexOf('appointments')),
      );
      // La tabla puente no sincroniza por cursor: en Postgres no tiene
      // tenant_id ni updated_at.
      expect(tablasSync, isNot(contains('appointment_services')));
    });
  });
}
