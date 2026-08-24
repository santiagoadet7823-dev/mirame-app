import 'package:flutter_test/flutter_test.dart';
import 'package:mirame/domain/entities/entities.dart';
import 'package:mirame/domain/rules/agenda.dart';

const clasicas = Service(id: 's1', nombre: 'Clásicas', duracionMin: 90);
const relleno = Service(id: 's2', nombre: 'Relleno', duracionMin: 60);
final serviciosPorId = {clasicas.id: clasicas, relleno.id: relleno};

Appointment turno(
  String fecha,
  String? hora, {
  String id = 'a1',
  String? pro,
  List<String> svs = const [],
  TurnoEstado estado = TurnoEstado.confirmed,
}) =>
    Appointment(
      id: id,
      fecha: DateTime.parse(fecha),
      hora: TimeOfDayValue.parse(hora),
      professionalId: pro,
      serviceIds: svs,
      estado: estado,
    );

void main() {
  group('TimeOfDayValue', () {
    test('parsea HH:mm', () {
      expect(TimeOfDayValue.parse('09:30'), const TimeOfDayValue(9, 30));
      expect(TimeOfDayValue.parse('14:05')!.totalMinutes, 845);
    });

    test('devuelve null en vez de lanzar con datos viejos rotos', () {
      expect(TimeOfDayValue.parse(null), isNull);
      expect(TimeOfDayValue.parse(''), isNull);
      expect(TimeOfDayValue.parse('99:99'), isNull);
      expect(TimeOfDayValue.parse('mañana'), isNull);
    });

    test('convierte a 12 horas como la tarjeta de turno', () {
      expect(const TimeOfDayValue(9, 30).to12h(), (9, '30', 'AM'));
      expect(const TimeOfDayValue(14, 0).to12h(), (2, '00', 'PM'));
      expect(const TimeOfDayValue(12, 0).to12h(), (12, '00', 'PM'));
      expect(const TimeOfDayValue(0, 15).to12h(), (12, '15', 'AM'));
    });
  });

  group('freeSlots', () {
    // 20/08/2026 es jueves.
    final jueves = DateTime(2026, 8, 20);

    test('ofrece las horas en punto del horario del salón', () {
      final libres = freeSlots(
        appointments: const [],
        dia: jueves,
        ahora: DateTime(2026, 8, 19), // otro día: no se recortan horas
      );
      expect(libres.first, const TimeOfDayValue(9, 0));
      expect(libres.last, const TimeOfDayValue(18, 0));
      expect(libres.length, 10); // de 9 a 18 inclusive
    });

    test('descarta las horas ocupadas', () {
      final libres = freeSlots(
        appointments: [turno('2026-08-20', '10:00')],
        dia: jueves,
        ahora: DateTime(2026, 8, 19),
      );
      expect(libres.contains(const TimeOfDayValue(10, 0)), isFalse);
      expect(libres.length, 9);
    });

    test('un turno cancelado libera el horario', () {
      final libres = freeSlots(
        appointments: [
          turno('2026-08-20', '10:00', estado: TurnoEstado.cancelled)
        ],
        dia: jueves,
        ahora: DateTime(2026, 8, 19),
      );
      expect(libres.contains(const TimeOfDayValue(10, 0)), isTrue);
    });

    test('hoy no ofrece horas pasadas ni la hora en curso', () {
      final libres = freeSlots(
        appointments: const [],
        dia: jueves,
        ahora: DateTime(2026, 8, 20, 14, 30),
      );
      expect(libres.first, const TimeOfDayValue(15, 0));
    });

    test('los domingos el salón no atiende', () {
      // 23/08/2026 es domingo.
      final libres = freeSlots(
        appointments: const [],
        dia: DateTime(2026, 8, 23),
        ahora: DateTime(2026, 8, 20),
      );
      expect(libres, isEmpty);
    });
  });

  group('upcomingFreeSlots', () {
    test('saltea los días sin disponibilidad', () {
      final r = upcomingFreeSlots(
        appointments: const [],
        ahora: DateTime(2026, 8, 20, 8),
        dias: 7,
      );
      // De los 7 días desde el jueves 20, el domingo 23 queda afuera.
      expect(r.length, 6);
      expect(r.any((e) => e.dia.weekday == DateTime.sunday), isFalse);
    });

    test('corta la cantidad de horarios por día', () {
      final r = upcomingFreeSlots(
        appointments: const [],
        ahora: DateTime(2026, 8, 20, 8),
        maxPorDia: 3,
      );
      expect(r.first.libres.length, 3);
    });
  });

  group('groupByHour', () {
    test('agrupa por hora en punto y ordena', () {
      final r = groupByHour([
        turno('2026-08-20', '14:00', id: 'b'),
        turno('2026-08-20', '09:30', id: 'a'),
        turno('2026-08-20', '09:00', id: 'c'),
        turno('2026-08-21', '10:00', id: 'otro-dia'),
      ], DateTime(2026, 8, 20));

      expect(r.map((e) => e.hora), [9, 14]);
      expect(r.first.turnos.map((t) => t.id), ['c', 'a']);
    });

    test('los turnos sin hora quedan al final', () {
      final r = groupByHour([
        turno('2026-08-20', null, id: 'sin-hora'),
        turno('2026-08-20', '09:00', id: 'con-hora'),
      ], DateTime(2026, 8, 20));
      expect(r.last.hora, isNull);
    });
  });

  group('appointmentEnd', () {
    test('suma la duración de los servicios', () {
      final fin = appointmentEnd(
        turno('2026-08-20', '09:00', svs: ['s1']),
        serviciosPorId,
      );
      expect(fin, const TimeOfDayValue(10, 30)); // 90 min
    });

    test('varios servicios suman sus duraciones', () {
      final fin = appointmentEnd(
        turno('2026-08-20', '09:00', svs: ['s1', 's2']),
        serviciosPorId,
      );
      expect(fin, const TimeOfDayValue(11, 30)); // 90 + 60
    });

    test('sin servicios asume una hora', () {
      final fin = appointmentEnd(turno('2026-08-20', '09:00'), serviciosPorId);
      expect(fin, const TimeOfDayValue(10, 0));
    });

    test('no se pasa de medianoche', () {
      final fin = appointmentEnd(
        turno('2026-08-20', '23:30', svs: ['s1']),
        serviciosPorId,
      );
      expect(fin, const TimeOfDayValue(23, 59));
    });
  });

  group('overlappingAppointments — detección que el legacy NO tenía', () {
    test('detecta dos turnos pisados de la misma profesional', () {
      final existente =
          turno('2026-08-20', '09:00', id: 'x', pro: 'p1', svs: ['s1']);
      final nuevo =
          turno('2026-08-20', '10:00', id: 'y', pro: 'p1', svs: ['s2']);
      final r = overlappingAppointments(
        candidato: nuevo,
        existentes: [existente],
        serviciosPorId: serviciosPorId,
      );
      expect(r.map((e) => e.id), ['x']);
    });

    test('empezar justo cuando el otro termina NO es solapamiento', () {
      final existente =
          turno('2026-08-20', '09:00', id: 'x', pro: 'p1', svs: ['s1']);
      final nuevo =
          turno('2026-08-20', '10:30', id: 'y', pro: 'p1', svs: ['s2']);
      expect(
        overlappingAppointments(
          candidato: nuevo,
          existentes: [existente],
          serviciosPorId: serviciosPorId,
        ),
        isEmpty,
      );
    });

    test('profesionales distintas pueden atender a la vez', () {
      final existente =
          turno('2026-08-20', '09:00', id: 'x', pro: 'p1', svs: ['s1']);
      final nuevo =
          turno('2026-08-20', '09:00', id: 'y', pro: 'p2', svs: ['s1']);
      expect(
        overlappingAppointments(
          candidato: nuevo,
          existentes: [existente],
          serviciosPorId: serviciosPorId,
        ),
        isEmpty,
      );
    });

    test('sin profesional asignada no se afirma conflicto', () {
      // No se puede saber quién lo atiende, así que no se molesta a la usuaria.
      final existente = turno('2026-08-20', '09:00', id: 'x', svs: ['s1']);
      final nuevo = turno('2026-08-20', '09:00', id: 'y', svs: ['s1']);
      expect(
        overlappingAppointments(
          candidato: nuevo,
          existentes: [existente],
          serviciosPorId: serviciosPorId,
        ),
        isEmpty,
      );
    });

    test('un turno cancelado no bloquea', () {
      final existente = turno('2026-08-20', '09:00',
          id: 'x', pro: 'p1', svs: ['s1'], estado: TurnoEstado.cancelled);
      final nuevo =
          turno('2026-08-20', '09:00', id: 'y', pro: 'p1', svs: ['s1']);
      expect(
        overlappingAppointments(
          candidato: nuevo,
          existentes: [existente],
          serviciosPorId: serviciosPorId,
        ),
        isEmpty,
      );
    });

    test('editar un turno no lo detecta contra sí mismo', () {
      final t = turno('2026-08-20', '09:00', id: 'x', pro: 'p1', svs: ['s1']);
      expect(
        overlappingAppointments(
          candidato: t,
          existentes: [t],
          serviciosPorId: serviciosPorId,
        ),
        isEmpty,
      );
    });

    test('días distintos no chocan', () {
      final existente =
          turno('2026-08-21', '09:00', id: 'x', pro: 'p1', svs: ['s1']);
      final nuevo =
          turno('2026-08-20', '09:00', id: 'y', pro: 'p1', svs: ['s1']);
      expect(
        overlappingAppointments(
          candidato: nuevo,
          existentes: [existente],
          serviciosPorId: serviciosPorId,
        ),
        isEmpty,
      );
    });
  });
}
