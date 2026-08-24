/// Inicio: el saludo, los turnos de hoy y el pulso del mes.
///
/// Lee de Drift, no de Supabase: abre igual sin señal. Los números salen de
/// `domain/rules/finance.dart`, que ya está testeado.
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
import '../shell/vistas_comunes.dart';

/// Turnos de hoy.
final turnosDeHoyProvider = StreamProvider.autoDispose<List<Appointment>>(
  (ref) {
    final repo = ref.watch(businessRepoProvider);
    if (repo == null) return const Stream.empty();
    return repo.verTurnosDe(DateTime.now());
  },
);

/// Movimientos del mes en curso.
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

class DashboardView extends ConsumerWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final turnos = ref.watch(turnosDeHoyProvider).value ?? const [];
    final movimientos = ref.watch(movimientosDelMesProvider).value ?? const [];
    final clientes = ref.watch(clientesProvider).value ?? const [];

    final ingresos = movimientos
        .where((m) => m.tipo == 'ingreso')
        .fold<double>(0, (a, m) => a + m.monto);
    final gastos = movimientos
        .where((m) => m.tipo == 'gasto')
        .fold<double>(0, (a, m) => a + m.monto);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 90),
      children: [
        FadeSlideIn(
          child: Text(
            greeting(DateTime.now()),
            style: serif(size: 28, weight: 600),
          ),
        ),
        const SizedBox(height: 4),
        FadeSlideIn(
          delay: const Duration(milliseconds: 30),
          child: Text(formatDateShort(DateTime.now()), style: MText.cuerpoSec),
        ),
        const SizedBox(height: 22),

        FadeSlideIn(
          delay: const Duration(milliseconds: 70),
          child: _Balance(ingresos: ingresos, gastos: gastos),
        ),
        const SizedBox(height: 14),

        FadeSlideIn(
          delay: const Duration(milliseconds: 110),
          child: Row(
            children: [
              Expanded(
                child: _Kpi(
                  valor: '${turnos.length}',
                  etiqueta: turnos.length == 1 ? 'turno hoy' : 'turnos hoy',
                  icono: Icons.calendar_month_outlined,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _Kpi(
                  valor: '${clientes.length}',
                  etiqueta:
                      clientes.length == 1 ? 'clienta' : 'clientas',
                  icono: Icons.people_outline,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 26),

        FadeSlideIn(
          delay: const Duration(milliseconds: 150),
          child: Text('Hoy', style: sans(size: 15, weight: 600)),
        ),
        const SizedBox(height: 10),

        if (turnos.isEmpty)
          FadeSlideIn(
            delay: const Duration(milliseconds: 190),
            child: const EstadoVacio(
              emoji: '🌿',
              titulo: 'Sin turnos hoy',
              detalle: 'Cuando cargues uno para hoy, va a aparecer acá.',
            ),
          )
        else
          for (var i = 0; i < turnos.length; i++)
            FadeSlideIn(
              delay: Duration(milliseconds: 190 + i * 40),
              child: _FilaTurno(turno: turnos[i]),
            ),
      ],
    );
  }
}

class _Balance extends StatelessWidget {
  const _Balance({required this.ingresos, required this.gastos});

  final double ingresos;
  final double gastos;

  @override
  Widget build(BuildContext context) {
    final neto = ingresos - gastos;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 20),
      decoration: BoxDecoration(
        gradient: MGradient.balance,
        borderRadius: BorderRadius.circular(MRadius.lg),
        boxShadow: MShadow.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Balance del mes',
            style: sans(size: 12, weight: 600, color: MColors.brandDark)
                .copyWith(letterSpacing: 0.06),
          ),
          const SizedBox(height: 8),
          Text(
            formatMoney(neto),
            style: serif(size: 34, weight: 600, color: MColors.tPrimary),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _MiniDato(etiqueta: 'Ingresos', valor: formatMoney(ingresos)),
              const SizedBox(width: 22),
              _MiniDato(etiqueta: 'Gastos', valor: formatMoney(gastos)),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniDato extends StatelessWidget {
  const _MiniDato({required this.etiqueta, required this.valor});

  final String etiqueta;
  final String valor;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            etiqueta,
            style: sans(
              size: 11,
              weight: 500,
              color: MColors.tMuted,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            valor,
            style: sans(size: 14, weight: 600, color: MColors.tSecondary),
          ),
        ],
      );
}

class _Kpi extends StatelessWidget {
  const _Kpi({
    required this.valor,
    required this.etiqueta,
    required this.icono,
  });

  final String valor;
  final String etiqueta;
  final IconData icono;

  @override
  Widget build(BuildContext context) => Container(
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
            Icon(icono, size: 18, color: MColors.brand),
            const SizedBox(height: 10),
            Text(valor, style: serif(size: 26, weight: 600)),
            Text(etiqueta, style: MText.menor),
          ],
        ),
      );
}

class _FilaTurno extends StatelessWidget {
  const _FilaTurno({required this.turno});

  final Appointment turno;

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: MColors.surface,
          borderRadius: BorderRadius.circular(MRadius.md),
          border: Border.all(color: MColors.border),
          boxShadow: MShadow.xs,
        ),
        child: Row(
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
                style:
                    sans(size: 13, weight: 600, color: MColors.brandDark),
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
              Text(formatMoney(turno.precio), style: MText.menor),
          ],
        ),
      );
}
