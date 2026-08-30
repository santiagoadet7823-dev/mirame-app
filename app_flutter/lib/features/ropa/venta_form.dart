/// Cargar una venta de ropa.
///
/// Lo que la distingue de una venta común: **el reparto se ve mientras se
/// carga**, no después. Saber que de $20.000 le quedan $6.000 antes de
/// confirmar es lo que permite decidir un descuento con criterio, y es
/// justamente la cuenta que en papel nadie hace en el momento.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../data/local/database.dart' as db;
import '../../data/repositories/ropa_repository.dart';
import '../../domain/rules/consignacion.dart';
import '../../domain/rules/formatting.dart';
import '../dashboard/dashboard_view.dart';
import '../shell/vistas_comunes.dart';
import 'ropa_view.dart';

Future<void> abrirVenta(BuildContext context, {db.ProductoVariante? variante}) =>
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _FormVenta(inicial: variante),
    );

/// Una línea del carrito mientras se arma la venta.
class _Linea {
  _Linea({required this.variante, required this.producto});

  final db.ProductoVariante variante;
  final db.Producto producto;

  /// Siempre arranca en 1 y sube con el botón: nadie tipea la cantidad en un
  /// mostrador.
  int cantidad = 1;
}

class _FormVenta extends ConsumerStatefulWidget {
  const _FormVenta({this.inicial});

  final db.ProductoVariante? inicial;

  @override
  ConsumerState<_FormVenta> createState() => _FormVentaState();
}

class _FormVentaState extends ConsumerState<_FormVenta> {
  final _descuento = TextEditingController();
  final _notas = TextEditingController();
  final _lineas = <_Linea>[];

  String? _depositoId;
  String? _clientId;
  String _metodo = 'efectivo';
  var _guardando = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final deps = ref.read(depositosProvider).value ?? const [];
    // El principal por defecto: es donde está casi toda la mercadería.
    _depositoId = deps.isEmpty
        ? null
        : (deps.firstWhere((d) => d.esPrincipal, orElse: () => deps.first)).id;

    if (widget.inicial case final v?) {
      final p = (ref.read(productosProvider).value ?? const [])
          .where((x) => x.id == v.productoId);
      if (p.isNotEmpty) {
        _lineas.add(_Linea(variante: v, producto: p.first));
      }
    }
  }

  @override
  void dispose() {
    _descuento.dispose();
    _notas.dispose();
    super.dispose();
  }

  /// El reparto de toda la venta, recalculado en cada cambio.
  RepartoVenta get _reparto {
    final proveedores = ref.read(proveedoresProvider).value ?? const [];
    final descuento = num.tryParse(_descuento.text.replaceAll(',', '.')) ?? 0;
    final bruto = _lineas.fold<num>(
        0, (a, l) => a + l.producto.precio * l.cantidad);

    return repartirVenta([
      for (final l in _lineas)
        () {
          final prov = proveedores
              .where((p) => p.id == l.producto.proveedorId)
              .firstOrNull;
          // El porcentaje del producto pisa al del proveedor; si no hay
          // ninguno, se asume que la prenda es propia y queda todo en casa.
          final pct = l.producto.pctSalon ?? prov?.pctSalon ?? 100;
          final suBruto = l.producto.precio * l.cantidad;
          return repartirItem(
            precioUnitario: l.producto.precio,
            cantidad: l.cantidad,
            // El descuento se reparte según cuánto pesa cada línea: cargarlo
            // entero a la primera deformaría la liquidación de ese proveedor.
            descuento: bruto == 0 ? 0 : descuento * (suBruto / bruto),
            pctSalon: pct,
            descuentoLoAbsorbeSalon: prov?.descuentoLoAbsorbeSalon ?? true,
          );
        }(),
    ]);
  }

  Future<void> _guardar() async {
    if (_lineas.isEmpty) {
      setState(() => _error = 'Agregá al menos una prenda');
      return;
    }
    if (_depositoId == null) {
      setState(() => _error = 'Creá un depósito antes de vender');
      return;
    }

    final repo = ref.read(ropaRepoProvider);
    if (repo == null) return;
    final proveedores = ref.read(proveedoresProvider).value ?? const [];

    setState(() {
      _guardando = true;
      _error = null;
    });
    final nav = Navigator.of(context);

    try {
      await repo.registrarVenta(
        depositoId: _depositoId!,
        clientId: _clientId,
        descuento: num.tryParse(_descuento.text.replaceAll(',', '.')) ?? 0,
        metodo: _metodo,
        notas: _notas.text.trim().isEmpty ? null : _notas.text.trim(),
        items: [
          for (final l in _lineas)
            () {
              final prov = proveedores
                  .where((p) => p.id == l.producto.proveedorId)
                  .firstOrNull;
              return ItemParaVender(
                varianteId: l.variante.id,
                descripcion: [
                  l.producto.nombre,
                  if (l.variante.talle case final t?) t,
                  if (l.variante.color case final c?) c,
                ].join(' · '),
                cantidad: l.cantidad,
                precioUnit: l.producto.precio,
                pctSalon: l.producto.pctSalon ?? prov?.pctSalon ?? 100,
                descuentoLoAbsorbeSalon:
                    prov?.descuentoLoAbsorbeSalon ?? true,
              );
            }(),
        ],
      );
      nav.pop();
    } catch (_) {
      if (mounted) {
        setState(() {
          _guardando = false;
          _error = 'No se pudo guardar la venta';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final clientes = ref.watch(clientesProvider).value ?? const [];
    final depositos = ref.watch(depositosProvider).value ?? const [];
    final r = _reparto;

    return SheetFormulario(
      titulo: 'Nueva venta',
      guardando: _guardando,
      error: _error,
      onGuardar: _guardar,
      campos: [
        // ── Las prendas ────────────────────────────────────────────────
        for (var i = 0; i < _lineas.length; i++)
          _FilaLinea(
            linea: _lineas[i],
            onMas: () => setState(() => _lineas[i].cantidad++),
            onMenos: () => setState(() {
              if (_lineas[i].cantidad > 1) {
                _lineas[i].cantidad--;
              } else {
                _lineas.removeAt(i);
              }
            }),
          ),
        Align(
          alignment: Alignment.centerLeft,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _elegirPrenda,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text('+ Agregar prenda',
                  style: sans(size: 13, weight: 600, color: MColors.brand)),
            ),
          ),
        ),

        if (_lineas.isNotEmpty) ...[
          const SizedBox(height: 6),
          _CajaReparto(reparto: r),
          const SizedBox(height: 14),
        ],

        // ── El cobro ───────────────────────────────────────────────────
        Row(
          children: [
            Expanded(
              child: CampoTexto(
                controlador: _descuento,
                etiqueta: 'Descuento',
                teclado: TextInputType.number,
                onCambio: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: DropdownButtonFormField<String>(
                  initialValue: _metodo,
                  decoration: _deco('Cómo paga'),
                  items: const [
                    DropdownMenuItem(
                        value: 'efectivo', child: Text('Efectivo')),
                    DropdownMenuItem(
                        value: 'transferencia', child: Text('Transferencia')),
                    DropdownMenuItem(
                        value: 'tarjeta', child: Text('Tarjeta')),
                  ],
                  onChanged: (v) => setState(() => _metodo = v ?? 'efectivo'),
                ),
              ),
            ),
          ],
        ),

        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: DropdownButtonFormField<String?>(
            initialValue: _clientId,
            isExpanded: true,
            decoration: _deco('Clienta (opcional)'),
            items: [
              const DropdownMenuItem(value: null, child: Text('Sin asignar')),
              for (final c in clientes)
                DropdownMenuItem(value: c.id, child: Text(c.nombre)),
            ],
            onChanged: (v) => setState(() => _clientId = v),
          ),
        ),

        if (depositos.length > 1)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: DropdownButtonFormField<String?>(
              initialValue: _depositoId,
              isExpanded: true,
              decoration: _deco('Depósito'),
              items: [
                for (final d in depositos)
                  DropdownMenuItem(value: d.id, child: Text(d.nombre)),
              ],
              onChanged: (v) => setState(() => _depositoId = v),
            ),
          ),

        CampoTexto(controlador: _notas, etiqueta: 'Notas', lineas: 2),
      ],
    );
  }

  InputDecoration _deco(String etiqueta) => InputDecoration(
        labelText: etiqueta,
        labelStyle: MText.menor,
        filled: true,
        fillColor: MColors.bg2,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(MRadius.md),
          borderSide: const BorderSide(color: MColors.border),
        ),
      );

  Future<void> _elegirPrenda() async {
    final elegida = await showModalBottomSheet<
        ({db.ProductoVariante variante, db.Producto producto})>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const _SelectorPrenda(),
    );
    if (elegida == null || !mounted) return;

    setState(() {
      // Si ya está en el carrito se suma una unidad en vez de repetir la
      // línea: dos filas iguales confunden al revisar el total.
      final ya = _lineas
          .where((l) => l.variante.id == elegida.variante.id)
          .firstOrNull;
      if (ya != null) {
        ya.cantidad++;
      } else {
        _lineas.add(
            _Linea(variante: elegida.variante, producto: elegida.producto));
      }
    });
  }
}

class _FilaLinea extends StatelessWidget {
  const _FilaLinea({
    required this.linea,
    required this.onMas,
    required this.onMenos,
  });

  final _Linea linea;
  final VoidCallback onMas;
  final VoidCallback onMenos;

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: MColors.bg2,
          borderRadius: BorderRadius.circular(MRadius.sm),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(linea.producto.nombre,
                      style: sans(size: 13, weight: 600),
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(
                    [
                      if (linea.variante.talle case final t?) t,
                      if (linea.variante.color case final c?) c,
                      formatMoney(linea.producto.precio),
                    ].join(' · '),
                    style: sans(size: 11, color: MColors.tMuted),
                  ),
                ],
              ),
            ),
            _boton(Icons.remove_rounded, onMenos),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text('${linea.cantidad}',
                  style: sans(size: 14, weight: 600)),
            ),
            _boton(Icons.add_rounded, onMas),
          ],
        ),
      );

  Widget _boton(IconData icono, VoidCallback onTap) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: MColors.surface,
            border: Border.all(color: MColors.border),
            borderRadius: BorderRadius.circular(MRadius.sm),
          ),
          child: Icon(icono, size: 15, color: MColors.tSecondary),
        ),
      );
}

/// El reparto, a la vista antes de confirmar.
class _CajaReparto extends StatelessWidget {
  const _CajaReparto({required this.reparto});

  final RepartoVenta reparto;

  @override
  Widget build(BuildContext context) {
    // Si el salón queda en negativo es porque un descuento se comió la
    // ganancia. El número se muestra en rojo, no se esconde: es exactamente
    // el aviso que evita repetir ese descuento.
    final enPerdida = reparto.salon < 0;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: enPerdida ? MColors.dangerBg : MColors.lav50,
        border: Border.all(
            color: enPerdida ? MColors.dangerBorder : MColors.borderLav),
        borderRadius: BorderRadius.circular(MRadius.md),
      ),
      child: Column(
        children: [
          _fila('Cobrás', reparto.neto, destacado: true),
          const SizedBox(height: 7),
          _fila('Para el proveedor', reparto.proveedor),
          const SizedBox(height: 5),
          _fila(
            enPerdida ? 'Te queda (en pérdida)' : 'Te queda',
            reparto.salon,
            color: enPerdida ? MColors.dangerText : MColors.successText,
            destacado: true,
          ),
          if (reparto.vendedor > 0) ...[
            const SizedBox(height: 5),
            _fila('Comisión del vendedor', reparto.vendedor),
          ],
        ],
      ),
    );
  }

  Widget _fila(String etiqueta, num monto,
          {Color? color, bool destacado = false}) =>
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(etiqueta,
              style: sans(
                  size: destacado ? 13 : 12,
                  weight: destacado ? 600 : 400,
                  color: MColors.tSecondary)),
          Text(formatMoney(monto),
              style: sans(
                  size: destacado ? 15 : 13,
                  weight: destacado ? 700 : 500,
                  color: color ?? MColors.tPrimary)),
        ],
      );
}

/// Buscador de prendas con stock, para agregar al carrito.
class _SelectorPrenda extends ConsumerStatefulWidget {
  const _SelectorPrenda();

  @override
  ConsumerState<_SelectorPrenda> createState() => _SelectorPrendaState();
}

class _SelectorPrendaState extends ConsumerState<_SelectorPrenda> {
  final _busqueda = TextEditingController();

  @override
  void dispose() {
    _busqueda.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productos = ref.watch(productosProvider).value ?? const [];
    final variantes = ref.watch(variantesProvider).value ?? const {};
    final stock = ref.watch(stockRopaProvider).value ?? const {};
    final texto = _busqueda.text.trim().toLowerCase();

    // Se listan VARIANTES y no productos: lo que se vende es un talle
    // concreto, y elegir "el vestido" para después elegir el talle es un paso
    // de más en el mostrador.
    final opciones = <({db.Producto p, db.ProductoVariante v, int stock})>[];
    for (final p in productos) {
      if (texto.isNotEmpty &&
          !p.nombre.toLowerCase().contains(texto) &&
          !(p.codigo ?? '').toLowerCase().contains(texto)) {
        continue;
      }
      for (final v in variantes[p.id] ?? const <db.ProductoVariante>[]) {
        opciones.add((p: p, v: v, stock: stock[v.id] ?? 0));
      }
    }

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.8,
      ),
      decoration: const BoxDecoration(
        color: MColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(MRadius.xl)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Elegí la prenda', style: serif(size: 18, weight: 600)),
            const SizedBox(height: 12),
            CampoTexto(
              controlador: _busqueda,
              etiqueta: 'Buscar por nombre o código',
              autofocus: true,
              onCambio: (_) => setState(() {}),
            ),
            Flexible(
              child: opciones.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Text('Nada con esa búsqueda',
                          textAlign: TextAlign.center,
                          style: sans(size: 13, color: MColors.tMuted)),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: opciones.length,
                      itemBuilder: (_, i) {
                        final o = opciones[i];
                        final sinStock = o.stock <= 0;
                        return GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          // Sin stock no se puede vender: dejarlo pasar
                          // dejaría el inventario en negativo y la prenda
                          // aparecería disponible en la vitrina.
                          onTap: sinStock
                              ? null
                              : () => Navigator.of(context)
                                  .pop((variante: o.v, producto: o.p)),
                          child: Opacity(
                            opacity: sinStock ? 0.4 : 1,
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 7),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 11),
                              decoration: BoxDecoration(
                                color: MColors.bg2,
                                borderRadius:
                                    BorderRadius.circular(MRadius.sm),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(o.p.nombre,
                                            style:
                                                sans(size: 13, weight: 600),
                                            overflow:
                                                TextOverflow.ellipsis),
                                        const SizedBox(height: 2),
                                        Text(
                                          [
                                            if (o.v.talle case final t?) t,
                                            if (o.v.color case final c?) c,
                                            sinStock
                                                ? 'sin stock'
                                                : '${o.stock} disponibles',
                                          ].join(' · '),
                                          style: sans(
                                              size: 11,
                                              color: sinStock
                                                  ? MColors.dangerText
                                                  : MColors.tMuted),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(formatMoney(o.p.precio),
                                      style: sans(size: 13, weight: 600)),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
