import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mirame/data/local/database.dart';
import 'package:mirame/data/sync/sync_engine.dart';
import 'package:supabase_flutter/supabase_flutter.dart'
    show PostgrestException;

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

  group('quedarse sin internet no puede costar el trabajo cargado', () {
    // El caso que motivó estos tests: el salón se queda sin datos, se sigue
    // cargando, y al volver el internet **todo tiene que subir solo**.
    //
    // Antes no: cada fallo de red gastaba uno de los ocho intentos, así que
    // veinte minutos sin señal dejaban el cambio trabado, y al volver la
    // conexión no se subía. Había que entrar a Ajustes y tocar Reintentar,
    // sabiendo que eso existe. El dato no se borraba nunca, pero para la
    // persona que lo cargó es lo mismo que perderlo.
    late MirameDb db;
    late SyncEngine engine;

    setUp(() {
      db = MirameDb.paraTest(NativeDatabase.memory());
      engine = SyncEngine(db);
    });

    tearDown(() => db.close());

    Future<void> encolarUna(String id) => engine.encolar(
          tenantId: 't1',
          tabla: 'clients',
          filaId: id,
          operacion: 'upsert',
          payload: {'id': id, 'nombre': 'Ana'},
        );

    /// Adelanta el reloj de la cola para poder pedir otro ciclo enseguida.
    Future<void> pasaElTiempo() =>
        (db.update(db.outbox)).write(OutboxCompanion(
          reintentarAt: Value(DateTime.now().subtract(const Duration(hours: 2))),
        ));

    // En los tests Supabase no está inicializado, así que `_subir` tira antes
    // de llegar a la red: es exactamente "no hay servidor al otro lado", que es
    // el escenario que hay que probar.

    test('un ciclo sin servidor no gasta el intento', () async {
      await encolarUna('c1');
      await engine.empujar('t1');

      final fila = (await db.select(db.outbox).get()).single;
      expect(fila.intentos, 0, reason: 'sin servidor no se gasta intento');
      expect(fila.ultimoError, isNotNull, reason: 'igual queda el motivo');
      expect(await engine.pendientes('t1'), 1);
    });

    test('veinte ciclos sin internet y el cambio sigue subible', () async {
      await encolarUna('c1');
      for (var i = 0; i < 20; i++) {
        await pasaElTiempo();
        await engine.empujar('t1');
      }

      expect((await engine.trabados('t1')).cuantos, 0,
          reason: 'sin señal nada puede quedar trabado');
      expect(await engine.pendientes('t1'), 1);
      // Y lo cargado sigue entero: el payload es lo que se vuelve a mandar.
      final fila = (await db.select(db.outbox).get()).single;
      expect(jsonDecode(fila.payload), {'id': 'c1', 'nombre': 'Ana'});
    });

    test('sin servidor corta el ciclo en la primera', () async {
      // Si no hay servidor para la primera fila no lo va a haber para las
      // otras: seguir escribe una fila de la base por cada una, por nada.
      await encolarUna('c1');
      await encolarUna('c2');
      await encolarUna('c3');
      await engine.empujar('t1');

      final tocadas = (await db.select(db.outbox).get())
          .where((f) => f.ultimoError != null)
          .length;
      expect(tocadas, 1);
      expect(await engine.pendientes('t1'), 3, reason: 'ninguna se pierde');
    });
  });

  group('esRechazoDelServidor', () {
    // Lo que decide si el intento se gasta. Del lado de "rechazo" van los
    // códigos permanentes: el servidor contestó y va a contestar igual.
    test('un rechazo de Postgres cuenta', () {
      expect(esRechazoDelServidor(PostgrestException(message: 'rls', code: '42501')), isTrue);
      expect(esRechazoDelServidor(PostgrestException(message: 'fk', code: '23503')), isTrue);
      expect(esRechazoDelServidor(PostgrestException(message: 'dato', code: '22P02')), isTrue);
      expect(esRechazoDelServidor(PostgrestException(message: 'schema', code: 'PGRST204')), isTrue);
    });

    test('lo transitorio NO cuenta, aunque venga del servidor', () {
      // 40001 es un choque de serialización y 57014 un timeout de consulta:
      // los dos se resuelven reintentando, y gastar intentos por eso termina
      // trabando una fila que estaba perfecta.
      expect(esRechazoDelServidor(PostgrestException(message: 'x', code: '40001')), isFalse);
      expect(esRechazoDelServidor(PostgrestException(message: 'x', code: '57014')), isFalse);
      expect(esRechazoDelServidor(PostgrestException(message: 'x')), isFalse);
    });

    test('no llegar al servidor no cuenta', () {
      expect(esRechazoDelServidor(Exception('SocketException: sin ruta')), isFalse);
      expect(esRechazoDelServidor(TimeoutException('tarde')), isFalse);
      expect(esRechazoDelServidor(StateError('cualquier cosa'), ), isFalse);
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
