/// Estadísticas: proyección, semanas, comparativa y gastos por categoría.
///
/// Los gráficos son `CustomPainter`. No se agrega una librería de charts: el
/// original los dibujaba con CSS y traer fl_chart o syncfusion por cuatro
/// formas simples pesa más que todo lo que hace esta pantalla.
///
/// Ningún cálculo vive acá — todos salen de `domain/rules/finance.dart`.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/motion.dart';
import '../../core/theme/shadows.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../data/local/database.dart' as db;
import '../../data/local/mappers.dart';
import '../../data/repositories/business_repository.dart';
import '../../domain/rules/finance.dart';
import '../../domain/rules/formatting.dart';
import '../../domain/rules/period.dart';
import '../shell/app_shell.dart';
import '../shell/vistas_comunes.dart';

/// Movimientos de los últimos 3 meses: alcanza para las 8 semanas del gráfico
/// y para comparar contra el mes anterior, sin traer todo el historial.
final movimientosRecientesProvider =
    StreamProvider.autoDispose<List<db.Transaction>>((ref) {
  final repo = ref.watch(businessRepoProvider);
  if (repo == null) return const Stream.empty();
  final hoy = DateTime.now();
  return repo.verMovimientosEntre(
    DateTime(hoy.year, hoy.month - 3, 1),
    DateTime(hoy.year, hoy.month + 1, 0),
  );
});

class StatsView extends ConsumerWidget {
  const StatsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filas = ref.watch(movimientosRecientesProvider).value ??
        const <db.Transaction>[];
    final movimientos = filas.map(aTransaction).toList();
    final hoy = DateTime.now();

    if (movimientos.isEmpty) {
      return const EstadoVacio(
        emoji: '📊',
        titulo: 'Todavía no hay números',
        detalle: 'Cargá movimientos en Caja y acá vas a ver cómo viene el mes.',
      );
    }

    final proyeccion = projectMonth(movimientos, hoy);
    final semanas = weeklyIncome(movimientos, hoy);
    final comparativa = monthlyComparison(movimientos, hoy);
    final gastos = expensesByCategory(movimientos, monthRange(hoy));

    return ListView(
      padding: padVistaMovil,
      children: [
        FadeSlideIn(
          child: _Tarjeta(
            titulo: 'Proyección del mes',
            hijo: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formatMoney(proyeccion.proyectado),
                  style: serif(size: 30, weight: 600),
                ),
                const SizedBox(height: 4),
                Text(
                  'Van ${formatMoney(proyeccion.acumulado)} en '
                  '${proyeccion.diaActual} de '
                  '${proyeccion.diasDelMes} días',
                  style: MText.menor,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        FadeSlideIn(
          delay: const Duration(milliseconds: 50),
          child: _Tarjeta(
            titulo: 'Ingresos por semana',
            hijo: SizedBox(
              height: 120,
              child: CustomPaint(
                painter: _BarrasPainter(
                  valores: [for (final s in semanas) s.pctAlto],
                ),
                child: const SizedBox.expand(),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        FadeSlideIn(
          delay: const Duration(milliseconds: 90),
          child: _Tarjeta(
            titulo: 'Este mes contra el anterior',
            hijo: Column(
              children: [
                _BarraComparativa(
                  etiqueta: 'Este mes',
                  monto: comparativa.actual,
                  pct: comparativa.pctActual,
                  color: MColors.brand,
                ),
                const SizedBox(height: 10),
                _BarraComparativa(
                  etiqueta: 'Mes anterior',
                  monto: comparativa.anterior,
                  pct: comparativa.pctAnterior,
                  color: MColors.nude300,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        if (gastos.isNotEmpty)
          FadeSlideIn(
            delay: const Duration(milliseconds: 130),
            child: _Tarjeta(
              titulo: 'Gastos por categoría',
              hijo: Row(
                children: [
                  SizedBox(
                    width: 108,
                    height: 108,
                    child: CustomPaint(
                      painter: _DonutPainter(
                        porciones: [for (final g in gastos) g.pct],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (var i = 0; i < gastos.length && i < 6; i++)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              children: [
                                Container(
                                  width: 9,
                                  height: 9,
                                  decoration: BoxDecoration(
                                    color: _colorSerie(i),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 7),
                                Expanded(
                                  child: Text(
                                    gastos[i].categoria,
                                    style: MText.menor,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  '${gastos[i].pct}%',
                                  style: sans(size: 12, weight: 600),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// Paleta de series. Se repite cíclicamente en vez de generar colores al azar:
/// un color inventado puede caer sobre el fondo crema y volverse invisible.
Color _colorSerie(int i) =>
    MSeries.expenses[i % MSeries.expenses.length];

class _Tarjeta extends StatelessWidget {
  const _Tarjeta({required this.titulo, required this.hijo});

  final String titulo;
  final Widget hijo;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: MColors.surface,
          borderRadius: BorderRadius.circular(MRadius.lg),
          border: Border.all(color: MColors.border),
          boxShadow: MShadow.xs,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(titulo, style: sans(size: 13, weight: 600)),
            const SizedBox(height: 12),
            hijo,
          ],
        ),
      );
}

class _BarraComparativa extends StatelessWidget {
  const _BarraComparativa({
    required this.etiqueta,
    required this.monto,
    required this.pct,
    required this.color,
  });

  final String etiqueta;
  final num monto;
  final int pct;
  final Color color;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(etiqueta, style: MText.menor),
              Text(formatMoney(monto), style: sans(size: 13, weight: 600)),
            ],
          ),
          const SizedBox(height: 5),
          ClipRRect(
            borderRadius: BorderRadius.circular(MRadius.full),
            child: LinearProgressIndicator(
              value: pct / 100,
              minHeight: 7,
              backgroundColor: MColors.bg3,
              color: color,
            ),
          ),
        ],
      );
}

/// Barras de las 8 semanas. Los valores llegan ya normalizados a 0..100 por
/// `weeklyIncome`; acá solo se dibuja.
class _BarrasPainter extends CustomPainter {
  const _BarrasPainter({required this.valores});

  final List<int> valores;

  @override
  void paint(Canvas canvas, Size size) {
    if (valores.isEmpty) return;
    final n = valores.length;
    final separacion = 6.0;
    final ancho = (size.width - separacion * (n - 1)) / n;
    final pincel = Paint()..style = PaintingStyle.fill;

    for (var i = 0; i < n; i++) {
      // Altura mínima de 3 px: una semana en cero dibujada como nada se
      // confunde con una semana que no existe.
      final alto = math.max(3.0, size.height * (valores[i] / 100));
      final x = i * (ancho + separacion);
      // La última barra es la semana en curso y va destacada.
      pincel.color = i == n - 1 ? MColors.brand : MColors.lav200;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, size.height - alto, ancho, alto),
          const Radius.circular(4),
        ),
        pincel,
      );
    }
  }

  @override
  bool shouldRepaint(_BarrasPainter viejo) => viejo.valores != valores;
}

/// Anillo de gastos. Las porciones llegan en porcentaje entero.
class _DonutPainter extends CustomPainter {
  const _DonutPainter({required this.porciones});

  final List<int> porciones;

  @override
  void paint(Canvas canvas, Size size) {
    final grosor = 18.0;
    final rect = Rect.fromLTWH(
      grosor / 2,
      grosor / 2,
      size.width - grosor,
      size.height - grosor,
    );
    final pincel = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = grosor;

    // Se arranca arriba (−90°) y no a la derecha: es como se lee un reloj.
    var inicio = -math.pi / 2;
    final total = porciones.fold<int>(0, (a, b) => a + b);
    if (total <= 0) return;

    for (var i = 0; i < porciones.length; i++) {
      final barrido = 2 * math.pi * (porciones[i] / total);
      pincel.color = _colorSerie(i);
      canvas.drawArc(rect, inicio, barrido, false, pincel);
      inicio += barrido;
    }
  }

  @override
  bool shouldRepaint(_DonutPainter viejo) => viejo.porciones != porciones;
}
