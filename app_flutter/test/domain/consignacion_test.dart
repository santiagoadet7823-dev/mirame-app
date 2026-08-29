import 'package:flutter_test/flutter_test.dart';
import 'package:mirame/domain/rules/consignacion.dart';

void main() {
  group('reparto simple, sin descuento ni vendedor', () {
    test('30% para el salón de una prenda de \$20.000', () {
      final r = repartirItem(precioUnitario: 20000, pctSalon: 30);
      expect(r.proveedor, 14000);
      expect(r.salon, 6000);
      expect(r.vendedor, 0);
      expect(r.cuadra, isTrue);
    });

    test('la cantidad multiplica', () {
      final r = repartirItem(precioUnitario: 20000, cantidad: 3, pctSalon: 30);
      expect(r.neto, 60000);
      expect(r.proveedor, 42000);
      expect(r.salon, 18000);
    });

    test('0% deja todo al proveedor y 100% todo al salón', () {
      expect(repartirItem(precioUnitario: 1000, pctSalon: 0).proveedor, 1000);
      expect(repartirItem(precioUnitario: 1000, pctSalon: 100).salon, 1000);
    });
  });

  group('la comisión del vendedor sale de la parte del salón', () {
    test('el proveedor cobra lo mismo con o sin vendedor', () {
      final sin = repartirItem(precioUnitario: 20000, pctSalon: 30);
      final con = repartirItem(
          precioUnitario: 20000, pctSalon: 30, pctVendedor: 20);
      expect(con.proveedor, sin.proveedor,
          reason: 'el proveedor no financia a alguien que no contrató');
      // 20% de los \$6.000 del salón.
      expect(con.vendedor, 1200);
      expect(con.salon, 4800);
      expect(con.cuadra, isTrue);
    });
  });

  group('descuentos', () {
    test('por defecto lo absorbe el salón: el proveedor cobra sobre la lista', () {
      final r = repartirItem(
          precioUnitario: 20000, descuento: 2000, pctSalon: 30);
      expect(r.neto, 18000);
      // 70% de 20.000, no de 18.000.
      expect(r.proveedor, 14000);
      expect(r.salon, 4000, reason: 'los \$2.000 salen de su parte');
      expect(r.cuadra, isTrue);
    });

    test('compartido: cada uno pone en su proporción', () {
      final r = repartirItem(
          precioUnitario: 20000,
          descuento: 2000,
          pctSalon: 30,
          descuentoLoAbsorbeSalon: false);
      expect(r.proveedor, 12600); // 70% de 18.000
      expect(r.salon, 5400); // 30% de 18.000
      expect(r.cuadra, isTrue);
    });

    test('un descuento grande puede dejar al salón en NEGATIVO', () {
      // Es real: si el proveedor cobra sobre lista y se rebaja mucho, el salón
      // pone plata. El número tiene que mostrarlo, no esconderlo en un cero.
      final r = repartirItem(
          precioUnitario: 20000, descuento: 8000, pctSalon: 30);
      expect(r.neto, 12000);
      expect(r.proveedor, 14000);
      expect(r.salon, -2000);
      expect(r.cuadra, isTrue);
    });

    test('con el salón en negativo, el vendedor NO cobra comisión negativa', () {
      final r = repartirItem(
          precioUnitario: 20000,
          descuento: 8000,
          pctSalon: 30,
          pctVendedor: 20);
      expect(r.vendedor, 0, reason: 'no paga por un descuento que no decidió');
      expect(r.salon, -2000);
      expect(r.cuadra, isTrue);
    });

    test('un descuento mayor que el total se recorta', () {
      final r = repartirItem(
          precioUnitario: 1000, descuento: 5000, pctSalon: 30);
      expect(r.neto, 0);
      expect(r.descuento, 1000);
    });
  });

  group('las tres partes siempre suman el neto', () {
    test('aunque el redondeo mueva centavos', () {
      // 33% de 999,99 no da un número redondo por ningún lado.
      final r = repartirItem(
          precioUnitario: 999.99, pctSalon: 33, pctVendedor: 17);
      expect(r.cuadra, isTrue);
      expect(r.proveedor + r.salon + r.vendedor, closeTo(r.neto, 0.005));
    });

    test('sobre cien precios distintos', () {
      for (var i = 1; i <= 100; i++) {
        final r = repartirItem(
            precioUnitario: i * 137.77,
            descuento: i.isEven ? i * 3.3 : 0,
            pctSalon: 30 + (i % 20),
            pctVendedor: i % 15);
        expect(r.cuadra, isTrue, reason: 'no cuadra con i=$i');
      }
    });
  });

  group('venta completa', () {
    test('suma los ítems y sigue cuadrando', () {
      final v = repartirVenta([
        repartirItem(precioUnitario: 20000, pctSalon: 30),
        repartirItem(precioUnitario: 15000, pctSalon: 40, pctVendedor: 10),
        repartirItem(precioUnitario: 8000, cantidad: 2, pctSalon: 25),
      ]);
      expect(v.neto, 51000);
      expect(v.cuadra, isTrue);
    });

    test('una venta vacía no rompe', () {
      final v = repartirVenta(const []);
      expect(v.neto, 0);
      expect(v.cuadra, isTrue);
    });
  });

  group('liquidación', () {
    test('suma lo pendiente y lista qué incluyó', () {
      final items = [
        (id: 'a', monto: 14000),
        (id: 'b', monto: 9000),
        (id: 'c', monto: 0),
      ];
      final l = liquidar(
        items: items,
        montoDe: (i) => i.monto,
        idDe: (i) => i.id,
      );
      expect(l.total, 23000);
      // El de monto cero no ensucia el comprobante.
      expect(l.items, ['a', 'b']);
    });

    test('sin nada pendiente da cero', () {
      final l = liquidar<({String id, num monto})>(
          items: const [], montoDe: (i) => i.monto, idDe: (i) => i.id);
      expect(l.total, 0);
      expect(l.items, isEmpty);
    });
  });
}
