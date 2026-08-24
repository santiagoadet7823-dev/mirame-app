import 'package:flutter_test/flutter_test.dart';
import 'package:mirame/domain/entities/entities.dart';
import 'package:mirame/domain/rules/backup.dart';

void main() {
  test('rechaza algo que no es un backup', () {
    expect(() => leerBackup({'hola': 1}), throwsA(isA<BackupInvalido>()));
    expect(() => leerBackup('texto suelto'), throwsA(isA<BackupInvalido>()));
  });

  test('acepta un archivo aunque traiga solo una colección', () {
    final b = leerBackup({
      'c': [
        {'id': 1, 'name': 'Ana'}
      ]
    });
    expect(b.clientas.single.nombre, 'Ana');
    expect(b.turnos, isEmpty);
  });

  group('tolerancia con los tipos del legacy', () {
    test('los números que venían como string se parsean', () {
      // El legacy guardaba `input.value` tal cual, así que todo era string.
      final b = leerBackup({
        'tx': [
          {'id': 1, 'type': 'income', 'amount': '15000', 'date': '2026-08-24'}
        ],
        'sv': [
          {'id': 1, 'name': 'Volumen', 'price': '8000', 'retouch': '21'}
        ],
      });
      expect(b.movimientos.single.monto, 15000);
      expect(b.servicios.single.precio, 8000);
      expect(b.servicios.single.retoqueDias, 21);
    });

    test("vip vale tanto true como el string 'true'", () {
      final b = leerBackup({
        'c': [
          {'id': 1, 'name': 'Ana', 'vip': 'true'},
          {'id': 2, 'name': 'Bea', 'vip': true},
          {'id': 3, 'name': 'Cami', 'vip': 'false'},
          {'id': 4, 'name': 'Dani'},
        ]
      });
      expect(b.clientas.map((c) => c.vip).toList(),
          [true, true, false, false]);
    });

    test('el string vacío es "sin dato", no un teléfono vacío', () {
      final b = leerBackup({
        'c': [
          {'id': 1, 'name': 'Ana', 'phone': '', 'notes': '  '}
        ]
      });
      expect(b.clientas.single.telefono, isNull);
      expect(b.clientas.single.notas, isNull);
    });
  });

  test('la fecha no pasa por UTC', () {
    // Un ISO completo con hora de la tarde: si se convirtiera a UTC, el turno
    // se correría al día siguiente.
    final b = leerBackup({
      'a': [
        {'id': 1, 'date': '2026-08-24T22:30:00.000Z', 'time': '22:30'}
      ]
    });
    final t = b.turnos.single;
    expect(t.fecha, DateTime(2026, 8, 24));
    expect(t.hora, const TimeOfDayValue(22, 30));
  });

  test('los estados desconocidos caen en confirmed, no rompen', () {
    final b = leerBackup({
      'a': [
        {'id': 1, 'date': '2026-08-24', 'status': 'done'},
        {'id': 2, 'date': '2026-08-24', 'status': 'pendiente'},
        {'id': 3, 'date': '2026-08-24'},
      ]
    });
    expect(b.turnos.map((t) => t.estado).toList(), [
      TurnoEstado.done,
      TurnoEstado.confirmed,
      TurnoEstado.confirmed,
    ]);
  });

  test('las filas que no son objetos se saltean en vez de tumbar todo', () {
    final b = leerBackup({
      'c': [
        {'id': 1, 'name': 'Ana'},
        null,
        'basura',
        {'id': 2, 'name': 'Bea'},
      ]
    });
    expect(b.clientas.map((c) => c.nombre).toList(), ['Ana', 'Bea']);
  });

  test('lo exportado se vuelve a leer igual', () {
    final original = armarBackup(
      version: '1.5.0',
      salon: 'Mírame Lash Studio',
      ahora: DateTime(2026, 8, 24),
      turnos: [
        Appointment(
          id: 'a1',
          fecha: DateTime(2026, 8, 24),
          clientId: 'c1',
          serviceIds: const ['s1'],
          hora: const TimeOfDayValue(15, 30),
          precio: 9000,
          estado: TurnoEstado.done,
        )
      ],
      clientas: const [Client(id: 'c1', nombre: 'Ana', vip: true)],
      movimientos: const [],
      stock: const [],
      profesionales: const [],
      servicios: const [
        Service(id: 's1', nombre: 'Volumen', precio: 9000, retoqueDias: 21)
      ],
    );

    final vuelta = leerBackup(original);
    expect(vuelta.salon, 'Mírame Lash Studio');
    expect(vuelta.clientas.single.vip, isTrue);
    expect(vuelta.turnos.single.hora, const TimeOfDayValue(15, 30));
    expect(vuelta.turnos.single.serviceIds, ['s1']);
    expect(vuelta.turnos.single.estado, TurnoEstado.done);
    expect(vuelta.servicios.single.retoqueDias, 21);
    expect(vuelta.total, 3);
  });
}
