/// Estadísticas. Portado del `#view-stats` del `index.html`.
///
/// Orden y medidas del original:
/// ```
/// .stat-grid  { 2 columnas (4 en escritorio); gap 10; margin-bottom 14 }
/// .stat-card  { padding 18px 16px }
/// .stat-ic    { emoji 20px; margin-bottom 8 }
/// .stat-v     { Cormorant 28/600; line-height 1 }
/// .stat-l     { 10px/500; letter-spacing .8; UPPERCASE; t-muted }
/// .chart-card { padding 18; margin-bottom 12 }
/// .chart-title{ 15px/600 }   .chart-sub { 11px t-muted; margin-bottom 16 }
/// .bars-wrap  { alto 90; gap 6; align-items flex-end }
/// ```
/// Después de los 4 KPI: resultado financiero (gastos, neta, margen,
/// proyección), gastos por categoría, ingresos semanales, servicios
/// populares, top clientas y comparativa mensual.
///
/// Los gráficos son `CustomPainter`: el original los dibujaba con CSS, y traer
/// una librería de charts por cuatro formas simples pesa más que toda esta
/// pantalla. **Ningún cálculo vive acá** — todos salen de `domain/rules/`.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/motion.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../data/local/database.dart' as db;
import '../../data/local/mappers.dart';
import '../../data/repositories/business_repository.dart';
import '../../domain/rules/csv.dart';
import '../../domain/rules/finance.dart';
import '../../domain/rules/formatting.dart';
import '../../domain/rules/period.dart';
import '../crm/clients_view.dart';
import 'exportar_csv.dart';
import '../dashboard/dashboard_view.dart';
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

/// Turnos del mes, para el ticket promedio y la cuenta de turnos.
final turnosDelMesProvider =
    StreamProvider.autoDispose<List<db.Appointment>>((ref) {
  final repo = ref.watch(businessRepoProvider);
  if (repo == null) return const Stream.empty();
  final hoy = DateTime.now();
  return repo.verTurnosEntre(
    DateTime(hoy.year, hoy.month, 1),
    DateTime(hoy.year, hoy.month + 1, 0),
  );
});

class StatsView extends ConsumerWidget {
  const StatsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final movimientos = (ref.watch(movimientosRecientesProvider).value ??
            const <db.Transaction>[])
        .map(aTransaction)
        .toList();
    final turnos =
        (ref.watch(turnosDelMesProvider).value ?? const <db.Appointment>[])
            .map((f) => aAppointment(f))
            .toList();
    final clientes = ref.watch(clientesProvider).value ?? const <db.Client>[];
    final resumenClientes = ref.watch(resumenClientesProvider).value ??
        const <String, ({int turnos, double gastado})>{};
    final hoy = DateTime.now();

    if (movimientos.isEmpty && turnos.isEmpty) {
      return const EstadoVacio(
        emoji: '📊',
        titulo: 'Sin datos todavía',
        detalle: 'Cargá turnos y movimientos y acá vas a ver cómo viene el mes',
      );
    }

    final rango = monthRange(hoy);
    final resumen = summarize(movimientos, rango);
    final proyeccion = projectMonth(movimientos, hoy);
    final semanas = weeklyIncome(movimientos, hoy);
    final comparativa = monthlyComparison(movimientos, hoy);
    final gastos = expensesByCategory(movimientos, rango);
    final ticket = averageTicket(movimientos, turnos, hoy);

    // Top clientas por lo gastado, igual que `topClients` del original.
    final nombres = {for (final c in clientes) c.id: c.nombre};
    final top = resumenClientes.entries
        .where((e) => e.value.gastado > 0)
        .map((e) => (nombre: nombres[e.key] ?? '—', monto: e.value.gastado))
        .toList()
      ..sort((a, b) => b.monto.compareTo(a.monto));
    final topCinco = top.take(5).toList();
    final maxTop = topCinco.isEmpty ? 1.0 : topCinco.first.monto;

    return ListView(
      padding: padVistaMovil,
      children: [
        // ── Los 4 KPI ───────────────────────────────────────────────────
        FadeSlideIn(
          child: Row(
            children: [
              _Kpi(
                emoji: '💜',
                valor: formatMoney(resumen.ingresos),
                etiqueta: 'INGRESOS',
              ),
              const SizedBox(width: 10),
              _Kpi(
                emoji: '✨',
                valor: '${clientes.length}',
                etiqueta: 'CLIENTAS',
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        FadeSlideIn(
          delay: const Duration(milliseconds: 40),
          child: Row(
            children: [
              _Kpi(emoji: '📅', valor: '${turnos.length}', etiqueta: 'TURNOS'),
              const SizedBox(width: 10),
              _Kpi(
                emoji: '🌸',
                valor: formatMoney(ticket),
                etiqueta: 'TICKET PROM.',
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // ── Resultado financiero ────────────────────────────────────────
        FadeSlideIn(
          delay: const Duration(milliseconds: 80),
          child: _TarjetaGrafico(
            titulo: 'Resultado financiero del mes',
            subtitulo: monthName(hoy.month),
            hijo: Column(
              children: [
                Row(
                  children: [
                    _CajaDato(
                      etiqueta: 'GASTOS TOTALES',
                      valor: formatMoney(resumen.egresos),
                      color: MColors.dangerText,
                    ),
                    const SizedBox(width: 10),
                    _CajaDato(
                      etiqueta: 'GANANCIA NETA',
                      valor: formatMoney(resumen.neta),
                      // El original deja el neto en color normal salvo que sea
                      // negativo: el rojo se reserva para lo que exige acción.
                      color: resumen.neta < 0
                          ? MColors.dangerText
                          : MColors.tPrimary,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _BarraMargen(resumen: resumen),
                const SizedBox(height: 14),
                _CajaProyeccion(proyeccion: proyeccion),
              ],
            ),
          ),
        ),

        // ── Gastos por categoría ────────────────────────────────────────
        if (gastos.isNotEmpty)
          FadeSlideIn(
            delay: const Duration(milliseconds: 120),
            child: _TarjetaGrafico(
              titulo: 'Gastos por categoría',
              subtitulo: 'Este mes',
              hijo: Column(
                children: [
                  for (var i = 0; i < gastos.length && i < 7; i++)
                    _FilaCategoria(
                      categoria: gastos[i].categoria,
                      monto: gastos[i].monto,
                      pct: gastos[i].pct,
                      color: MSeries.expenses[i % MSeries.expenses.length],
                    ),
                ],
              ),
            ),
          ),

        // ── Ingresos semanales ──────────────────────────────────────────
        FadeSlideIn(
          delay: const Duration(milliseconds: 160),
          child: _TarjetaGrafico(
            titulo: 'Ingresos semanales',
            subtitulo: 'Últimas 8 semanas',
            hijo: SizedBox(
              // `.bars-wrap { height:90px }`
              height: 90,
              child: CustomPaint(
                painter: _BarrasPainter(
                  valores: [for (final s in semanas) s.pctAlto],
                ),
                child: const SizedBox.expand(),
              ),
            ),
          ),
        ),

        // ── Gastos en donut ─────────────────────────────────────────────
        if (gastos.isNotEmpty)
          FadeSlideIn(
            delay: const Duration(milliseconds: 200),
            child: _TarjetaGrafico(
              titulo: 'Reparto de gastos',
              subtitulo: 'Este mes, por categoría',
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
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (var i = 0; i < gastos.length && i < 6; i++)
                          _Leyenda(
                            texto: gastos[i].categoria,
                            pct: gastos[i].pct,
                            color:
                                MSeries.expenses[i % MSeries.expenses.length],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

        // ── Top clientas ────────────────────────────────────────────────
        if (topCinco.isNotEmpty)
          FadeSlideIn(
            delay: const Duration(milliseconds: 240),
            child: _TarjetaGrafico(
              titulo: 'Top Clientas 🌸',
              subtitulo: 'Por monto gastado',
              hijo: Column(
                children: [
                  for (var i = 0; i < topCinco.length; i++)
                    _FilaRanking(
                      puesto: i + 1,
                      nombre: topCinco[i].nombre,
                      monto: topCinco[i].monto,
                      pct: (topCinco[i].monto / maxTop * 100).round(),
                    ),
                ],
              ),
            ),
          ),

        // ── Comparativa mensual ─────────────────────────────────────────
        FadeSlideIn(
          delay: const Duration(milliseconds: 280),
          child: _TarjetaGrafico(
            titulo: 'Comparativa mensual',
            subtitulo: 'Este mes vs anterior',
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

        // Pie del original: las dos tarjetas de export.
        const SizedBox(height: 14),
        FadeSlideIn(
          delay: const Duration(milliseconds: 260),
          child: Builder(
            builder: (ctx) => FilaExports(
              onCaja: () => compartirCsv(
                ctx,
                contenido: csvDeCaja(movimientos),
                nombre: nombreCsvCaja(DateTime.now()),
              ),
              onClientas: () => compartirCsv(
                ctx,
                contenido: csvDeClientas(clientes.map(aClient)),
                nombre: nombreCsvClientas(DateTime.now()),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// `.stat-card` — emoji, valor en Cormorant 28 y etiqueta en mayúsculas.
class _Kpi extends StatelessWidget {
  const _Kpi({
    required this.emoji,
    required this.valor,
    required this.etiqueta,
  });

  final String emoji;
  final String valor;
  final String etiqueta;

  @override
  Widget build(BuildContext context) => Expanded(
        child: TarjetaMirame(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          hijo: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(height: 8),
              Text(
                valor,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: serif(size: 28, weight: 600).copyWith(height: 1),
              ),
              const SizedBox(height: 4),
              Text(
                etiqueta,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: sans(size: 10, weight: 500, color: MColors.tMuted)
                    .copyWith(letterSpacing: 0.8),
              ),
            ],
          ),
        ),
      );
}

/// `.chart-card` — título, subtítulo y contenido.
class _TarjetaGrafico extends StatelessWidget {
  const _TarjetaGrafico({
    required this.titulo,
    required this.subtitulo,
    required this.hijo,
  });

  final String titulo;
  final String subtitulo;
  final Widget hijo;

  @override
  Widget build(BuildContext context) => TarjetaMirame(
        margenInferior: 12,
        padding: const EdgeInsets.all(18),
        hijo: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(titulo, style: sans(size: 15, weight: 600)),
            const SizedBox(height: 3),
            Text(subtitulo, style: sans(size: 11, color: MColors.tMuted)),
            const SizedBox(height: 16),
            hijo,
          ],
        ),
      );
}

/// Las dos cajitas de gastos y ganancia: fondo bg2, radio 12, centradas.
class _CajaDato extends StatelessWidget {
  const _CajaDato({
    required this.etiqueta,
    required this.valor,
    required this.color,
  });

  final String etiqueta;
  final String valor;
  final Color color;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: MColors.bg2,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Text(
                etiqueta,
                textAlign: TextAlign.center,
                style: sans(size: 10, weight: 600, color: MColors.tMuted)
                    .copyWith(letterSpacing: 1),
              ),
              const SizedBox(height: 6),
              Text(
                valor,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: serif(size: 26, weight: 600, color: color),
              ),
            ],
          ),
        ),
      );
}

class _BarraMargen extends StatelessWidget {
  const _BarraMargen({required this.resumen});

  final CashSummary resumen;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Margen neto', style: sans(size: 12, color: MColors.tMuted)),
              Text(
                '${resumen.margenPct}%',
                style: sans(
                  size: 12,
                  weight: 700,
                  // El TEXTO muestra el margen sin recortar y puede ser
                  // negativo; la BARRA se recorta a 0..100 porque no puede
                  // medir −40%. Esa distinción es del original.
                  color: resumen.margenPct < 0
                      ? MColors.dangerText
                      : MColors.lav600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              height: 8,
              child: Stack(
                children: [
                  Container(color: MColors.bg3),
                  FractionallySizedBox(
                    widthFactor: resumen.margenBarPct / 100,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [MColors.lav400, MColors.lav600],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
}

class _CajaProyeccion extends StatelessWidget {
  const _CajaProyeccion({required this.proyeccion});

  final Projection proyeccion;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: MColors.bg2,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PROYECCIÓN DEL MES',
                    style: sans(size: 10, weight: 600, color: MColors.tMuted)
                        .copyWith(letterSpacing: 1),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Basado en el ritmo actual',
                    style: sans(size: 11, color: MColors.tMuted),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text(
              formatMoney(proyeccion.proyectado),
              style: serif(size: 22, weight: 600, color: MColors.lav700),
            ),
          ],
        ),
      );
}

class _FilaCategoria extends StatelessWidget {
  const _FilaCategoria({
    required this.categoria,
    required this.monto,
    required this.pct,
    required this.color,
  });

  final String categoria;
  final num monto;
  final int pct;
  final Color color;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    categoria,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: sans(size: 12, weight: 500),
                  ),
                ),
                Text(
                  '${formatMoney(monto)}  ·  $pct%',
                  style: sans(size: 11, color: MColors.tMuted),
                ),
              ],
            ),
            const SizedBox(height: 5),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: pct / 100,
                minHeight: 6,
                backgroundColor: MColors.bg3,
                color: color,
              ),
            ),
          ],
        ),
      );
}

/// `.rank` — el puesto en lavanda y angosto, el nombre, y el monto.
class _FilaRanking extends StatelessWidget {
  const _FilaRanking({
    required this.puesto,
    required this.nombre,
    required this.monto,
    required this.pct,
  });

  final int puesto;
  final String nombre;
  final num monto;
  final int pct;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Column(
          children: [
            Row(
              children: [
                SizedBox(
                  width: 18,
                  child: Text(
                    '$puesto',
                    style: sans(size: 11, weight: 700, color: MColors.brand),
                  ),
                ),
                Expanded(
                  child: Text(
                    nombre,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: sans(size: 12, weight: 500),
                  ),
                ),
                Text(
                  formatMoney(monto),
                  style: sans(size: 11, weight: 600, color: MColors.tMuted),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.only(left: 18),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: pct / 100,
                  minHeight: 5,
                  backgroundColor: MColors.bg3,
                  color: MColors.brand,
                ),
              ),
            ),
          ],
        ),
      );
}

class _Leyenda extends StatelessWidget {
  const _Leyenda({
    required this.texto,
    required this.pct,
    required this.color,
  });

  final String texto;
  final int pct;
  final Color color;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          children: [
            Container(
              width: 9,
              height: 9,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                texto,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: sans(size: 11, color: MColors.tMuted),
              ),
            ),
            Text('$pct%', style: sans(size: 12, weight: 600)),
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
              Text(etiqueta, style: sans(size: 12, color: MColors.tMuted)),
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
    const separacion = 6.0; // `.bars-wrap { gap:6px }`
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
    const grosor = 18.0;
    final rect = Rect.fromLTWH(
      grosor / 2,
      grosor / 2,
      size.width - grosor,
      size.height - grosor,
    );
    final pincel = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = grosor;

    final total = porciones.fold<int>(0, (a, b) => a + b);
    if (total <= 0) return;

    // Se arranca arriba (−90°) y no a la derecha: es como se lee un reloj.
    var inicio = -math.pi / 2;
    for (var i = 0; i < porciones.length; i++) {
      final barrido = 2 * math.pi * (porciones[i] / total);
      pincel.color = MSeries.expenses[i % MSeries.expenses.length];
      canvas.drawArc(rect, inicio, barrido, false, pincel);
      inicio += barrido;
    }
  }

  @override
  bool shouldRepaint(_DonutPainter viejo) => viejo.porciones != porciones;
}
