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
import '../../data/local/database.dart' as db;
import '../../data/local/mappers.dart';
import '../../data/repositories/business_repository.dart';
import '../../domain/rules/formatting.dart';
import '../../domain/entities/entities.dart';
import '../../domain/rules/reminders.dart';
import '../../domain/rules/stock.dart';
import '../ropa/mi_tienda.dart';
import '../shell/app_shell.dart';
import '../shell/vistas_comunes.dart';
import '../stock/stock_view.dart';

final turnosDeHoyProvider =
    StreamProvider.autoDispose<List<db.Appointment>>((ref) {
  final repo = ref.watch(businessRepoProvider);
  if (repo == null) return const Stream.empty();
  return repo.verTurnosDe(DateTime.now());
});

final movimientosDelMesProvider =
    StreamProvider.autoDispose<List<db.Transaction>>((ref) {
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

/// Turnos de los últimos 90 días y sus servicios: es lo que necesitan los
/// recordatorios de retoque.
final turnosRecientesProvider =
    StreamProvider.autoDispose<List<db.Appointment>>((ref) {
  final repo = ref.watch(businessRepoProvider);
  if (repo == null) return const Stream.empty();
  return repo.verTurnosRecientes();
});

final serviciosDeTurnosProvider =
    StreamProvider.autoDispose<Map<String, List<String>>>((ref) {
  final repo = ref.watch(businessRepoProvider);
  if (repo == null) return const Stream.empty();
  return repo.verServiciosDeTurnos();
});

final serviciosProvider = StreamProvider.autoDispose<List<db.Service>>((ref) {
  final repo = ref.watch(businessRepoProvider);
  if (repo == null) return const Stream.empty();
  return repo.verServicios();
});

final clientesProvider = StreamProvider.autoDispose<List<db.Client>>((ref) {
  final repo = ref.watch(businessRepoProvider);
  if (repo == null) return const Stream.empty();
  return repo.verClientes();
});

/// Movimientos de la semana en curso, para el dato de la derecha del hero.
final movimientosDeLaSemanaProvider =
    StreamProvider.autoDispose<List<db.Transaction>>((ref) {
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
    final clientes = ref.watch(clientesProvider).value ?? const <db.Client>[];
    final stock = (ref.watch(stockProvider).value ?? const <db.StockItem>[])
        .map(aStockItem)
        .toList();
    final alertas = stockAlerts(stock, limit: 3);

    // Los recordatorios de retoque necesitan el historial y el catálogo:
    // `pendingReminders` cruza el último turno hecho de cada clienta con los
    // días de retoque de su servicio.
    final serviciosPorTurno =
        ref.watch(serviciosDeTurnosProvider).value ?? const <String, List<String>>{};
    final recordatorios = pendingReminders(
      clients: clientes.map(aClient),
      // Los `serviceIds` viven en la tabla puente, así que hay que unirlos
      // acá: sin ellos `pendingReminders` no encuentra los días de retoque y
      // devuelve siempre vacío.
      appointments: (ref.watch(turnosRecientesProvider).value ??
              const <db.Appointment>[])
          .map((f) => aAppointment(f,
              serviceIds: serviciosPorTurno[f.id] ?? const [])),
      services: (ref.watch(serviciosProvider).value ?? const <db.Service>[])
          .map(aService),
      hoy: DateTime.now(),
    );

    // 'income' es el valor del enum `tx_tipo` de Postgres.
    num ingresosDe(List<db.Transaction> txs) => txs
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
          child: FilaSeccion(
            titulo: 'AGENDA DE HOY',
            accion: 'Ver todo',
            onAccion: () => NavegadorShell.ir(context, Vistas.agenda),
          ),
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

        // 4 · Acciones rápidas — `.qa-grid`
        FadeSlideIn(
          delay: const Duration(milliseconds: 190),
          child: const EtiquetaSeccion('ACCIONES RÁPIDAS'),
        ),
        FadeSlideIn(
          delay: const Duration(milliseconds: 220),
          child: Row(
            children: [
              _AccionRapida(
                emoji: '📅',
                titulo: 'Nuevo Turno',
                detalle: 'Agendar cita',
                fondo: MColors.lav50,
                borde: MColors.borderLav,
                onTap: () => NavegadorShell.ir(context, Vistas.agenda),
              ),
              const SizedBox(width: 10),
              _AccionRapida(
                emoji: '🌸',
                titulo: 'Nueva Clienta',
                detalle: 'Registrar',
                fondo: MColors.nude100,
                borde: MColors.nude300,
                onTap: () => NavegadorShell.ir(context, Vistas.clientas),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        FadeSlideIn(
          delay: const Duration(milliseconds: 250),
          child: Row(
            children: [
              _AccionRapida(
                emoji: '💰',
                titulo: 'Registrar Pago',
                detalle: 'Caja',
                fondo: MColors.successBg,
                borde: MColors.successBorder,
                onTap: () => NavegadorShell.ir(context, Vistas.caja),
              ),
              const SizedBox(width: 10),
              _AccionRapida(
                emoji: '📊',
                titulo: 'Estadísticas',
                detalle: 'Ver análisis',
                fondo: MColors.skyBg,
                borde: MColors.skyBorder,
                onTap: () => NavegadorShell.ir(context, Vistas.stats),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        FadeSlideIn(
          delay: const Duration(milliseconds: 265),
          child: Row(
            children: [
              _AccionRapida(
                emoji: '🛍️',
                titulo: 'Tienda',
                detalle: 'Catálogo y ventas',
                fondo: MColors.nude100,
                borde: MColors.nude300,
                onTap: () => NavegadorShell.ir(context, Vistas.ropa),
              ),
              const SizedBox(width: 10),
              _AccionRapida(
                emoji: '🔗',
                titulo: 'Compartir',
                detalle: 'El link de la tienda',
                fondo: MColors.lav50,
                borde: MColors.borderLav,
                onTap: () => mostrarMiTienda(context),
              ),
            ],
          ),
        ),

        // 5 · Alertas de stock
        if (alertas.isNotEmpty) ...[
          FadeSlideIn(
            delay: const Duration(milliseconds: 280),
            child: FilaSeccion(
              titulo: 'ALERTAS DE STOCK',
              accion: 'Ver stock',
              onAccion: () => NavegadorShell.ir(context, Vistas.stock),
            ),
          ),
          for (final s in alertas.take(3))
            FadeSlideIn(
              delay: const Duration(milliseconds: 300),
              child: _FilaAlertaStock(item: s),
            ),
        ],

        // 6 · Recordatorios de retoque — `#rem-wrap`, que en el original
        // está oculto salvo que haya algo que recordar.
        if (recordatorios.isNotEmpty) ...[
          FadeSlideIn(
            delay: const Duration(milliseconds: 320),
            child: const EtiquetaSeccion('RECORDATORIOS RETOQUE ✂️'),
          ),
          for (final r in recordatorios)
            FadeSlideIn(
              delay: const Duration(milliseconds: 340),
              child: _FilaRecordatorio(recordatorio: r),
            ),
        ],
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

  final db.Appointment turno;

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

/// `.qa-card` — ícono de 40 con su fondo de color, título y descripción.
class _AccionRapida extends StatelessWidget {
  const _AccionRapida({
    required this.emoji,
    required this.titulo,
    required this.detalle,
    required this.fondo,
    required this.borde,
    required this.onTap,
  });

  final String emoji;
  final String titulo;
  final String detalle;
  final Color fondo;
  final Color borde;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Expanded(
        child: TarjetaMirame(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          onTap: onTap,
          hijo: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: fondo,
                  border: Border.all(color: borde),
                  borderRadius: BorderRadius.circular(MRadius.sm),
                ),
                child: Text(emoji, style: const TextStyle(fontSize: 19)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: sans(size: 13, weight: 600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      detalle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: sans(size: 11, color: MColors.tMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}

class _FilaAlertaStock extends StatelessWidget {
  const _FilaAlertaStock({required this.item});

  final StockItem item;

  @override
  Widget build(BuildContext context) {
    final agotado = stockStatus(item) == StockStatus.out;
    return TarjetaMirame(
      margenInferior: 7,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      hijo: Row(
        children: [
          Text(agotado ? '🔴' : '⚠️', style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              item.nombre,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: sans(size: 13, weight: 500),
            ),
          ),
          Text(
            '${item.cantidad} ${item.unidad}',
            style: sans(
              size: 12,
              weight: 600,
              color: agotado ? MColors.dangerText : MColors.warningText,
            ),
          ),
        ],
      ),
    );
  }
}

/// `.rem-tag` — la píldora ámbar del retoque; roja si ya se pasó.
class _FilaRecordatorio extends StatelessWidget {
  const _FilaRecordatorio({required this.recordatorio});

  final Reminder recordatorio;

  @override
  Widget build(BuildContext context) {
    // `Reminder` ya sabe si venció y cómo se escribe la etiqueta: no se
    // reimplementa acá.
    final vencido = recordatorio.vencido;
    final etiqueta = recordatorio.etiqueta;

    return TarjetaMirame(
      margenInferior: 7,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      hijo: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: MGradient.avatar(avatarIndex(recordatorio.client.nombre)),
              shape: BoxShape.circle,
            ),
            child: Text(
              initials(recordatorio.client.nombre),
              style: sans(size: 13, weight: 600, color: MColors.tWhite),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recordatorio.client.nombre,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: sans(size: 13, weight: 600),
                ),
                Text(
                  recordatorio.service.nombre,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: sans(size: 11, color: MColors.tSecondary),
                ),
                const SizedBox(height: 5),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: vencido ? MColors.dangerBg : MColors.warningBg,
                    border: Border.all(
                      color: vencido
                          ? MColors.dangerBorder
                          : MColors.warningBorder,
                    ),
                    borderRadius: BorderRadius.circular(MRadius.full),
                  ),
                  child: Text(
                    '✂️ Retoque: $etiqueta',
                    style: sans(
                      size: 10,
                      weight: 600,
                      color: vencido
                          ? MColors.dangerText
                          : MColors.warningText,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
