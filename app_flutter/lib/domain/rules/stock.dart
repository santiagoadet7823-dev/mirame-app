/// Reglas de stock. Portadas de `renderStock` y `adjQ` del `index.html`.
library;

import '../entities/entities.dart';

enum StockStatus { ok, low, out }

/// Estado de un producto. Puerto de:
///
/// ```js
/// const qty = +s.qty||0, min = +s.min||1;
/// const st = qty===0 ? 'out' : qty<=min ? 'low' : 'ok';
/// ```
///
/// El `|| 1` importa: un producto con mínimo 0 se trata como si tuviera mínimo
/// 1, así que tener exactamente 1 unidad lo marca como bajo.
StockStatus stockStatus(StockItem item) {
  final qty = item.cantidad;
  final min = item.minimo < 1 ? 1 : item.minimo;
  if (qty == 0) return StockStatus.out;
  if (qty <= min) return StockStatus.low;
  return StockStatus.ok;
}

/// Ancho de la barra de progreso, de 0 a 100. Puerto de:
///
/// ```js
/// const pct = Math.min(100, Math.round((qty / Math.max(min*2,1)) * 100));
/// ```
///
/// La barra se llena al **doble del mínimo**, no al mínimo: estar justo en el
/// mínimo se ve como media barra, que es la lectura correcta.
int stockBarPct(StockItem item) {
  final qty = item.cantidad;
  final min = item.minimo < 1 ? 1 : item.minimo;
  final divisor = min * 2 < 1 ? 1 : min * 2;
  return (qty / divisor * 100).round().clamp(0, 100);
}

/// Nueva cantidad tras un ajuste. Puerto de `adjQ`:
/// `it.qty = Math.max(0, (+it.qty||0) + d)`.
///
/// Nunca baja de cero.
///
/// **Importante para el sync:** este cálculo es solo para la UI optimista. Lo
/// que se encola es el DELTA, no este resultado, y el servidor vuelve a
/// aplicarlo con `ajustar_stock(item, delta)`. Si se subiera el valor absoluto,
/// dos ajustes concurrentes offline se pisarían y se perdería uno.
/// Ver `android/05-OFFLINE-SYNC.md` §7.2.
int adjustQuantity(int actual, int delta) {
  final n = actual + delta;
  return n < 0 ? 0 : n;
}

/// Productos a mostrar en las alertas del dashboard: **primero los agotados**,
/// después los bajos, cortando en [limit]. Puerto de `renderStockAlerts`.
List<StockItem> stockAlerts(Iterable<StockItem> items, {int limit = 3}) {
  final out = <StockItem>[];
  final low = <StockItem>[];
  for (final i in items) {
    switch (stockStatus(i)) {
      case StockStatus.out:
        out.add(i);
      case StockStatus.low:
        low.add(i);
      case StockStatus.ok:
        break;
    }
  }
  return [...out, ...low].take(limit).toList();
}

/// Filtro de la pantalla de stock.
///
/// Ojo con `low`: **excluye los que están en cero**. Un producto agotado no
/// aparece en "bajo stock", aparece en "sin stock". Es el comportamiento del
/// original y evita contarlo dos veces.
List<StockItem> filterStock(
  Iterable<StockItem> items, {
  String query = '',
  StockStatus? estado,
}) {
  final q = query.trim().toLowerCase();
  return items.where((i) {
    if (q.isNotEmpty && !i.nombre.toLowerCase().contains(q)) return false;
    if (estado == null) return true;
    return stockStatus(i) == estado;
  }).toList();
}
