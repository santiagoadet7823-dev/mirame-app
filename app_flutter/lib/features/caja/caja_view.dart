/// Caja: ingresos y gastos del mes.
///
/// Los totales salen de `domain/rules/finance.dart`, que ya está testeado —
/// esta pantalla dibuja, no calcula.
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
import '../../domain/rules/finance.dart';
import '../../domain/rules/formatting.dart';
import '../../domain/rules/period.dart';
import '../auth/session_controller.dart';
import '../dashboard/dashboard_view.dart';
import '../shell/app_shell.dart';
import '../shell/vistas_comunes.dart';

class CajaView extends ConsumerWidget {
  const CajaView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filas =
        ref.watch(movimientosDelMesProvider).value ?? const <db.Transaction>[];
    final movimientos = filas.map(aTransaction).toList();
    final resumen = summarize(movimientos, monthRange(DateTime.now()));
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
          FadeSlideIn(
            child: Row(
              children: [
                Expanded(
                  child: _Total(
                    etiqueta: 'Ingresos',
                    valor: resumen.ingresos,
                    color: MColors.successText,
                    fondo: MColors.successBg,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _Total(
                    etiqueta: 'Gastos',
                    valor: resumen.egresos,
                    color: MColors.dangerText,
                    fondo: MColors.dangerBg,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          FadeSlideIn(
            delay: const Duration(milliseconds: 50),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: MColors.surface,
                borderRadius: BorderRadius.circular(MRadius.md),
                border: Border.all(color: MColors.border),
                boxShadow: MShadow.xs,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Neto del mes', style: MText.menor),
                  const SizedBox(height: 2),
                  Text(
                    formatMoney(resumen.neta),
                    style: serif(
                      size: 28,
                      weight: 600,
                      // El rojo se reserva para el neto negativo: es el único
                      // número de esta pantalla que exige una decisión.
                      color: resumen.neta < 0
                          ? MColors.dangerText
                          : MColors.tPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 22),
          FadeSlideIn(
            delay: const Duration(milliseconds: 90),
            child: Text('Movimientos', style: sans(size: 15, weight: 600)),
          ),
          const SizedBox(height: 10),
          if (movimientos.isEmpty)
            const EstadoVacio(
              emoji: '💸',
              titulo: 'Sin movimientos',
              detalle: 'No hay movimientos este mes',
            )
          else
            for (var i = 0; i < movimientos.length; i++)
              FadeSlideIn(
                delay: Duration(milliseconds: 130 + (i < 8 ? i : 8) * 35),
                child: _FilaMovimiento(mov: movimientos[i]),
              ),
        ],
      ),
    );
  }
}

class _Total extends StatelessWidget {
  const _Total({
    required this.etiqueta,
    required this.valor,
    required this.color,
    required this.fondo,
  });

  final String etiqueta;
  final num valor;
  final Color color;
  final Color fondo;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: fondo,
          borderRadius: BorderRadius.circular(MRadius.md),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(etiqueta, style: sans(size: 11.5, weight: 600, color: color)),
            const SizedBox(height: 4),
            Text(
              formatMoney(valor),
              style: sans(size: 17, weight: 600, color: color),
            ),
          ],
        ),
      );
}

/// `.tx-item` — ícono de 40 con el fondo del tipo, descripción, la meta
/// "fecha · método" y el monto con signo.
///
/// El original usa emoji (✅ / 🔴) y no íconos de línea: es lo que le da el
/// aire de la app, y a 17px se leen mejor que un trazo fino.
class _FilaMovimiento extends ConsumerWidget {
  const _FilaMovimiento({required this.mov});

  final Transaction mov;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final esIngreso = mov.tipo == TxTipo.income;
    return TarjetaMirame(
      margenInferior: 7,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      onTap: () => _mostrarFormulario(context, ref, mov: mov),
      hijo: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: esIngreso ? MColors.successBg : MColors.dangerBg,
              border: Border.all(
                color: esIngreso
                    ? MColors.successBorder
                    : MColors.dangerBorder,
              ),
              borderRadius: BorderRadius.circular(MRadius.sm),
            ),
            child: Text(
              esIngreso ? '✅' : '🔴',
              style: const TextStyle(fontSize: 17),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  // El original cae a la categoría y después a "Movimiento":
                  // una fila sin texto no se puede distinguir de otra.
                  mov.descripcion?.isNotEmpty ?? false
                      ? mov.descripcion!
                      : (mov.categoria?.isNotEmpty ?? false
                          ? mov.categoria!
                          : 'Movimiento'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: sans(size: 13, weight: 500),
                ),
                const SizedBox(height: 2),
                Text(
                  '${formatDateShort(mov.fecha)} · ${_metodo(mov.metodo)}',
                  style: sans(size: 11, color: MColors.tMuted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${esIngreso ? '+' : '-'}${formatMoney(mov.monto)}',
            style: sans(
              size: 14,
              weight: 700,
              color: esIngreso ? MColors.ingreso : MColors.gasto,
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 4),
            child: Text('›',
                style: TextStyle(fontSize: 18, color: MColors.tMuted)),
          ),
        ],
      ),
    );
  }

  static String _metodo(TxMetodo m) => switch (m) {
        TxMetodo.transferencia => 'Transferencia',
        TxMetodo.tarjeta => 'Tarjeta',
        TxMetodo.efectivo => 'Efectivo',
      };
}

Future<void> _mostrarFormulario(
  BuildContext context,
  WidgetRef ref, {
  Transaction? mov,
}) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FormularioMovimiento(mov: mov),
    );

class _FormularioMovimiento extends ConsumerStatefulWidget {
  const _FormularioMovimiento({this.mov});

  final Transaction? mov;

  @override
  ConsumerState<_FormularioMovimiento> createState() => _FormMovState();
}

class _FormMovState extends ConsumerState<_FormularioMovimiento> {
  late final TextEditingController _monto;
  late final TextEditingController _descripcion;
  late bool _esIngreso;
  bool _guardando = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final m = widget.mov;
    _monto = TextEditingController(
      text: m == null ? '' : m.monto.toStringAsFixed(0),
    );
    _descripcion = TextEditingController(text: m?.descripcion ?? '');
    _esIngreso = m == null || m.tipo == TxTipo.income;
  }

  @override
  void dispose() {
    _monto.dispose();
    _descripcion.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    // Se aceptan coma y punto como separador decimal: en Argentina se escribe
    // con coma y el teclado numérico ofrece las dos.
    final crudo = _monto.text.trim().replaceAll('.', '').replaceAll(',', '.');
    final monto = double.tryParse(crudo);
    if (monto == null || monto <= 0) {
      setState(() => _error = 'Poné un monto mayor a cero.');
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
      await repo.guardarMovimiento(
        id: widget.mov?.id,
        // Los valores del enum del servidor, no traducciones.
        tipo: _esIngreso ? 'income' : 'expense',
        monto: monto,
        fecha: widget.mov?.fecha ?? DateTime.now(),
        descripcion:
            _descripcion.text.trim().isEmpty ? null : _descripcion.text.trim(),
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
        titulo: widget.mov == null ? 'Nuevo movimiento' : 'Editar movimiento',
        error: _error,
        guardando: _guardando,
        onGuardar: _guardar,
        onBorrar: widget.mov == null
            ? null
            : () async {
                final nav = Navigator.of(context);
                await ref
                    .read(businessRepoProvider)
                    ?.borrar('transactions', widget.mov!.id);
                nav.pop();
              },
        campos: [
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: true, label: Text('Ingreso')),
                ButtonSegment(value: false, label: Text('Gasto')),
              ],
              selected: {_esIngreso},
              onSelectionChanged: (s) =>
                  setState(() => _esIngreso = s.first),
              style: SegmentedButton.styleFrom(
                selectedBackgroundColor: MColors.brandBg,
                selectedForegroundColor: MColors.brandDark,
                textStyle: sans(size: 13, weight: 600),
              ),
            ),
          ),
          CampoTexto(
            controlador: _monto,
            etiqueta: 'Monto',
            prefijo: r'$ ',
            teclado: const TextInputType.numberWithOptions(decimal: true),
            autofocus: true,
          ),
          CampoTexto(controlador: _descripcion, etiqueta: 'Descripción'),
        ],
      );
}
