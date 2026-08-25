import 'package:flutter_test/flutter_test.dart';
import 'package:mirame/domain/entities/entities.dart';
import 'package:mirame/domain/rules/avisos.dart';

/// 7 de la mañana: antes de TODAS las horas de aviso —la primera es el resumen
/// de las 8— así los tests ven la agenda completa.
final ahora = DateTime(2026, 8, 24, 7);

Client cliente(String id, String nombre, {DateTime? cumple}) =>
    Client(id: id, nombre: nombre, cumple: cumple);

Appointment turno(
  String id,
  DateTime fecha, {
  String? clientId,
  List<String> servicios = const [],
  TurnoEstado estado = TurnoEstado.confirmed,
  TimeOfDayValue? hora,
}) =>
    Appointment(
      id: id,
      fecha: fecha,
      clientId: clientId,
      serviceIds: servicios,
      estado: estado,
      hora: hora,
    );

void main() {
  group('idEstable', () {
    test('no cambia entre llamadas y nunca es cero', () {
      expect(idEstable('retoque-2026-08-24'), idEstable('retoque-2026-08-24'));
      expect(idEstable(''), isNot(0));
    });

    test('claves distintas dan ids distintos', () {
      expect(idEstable('caja-2026-08-24'), isNot(idEstable('caja-2026-08-25')));
    });
  });

  group('avisosDelDia', () {
    test('sin datos no programa nada', () {
      expect(
        avisosDelDia(
          clients: const [],
          appointments: const [],
          services: const [],
          transactions: const [],
          ahora: ahora,
        ),
        isEmpty,
      );
    });

    test('avisa el cumpleaños de hoy ignorando el año', () {
      final avisos = avisosDelDia(
        clients: [cliente('c1', 'Ana', cumple: DateTime(1990, 8, 24))],
        appointments: const [],
        services: const [],
        transactions: const [],
        ahora: ahora,
      );
      expect(avisos, hasLength(1));
      expect(avisos.single.titulo, contains('Ana'));
      expect(avisos.single.cuando.hour, kHoraCumples);
    });

    test('resume los turnos de mañana con la hora del primero', () {
      final avisos = avisosDelDia(
        clients: const [],
        appointments: [
          turno('a1', DateTime(2026, 8, 25), hora: const TimeOfDayValue(15, 0)),
          turno('a2', DateTime(2026, 8, 25), hora: const TimeOfDayValue(9, 30)),
        ],
        services: const [],
        transactions: const [],
        ahora: ahora,
      );
      final manana = avisos.singleWhere((a) => a.payload == 'agenda');
      expect(manana.titulo, contains('2 turnos'));
      expect(manana.cuerpo, contains('09:30'));
      expect(manana.cuando.hour, kHoraTurnosDeManana);
    });

    test('los turnos cancelados de mañana no cuentan', () {
      final avisos = avisosDelDia(
        clients: const [],
        appointments: [
          turno('a1', DateTime(2026, 8, 25), estado: TurnoEstado.cancelled),
        ],
        services: const [],
        transactions: const [],
        ahora: ahora,
      );
      expect(avisos.where((a) => a.payload == 'agenda'), isEmpty);
    });

    test('el retoque avisa solo cuando vence hoy o ya venció', () {
      // Servicio de 21 dias. El turno de hace 21 dias vence HOY; el de hace 23
      // vencio hace 2 y sigue dentro de la ventana de -3; el de hace 18
      // vence en 3 y no debe notificar todavia.
      const sv = Service(id: 's1', nombre: 'Volumen', retoqueDias: 21);
      List<AvisoProgramado> conTurnoHace(int dias) => avisosDelDia(
            clients: [cliente('c1', 'Ana')],
            appointments: [
              turno('a1', ahora.subtract(Duration(days: dias)),
                  clientId: 'c1',
                  servicios: const ['s1'],
                  estado: TurnoEstado.done),
            ],
            services: const [sv],
            transactions: const [],
            ahora: ahora,
          );

      expect(conTurnoHace(21).where((a) => a.payload == 'inicio'), hasLength(1));
      expect(conTurnoHace(23).where((a) => a.payload == 'inicio'), hasLength(1));
      expect(conTurnoHace(18).where((a) => a.payload == 'inicio'), isEmpty);
    });

    group('la jornada de hoy', () {
      List<AvisoProgramado> conTurnosHoy(List<Appointment> turnos) =>
          avisosDelDia(
            clients: [cliente('c1', 'Ana'), cliente('c2', 'Bea')],
            appointments: turnos,
            services: const [],
            transactions: const [],
            ahora: ahora,
          );

      test('resume los turnos del día con hora y nombre', () {
        final avisos = conTurnosHoy([
          turno('a1', DateTime(2026, 8, 24),
              clientId: 'c1', hora: const TimeOfDayValue(18, 0)),
          turno('a2', DateTime(2026, 8, 24),
              clientId: 'c2', hora: const TimeOfDayValue(9, 30)),
        ]);
        final resumen =
            avisos.firstWhere((a) => a.titulo.startsWith('☀️'));
        expect(resumen.titulo, contains('2 turnos'));
        // En orden de hora, no en el que vinieron.
        expect(resumen.cuerpo, '09:30 · Bea\n18:00 · Ana');
        expect(resumen.cuando.hour, kHoraResumenDelDia);
      });

      test('avisa media hora antes de cada turno', () {
        final avisos = conTurnosHoy([
          turno('a1', DateTime(2026, 8, 24),
              clientId: 'c1', hora: const TimeOfDayValue(18, 0)),
        ]);
        final previo = avisos.firstWhere((a) => a.titulo.startsWith('💅'));
        expect(previo.cuando, DateTime(2026, 8, 24, 17, 30));
        expect(previo.cuerpo, 'Ana · 18:00');
      });

      test('un turno sin hora no genera aviso previo', () {
        final avisos = conTurnosHoy([
          turno('a1', DateTime(2026, 8, 24), clientId: 'c1'),
        ]);
        expect(avisos.where((a) => a.titulo.startsWith('💅')), isEmpty);
      });

      test('los turnos ya hechos o cancelados no cuentan', () {
        final avisos = conTurnosHoy([
          turno('a1', DateTime(2026, 8, 24),
              clientId: 'c1',
              hora: const TimeOfDayValue(18, 0),
              estado: TurnoEstado.done),
          turno('a2', DateTime(2026, 8, 24),
              clientId: 'c2',
              hora: const TimeOfDayValue(19, 0),
              estado: TurnoEstado.cancelled),
        ]);
        expect(avisos, isEmpty);
      });

      test('el aviso del turno no se programa si ya pasó su hora', () {
        // 7:15 menos 30 minutos es antes de las 7, que es "ahora".
        final avisos = avisosDelDia(
          clients: [cliente('c1', 'Ana')],
          appointments: [
            turno('a1', DateTime(2026, 8, 24),
                clientId: 'c1', hora: const TimeOfDayValue(7, 15)),
          ],
          services: const [],
          transactions: const [],
          ahora: ahora,
        );
        expect(avisos.where((a) => a.titulo.startsWith('💅')), isEmpty);
      });

      test('el id del aviso previo es por turno, no por día', () {
        // Mover la hora tiene que PISAR el aviso viejo, no dejar los dos.
        final a = conTurnosHoy([
          turno('a1', DateTime(2026, 8, 24),
              clientId: 'c1', hora: const TimeOfDayValue(18, 0)),
        ]).firstWhere((x) => x.titulo.startsWith('💅'));
        final b = conTurnosHoy([
          turno('a1', DateTime(2026, 8, 24),
              clientId: 'c1', hora: const TimeOfDayValue(19, 0)),
        ]).firstWhere((x) => x.titulo.startsWith('💅'));
        expect(a.id, b.id);
        expect(a.cuando, isNot(b.cuando));
      });
    });

    test('el cierre de caja no se programa si no hubo movimientos', () {
      final avisos = avisosDelDia(
        clients: const [],
        appointments: const [],
        services: const [],
        transactions: [
          // De ayer: no cuenta para el cierre de hoy.
          Transaction(
              id: 't1', tipo: TxTipo.income, fecha: DateTime(2026, 8, 23),
              monto: 5000),
        ],
        ahora: ahora,
      );
      expect(avisos.where((a) => a.payload == 'caja'), isEmpty);
    });

    test('el cierre de caja informa ingresos, gastos y neto', () {
      final avisos = avisosDelDia(
        clients: const [],
        appointments: const [],
        services: const [],
        transactions: [
          Transaction(
              id: 't1', tipo: TxTipo.income, fecha: ahora, monto: 12000),
          Transaction(
              id: 't2', tipo: TxTipo.expense, fecha: ahora, monto: 2000),
        ],
        ahora: ahora,
      );
      final caja = avisos.singleWhere((a) => a.payload == 'caja');
      expect(caja.cuerpo, contains('\$12000'));
      expect(caja.cuerpo, contains('\$2000'));
      expect(caja.cuerpo, contains('\$10000'));
      expect(caja.cuando.hour, kHoraCierreCaja);
    });

    test('no programa avisos cuya hora ya pasó', () {
      // 22:00: pasaron las cuatro horas de aviso del día.
      final avisos = avisosDelDia(
        clients: [cliente('c1', 'Ana', cumple: DateTime(1990, 8, 24))],
        appointments: [turno('a1', DateTime(2026, 8, 25))],
        services: const [],
        transactions: [
          Transaction(id: 't1', tipo: TxTipo.income, fecha: ahora, monto: 1),
        ],
        ahora: DateTime(2026, 8, 24, 22),
      );
      expect(avisos, isEmpty);
    });

    test('el id de un aviso es el mismo al recalcularlo', () {
      List<AvisoProgramado> calcular() => avisosDelDia(
            clients: [cliente('c1', 'Ana', cumple: DateTime(1990, 8, 24))],
            appointments: const [],
            services: const [],
            transactions: const [],
            ahora: ahora,
          );
      expect(calcular().single.id, calcular().single.id);
    });
  });

  group('avisoDeStock', () {
    test('devuelve null con el stock en orden', () {
      expect(
        avisoDeStock(
          const [StockItem(id: 's1', nombre: 'Adhesivo', cantidad: 10, minimo: 2)],
          ahora,
        ),
        isNull,
      );
    });

    test('cuenta los agotados aparte de los bajos', () {
      final aviso = avisoDeStock(
        const [
          StockItem(id: 's1', nombre: 'Adhesivo', cantidad: 0, minimo: 2),
          StockItem(id: 's2', nombre: 'Parches', cantidad: 2, minimo: 2),
        ],
        ahora,
      );
      expect(aviso!.titulo, contains('1 producto'));
      expect(aviso.titulo, contains('sin stock'));
      expect(aviso.cuerpo, contains('Adhesivo'));
      expect(aviso.canal, CanalAviso.stock);
    });

    test('con muchos productos resume el resto', () {
      final aviso = avisoDeStock(
        [
          for (var i = 0; i < 5; i++)
            StockItem(id: 's$i', nombre: 'Item $i', cantidad: 1, minimo: 3),
        ],
        ahora,
      );
      expect(aviso!.cuerpo, contains('y 2 más'));
    });
  });
}
