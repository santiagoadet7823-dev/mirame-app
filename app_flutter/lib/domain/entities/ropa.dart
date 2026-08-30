/// Entidades del módulo de ropa. Dart puro: sin Flutter, sin Drift, sin
/// Supabase.
library;

enum VentaEstado { completada, anulada }

enum ReservaEstado { pendiente, confirmada, entregada, cancelada }

enum LiquidacionTipo {
  proveedor,
  vendedor;

  String get etiqueta =>
      this == LiquidacionTipo.proveedor ? 'Proveedor' : 'Vendedor';

  /// Qué representa el monto para quien lo recibe. Va en el comprobante.
  String get concepto => this == LiquidacionTipo.proveedor
      ? 'Por la mercadería vendida en el período'
      : 'Comisiones por las ventas del período';
}

enum LiquidacionEstado { borrador, pagada }

/// Por qué se movió el stock. Es lo que permite responder "¿qué pasó con esta
/// prenda?" sin reconstruirlo de otras tablas.
enum MotivoStock {
  ingreso,
  venta,
  devolucionProveedor,
  transferencia,
  ajuste,
  anulacion;

  /// El valor exacto del enum de Postgres. `devolucion_proveedor` no coincide
  /// con el `name` de Dart, y mandar el nombre camelCase haría que el servidor
  /// rechace la fila y quede dando vueltas en el outbox sin que nadie se
  /// entere.
  String get sql => switch (this) {
        MotivoStock.devolucionProveedor => 'devolucion_proveedor',
        _ => name,
      };

  static MotivoStock desdeSql(String v) => switch (v) {
        'devolucion_proveedor' => MotivoStock.devolucionProveedor,
        'ingreso' => MotivoStock.ingreso,
        'venta' => MotivoStock.venta,
        'transferencia' => MotivoStock.transferencia,
        'anulacion' => MotivoStock.anulacion,
        _ => MotivoStock.ajuste,
      };

  String get etiqueta => switch (this) {
        MotivoStock.ingreso => 'Ingreso',
        MotivoStock.venta => 'Venta',
        MotivoStock.devolucionProveedor => 'Devolución al proveedor',
        MotivoStock.transferencia => 'Transferencia',
        MotivoStock.ajuste => 'Ajuste',
        MotivoStock.anulacion => 'Anulación',
      };
}

class Proveedor {
  const Proveedor({
    required this.id,
    required this.nombre,
    this.telefono,
    this.email,
    this.pctSalon = 30,
    this.descuentoLoAbsorbeSalon = true,
    this.notas,
    this.activo = true,
  });

  final String id;
  final String nombre;
  final String? telefono;
  final String? email;

  /// Porcentaje que se queda EL SALÓN. El resto es del proveedor.
  final num pctSalon;
  final bool descuentoLoAbsorbeSalon;
  final String? notas;
  final bool activo;
}

class Deposito {
  const Deposito({
    required this.id,
    required this.nombre,
    this.direccion,
    this.esPrincipal = false,
  });

  final String id;
  final String nombre;
  final String? direccion;
  final bool esPrincipal;
}

class Producto {
  const Producto({
    required this.id,
    required this.nombre,
    this.proveedorId,
    this.descripcion,
    this.categoria,
    this.codigo,
    this.precio = 0,
    this.pctSalon,
    this.publicado = false,
    this.destacado = false,
    this.creadoEl,
  });

  final String id;
  final String nombre;
  final String? proveedorId;
  final String? descripcion;
  final String? categoria;

  /// Código corto tipo `MIR-042`.
  final String? codigo;
  final num precio;

  /// Pisa el del proveedor cuando este producto tiene otro acuerdo.
  final num? pctSalon;
  final bool publicado;
  final bool destacado;
  final DateTime? creadoEl;
}

class Variante {
  const Variante({
    required this.id,
    required this.productoId,
    this.talle,
    this.color,
    this.sku,
  });

  final String id;
  final String productoId;
  final String? talle;
  final String? color;
  final String? sku;

  /// `M · Negro`, o solo lo que haya. Lo usa la etiqueta de cada fila.
  String get etiqueta =>
      [talle, color].where((s) => s != null && s.isNotEmpty).join(' · ');
}

class Foto {
  const Foto({
    required this.id,
    required this.productoId,
    required this.path,
    this.varianteId,
    this.orden = 0,
    this.pendienteDeSubir = false,
    this.rutaLocal,
  });

  final String id;
  final String productoId;
  final String? varianteId;
  final String path;
  final int orden;

  /// Mientras sea true, la ficha muestra "falta subir" en vez de una imagen
  /// rota: una foto no se puede encolar como una fila de texto.
  final bool pendienteDeSubir;
  final String? rutaLocal;
}

class VentaRopa {
  const VentaRopa({
    required this.id,
    required this.fecha,
    this.depositoId,
    this.vendedorId,
    this.clientId,
    this.total = 0,
    this.descuento = 0,
    this.metodo = 'efectivo',
    this.estado = VentaEstado.completada,
    this.notas,
  });

  final String id;
  final DateTime fecha;
  final String? depositoId;
  final String? vendedorId;
  final String? clientId;
  final num total;
  final num descuento;
  final String metodo;
  final VentaEstado estado;
  final String? notas;
}

class ItemVendido {
  const ItemVendido({
    required this.id,
    required this.ventaId,
    this.varianteId,
    this.descripcion,
    this.cantidad = 1,
    this.precioUnit = 0,
    this.pctSalon = 0,
    this.pctVendedor = 0,
    this.montoProveedor = 0,
    this.montoSalon = 0,
    this.montoVendedor = 0,
    this.liquidacionId,
  });

  final String id;
  final String ventaId;
  final String? varianteId;
  final String? descripcion;
  final int cantidad;
  final num precioUnit;

  /// Congelados al momento de vender. Ver `rules/consignacion.dart`.
  final num pctSalon;
  final num pctVendedor;
  final num montoProveedor;
  final num montoSalon;
  final num montoVendedor;

  /// Null = todavía no se liquidó.
  final String? liquidacionId;
}

class Reserva {
  const Reserva({
    required this.id,
    required this.codigo,
    required this.nombre,
    required this.venceAt,
    this.telefono,
    this.estado = ReservaEstado.pendiente,
    this.notas,
  });

  final String id;

  /// Corto y legible: la clienta lo dice por WhatsApp o lo muestra al retirar.
  final String codigo;
  final String nombre;
  final String? telefono;
  final ReservaEstado estado;
  final DateTime venceAt;
  final String? notas;

  bool vigenteAl(DateTime ahora) =>
      venceAt.isAfter(ahora) &&
      (estado == ReservaEstado.pendiente ||
          estado == ReservaEstado.confirmada);
}
