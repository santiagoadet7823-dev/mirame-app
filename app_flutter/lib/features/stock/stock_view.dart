/// Stock: qué hay, qué falta y ajuste rápido.
///
/// Los ajustes van **por delta** (`+1` / `−1`), no por valor absoluto: es la
/// única excepción al last-write-wins del sync. Ver `business_repository`.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/motion.dart';
import '../../core/theme/shadows.dart';
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

class StockView extends ConsumerWidget {
  const StockView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filas = ref.watch(stockProvider).value ?? const <db.StockItem>[];
    final items = filas.map(aStockItem).toList();
    final alertas = stockAlerts(items, limit: 99);
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
          if (items.isEmpty)
            const EstadoVacio(
              emoji: '📦',
              titulo: 'Sin productos cargados',
              detalle: 'Tocá + para agregar el primero.',
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

class _FilaStock extends ConsumerWidget {
  const _FilaStock({required this.item, required this.puedeEscribir});

  final StockItem item;
  final bool puedeEscribir;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estado = stockStatus(item);
    final (color, fondo) = switch (estado) {
      StockStatus.out => (MColors.dangerText, MColors.dangerBg),
      StockStatus.low => (MColors.warningText, MColors.warningBg),
      StockStatus.ok => (MColors.successText, MColors.successBg),
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
      decoration: BoxDecoration(
        color: MColors.surface,
        borderRadius: BorderRadius.circular(MRadius.md),
        border: Border.all(color: MColors.border),
        boxShadow: MShadow.xs,
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _mostrarFormulario(context, ref, item: item),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.nombre,
                    style: sans(size: 14, weight: 600),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: fondo,
                          borderRadius:
                              BorderRadius.circular(MRadius.full),
                        ),
                        child: Text(
                          '${item.cantidad} ${item.unidad}',
                          style: sans(
                              size: 11.5, weight: 600, color: color),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('mín. ${item.minimo}', style: MText.menor),
                    ],
                  ),
                  const SizedBox(height: 7),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(MRadius.full),
                    child: LinearProgressIndicator(
                      value: stockBarPct(item) / 100,
                      minHeight: 4,
                      backgroundColor: MColors.bg3,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (puedeEscribir) ...[
            _BotonAjuste(
              icono: Icons.remove_rounded,
              // No baja de cero: `adjustQuantity` ya lo garantiza, pero
              // deshabilitar el botón evita encolar un delta que no cambia nada.
              activo: item.cantidad > 0,
              onTap: () => ref
                  .read(businessRepoProvider)
                  ?.ajustarStock(item.id, -1),
            ),
            _BotonAjuste(
              icono: Icons.add_rounded,
              activo: true,
              onTap: () =>
                  ref.read(businessRepoProvider)?.ajustarStock(item.id, 1),
            ),
          ],
        ],
      ),
    );
  }
}

class _BotonAjuste extends StatelessWidget {
  const _BotonAjuste({
    required this.icono,
    required this.activo,
    required this.onTap,
  });

  final IconData icono;
  final bool activo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => IconButton(
        onPressed: activo ? onTap : null,
        visualDensity: VisualDensity.compact,
        icon: Icon(
          icono,
          size: 19,
          color: activo ? MColors.brand : MColors.tLight,
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
