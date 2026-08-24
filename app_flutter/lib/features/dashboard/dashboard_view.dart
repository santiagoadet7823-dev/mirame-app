/// Inicio. Portado del `#view-dashboard` del `index.html`.
///
/// Estructura del original, en orden:
///   1. saludo (Cormorant 24/500) + fecha (13px t-muted)
///   2. `.kpi-hero` — turnos de hoy en grande, ingresos de la semana a la
///      derecha, y tres `.kpi-mini` abajo
///   3. secciones de tarjetas
///
/// Medidas literales del CSS:
/// ```
/// .kpi-hero     { gradient 135deg lav-50→nude-100; border 1px border-lav;
///                 radius r-xl; padding 24px 20px 18px; margin-bottom 14 }
/// .kpi-hero-lbl { 11px/500; letter-spacing 1.2; UPPERCASE; t-muted }
/// .kpi-hero-val { Cormorant 42px/600; line-height 1; letter-spacing -1 }
/// .kpi-hero-sub { 12px; t-muted; margin-top 5 }
/// .kpi-mini-row { gap 6; margin-top 14 }
/// .kpi-mini     { bg rgba(255,255,255,.7); border 1px; r-md; 10px 12px }
/// .kpi-mini-v   { Cormorant 20px/600 }
/// .kpi-mini-l   { 9px/600; letter-spacing .8; UPPERCASE; t-muted }
/// ```
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/motion.dart';
import '../../core/theme/shadows.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../data/local/database.dart';
import '../../data/repositories/business_repository.dart';
import '../../domain/rules/formatting.dart';
import '../shell/app_shell.dart';
import '../shell/vistas_comunes.dart';

final turnosDeHoyProvider =
    StreamProvider.autoDispose<List<Appointment>>((ref) {
  final repo = ref.watch(businessRepoProvider);
  if (repo == null) return const Stream.empty();
  return repo.verTurnosDe(DateTime.now());
});

final movimientosDelMesProvider =
    StreamProvider.autoDispose<List<Transaction>>((ref) {
  final repo = ref.watch(businessRepoProvider);
  if (repo == null) return const Stream.empty();
  final hoy = DateTime.now();
  return repo.verMovimientosEntre(
    DateTime(hoy.year, hoy.month, 1),
    // Día 0 del mes siguiente es el último del actual, sin tener que saber
    // cuántos días tiene ni acordarse de los bisiestos.
    DateTime(hoy.year, hoy.month + 1, 0),
  );
});

final clientesProvider = StreamProvider.autoDispose<List<Client>>((ref) {
  final repo = ref.watch(businessRepoProvider);
  if (repo == null) return const Stream.empty();
  return repo.verClientes();
});

/// Movimientos de la semana en curso, para el dato de la derecha del hero.
final movimientosDeLaSemanaProvider =
    StreamProvider.autoDispose<List<Transaction>>((ref) {
  final repo = ref.watch(businessRepoProvider);
  if (repo == null) return const Stream.empty();
  final hoy = DateTime.now();
  // Semana domingo→sábado, igual que el original (`weekRange`).
  final domingo = hoy.subtract(Duration(days: hoy.weekday % 7));
  return repo.verMovimientosEntre(domingo, domingo.add(const Duration(days: 6)));
});

class DashboardView extends ConsumerWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final turnos = ref.watch(turnosDeHoyProvider).value ?? const [];
    final mes = ref.watch(movimientosDelMesProvider).value ?? const [];
    final semana = ref.watch(movimientosDeLaSemanaProvider).value ?? const [];
    final clientes = ref.watch(clientesProvider).value ?? const [];

    // 'income' es el valor del enum `tx_tipo` de Postgres.
    num ingresosDe(List<Transaction> txs) => txs
        .where((m) => m.tipo == 'income')
        .fold<num>(0, (a, m) => a + m.monto);

    final delMes = ingresosDe(mes);
    final deLaSemana = ingresosDe(semana);
    final deHoy = turnos.fold<num>(0, (a, t) => a + t.precio);
    final pendientes =
        turnos.where((t) => t.estado != 'done' && t.estado != 'cancelled').length;

    return ListView(
      padding: padVistaMovil,
      children: [
        // 1 · Saludo
        FadeSlideIn(
          child: Text(
            greeting(DateTime.now()),
            // `font-size:24px; font-weight:500` — no 28/600 como estaba antes.
            style: serif(size: 24, weight: 500),
          ),
        ),
        const SizedBox(height: 3),
        FadeSlideIn(
          delay: const Duration(milliseconds: 30),
          child: Text(
            formatDateShort(DateTime.now()),
            style: sans(size: 13, color: MColors.tMuted),
          ),
        ),
        const SizedBox(height: 18),

        // 2 · KPI hero
        FadeSlideIn(
          delay: const Duration(milliseconds: 70),
          child: _KpiHero(
            turnosHoy: turnos.length,
            ingresoHoy: deHoy,
            ingresoSemana: deLaSemana,
            clientas: clientes.length,
            ingresoMes: delMes,
            pendientes: pendientes,
          ),
        ),
        const SizedBox(height: 14),

        // 3 · Turnos del día
        FadeSlideIn(
          delay: const Duration(milliseconds: 110),
          child: const TituloSeccion('Hoy'),
        ),
        const SizedBox(height: 10),
        if (turnos.isEmpty)
          FadeSlideIn(
            delay: const Duration(milliseconds: 150),
            child: const EstadoVacio(
              emoji: '🌿',
              titulo: 'Sin turnos hoy',
              detalle: 'Cuando cargues uno para hoy, va a aparecer acá.',
            ),
          )
        else
          for (var i = 0; i < turnos.length; i++)
            FadeSlideIn(
              delay: Duration(milliseconds: 150 + (i < 8 ? i : 8) * 35),
              child: _FilaTurno(turno: turnos[i]),
            ),
      ],
    );
  }
}

class _KpiHero extends StatelessWidget {
  const _KpiHero({
    required this.turnosHoy,
    required this.ingresoHoy,
    required this.ingresoSemana,
    required this.clientas,
    required this.ingresoMes,
    required this.pendientes,
  });

  final int turnosHoy;
  final num ingresoHoy;
  final num ingresoSemana;
  final int clientas;
  final num ingresoMes;
  final int pendientes;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 18),
        decoration: BoxDecoration(
          gradient: MGradient.kpiHero,
          border: Border.all(color: MColors.borderLav),
          borderRadius: BorderRadius.circular(MRadius.xl),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              // `align-items: flex-end` — los dos números apoyan abajo.
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('TURNOS HOY', style: MText.etiquetaHero),
                      const SizedBox(height: 6),
                      Text(
                        '$turnosHoy',
                        style: serif(size: 42, weight: 600).copyWith(
                          height: 1,
                          letterSpacing: -1,
                        ),
                      ),
                      if (ingresoHoy > 0) ...[
                        const SizedBox(height: 5),
                        Text(
                          '${formatMoney(ingresoHoy)} agendado',
                          style: sans(size: 12, color: MColors.tMuted),
                        ),
                      ],
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('ESTA SEMANA', style: MText.etiquetaHeroChica),
                    const SizedBox(height: 4),
                    Text(
                      formatMoney(ingresoSemana),
                      style: serif(size: 22, weight: 600),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                _KpiMini(valor: '$clientas', etiqueta: 'CLIENTAS'),
                const SizedBox(width: 6),
                _KpiMini(
                  valor: formatMoney(ingresoMes),
                  etiqueta: 'ESTE MES',
                  // El original le baja el tamaño a este porque un monto no
                  // entra a 20px en la columna del medio.
                  tamanio: 16,
                ),
                const SizedBox(width: 6),
                _KpiMini(valor: '$pendientes', etiqueta: 'PENDIENTES'),
              ],
            ),
          ],
        ),
      );
}

class _KpiMini extends StatelessWidget {
  const _KpiMini({
    required this.valor,
    required this.etiqueta,
    this.tamanio = 20,
  });

  final String valor;
  final String etiqueta;
  final double tamanio;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            // `rgba(255,255,255,0.7)` sobre el degradado: deja pasar un poco
            // del lavanda y por eso no es blanco puro.
            color: Colors.white.withValues(alpha: 0.7),
            border: Border.all(color: MColors.border),
            borderRadius: BorderRadius.circular(MRadius.md),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                valor,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: serif(size: tamanio, weight: 600),
              ),
              const SizedBox(height: 3),
              Text(
                etiqueta,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: sans(size: 9, weight: 600, color: MColors.tMuted)
                    .copyWith(letterSpacing: 0.8),
              ),
            ],
          ),
        ),
      );
}

class _FilaTurno extends StatelessWidget {
  const _FilaTurno({required this.turno});

  final Appointment turno;

  @override
  Widget build(BuildContext context) => TarjetaMirame(
        margenInferior: 8,
        hijo: Row(
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: MColors.brandBg,
                borderRadius: BorderRadius.circular(MRadius.sm),
              ),
              child: Text(
                turno.hora,
                style: sans(size: 13, weight: 600, color: MColors.brandDark),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                turno.notas?.isNotEmpty == true ? turno.notas! : 'Turno',
                style: sans(size: 14, weight: 500),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (turno.precio > 0)
              Text(
                formatMoney(turno.precio),
                style: sans(size: 12, color: MColors.tMuted),
              ),
          ],
        ),
      );
}
