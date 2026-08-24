/// Stock: qué hay, qué falta y ajuste rápido.
///
/// Los ajustes van **por delta** (`+1` / `−1`), no por valor absoluto: es la
/// única excepción al last-write-wins del sync. Ver `business_repository`.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/motion.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../data/local/database.dart' as db;
import '../../data/local/mappers.dart';
import '../../data/repositories/business_repository.dart';
import '../../domain/entities/entities.dart';
import '../../domain/rules/access.dart';
import '../../domain/rules/stock.dart';
import '../auth/session_controller.dart';
import '../shell/app_shell.dart';
import '../shell/vistas_comunes.dart';

final stockProvider = StreamProvider.autoDispose<List<db.StockItem>>((ref) {
  final repo = ref.watch(businessRepoProvider);
  if (repo == null) return const Stream.empty();
  return repo.verStock();
});

class StockView extends ConsumerStatefulWidget {
  const StockView({super.key});

  @override
  ConsumerState<StockView> createState() => _StockViewState();
}

class _StockViewState extends ConsumerState<StockView> {
  String _filtro = 'all';

  @override
  Widget build(BuildContext context) {
    final filas = ref.watch(stockProvider).value ?? const <db.StockItem>[];
    final todos = filas.map(aStockItem).toList();
    // Las alertas se cuentan sobre TODO el stock, no sobre lo filtrado: si no,
    // filtrar por "sin stock" haría desaparecer el aviso de los que están bajos.
    final alertas = stockAlerts(todos, limit: 99);
    final items = switch (_filtro) {
      'low' => todos.where((i) => stockStatus(i) == StockStatus.low).toList(),
      'out' => todos.where((i) => stockStatus(i) == StockStatus.out).toList(),
      _ => todos,
    };
    final puedeEscribir = ref.watch(puedeProvider(Permiso.escribirDatos));

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: puedeEscribir
          ? Padding(
              // `bottom: 80px + safe` y `right: 18px` del CSS. El
              // Scaffold ya separa 16 del borde, así que acá van 2.
              padding: const EdgeInsets.only(right: 2, bottom: 8),
              child: FabMirame(onTap: () => _mostrarFormulario(context, ref)),
            )
          : null,
      body: ListView(
        padding: padVistaMovil,
        children: [
          if (alertas.isNotEmpty) ...[
            FadeSlideIn(
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: MColors.warningBg,
                  borderRadius: BorderRadius.circular(MRadius.md),
                ),
                child: Row(
                  children: [
                    const Text('⚠️', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '${alertas.length} '
                        '${alertas.length == 1 ? "producto está" : "productos están"}'
                        ' por debajo del mínimo',
                        style: sans(
                            size: 13,
                            weight: 600,
                            color: MColors.warningText),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
          ],
          if (todos.isNotEmpty) ...[
            FadeSlideIn(
              child: FilaFiltros(
                opciones: const [
                  ('all', 'Todos'),
                  ('low', 'Bajo stock'),
                  ('out', 'Sin stock'),
                ],
                activo: _filtro,
                onElegir: (f) => setState(() => _filtro = f),
              ),
            ),
            const SizedBox(height: 12),
          ],
          if (items.isEmpty)
            EstadoVacio(
              emoji: '📦',
              titulo: _filtro == 'all' ? 'Sin productos' : 'Nada por acá',
              detalle: _filtro == 'all'
                  ? 'Agregá productos al inventario'
                  : 'Ningún producto en este estado',
            )
          else
            for (var i = 0; i < items.length; i++)
              FadeSlideIn(
                delay: Duration(milliseconds: (i < 8 ? i : 8) * 35),
                child: _FilaStock(item: items[i], puedeEscribir: puedeEscribir),
              ),
        ],
      ),
    );
  }
}

/// `.stk-item` — ícono de categoría, nombre, categoría, chip de alerta,
/// barra de nivel, y a la derecha la cantidad grande con los botones ± .
///
/// La columna derecha es la diferencia con una lista cualquiera: el número en
/// 20px y en negrita es lo que se mira de reojo para saber si falta algo.
class _FilaStock extends ConsumerWidget {
  const _FilaStock({required this.item, required this.puedeEscribir});

  final StockItem item;
  final bool puedeEscribir;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estado = stockStatus(item);
    final colorBarra = switch (estado) {
      StockStatus.out => MColors.stockOut,
      StockStatus.low => MColors.stockLow,
      StockStatus.ok => MColors.stockOk,
    };
    final colorNumero = switch (estado) {
      StockStatus.out => MColors.dangerText,
      StockStatus.low => MColors.warningText,
      StockStatus.ok => MColors.tPrimary,
    };

    return TarjetaMirame(
      margenInferior: 8,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      onTap: () => _mostrarFormulario(context, ref, item: item),
      hijo: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: MColors.bg2,
              border: Border.all(color: MColors.border),
              borderRadius: BorderRadius.circular(MRadius.sm),
            ),
            child: Text(
              _iconoCategoria(item.categoria),
              style: const TextStyle(fontSize: 19),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.nombre,
                  style: sans(size: 14, weight: 600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  item.categoria?.isNotEmpty ?? false
                      ? item.categoria!
                      : 'General',
                  style: sans(size: 11, color: MColors.tMuted),
                ),
                if (estado != StockStatus.ok) ...[
                  const SizedBox(height: 4),
                  _ChipAlerta(sinStock: estado == StockStatus.out),
                ],
                const SizedBox(height: 8),
                // `.stk-bar-w { height:3px }` — una línea fina, no una barra
                // gruesa: acompaña, no grita.
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: stockBarPct(item) / 100,
                    minHeight: 3,
                    backgroundColor: MColors.bg3,
                    color: colorBarra,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${item.cantidad}',
                style: sans(size: 20, weight: 700, color: colorNumero),
              ),
              const SizedBox(height: 1),
              Text(item.unidad, style: sans(size: 9, color: MColors.tMuted)),
              if (puedeEscribir) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    _BotonAjuste(
                      simbolo: '\u2212',
                      // `adjustQuantity` ya impide bajar de cero; deshabilitar
                      // el botón evita encolar un delta que no cambia nada.
                      activo: item.cantidad > 0,
                      onTap: () => ref
                          .read(businessRepoProvider)
                          ?.ajustarStock(item.id, -1),
                    ),
                    const SizedBox(width: 4),
                    _BotonAjuste(
                      simbolo: '+',
                      activo: true,
                      onTap: () => ref
                          .read(businessRepoProvider)
                          ?.ajustarStock(item.id, 1),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  /// `catI()` del original: un emoji por familia de producto.
  static String _iconoCategoria(String? c) {
    final s = (c ?? '').toLowerCase();
    if (s.contains('adhesiv') || s.contains('pegamento')) return '🧴';
    if (s.contains('remov')) return '🧪';
    if (s.contains('pesta')) return '👁️';
    if (s.contains('ceja')) return '✏️';
    if (s.contains('depil') || s.contains('cera')) return '🕯️';
    if (s.contains('descart')) return '🧻';
    return '📦';
  }
}

/// `.stk-alert` — chip chico, radio 5 (no píldora), 9px en negrita.
class _ChipAlerta extends StatelessWidget {
  const _ChipAlerta({required this.sinStock});

  final bool sinStock;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        decoration: BoxDecoration(
          color: sinStock ? MColors.dangerBg : MColors.warningBg,
          border: Border.all(
            color: sinStock ? MColors.dangerBorder : MColors.warningBorder,
          ),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(
          sinStock ? 'Sin stock' : 'Bajo stock',
          style: sans(
            size: 9,
            weight: 600,
            color: sinStock ? MColors.dangerText : MColors.warningText,
          ),
        ),
      );
}

/// `.adj-btn` — 26×26, radio 7, fondo bg2. No es un `IconButton`: el de
/// Material trae 48 px de área táctil y rompe el alto de la fila.
class _BotonAjuste extends StatelessWidget {
  const _BotonAjuste({
    required this.simbolo,
    required this.activo,
    required this.onTap,
  });

  final String simbolo;
  final bool activo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: activo ? onTap : null,
        child: Container(
          width: 26,
          height: 26,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: MColors.bg2,
            border: Border.all(color: MColors.border),
            borderRadius: BorderRadius.circular(7),
          ),
          child: Text(
            simbolo,
            style: sans(
              size: 15,
              weight: 600,
              color: activo ? MColors.tSecondary : MColors.tLight,
            ),
          ),
        ),
      );
}

Future<void> _mostrarFormulario(
  BuildContext context,
  WidgetRef ref, {
  StockItem? item,
}) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FormularioStock(item: item),
    );

class _FormularioStock extends ConsumerStatefulWidget {
  const _FormularioStock({this.item});

  final StockItem? item;

  @override
  ConsumerState<_FormularioStock> createState() => _FormStockState();
}

class _FormStockState extends ConsumerState<_FormularioStock> {
  late final TextEditingController _nombre;
  late final TextEditingController _cantidad;
  late final TextEditingController _minimo;
  late final TextEditingController _unidad;
  bool _guardando = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final i = widget.item;
    _nombre = TextEditingController(text: i?.nombre ?? '');
    _cantidad = TextEditingController(text: '${i?.cantidad ?? 0}');
    _minimo = TextEditingController(text: '${i?.minimo ?? 5}');
    _unidad = TextEditingController(text: i?.unidad ?? 'unidades');
  }

  @override
  void dispose() {
    _nombre.dispose();
    _cantidad.dispose();
    _minimo.dispose();
    _unidad.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    final nombre = _nombre.text.trim();
    if (nombre.isEmpty) {
      setState(() => _error = 'Poné un nombre.');
      return;
    }
    final repo = ref.read(businessRepoProvider);
    if (repo == null) return;

    setState(() {
      _guardando = true;
      _error = null;
    });
    final nav = Navigator.of(context);
    try {
      await repo.guardarStock(
        id: widget.item?.id,
        nombre: nombre,
        cantidad: int.tryParse(_cantidad.text.trim()) ?? 0,
        minimo: int.tryParse(_minimo.text.trim()) ?? 0,
        unidad: _unidad.text.trim().isEmpty ? null : _unidad.text.trim(),
      );
      nav.pop();
    } catch (_) {
      if (mounted) {
        setState(() {
          _guardando = false;
          _error = 'No se pudo guardar en este dispositivo.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => SheetFormulario(
        titulo: widget.item == null ? 'Nuevo producto' : 'Editar producto',
        error: _error,
        guardando: _guardando,
        onGuardar: _guardar,
        onBorrar: widget.item == null
            ? null
            : () async {
                final nav = Navigator.of(context);
                await ref
                    .read(businessRepoProvider)
                    ?.borrar('stock_items', widget.item!.id);
                nav.pop();
              },
        campos: [
          CampoTexto(
              controlador: _nombre, etiqueta: 'Producto', autofocus: true),
          Row(
            children: [
              Expanded(
                child: CampoTexto(
                  controlador: _cantidad,
                  etiqueta: 'Cantidad',
                  teclado: TextInputType.number,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: CampoTexto(
                  controlador: _minimo,
                  etiqueta: 'Mínimo',
                  teclado: TextInputType.number,
                ),
              ),
            ],
          ),
          CampoTexto(controlador: _unidad, etiqueta: 'Unidad'),
        ],
      );
}
