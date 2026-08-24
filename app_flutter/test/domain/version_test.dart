import 'package:flutter_test/flutter_test.dart';
import 'package:mirame/domain/rules/version.dart';

void main() {
  group('cmpVer', () {
    test('ordena por número, no alfabéticamente', () {
      // El bug clásico: como string, '1.5.9' > '1.5.42'.
      expect(cmpVer('1.5.9', '1.5.42'), lessThan(0));
      expect(cmpVer('1.10.0', '1.9.0'), greaterThan(0));
      expect(cmpVer('2.0.0', '10.0.0'), lessThan(0));
    });

    test('iguales dan 0', () {
      expect(cmpVer('1.2.3', '1.2.3'), 0);
    });

    test('distinta cantidad de segmentos: falta = 0', () {
      expect(cmpVer('1.2', '1.2.0'), 0);
      expect(cmpVer('1.2', '1.2.1'), lessThan(0));
      expect(cmpVer('1.2.0.0', '1.2'), 0);
    });

    test('tolera la v inicial y los espacios', () {
      expect(cmpVer('v1.2.3', ' 1.2.3 '), 0);
    });

    test('ignora pre-release y build metadata', () {
      expect(cmpVer('1.2.3-beta', '1.2.3'), 0);
      expect(cmpVer('1.2.3+45', '1.2.3'), 0);
      expect(cmpVer('1.2.4-rc1', '1.2.3'), greaterThan(0));
    });

    test('un segmento basura cuenta como 0, no rompe', () {
      expect(cmpVer('1.x.3', '1.0.3'), 0);
      expect(cmpVer('', '0.0.0'), 0);
    });
  });

  group('debeActualizar — minVersion es un piso', () {
    test('por debajo del piso: sí', () {
      expect(debeActualizar(instalada: '1.0.0', minVersion: '1.1.0'), isTrue);
    });

    test('justo en el piso: no', () {
      expect(debeActualizar(instalada: '1.1.0', minVersion: '1.1.0'), isFalse);
    });

    test('por encima del piso: no', () {
      // Publicar 1.2.0 sin subir el piso no debe forzar a nadie.
      expect(debeActualizar(instalada: '1.2.0', minVersion: '1.1.0'), isFalse);
    });
  });

  group('hayNovedad', () {
    test('separa "hay una nueva" de "es obligatoria"', () {
      expect(hayNovedad(instalada: '1.0.0', latestVersion: '1.1.0'), isTrue);
      expect(debeActualizar(instalada: '1.0.0', minVersion: '1.0.0'), isFalse);
    });
  });
}
