import 'package:flutter_test/flutter_test.dart';
import 'package:mirame/domain/entities/ropa.dart';
import 'package:mirame/domain/rules/rotacion.dart';

final hoy = DateTime(2026, 8, 25);

Producto prod(String id, {num precio = 10000, DateTime? creado}) =>
    Producto(id: id, nombre: 'Prenda $id', precio: precio, creadoEl: creado);

void main() {
  group('prendas estancadas', () {
    test('una prenda vendida hace poco no aparece', () {
      final r = prendasEstancadas(
        productos: [prod('p1')],
        ultimaVentaPorProducto: {'p1': hoy.subtract(const Duration(days: 10))},
        stockPorProducto: {'p1': 3},
        hoy: hoy,
      );
      expect(r, isEmpty);
    });

    test('una prenda sin vender hace 60 días sí', () {
      final r = prendasEstancadas(
        productos: [prod('p1')],
        ultimaVentaPorProducto: {'p1': hoy.subtract(const Duration(days: 60))},
        stockPorProducto: {'p1': 2},
        hoy: hoy,
      );
      expect(r, hasLength(1));
      expect(r.single.diasSinVender, 60);
      expect(r.single.nuncaSeVendio, isFalse);
    });

    test('sin stock NO es un problema: es una prenda vendida', () {
      final r = prendasEstancadas(
        productos: [prod('p1')],
        ultimaVentaPorProducto: {'p1': hoy.subtract(const Duration(days: 200))},
        stockPorProducto: {'p1': 0},
        hoy: hoy,
      );
      expect(r, isEmpty);
    });

    test('la que nunca se vendió se mide desde que entró', () {
      final r = prendasEstancadas(
        productos: [prod('p1', creado: hoy.subtract(const Duration(days: 90)))],
        ultimaVentaPorProducto: const {},
        stockPorProducto: {'p1': 1},
        hoy: hoy,
      );
      expect(r.single.nuncaSeVendio, isTrue);
      expect(r.single.diasSinVender, 90);
      expect(r.single.etiqueta, contains('Nunca se vendió'));
    });

    test('sin ventas y sin fecha de alta se calla en vez de inventar', () {
      final r = prendasEstancadas(
        productos: [prod('p1')], // creadoEl == null
        ultimaVentaPorProducto: const {},
        stockPorProducto: {'p1': 5},
        hoy: hoy,
      );
      expect(r, isEmpty);
    });

    test('justo en el límite todavía no entra', () {
      List<Estancada> con(int dias) => prendasEstancadas(
            productos: [prod('p1')],
            ultimaVentaPorProducto: {
              'p1': hoy.subtract(Duration(days: dias))
            },
            stockPorProducto: {'p1': 1},
            hoy: hoy,
          );
      expect(con(kDiasParaEstancarse - 1), isEmpty);
      expect(con(kDiasParaEstancarse), hasLength(1));
    });

    test('ordena por días y, a igualdad, por plata parada', () {
      final r = prendasEstancadas(
        productos: [
          prod('barata', precio: 1000),
          prod('cara', precio: 50000),
          prod('vieja', precio: 500),
        ],
        ultimaVentaPorProducto: {
          'barata': hoy.subtract(const Duration(days: 50)),
          'cara': hoy.subtract(const Duration(days: 50)),
          'vieja': hoy.subtract(const Duration(days: 300)),
        },
        stockPorProducto: {'barata': 1, 'cara': 1, 'vieja': 1},
        hoy: hoy,
      );
      expect(r.map((e) => e.producto.id).toList(),
          ['vieja', 'cara', 'barata']);
    });

    test('el capital quieto es precio por stock', () {
      final r = prendasEstancadas(
        productos: [prod('p1', precio: 12000)],
        ultimaVentaPorProducto: {'p1': hoy.subtract(const Duration(days: 60))},
        stockPorProducto: {'p1': 4},
        hoy: hoy,
      );
      expect(r.single.capitalQuieto, 48000);
    });
  });

  group('próximo código', () {
    test('sin nada cargado arranca en 001', () {
      expect(proximoCodigo(const []), 'MIR-001');
    });

    test('sigue al máximo, no a la cantidad', () {
      // El caso que importa: si se numerara contando, borrar una prenda haría
      // que la siguiente reutilizara un código que ya estuvo impreso en una
      // etiqueta.
      expect(proximoCodigo(['MIR-001', 'MIR-007']), 'MIR-008');
    });

    test('ignora códigos de otro formato y nulos', () {
      expect(proximoCodigo(['ABC-99', null, 'sin formato', 'MIR-003']),
          'MIR-004');
    });

    test('no se confunde con otro prefijo', () {
      expect(proximoCodigo(['OTRO-500', 'MIR-002']), 'MIR-003');
    });

    test('respeta el prefijo que se le pase', () {
      expect(proximoCodigo(['VER-010'], prefijo: 'VER'), 'VER-011');
    });

    test('pasa de 999 sin romper', () {
      expect(proximoCodigo(['MIR-999']), 'MIR-1000');
    });
  });
}
