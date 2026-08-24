import 'package:flutter_test/flutter_test.dart';
import 'package:mirame/domain/rules/formatting.dart';

void main() {
  group('formatMoney — debe dar exactamente lo mismo que es-AR', () {
    test('agrupa miles con punto', () {
      expect(formatMoney(284500), r'$284.500');
      expect(formatMoney(8000), r'$8.000');
      expect(formatMoney(1000000), r'$1.000.000');
    });

    test('no agrupa por debajo de mil', () {
      expect(formatMoney(0), r'$0');
      expect(formatMoney(999), r'$999');
    });

    test('null y cero dan lo mismo (el original hace Number(n||0))', () {
      expect(formatMoney(null), r'$0');
    });

    test('los negativos llevan el signo antes del peso', () {
      // Es como se muestra la caja en rojo cuando los egresos superan.
      expect(formatMoney(-4500), r'-$4.500');
    });

    test('redondea decimales', () {
      expect(formatMoney(1500.4), r'$1.500');
      expect(formatMoney(1500.6), r'$1.501');
    });
  });

  group('initials', () {
    test('toma la inicial de las dos primeras palabras', () {
      expect(initials('Camila Fernández'), 'CF');
      expect(initials('María José Gómez'), 'MJ');
    });

    test('un solo nombre da una sola letra', () {
      expect(initials('Camila'), 'C');
    });

    test('vacío o null dan el interrogante del original', () {
      expect(initials(null), '?');
      expect(initials(''), '?');
    });
  });

  group('avatarIndex — el hash NO se puede cambiar', () {
    // Si estos valores cambian, todas las clientas cambian de color respecto
    // de la app que la dueña ya usa. Son el contrato con el original.
    test('acumula el módulo en cada iteración, no al final', () {
      // Referencia calculada con el algoritmo del index.html:
      //   h = 0; para cada char: h = (h*31 + code) % 6
      int referencia(String s) {
        var h = 0;
        for (final c in s.codeUnits) {
          h = (h * 31 + c) % 6;
        }
        return h;
      }

      for (final nombre in [
        'Camila',
        'María José',
        'Ana',
        'Sofía Gutiérrez',
        'Belén',
        'Z',
      ]) {
        expect(avatarIndex(nombre), referencia(nombre),
            reason: 'desvío en "$nombre"');
      }
    });

    test('siempre cae dentro de la paleta de 6', () {
      for (final n in ['A', 'Camila', 'x' * 200, 'Ñoño']) {
        expect(avatarIndex(n), inInclusiveRange(0, 5));
      }
    });

    test('null y vacío usan la "A" de default, como el original', () {
      expect(avatarIndex(null), avatarIndex('A'));
      expect(avatarIndex(''), avatarIndex('A'));
    });

    test('es estable: el mismo nombre da siempre el mismo color', () {
      expect(avatarIndex('Camila'), avatarIndex('Camila'));
    });
  });

  group('greeting', () {
    test('cambia a las 12 y a las 18', () {
      expect(greeting(DateTime(2026, 8, 23, 11, 59)), contains('Buenos días'));
      expect(greeting(DateTime(2026, 8, 23, 12, 0)), contains('Buenas tardes'));
      expect(
          greeting(DateTime(2026, 8, 23, 17, 59)), contains('Buenas tardes'));
      expect(greeting(DateTime(2026, 8, 23, 18, 0)), contains('Buenas noches'));
    });
  });

  group('formatDateShort', () {
    test('da el formato corto en español', () {
      // 23/08/2026 es domingo.
      expect(formatDateShort(DateTime(2026, 8, 23)), 'dom, 23 ago');
      expect(formatDateShort(DateTime(2026, 3, 2)), 'lun, 2 mar');
    });
  });
}
