/// Qué prendas están dormidas y qué código le toca a la próxima.
///
/// En consignación, una prenda que no rota es plata quieta: ocupa lugar, el
/// proveedor la reclama, y cuanto más tarde se detecta menos margen queda para
/// rematarla o devolverla. Esta es la regla que la hace visible.
library;

import '../entities/ropa.dart';

/// A partir de cuántos días sin vender una prenda se considera estancada.
///
/// 45 días es aproximadamente una temporada y media de rotación de indumentaria:
/// suficiente para no alarmar por algo que recién entró, poco para reaccionar
/// antes de que se pase de moda.
const kDiasParaEstancarse = 45;

class Estancada {
  const Estancada({
    required this.producto,
    required this.diasSinVender,
    required this.stock,
    required this.ultimaVenta,
  });

  final Producto producto;

  /// Días desde la última venta, o desde que entró si nunca se vendió.
  final int diasSinVender;

  /// Cuántas unidades siguen sin salir.
  final int stock;

  /// Null si nunca se vendió una.
  final DateTime? ultimaVenta;

  bool get nuncaSeVendio => ultimaVenta == null;

  /// Plata inmovilizada a precio de venta.
  num get capitalQuieto => producto.precio * stock;

  String get etiqueta => nuncaSeVendio
      ? 'Nunca se vendió · hace ${diasSinVender}d que entró'
      : 'Última venta hace ${diasSinVender}d';
}

/// Las prendas que hay que mirar, de la más dormida a la menos.
///
/// [ultimaVentaPorProducto] y [stockPorProducto] llegan resueltos porque
/// calcularlos exige cruzar tres tablas, y esta función tiene que poder
/// testearse sin base de datos.
///
/// Solo entra lo que **todavía tiene stock**: una prenda agotada hace dos meses
/// no es un problema, es una prenda vendida.
List<Estancada> prendasEstancadas({
  required Iterable<Producto> productos,
  required Map<String, DateTime> ultimaVentaPorProducto,
  required Map<String, int> stockPorProducto,
  required DateTime hoy,
  int dias = kDiasParaEstancarse,
}) {
  final out = <Estancada>[];

  for (final p in productos) {
    final stock = stockPorProducto[p.id] ?? 0;
    if (stock <= 0) continue;

    final ultima = ultimaVentaPorProducto[p.id];
    // Sin ventas se mide desde que entró al catálogo. Si tampoco hay fecha de
    // alta no se puede afirmar nada, y se prefiere callar antes que inventar
    // una antigüedad.
    final referencia = ultima ?? p.creadoEl;
    if (referencia == null) continue;

    final d = _diasEntre(referencia, hoy);
    if (d < dias) continue;

    out.add(Estancada(
      producto: p,
      diasSinVender: d,
      stock: stock,
      ultimaVenta: ultima,
    ));
  }

  // Las más dormidas arriba. A igualdad de días, primero la que tiene más
  // plata parada: es la que conviene mover.
  out.sort((a, b) {
    final porDias = b.diasSinVender.compareTo(a.diasSinVender);
    return porDias != 0
        ? porDias
        : b.capitalQuieto.compareTo(a.capitalQuieto);
  });
  return out;
}

/// Días completos entre dos fechas, ignorando la hora.
int _diasEntre(DateTime desde, DateTime hasta) =>
    DateTime(hasta.year, hasta.month, hasta.day)
        .difference(DateTime(desde.year, desde.month, desde.day))
        .inDays;

/// El próximo código libre con el prefijo dado: `MIR-001`, `MIR-002`…
///
/// Se numera a partir del **máximo existente** y no de la cantidad de
/// productos: contando, borrar una prenda haría que la siguiente reutilizara
/// un código que ya estuvo impreso en una etiqueta.
String proximoCodigo(Iterable<String?> codigosUsados, {String prefijo = 'MIR'}) {
  var maximo = 0;
  final patron = RegExp('^${RegExp.escape(prefijo)}-(\\d+)\$', caseSensitive: false);

  for (final c in codigosUsados) {
    if (c == null) continue;
    final m = patron.firstMatch(c.trim());
    if (m == null) continue;
    final n = int.tryParse(m.group(1)!);
    if (n != null && n > maximo) maximo = n;
  }

  return '$prefijo-${(maximo + 1).toString().padLeft(3, '0')}';
}
