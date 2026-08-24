import 'package:flutter_test/flutter_test.dart';
import 'package:mirame/domain/entities/entities.dart';
import 'package:mirame/domain/rules/stock.dart';

StockItem item(String nombre, int cantidad, {int minimo = 5}) => StockItem(
    id: 'x-$nombre', nombre: nombre, cantidad: cantidad, minimo: minimo);

void main() {
  group('stockStatus', () {
    test('cero es "sin stock"', () {
      expect(stockStatus(item('Adhesivo', 0)), StockStatus.out);
    });

    test('estar justo en el mínimo ya es "bajo"', () {
      expect(stockStatus(item('Adhesivo', 5, minimo: 5)), StockStatus.low);
    });

    test('por encima del mínimo está ok', () {
      expect(stockStatus(item('Adhesivo', 6, minimo: 5)), StockStatus.ok);
    });

    test('un mínimo de 0 se trata como 1, igual que el `||1` del original', () {
      expect(stockStatus(item('Pinza', 1, minimo: 0)), StockStatus.low);
      expect(stockStatus(item('Pinza', 2, minimo: 0)), StockStatus.ok);
    });
  });

  group('stockBarPct — la barra se llena al DOBLE del mínimo', () {
    test('estar en el mínimo es media barra', () {
      expect(stockBarPct(item('Adhesivo', 5, minimo: 5)), 50);
    });

    test('el doble del mínimo llena la barra', () {
      expect(stockBarPct(item('Adhesivo', 10, minimo: 5)), 100);
    });

    test('nunca pasa de 100 aunque haya de sobra', () {
      expect(stockBarPct(item('Adhesivo', 500, minimo: 5)), 100);
    });

    test('cero es barra vacía', () {
      expect(stockBarPct(item('Adhesivo', 0)), 0);
    });
  });

  group('adjustQuantity', () {
    test('suma y resta', () {
      expect(adjustQuantity(5, 1), 6);
      expect(adjustQuantity(5, -1), 4);
    });

    test('nunca baja de cero', () {
      expect(adjustQuantity(0, -1), 0);
      expect(adjustQuantity(1, -5), 0);
    });
  });

  group('stockAlerts', () {
    test('los agotados van primero', () {
      final r = stockAlerts([
        item('Bajo', 2, minimo: 5),
        item('Agotado', 0),
        item('Ok', 50),
      ]);
      expect(r.first.nombre, 'Agotado');
      expect(r.length, 2, reason: 'los que están ok no son alerta');
    });

    test('corta en el límite', () {
      final r = stockAlerts([
        for (var i = 0; i < 10; i++) item('P$i', 0),
      ]);
      expect(r.length, 3);
    });
  });

  group('filterStock', () {
    final items = [
      item('Adhesivo Premium', 0),
      item('Pestañas C 0.10', 3, minimo: 5),
      item('Primer', 40),
    ];

    test('el filtro "bajo" EXCLUYE los agotados', () {
      // Detalle del original: un producto en cero no aparece en "bajo stock",
      // aparece en "sin stock". Si no, se contaría dos veces.
      final r = filterStock(items, estado: StockStatus.low);
      expect(r.map((e) => e.nombre), ['Pestañas C 0.10']);
    });

    test('el filtro "sin stock" trae solo los de cantidad cero', () {
      final r = filterStock(items, estado: StockStatus.out);
      expect(r.map((e) => e.nombre), ['Adhesivo Premium']);
    });

    test('la búsqueda no distingue mayúsculas', () {
      expect(filterStock(items, query: 'PREMIUM').length, 1);
      expect(filterStock(items, query: 'pesta').length, 1);
    });

    test('sin filtros devuelve todo', () {
      expect(filterStock(items).length, 3);
    });
  });
}
