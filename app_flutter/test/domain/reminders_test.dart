import 'package:flutter_test/flutter_test.dart';
import 'package:mirame/domain/entities/entities.dart';
import 'package:mirame/domain/rules/reminders.dart';

const cami = Client(id: 'c1', nombre: 'Camila');
const sofi = Client(id: 'c2', nombre: 'Sofía');

const clasicas =
    Service(id: 's1', nombre: 'Extensiones Clásicas', retoqueDias: 21);
const lifting =
    Service(id: 's2', nombre: 'Lifting de Pestañas', retoqueDias: 60);
const sinRetoque = Service(id: 's3', nombre: 'Diseño de Cejas');

Appointment done(String fecha, String cliente, List<String> svs) => Appointment(
      id: 'a-$fecha-$cliente',
      fecha: DateTime.parse(fecha),
      clientId: cliente,
      serviceIds: svs,
      estado: TurnoEstado.done,
    );

void main() {
  final hoy = DateTime(2026, 8, 23);

  group('pendingReminders — ventana de -3 a +7 días', () {
    test('avisa el día exacto del retoque', () {
      // 02/08 + 21 días = 23/08 = hoy
      final r = pendingReminders(
        clients: [cami],
        appointments: [
          done('2026-08-02', 'c1', ['s1'])
        ],
        services: [clasicas],
        hoy: hoy,
      );
      expect(r.single.diasRestantes, 0);
      expect(r.single.etiqueta, 'Hoy');
    });

    test('avisa hasta 7 días antes, pero no 8', () {
      // retoque el 30/08 → faltan 7
      final siete = pendingReminders(
        clients: [cami],
        appointments: [
          done('2026-08-09', 'c1', ['s1'])
        ],
        services: [clasicas],
        hoy: hoy,
      );
      expect(siete, hasLength(1));
      expect(siete.single.diasRestantes, 7);

      // retoque el 31/08 → faltan 8: todavía no
      final ocho = pendingReminders(
        clients: [cami],
        appointments: [
          done('2026-08-10', 'c1', ['s1'])
        ],
        services: [clasicas],
        hoy: hoy,
      );
      expect(ocho, isEmpty);
    });

    test('sigue avisando hasta 3 días después de vencido, pero no 4', () {
      // retoque el 20/08 → hace 3 días
      final tres = pendingReminders(
        clients: [cami],
        appointments: [
          done('2026-07-30', 'c1', ['s1'])
        ],
        services: [clasicas],
        hoy: hoy,
      );
      expect(tres, hasLength(1));
      expect(tres.single.diasRestantes, -3);
      expect(tres.single.etiqueta, 'Hace 3d');
      expect(tres.single.vencido, isTrue);

      // retoque el 19/08 → hace 4 días: se deja de avisar
      final cuatro = pendingReminders(
        clients: [cami],
        appointments: [
          done('2026-07-29', 'c1', ['s1'])
        ],
        services: [clasicas],
        hoy: hoy,
      );
      expect(cuatro, isEmpty);
    });
  });

  group('selección del turno y del servicio', () {
    test('solo mira turnos COMPLETADOS', () {
      final r = pendingReminders(
        clients: [cami],
        appointments: [
          Appointment(
            id: 'a1',
            fecha: DateTime(2026, 8, 2),
            clientId: 'c1',
            serviceIds: const ['s1'],
            estado: TurnoEstado.confirmed, // agendado, no realizado
          ),
        ],
        services: [clasicas],
        hoy: hoy,
      );
      expect(r, isEmpty);
    });

    test('usa el turno completado más reciente', () {
      final r = pendingReminders(
        clients: [cami],
        appointments: [
          done('2026-05-01', 'c1', ['s1']), // viejo
          done('2026-08-02', 'c1', ['s1']), // el que manda
        ],
        services: [clasicas],
        hoy: hoy,
      );
      expect(r.single.diasRestantes, 0);
    });

    test('un servicio sin retoque no genera recordatorio', () {
      final r = pendingReminders(
        clients: [cami],
        appointments: [
          done('2026-08-02', 'c1', ['s3'])
        ],
        services: [sinRetoque],
        hoy: hoy,
      );
      expect(r, isEmpty);
    });

    test('con varios servicios manda el de retoque más corto', () {
      // Clásicas (21d) y Lifting (60d) juntos: tiene que volver a los 21.
      final r = pendingReminders(
        clients: [cami],
        appointments: [
          done('2026-08-02', 'c1', ['s2', 's1'])
        ],
        services: [clasicas, lifting],
        hoy: hoy,
      );
      expect(r.single.service.id, 's1');
      expect(r.single.diasRestantes, 0);
    });

    test('un servicio borrado no rompe el cálculo', () {
      // En el legacy esto pasaba al renombrar: el vínculo por nombre se cortaba
      // y la clienta desaparecía de los recordatorios sin aviso.
      final r = pendingReminders(
        clients: [cami],
        appointments: [
          done('2026-08-02', 'c1', ['servicio-inexistente'])
        ],
        services: [clasicas],
        hoy: hoy,
      );
      expect(r, isEmpty);
    });
  });

  group('orden y alcance', () {
    test('los más urgentes van primero', () {
      final r = pendingReminders(
        clients: [cami, sofi],
        appointments: [
          done('2026-08-09', 'c1', ['s1']), // en 7 días
          done('2026-07-30', 'c2', ['s1']), // hace 3 días
        ],
        services: [clasicas],
        hoy: hoy,
      );
      expect(r.map((e) => e.client.id), ['c2', 'c1']);
    });

    test('una clienta sin turnos completados no aparece', () {
      final r = pendingReminders(
        clients: [cami, sofi],
        appointments: [
          done('2026-08-02', 'c1', ['s1'])
        ],
        services: [clasicas],
        hoy: hoy,
      );
      expect(r.map((e) => e.client.id), ['c1']);
    });
  });

  group('birthdaysToday', () {
    test('compara mes y día, ignorando el año', () {
      final r = birthdaysToday([
        const Client(id: 'c1', nombre: 'Camila', cumple: null),
        Client(id: 'c2', nombre: 'Sofía', cumple: DateTime(1995, 8, 23)),
        Client(id: 'c3', nombre: 'Ana', cumple: DateTime(1990, 8, 24)),
      ], hoy);
      expect(r.map((e) => e.id), ['c2']);
    });
  });
}
