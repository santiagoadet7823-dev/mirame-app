/// Cierre de caja. Puerto de `openCierre()` del `index.html`.
///
/// Es el resumen que se mira al final del día: cuánto entró, por qué concepto,
/// por qué medio de pago, y cuánto se fue.
library;

import 'package:flutter/material.dart';

import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../domain/entities/entities.dart';
import '../../domain/rules/finance.dart';
import '../../domain/rules/formatting.dart';
import '../../domain/rules/period.dart';

Future<void> mostrarCierre(
  BuildContext context, {
  required Iterable<Transaction> movimientos,
  required DateRange rango,
  required String titulo,
}) =>
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _SheetCierre(
        cierre: closeCash(movimientos, rango),
        titulo: titulo,
      ),
    );

class _SheetCierre extends StatelessWidget {
  const _SheetCierre({required this.cierre, required this.titulo});

  final CashClose cierre;
  final String titulo;

  @override
  Widget build(BuildContext context) {
    final s = cierre.summary;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: MColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(MRadius.xl)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Cierre 📋', style: serif(size: 20, weight: 600)),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => Navigator.of(context).pop(),
                  child:
                      Text('✕', style: sans(size: 16, color: MColors.tMuted)),
                ),
              ],
            ),
            Text(titulo, style: sans(size: 12, color: MColors.tMuted)),
            const SizedBox(height: 16),

            // El neto arriba: es el número por el que se abre este modal.
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: MColors.bg2,
                borderRadius: BorderRadius.circular(MRadius.md),
              ),
              child: Column(
                children: [
                  Text('Neto', style: MText.menor),
                  const SizedBox(height: 2),
                  Text(
                    formatMoney(s.neta),
                    style: serif(
                      size: 32,
                      weight: 600,
                      color: s.neta < 0
                          ? MColors.dangerText
                          : MColors.tPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${formatMoney(s.ingresos)} de ingresos · '
                    '${formatMoney(s.egresos)} de gastos',
                    style: sans(size: 12, color: MColors.tSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  _Bloque(
                    titulo: 'INGRESOS POR CONCEPTO',
                    filas: cierre.porCategoriaIngreso,
                    color: MColors.successText,
                  ),
                  // Solo ingresos: el original nunca acumula egresos por medio
                  // de pago, y agregarlo cambiaría los números que la dueña ya
                  // conoce.
                  _Bloque(
                    titulo: 'INGRESOS POR MEDIO DE PAGO',
                    filas: cierre.porMetodo,
                    color: MColors.tPrimary,
                  ),
                  _Bloque(
                    titulo: 'GASTOS POR CONCEPTO',
                    filas: cierre.porCategoriaEgreso,
                    color: MColors.dangerText,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Bloque extends StatelessWidget {
  const _Bloque({
    required this.titulo,
    required this.filas,
    required this.color,
  });

  final String titulo;
  final List<MapEntry<String, num>> filas;
  final Color color;

  @override
  Widget build(BuildContext context) {
    // Un bloque vacío no aporta: se omite en vez de mostrar "sin datos" tres
    // veces seguidas.
    if (filas.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            titulo,
            style: sans(
              size: 10,
              weight: 600,
              color: MColors.tMuted,
              letterSpacing: 0.8,
            ),
          ),
        ),
        for (final f in filas)
          Padding(
            padding: const EdgeInsets.only(bottom: 7),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _lindo(f.key),
                    style: sans(size: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  formatMoney(f.value),
                  style: sans(size: 13, weight: 600, color: color),
                ),
              ],
            ),
          ),
        const SizedBox(height: 14),
      ],
    );
  }

  /// Las categorías se guardan en kebab-case (`otro-gasto`) porque vienen del
  /// legacy; acá se muestran como se leen.
  static String _lindo(String crudo) {
    final txt = crudo.replaceAll('-', ' ');
    return txt.isEmpty ? txt : txt[0].toUpperCase() + txt.substring(1);
  }
}
