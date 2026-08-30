/// El reparto de la plata en una venta a consignación.
///
/// Dart puro y sin efectos: es la parte del módulo de ropa que más duele si se
/// rompe, porque un error acá no se ve — se ve tres meses después, cuando una
/// liquidación no cuadra y nadie sabe de qué venta salió la diferencia.
///
/// **El reparto va a tres puntas:**
///
/// 1. El **proveedor** cobra su parte del precio de venta. Entregó la
///    mercadería y su corte está cerrado de antemano.
/// 2. Lo que queda es del **salón**.
/// 3. Si vendió un **vendedor**, su comisión sale de la parte del salón, no
///    del total: el proveedor ya cobró lo suyo y no tiene por qué financiar a
///    alguien que no contrató.
library;

import '../entities/ropa.dart';

/// Lo que le toca a cada uno en un ítem vendido.
class RepartoItem {
  const RepartoItem({
    required this.bruto,
    required this.descuento,
    required this.neto,
    required this.proveedor,
    required this.salon,
    required this.vendedor,
  });

  /// Precio de lista por la cantidad, antes de descuentos.
  final num bruto;

  /// Lo que se rebajó en este ítem.
  final num descuento;

  /// Lo que realmente entra en caja por este ítem.
  final num neto;

  final num proveedor;

  /// Lo que le queda al salón **después** de pagarle al vendedor.
  final num salon;

  final num vendedor;

  /// Control: las tres partes tienen que sumar exactamente el neto.
  bool get cuadra => (proveedor + salon + vendedor - neto).abs() < 0.005;
}

/// Calcula el reparto de un ítem.
///
/// [pctSalon] es el porcentaje que se queda el salón (el resto es del
/// proveedor). [pctVendedor] se aplica **sobre la parte del salón**.
///
/// [descuentoLoAbsorbeSalon] decide de dónde sale una rebaja:
///   · `true`  (lo normal en consignación) — el proveedor cobra su porcentaje
///     sobre el precio de LISTA y la rebaja sale del bolsillo del salón. Es lo
///     justo: el proveedor no participó de la decisión de rebajar.
///   · `false` — los dos ponen, cada uno en su proporción.
///
/// El caso feo que esto contempla: con un descuento grande y el proveedor
/// cobrando sobre lista, la parte del salón puede volverse **negativa**. No se
/// recorta a cero a propósito — que el número muestre la pérdida es
/// exactamente lo que hace que no se repita el descuento.
RepartoItem repartirItem({
  required num precioUnitario,
  int cantidad = 1,
  num descuento = 0,
  required num pctSalon,
  num pctVendedor = 0,
  bool descuentoLoAbsorbeSalon = true,
}) {
  final bruto = precioUnitario * cantidad;
  // Un descuento mayor que el total sería un error de carga; se recorta en vez
  // de generar un neto negativo que después contamina toda la liquidación.
  final desc = descuento.clamp(0, bruto == 0 ? 0 : bruto);
  final neto = bruto - desc;

  final pS = pctSalon.clamp(0, 100) / 100;
  final pV = pctVendedor.clamp(0, 100) / 100;

  // Sobre qué monto cobra el proveedor.
  final baseProveedor = descuentoLoAbsorbeSalon ? bruto : neto;
  final proveedor = _redondear(baseProveedor * (1 - pS));

  // Lo que queda para el salón, del neto real.
  final quedaEnCasa = neto - proveedor;
  // La comisión sale de la parte del salón. Si esa parte es negativa (un
  // descuento se comió la ganancia), el vendedor NO paga por ese error: cobra
  // sobre cero, no una comisión negativa.
  final vendedor = _redondear((quedaEnCasa > 0 ? quedaEnCasa : 0) * pV);

  return RepartoItem(
    bruto: bruto,
    descuento: desc,
    neto: neto,
    proveedor: proveedor,
    // Se despeja para que la suma cierre EXACTA aunque el redondeo de las
    // otras dos partes haya movido algún centavo.
    salon: _redondear(neto - proveedor - vendedor),
    vendedor: vendedor,
  );
}

/// Totales de una venta completa.
class RepartoVenta {
  const RepartoVenta({
    required this.items,
    required this.neto,
    required this.proveedor,
    required this.salon,
    required this.vendedor,
  });

  final List<RepartoItem> items;
  final num neto;
  final num proveedor;
  final num salon;
  final num vendedor;

  bool get cuadra => (proveedor + salon + vendedor - neto).abs() < 0.005;
}

RepartoVenta repartirVenta(Iterable<RepartoItem> items) {
  final lista = items.toList();
  num s(num Function(RepartoItem) f) =>
      _redondear(lista.fold<num>(0, (a, i) => a + f(i)));

  return RepartoVenta(
    items: lista,
    neto: s((i) => i.neto),
    proveedor: s((i) => i.proveedor),
    salon: s((i) => i.salon),
    vendedor: s((i) => i.vendedor),
  );
}

/// Lo que hay que pagarle a alguien en un período.
class Liquidacion {
  const Liquidacion({required this.total, required this.items});

  final num total;

  /// Los ítems incluidos. Se guardan para poder marcarlos como liquidados y no
  /// pagarlos dos veces.
  final List<String> items;
}

/// Suma lo pendiente de un proveedor o de un vendedor.
///
/// [montoDe] saca del ítem la parte que le corresponde a quien se liquida, y
/// [idDe] su identificador. Que la función no sepa si liquida a un proveedor o
/// a un vendedor es a propósito: es la misma cuenta y duplicarla sería tener
/// dos lugares donde arreglar el mismo error.
Liquidacion liquidar<T>({
  required Iterable<T> items,
  required num Function(T) montoDe,
  required String Function(T) idDe,
}) {
  final incluidos = <String>[];
  num total = 0;
  for (final i in items) {
    final m = montoDe(i);
    // Los de monto cero no se listan: ensucian el comprobante sin cambiar el
    // número.
    if (m == 0) continue;
    total += m;
    incluidos.add(idDe(i));
  }
  return Liquidacion(total: _redondear(total), items: incluidos);
}

/// Dos decimales. La plata no se guarda con la basura binaria de un double:
/// `0.1 + 0.2` da `0.30000000000000004`, y sumado sobre cien ventas eso se
/// convierte en una diferencia real en la liquidación.
num _redondear(num n) => (n * 100).round() / 100;

// ─────────────────────────────────────────────────────────────────────────────
// Detalle para el comprobante
// ─────────────────────────────────────────────────────────────────────────────

/// Una línea del comprobante de liquidación.
///
/// Lleva TODO lo necesario para que el proveedor pueda auditarla sin la app:
/// qué prenda, cuándo se vendió, a cuánto, qué porcentaje se aplicó y cuánto
/// le toca. Un comprobante que solo diga "te debo $180.000" no sirve para
/// resolver una discusión, que es justo para lo que se usa.
class FilaLiquidacion {
  const FilaLiquidacion({
    required this.itemId,
    required this.fecha,
    required this.prenda,
    required this.cantidad,
    required this.precioUnit,
    required this.pct,
    required this.monto,
    this.codigo,
    this.variante,
  });

  final String itemId;
  final DateTime fecha;
  final String prenda;
  final String? codigo;

  /// `M · Negro`
  final String? variante;
  final int cantidad;
  final num precioUnit;

  /// El porcentaje que se le aplicó, congelado al momento de la venta.
  final num pct;
  final num monto;
}

class DetalleLiquidacion {
  const DetalleLiquidacion({
    required this.destinatario,
    required this.tipo,
    required this.desde,
    required this.hasta,
    required this.filas,
    required this.total,
  });

  final String destinatario;
  final LiquidacionTipo tipo;
  final DateTime desde;
  final DateTime hasta;
  final List<FilaLiquidacion> filas;
  final num total;

  int get prendas => filas.fold(0, (a, f) => a + f.cantidad);
}

/// Arma el comprobante a partir de las filas ya resueltas.
DetalleLiquidacion armarDetalle({
  required String destinatario,
  required LiquidacionTipo tipo,
  required DateTime desde,
  required DateTime hasta,
  required Iterable<FilaLiquidacion> filas,
}) {
  // De la más vieja a la más nueva: así se lee como un extracto bancario, que
  // es la forma en que la gente espera revisar una cuenta.
  final lista = filas.toList()..sort((a, b) => a.fecha.compareTo(b.fecha));
  return DetalleLiquidacion(
    destinatario: destinatario,
    tipo: tipo,
    desde: desde,
    hasta: hasta,
    filas: lista,
    total: _redondear(lista.fold<num>(0, (a, f) => a + f.monto)),
  );
}
