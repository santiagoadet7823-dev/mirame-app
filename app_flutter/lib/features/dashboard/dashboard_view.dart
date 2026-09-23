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

import '../../core/layout/layout.dart';
import '../../core/theme/motion.dart';
import '../../core/theme/shadows.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../data/local/database.dart' as db;
import '../../data/local/mappers.dart';
import '../../data/repositories/business_repository.dart';
import '../../domain/rules/finance.dart';
import '../../domain/rules/formatting.dart';
import '../../domain/entities/entities.dart';
import '../../domain/rules/reminders.dart';
import '../../domain/rules/stock.dart';
import '../settings/catalogo.dart';
import '../shell/app_shell.dart';
import '../../shared/widgets/comportamiento.dart';
import '../../shared/widgets/piezas.dart';
import 'inicio_escritorio.dart';
import '../stats/stats_view.dart';
import '../shell/vistas_comunes.dart';
import '../stock/stock_view.dart';

final turnosDeHoyProvider =
    StreamProvider.autoDispose<List<db.Appointment>>((ref) {
  final repo = ref.watch(businessRepoProvider);
  if (repo == null) return Stream.value(const []);
  return repo.verTurnosDe(DateTime.now());
});

final movimientosDelMesProvider =
    StreamProvider.autoDispose<List<db.Transaction>>((ref) {
  final repo = ref.watch(businessRepoProvider);
  if (repo == null) return Stream.value(const []);
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
  if (repo == null) return Stream.value(const []);
  return repo.verTurnosRecientes();
});

final serviciosDeTurnosProvider =
    StreamProvider.autoDispose<Map<String, List<String>>>((ref) {
  final repo = ref.watch(businessRepoProvider);
  if (repo == null) return Stream.value(const {});
  return repo.verServiciosDeTurnos();
});

final serviciosProvider = StreamProvider.autoDispose<List<db.Service>>((ref) {
  final repo = ref.watch(businessRepoProvider);
  if (repo == null) return Stream.value(const []);
  return repo.verServicios();
});

final clientesProvider = StreamProvider.autoDispose<List<db.Client>>((ref) {
  final repo = ref.watch(businessRepoProvider);
  if (repo == null) return Stream.value(const []);
  return repo.verClientes();
});

/// Movimientos de la semana en curso, para el dato de la derecha del hero.
final movimientosDeLaSemanaProvider =
    StreamProvider.autoDispose<List<db.Transaction>>((ref) {
  final repo = ref.watch(businessRepoProvider);
  if (repo == null) return Stream.value(const []);
  final hoy = DateTime.now();
  // Semana domingo→sábado, igual que el original (`weekRange`).
  final domingo = hoy.subtract(Duration(days: hoy.weekday % 7));
  return repo.verMovimientosEntre(
      domingo, domingo.add(const Duration(days: 6)));
});

/// La KPI hero en violeta sólido con texto blanco, como la diseñó la segunda
/// vuelta. En `false` vuelve al gradiente claro con texto oscuro de siempre.
///
/// Está como interruptor y no decidido a fuego porque es **el elemento más
/// reconocible de la app**: el brief de la segunda vuelta decía "se queda
/// igual" y el diseñador la cambió igual. Se construyen las dos para poder
/// mirarlas en el teléfono y recién ahí decidir.
const kHeroEnBrand = true;

class DashboardView extends ConsumerWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final turnosDeHoy = ref.watch(turnosDeHoyProvider);
    final cargando = turnosDeHoy.isLoading && !turnosDeHoy.hasValue;
    final turnos = turnosDeHoy.value ?? const [];
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
    final serviciosPorTurno = ref.watch(serviciosDeTurnosProvider).value ??
        const <String, List<String>>{};
    final recordatorios = pendingReminders(
      clients: clientes.map(aClient),
      // Los `serviceIds` viven en la tabla puente, así que hay que unirlos
      // acá: sin ellos `pendingReminders` no encuentra los días de retoque y
      // devuelve siempre vacío.
      appointments: (ref.watch(turnosRecientesProvider).value ??
              const <db.Appointment>[])
          .map((f) =>
              aAppointment(f, serviceIds: serviciosPorTurno[f.id] ?? const [])),
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
    // Las filas de Drift; la tarjeta compartida habla el modelo del dominio.
    final turnosDom = turnos.map(aAppointment).toList();
    final nombrePorIdCliente = {for (final c in clientes) c.id: c.nombre};
    final nombrePorIdPro = {
      for (final p in ref.watch(profesionalesProvider).value ??
          const <db.Professional>[])
        p.id: p.nombre,
    };

    // El próximo turno del día: el primero que todavía no pasó.
    final ahora = DateTime.now();
    final minutosAhora = ahora.hour * 60 + ahora.minute;
    String? idProximo;
    for (final t in turnosDom) {
      final h = t.hora;
      if (t.estado == TurnoEstado.cancelled || h == null) continue;
      if (h.totalMinutes >= minutosAhora) {
        idProximo = t.id;
        break;
      }
    }

    final pendientes = turnos
        .where((t) => t.estado != 'done' && t.estado != 'cancelled')
        .length;

    final escritorio = esPantallaGrande(context);
    // La tablet del mostrador: mismo reparto que el escritorio, escalas de
    // dedo. Los chips de 44 son para apuntar con el mouse.
    final tablet = esTabletTactil(context);

    // Cinco acciones en círculos tintados, no seis tarjetas con emoji: el
    // emoji lo dibuja cada sistema a su manera y a 22 px un 📅 de Samsung no
    // se parece a uno de Xiaomi.
    final acciones = <ChipIcono>[
      ChipIcono(
        icono: Icons.calendar_today_outlined,
        etiqueta: 'Turno',
        tinte: TinteChip.lavanda,
        onTap: () => NavegadorShell.ir(context, Vistas.agenda),
      ),
      ChipIcono(
        icono: Icons.person_add_alt_1_outlined,
        etiqueta: 'Clienta',
        tinte: TinteChip.nude,
        onTap: () => NavegadorShell.ir(context, Vistas.clientas),
      ),
      ChipIcono(
        icono: Icons.attach_money_rounded,
        etiqueta: 'Pago',
        tinte: TinteChip.exito,
        onTap: () => NavegadorShell.ir(context, Vistas.caja),
      ),
      ChipIcono(
        icono: Icons.shopping_bag_outlined,
        etiqueta: 'Venta',
        tinte: TinteChip.aviso,
        onTap: () => NavegadorShell.ir(context, Vistas.ropa),
      ),
      ChipIcono(
        icono: Icons.insert_chart_outlined_rounded,
        etiqueta: 'Stats',
        tinte: TinteChip.cielo,
        onTap: () => NavegadorShell.ir(context, Vistas.stats),
      ),
    ];

    // En escritorio el Inicio se arma distinto: la hero estirada a mil
    // píxeles mostraba cuatro números y dejaba la agenda vacía al lado.
    if (escritorio) {
      final movs = ref.watch(movimientosRecientesProvider).value ??
          const <db.Transaction>[];
      final txs = movs.map(aTransaction).toList();
      final porSemana = weeklyIncome(txs, DateTime.now());
      // Las dos series que pide la entrega: servicios en lavanda, tienda en
      // nude. La venta de tienda se registra con `categoria: 'ropa'`
      // (`ropa_repository.dart`, `registrarVenta`); todo el resto de los
      // ingresos es trabajo del salón.
      final porSemanaServicios =
          weeklyIncome(txs.where((t) => t.categoria != 'ropa'), DateTime.now());
      final porSemanaTienda =
          weeklyIncome(txs.where((t) => t.categoria == 'ropa'), DateTime.now());
      final estaSemana = porSemana.isEmpty ? 0 : porSemana.last.total;
      final semanaAnterior =
          porSemana.length < 2 ? 0 : porSemana[porSemana.length - 2].total;
      final (varSemana, tonoSemana) =
          variacionTexto(estaSemana, semanaAnterior);

      return ContenidoEscritorio.tabla(
        // Scrollea: en una ventana baja —una notebook de 768, el navegador
        // con la barra de favoritos— un Column rígido recorta el gráfico en
        // vez de dejar bajar.
        child: SingleChildScrollView(
          padding: padVista(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          greeting(DateTime.now()),
                          style: serif(size: 30, weight: 500),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          [
                            formatDateShort(DateTime.now()),
                            if (turnos.isNotEmpty)
                              '${turnos.length} '
                                  '${turnos.length == 1 ? "turno" : "turnos"}',
                          ].join(' · '),
                          style: sans(size: 13, color: MColors.tMuted),
                        ),
                      ],
                    ),
                  ),
                  // Las mismas acciones del teléfono, más chicas: acá
                  // "Nuevo turno" ya vive en la barra de arriba. Con ancho
                  // fijo porque la barra reparte a sus hijos y adentro de
                  // una fila no sabría entre cuánto repartir.
                  SizedBox(
                    width: (tablet ? 80.0 : 64.0) * (acciones.length - 1),
                    child: BarraDeAcciones(
                      lado: tablet ? 58 : 44,
                      acciones: acciones.sublist(1),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Las cuatro en UNA fila, que es lo que pide la entrega del
              // diseñador, pero por ancho disponible y no por un número fijo:
              // con `maxCrossAxisExtent: 320` a 1032 px entraban tres y la
              // cuarta bajaba sola a un segundo renglón. `columnasPara` ya
              // estaba escrito para esto y no se usaba en ningún lado.
              LayoutBuilder(
                builder: (_, c) => GridView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount:
                        columnasPara(c.maxWidth, minAncho: 210, max: 4),
                    // 124 y no 108: con la etiqueta, el número de 34 y el pie,
                    // 108 se pasaba por 9 px justo cuando el sistema agranda
                    // un poco el texto.
                    mainAxisExtent: 124,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                  ),
                  children: [
                  TarjetaKpi(
                    etiqueta: 'Turnos hoy',
                    valor: '${turnos.length}',
                    pie: deHoy > 0 ? '${formatMoney(deHoy)} agendado' : null,
                  ),
                  TarjetaKpi(
                    etiqueta: 'Esta semana',
                    valor: formatMoney(deLaSemana),
                    variacion: varSemana.isEmpty ? null : varSemana,
                    tono: tonoSemana,
                  ),
                  TarjetaKpi(
                    etiqueta: 'Este mes',
                    valor: formatMoney(delMes),
                    pie: '${clientes.length} clientas',
                  ),
                  TarjetaKpi(
                    etiqueta: 'Pendientes',
                    valor: '$pendientes',
                    variacion: pendientes > 0 ? 'a confirmar' : null,
                    tono: TonoVariacion.atencion,
                  ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              _GraficoYAgenda(
                servicios: [for (final s in porSemanaServicios) s.total],
                tienda: [for (final s in porSemanaTienda) s.total],
                turnos: turnosDom,
                nombrePorIdCliente: nombrePorIdCliente,
                nombrePorIdPro: nombrePorIdPro,
                idProximo: idProximo,
              ),
              // Los retoques y los insumos bajo el mínimo existían solo en el
              // teléfono: en la pantalla grande sobraba lugar y justo faltaban
              // las dos cosas que hacen falta mirar sin que nadie las pida.
              if (recordatorios.isNotEmpty || alertas.isNotEmpty) ...[
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (recordatorios.isNotEmpty)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FilaSeccion(
                              titulo: 'PRÓXIMOS RETOQUES ✂️',
                              accion: 'Ver clientas',
                              onAccion: () =>
                                  NavegadorShell.ir(context, Vistas.clientas),
                            ),
                            for (final r in recordatorios.take(3))
                              _FilaRecordatorio(recordatorio: r),
                          ],
                        ),
                      ),
                    if (recordatorios.isNotEmpty && alertas.isNotEmpty)
                      const SizedBox(width: 16),
                    if (alertas.isNotEmpty)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FilaSeccion(
                              titulo: 'ALERTAS DE STOCK',
                              accion: 'Ver insumos',
                              onAccion: () =>
                                  NavegadorShell.ir(context, Vistas.stock),
                            ),
                            for (final a in alertas.take(3))
                              _FilaAlertaStock(item: a),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      );
    }

    return ContenidoEscritorio.lectura(
      child: ListView(
        padding: padVista(context),
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
          if (cargando)
            const EsqueletoDeLista(
              filas: 2,
              alto: 62,
              padding: EdgeInsets.zero,
              desplazable: false,
            )
          else if (turnos.isEmpty)
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
                child: TarjetaTurno(
                  turno: turnosDom[i],
                  nombreCliente: nombrePorIdCliente[turnosDom[i].clientId],
                  profesional: nombrePorIdPro[turnosDom[i].professionalId],
                  destacada: turnosDom[i].id == idProximo,
                  onTap: () => NavegadorShell.ir(context, Vistas.agenda),
                ),
              ),

          // 4 · Acciones rápidas — una fila de cinco círculos.
          //
          // Entran los cinco en 390 px, así que no scrollea: una fila de
          // acciones que se desliza esconde la mitad de lo que ofrece.
          FadeSlideIn(
            delay: const Duration(milliseconds: 190),
            child: Padding(
              padding: const EdgeInsets.only(top: 18, bottom: 4),
              child: BarraDeAcciones(
                acciones: acciones,
                lado: escritorio ? 48 : 56,
              ),
            ),
          ),

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
        ],
      ),
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

  /// Sobre el violeta el texto es blanco; sobre el crema, el de siempre.
  Color get _tinta => kHeroEnBrand ? MColors.tWhite : MColors.tPrimary;
  Color get _tintaSuave =>
      kHeroEnBrand ? MColors.tWhite.withValues(alpha: 0.72) : MColors.tMuted;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 18),
        decoration: BoxDecoration(
          gradient: kHeroEnBrand
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [MColors.brand, MColors.lav600],
                )
              : MGradient.kpiHero,
          border: Border.all(
            color: kHeroEnBrand ? Colors.transparent : MColors.borderLav,
          ),
          borderRadius: BorderRadius.circular(MRadius.xl),
          boxShadow: kHeroEnBrand ? MShadow.brand : null,
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
                      Text(
                        'TURNOS HOY',
                        style: MText.etiquetaHero.copyWith(color: _tintaSuave),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '$turnosHoy',
                        style: serif(size: 42, weight: 600, color: _tinta)
                            .copyWith(height: 1, letterSpacing: -1),
                      ),
                      if (ingresoHoy > 0) ...[
                        const SizedBox(height: 5),
                        Text(
                          '${formatMoney(ingresoHoy)} agendado',
                          style: sans(size: 12, color: _tintaSuave),
                        ),
                      ],
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'ESTA SEMANA',
                      style:
                          MText.etiquetaHeroChica.copyWith(color: _tintaSuave),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatMoney(ingresoSemana),
                      style: serif(size: 22, weight: 600, color: _tinta),
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
              gradient:
                  MGradient.avatar(avatarIndex(recordatorio.client.nombre)),
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
                      color: vencido ? MColors.dangerText : MColors.warningText,
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

/// El gráfico y la agenda del día, uno al lado del otro **si entran**.
///
/// La entrega los pide 3/5 y 2/5, y a 1280 es exactamente eso. Pero el reparto
/// fijo se rompía en las pantallas grandes más chicas: en la tablet del
/// mostrador (853 px lógicos) el panel de la agenda quedaba en 133 px de ancho,
/// las filas se envolvían y la columna desbordaba 67 px hacia abajo, clipeados
/// sin avisar. Por debajo de 860 px de ancho van apilados, que es la misma
/// información sin recortar nada.
class _GraficoYAgenda extends StatelessWidget {
  const _GraficoYAgenda({
    required this.servicios,
    required this.tienda,
    required this.turnos,
    required this.nombrePorIdCliente,
    required this.nombrePorIdPro,
    required this.idProximo,
  });

  final List<num> servicios;
  final List<num> tienda;
  final List<Appointment> turnos;
  final Map<String, String> nombrePorIdCliente;
  final Map<String, String> nombrePorIdPro;
  final String? idProximo;

  /// Debajo de esto, el panel de la agenda queda más angosto que sus propias
  /// filas y no hay reparto que lo salve.
  static const _minimoParaDosColumnas = 860.0;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (_, c) {
          final grafico = GraficoDeArea(
            serieA: servicios,
            serieB: tienda,
            etiquetas: const [],
          );
          final agenda = AgendaCompacta(
            turnos: turnos,
            nombrePorId: nombrePorIdCliente,
            nombreProfesional: nombrePorIdPro,
            idProximo: idProximo,
            onVerAgenda: () => NavegadorShell.ir(context, Vistas.agenda),
          );

          if (c.maxWidth < _minimoParaDosColumnas) {
            // Los dos con alto propio: `AgendaCompacta` reparte su alto con un
            // `Expanded`, así que adentro de una columna que scrollea —alto sin
            // tope— no sabría entre cuánto repartir.
            return Column(
              children: [
                SizedBox(height: 300, child: grafico),
                const SizedBox(height: 16),
                SizedBox(height: 320, child: agenda),
              ],
            );
          }

          return SizedBox(
            // Alto fijo y generoso: el gráfico necesita aire para que la curva
            // se lea, y la agenda entra con cuatro turnos.
            height: 360,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(flex: 3, child: grafico),
                const SizedBox(width: 16),
                Expanded(flex: 2, child: agenda),
              ],
            ),
          );
        },
      );
}
