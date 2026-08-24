import 'package:flutter_test/flutter_test.dart';
import 'package:mirame/domain/entities/entities.dart';
import 'package:mirame/domain/rules/finance.dart';
import 'package:mirame/domain/rules/period.dart';

Transaction inc(String fecha, num monto, {String? cat, TxMetodo? metodo}) =>
    Transaction(
      id: 'i-$fecha-$monto',
      tipo: TxTipo.income,
      fecha: DateTime.parse(fecha),
      monto: monto,
      categoria: cat,
      metodo: metodo ?? TxMetodo.efectivo,
    );

Transaction exp(String fecha, num monto, {String? cat}) => Transaction(
      id: 'e-$fecha-$monto',
      tipo: TxTipo.expense,
      fecha: DateTime.parse(fecha),
      monto: monto,
      categoria: cat,
    );

Appointment appt(String fecha,
        {String? cliente, num precio = 0, List<String> svs = const []}) =>
    Appointment(
      id: 'a-$fecha-$precio-$cliente',
      fecha: DateTime.parse(fecha),
      clientId: cliente,
      precio: precio,
      serviceIds: svs,
    );

void main() {
  group('summarize', () {
    final txs = [
      inc('2026-08-05', 8000),
      inc('2026-08-20', 12000),
      exp('2026-08-10', 5000),
      inc('2026-07-30', 99999), // fuera del mes: no debe contar
    ];

    test('suma solo lo que cae dentro del rango', () {
      final s = summarize(txs, monthRange(DateTime(2026, 8, 15)));
      expect(s.ingresos, 20000);
      expect(s.egresos, 5000);
      expect(s.neta, 15000);
    });

    test('el margen es entero y se calcula sobre los ingresos', () {
      final s = summarize(txs, monthRange(DateTime(2026, 8, 15)));
      expect(s.margenPct, 75); // 15000/20000
    });

    test('sin ingresos el margen es 0, no una división por cero', () {
      final s = summarize(
          [exp('2026-08-01', 3000)], monthRange(DateTime(2026, 8, 1)));
      expect(s.margenPct, 0);
      expect(s.neta, -3000);
    });

    test('el margen negativo se muestra sin recortar pero la barra sí recorta',
        () {
      // Este es el detalle del original: el TEXTO puede decir -150%,
      // la BARRA no puede medir menos de 0.
      final s = summarize(
        [inc('2026-08-01', 1000), exp('2026-08-02', 2500)],
        monthRange(DateTime(2026, 8, 1)),
      );
      expect(s.margenPct, -150);
      expect(s.margenBarPct, 0);
    });

    test('incluye los bordes del rango', () {
      final s = summarize(
        [inc('2026-08-01', 100), inc('2026-08-31', 200)],
        monthRange(DateTime(2026, 8, 15)),
      );
      expect(s.ingresos, 300);
    });
  });

  group('projectMonth', () {
    test('proyecta el promedio diario al total de días del mes', () {
      // 10 del mes, $30.000 acumulados → $3.000/día × 31 días = $93.000
      final p = projectMonth(
        [inc('2026-08-05', 20000), inc('2026-08-09', 10000)],
        DateTime(2026, 8, 10),
      );
      expect(p.acumulado, 30000);
      expect(p.promedioDiario, 3000);
      expect(p.proyectado, 93000);
      expect(p.diasDelMes, 31);
    });

    test('solo cuenta hasta hoy, no el mes entero', () {
      // Un ingreso futuro cargado por adelantado no infla la proyección.
      final p = projectMonth(
        [inc('2026-08-05', 10000), inc('2026-08-28', 50000)],
        DateTime(2026, 8, 10),
      );
      expect(p.acumulado, 10000);
    });

    test('sin ingresos la tarjeta se esconde', () {
      final p = projectMonth(<Transaction>[], DateTime(2026, 8, 10));
      expect(p.visible, isFalse);
      expect(p.acumulado, 0);
    });

    test('el pct nunca pasa de 100', () {
      final p = projectMonth([inc('2026-08-31', 1000)], DateTime(2026, 8, 31));
      expect(p.pct, lessThanOrEqualTo(100));
    });

    test('febrero de año bisiesto da 29 días', () {
      final p = projectMonth([inc('2028-02-10', 1000)], DateTime(2028, 2, 10));
      expect(p.diasDelMes, 29);
    });

    test('el subtítulo describe el avance del mes', () {
      final p = projectMonth([inc('2026-08-10', 100)], DateTime(2026, 8, 10));
      expect(p.subtitulo, 'Día 10 de 31 · 32% del mes');
    });
  });

  group('projectNet', () {
    test('proyecta los ingresos y resta los egresos ya registrados', () {
      // 10/31, $30.000 ingresos → proyecta $93.000, menos $8.000 = $85.000
      final n = projectNet(
        [inc('2026-08-05', 30000), exp('2026-08-06', 8000)],
        DateTime(2026, 8, 10),
      );
      expect(n, 85000);
    });
  });

  group('closeCash', () {
    final txs = [
      inc('2026-08-02', 8000, cat: 'servicio', metodo: TxMetodo.efectivo),
      inc('2026-08-03', 12000, cat: 'producto', metodo: TxMetodo.transferencia),
      inc('2026-08-04', 5000, metodo: TxMetodo.efectivo), // sin categoría
      exp('2026-08-05', 3000, cat: 'insumo'),
      exp('2026-08-06', 1000), // sin categoría
    ];
    final cierre = closeCash(txs, monthRange(DateTime(2026, 8, 1)));

    test('los ingresos sin categoría caen en "servicio"', () {
      final servicio = cierre.porCategoriaIngreso
          .firstWhere((e) => e.key == kDefaultIncomeCategory);
      expect(servicio.value, 13000); // 8000 + los 5000 sin categoría
    });

    test('los egresos sin categoría caen en "otro-gasto"', () {
      final otros = cierre.porCategoriaEgreso
          .firstWhere((e) => e.key == kDefaultExpenseCategory);
      expect(otros.value, 1000);
    });

    test('ordena de mayor a menor', () {
      final montos = cierre.porCategoriaIngreso.map((e) => e.value).toList();
      expect(montos, [13000, 12000]);
    });

    test('el desglose por método incluye SOLO ingresos', () {
      final total = cierre.porMetodo.fold<num>(0, (s, e) => s + e.value);
      expect(total, 25000, reason: 'los egresos no deben entrar acá');
      expect(cierre.porMetodo.map((e) => e.key), contains('efectivo'));
    });

    test('el neto coincide con el resumen', () {
      expect(cierre.summary.neta, 21000); // 25000 - 4000
    });
  });

  group('expensesByCategory', () {
    test('calcula el porcentaje sobre el total de gastos', () {
      final r = expensesByCategory(
        [
          exp('2026-08-01', 7500, cat: 'alquiler'),
          exp('2026-08-02', 2500, cat: 'insumo'),
        ],
        monthRange(DateTime(2026, 8, 1)),
      );
      expect(r.first.categoria, 'alquiler');
      expect(r.first.pct, 75);
      expect(r.last.pct, 25);
    });

    test('sin gastos devuelve vacío, no una lista con ceros', () {
      final r = expensesByCategory(
          [inc('2026-08-01', 100)], monthRange(DateTime(2026, 8, 1)));
      expect(r, isEmpty);
    });
  });

  group('weeklyIncome', () {
    test('devuelve 8 semanas, de la más vieja a la más reciente', () {
      final r = weeklyIncome(<Transaction>[], DateTime(2026, 8, 20));
      expect(r.length, 8);
      expect(r.first.inicio.isBefore(r.last.inicio), isTrue);
    });

    test('las semanas empiezan en domingo', () {
      final r = weeklyIncome(<Transaction>[], DateTime(2026, 8, 20));
      for (final s in r) {
        expect(s.inicio.weekday, DateTime.sunday);
      }
    });

    test('la última semana contiene a hoy', () {
      final hoy = DateTime(2026, 8, 20); // jueves
      final r = weeklyIncome(<Transaction>[], hoy);
      final ultima = r.last;
      expect(ultima.inicio.isAfter(hoy), isFalse);
      expect(hoy.difference(ultima.inicio).inDays, lessThan(7));
    });

    test('la barra más alta llega a 100', () {
      final r = weeklyIncome([inc('2026-08-18', 5000)], DateTime(2026, 8, 20));
      expect(r.map((e) => e.pctAlto).reduce((a, b) => a > b ? a : b), 100);
    });

    test('sin datos no divide por cero', () {
      final r = weeklyIncome(<Transaction>[], DateTime(2026, 8, 20));
      expect(r.every((e) => e.pctAlto == 0), isTrue);
    });
  });

  group('topServices', () {
    test('cuenta apariciones en todos los turnos y corta en 5', () {
      final appts = [
        appt('2026-08-01', svs: ['s1', 's2']),
        appt('2026-08-02', svs: ['s1']),
        appt('2026-08-03', svs: ['s1', 's3']),
        appt('2026-08-04', svs: ['s2']),
        appt('2026-08-05', svs: ['s4']),
        appt('2026-08-06', svs: ['s5']),
        appt('2026-08-07', svs: ['s6']),
      ];
      final r = topServices(appts);
      expect(r.length, 5);
      expect(r.first.serviceId, 's1');
      expect(r.first.cantidad, 3);
    });

    test('un turno con varios servicios cuenta para cada uno', () {
      final r = topServices([
        appt('2026-08-01', svs: ['a', 'b', 'c'])
      ]);
      expect(r.map((e) => e.cantidad), everyElement(1));
      expect(r.length, 3);
    });
  });

  group('topClients', () {
    test('suma el precio de los TURNOS, no las transacciones', () {
      final r = topClients([
        appt('2026-08-01', cliente: 'c1', precio: 8000),
        appt('2026-08-02', cliente: 'c1', precio: 4000),
        appt('2026-08-03', cliente: 'c2', precio: 10000),
      ]);
      expect(r.first.clientId, 'c1');
      expect(r.first.total, 12000);
      expect(r.first.pctBarra, 100);
      expect(r.last.pctBarra, 83); // 10000/12000
    });

    test('ignora turnos sin clienta o sin precio', () {
      final r = topClients([
        appt('2026-08-01', precio: 5000), // sin clienta
        appt('2026-08-02', cliente: 'c1'), // sin precio
      ]);
      expect(r, isEmpty);
    });
  });

  group('averageTicket', () {
    test('divide los ingresos del mes por la cantidad de turnos del mes', () {
      final r = averageTicket(
        [inc('2026-08-01', 30000)],
        [appt('2026-08-01'), appt('2026-08-02'), appt('2026-08-03')],
        DateTime(2026, 8, 15),
      );
      expect(r, 10000);
    });

    test('sin turnos da 0 en vez de dividir por cero', () {
      final r = averageTicket(
          [inc('2026-08-01', 30000)], <Appointment>[], DateTime(2026, 8, 15));
      expect(r, 0);
    });
  });

  group('monthlyComparison', () {
    test('compara este mes contra el anterior', () {
      final r = monthlyComparison(
        [inc('2026-08-10', 20000), inc('2026-07-10', 10000)],
        DateTime(2026, 8, 15),
      );
      expect(r.actual, 20000);
      expect(r.anterior, 10000);
      expect(r.pctActual, 100);
      expect(r.pctAnterior, 50);
    });

    test('en enero el mes anterior es diciembre del año pasado', () {
      final r =
          monthlyComparison([inc('2025-12-10', 7000)], DateTime(2026, 1, 15));
      expect(r.anterior, 7000);
    });

    test('sin datos no divide por cero', () {
      final r = monthlyComparison(<Transaction>[], DateTime(2026, 8, 15));
      expect(r.pctActual, 0);
      expect(r.pctAnterior, 0);
    });
  });
}
