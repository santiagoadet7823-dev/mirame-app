/// Ficha de clienta. Portado de `openCliDetail()` del `index.html`.
///
/// Es lo que se abre al tocar una clienta — **no** el formulario de edición.
/// La diferencia importa: lo que se hace todo el tiempo es mirar el historial
/// y mandar un WhatsApp, no cambiarle el nombre.
///
/// Estructura del original:
///   1. avatar de 72 centrado, nombre en Cormorant 22/500 y el tag VIP
///   2. tres tarjetas: turnos · total · promedio
///   3. fila de WhatsApp, si tiene teléfono
///   4. observaciones, si tiene
///   5. historial: los últimos 5 turnos
///   6. botón de editar
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/motion.dart';
import '../../core/theme/shadows.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../data/local/database.dart' as db;
import '../../data/local/mappers.dart';
import '../../data/repositories/business_repository.dart';
import '../../domain/entities/entities.dart';
import '../../domain/rules/formatting.dart';
import '../../shared/widgets/piezas.dart';
import '../../shared/widgets/comportamiento.dart';
import '../shell/app_shell.dart';
import '../shell/vistas_comunes.dart';
import 'clients_view.dart';

/// Historial de una clienta, del más nuevo al más viejo.
final historialClienteProvider = StreamProvider.autoDispose
    .family<List<db.Appointment>, String>((ref, clienteId) {
  final repo = ref.watch(businessRepoProvider);
  if (repo == null) return Stream.value(const []);
  return repo.verTurnosDeCliente(clienteId);
});

/// Lo que pagó esta clienta. Sale de `Transactions.client_id`, que ya existía:
/// es como se guardan los cobros de turno.
final pagosClienteProvider = StreamProvider.autoDispose
    .family<List<db.Transaction>, String>((ref, clienteId) {
  final repo = ref.watch(businessRepoProvider);
  if (repo == null) return Stream.value(const []);
  return repo.verMovimientosDeCliente(clienteId);
});

/// Abre la ficha.
///
/// Dejó de ser un sheet arrastrable: ahora es una **pantalla completa** que
/// se empuja encima. El sheet servía cuando la ficha eran tres números y
/// cinco filas; con banda, acciones y tabs, arrastrarlo para leer el
/// historial era pelear con la pantalla.
Future<void> mostrarFichaCliente(BuildContext context, db.Client cliente) =>
    Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: MColors.bg,
          body: FichaCliente(cliente: cliente),
        ),
      ),
    );

/// La ficha: cabecera, tres números, WhatsApp, observaciones e historial.
///
/// Vive en un sheet en el teléfono y en el panel lateral en escritorio
/// ([enPanel]): mismo contenido, sin manija ni fondo propio, y "Editar" no
/// tiene nada que cerrar antes de abrir el formulario.
class FichaCliente extends ConsumerStatefulWidget {
  const FichaCliente({
    super.key,
    required this.cliente,
    this.scroll,
    this.enPanel = false,
  });

  final db.Client cliente;
  final ScrollController? scroll;

  /// En el panel lateral de escritorio: banda más baja, sin botón de volver
  /// (se cierra con la ×) y sin CTA flotante, que va al pie del panel.
  final bool enPanel;

  @override
  ConsumerState<FichaCliente> createState() => _FichaClienteState();
}

class _FichaClienteState extends ConsumerState<FichaCliente> {
  String _tab = 'Historial';

  db.Client get cliente => widget.cliente;

  @override
  Widget build(BuildContext context) {
    final enPanel = widget.enPanel;
    final turnos = (ref.watch(historialClienteProvider(cliente.id)).value ??
            const <db.Appointment>[])
        .map((f) => aAppointment(f))
        .toList();
    final pagos = ref.watch(pagosClienteProvider(cliente.id)).value ??
        const <db.Transaction>[];

    final total = turnos.fold<num>(0, (a, t) => a + t.precio);
    final promedio = turnos.isEmpty ? 0 : (total / turnos.length).round();
    final tel = cliente.telefono;
    final tieneTel = tel?.isNotEmpty ?? false;

    return Column(
      children: [
        Expanded(
          child: ListaConEncabezado(
            // La banda y las tabs quedan fijas; scrollea solo el contenido de
            // la tab. Sin esto, al bajar por el historial se perdía de vista
            // de quién era la ficha.
            encabezado: (_, hayArriba) => _Cabecera(
              cliente: cliente,
              enPanel: enPanel,
              hayArriba: hayArriba,
              turnos: turnos.length,
              total: total,
              promedio: promedio,
              tab: _tab,
              onTab: (t) => setState(() => _tab = t),
              onEditar: () =>
                  mostrarFormularioCliente(context, ref, cliente: cliente),
              onCerrar: enPanel ? null : () => Navigator.of(context).pop(),
              tieneTelefono: tieneTel,
              onWhatsapp: tieneTel ? () => _abrirWhatsapp(tel!) : null,
              onLlamar: tieneTel ? () => _llamar(tel!) : null,
              onTurno: () {
                if (!enPanel) Navigator.of(context).pop();
                NavegadorShell.ir(context, Vistas.agenda);
              },
            ),
            lista: _ContenidoTab(
              tab: _tab,
              cliente: cliente,
              turnos: turnos,
              pagos: pagos,
              scroll: widget.scroll,
            ),
          ),
        ),
        // En el panel el CTA va al pie con borde, sin degradé: no hay nada
        // que se le pase por abajo.
        CtaFijo(
          texto: 'Agendar turno',
          icono: Icons.add_rounded,
          conDegrade: !enPanel,
          onTap: () {
            if (!enPanel) Navigator.of(context).pop();
            NavegadorShell.ir(context, Vistas.agenda);
          },
        ),
      ],
    );
  }

  Future<void> _abrirWhatsapp(String telefono) async {
    final limpio = telefono.replaceAll(RegExp(r'\D'), '');
    if (limpio.isEmpty) return;
    await launchUrl(
      Uri.parse('https://wa.me/$limpio'),
      mode: LaunchMode.externalApplication,
    );
  }

  Future<void> _llamar(String telefono) async {
    final limpio = telefono.replaceAll(RegExp(r'[^0-9+]'), '');
    if (limpio.isEmpty) return;
    await launchUrl(Uri.parse('tel:$limpio'));
  }
}

/// Banda con gradiente, avatar superpuesto, píldoras, los tres números, la
/// barra de acciones y las tabs. Todo lo que no scrollea.
class _Cabecera extends StatelessWidget {
  const _Cabecera({
    required this.cliente,
    required this.enPanel,
    required this.hayArriba,
    required this.turnos,
    required this.total,
    required this.promedio,
    required this.tab,
    required this.onTab,
    required this.onEditar,
    required this.onCerrar,
    required this.tieneTelefono,
    required this.onWhatsapp,
    required this.onLlamar,
    required this.onTurno,
  });

  final db.Client cliente;
  final bool enPanel;
  final bool hayArriba;
  final int turnos;
  final num total;
  final num promedio;
  final String tab;
  final ValueChanged<String> onTab;
  final VoidCallback onEditar;
  final VoidCallback? onCerrar;
  final bool tieneTelefono;
  final VoidCallback? onWhatsapp;
  final VoidCallback? onLlamar;
  final VoidCallback onTurno;

  @override
  Widget build(BuildContext context) {
    final altoBanda = enPanel ? 120.0 : 170.0;
    final ladoAvatar = enPanel ? 68.0 : 84.0;

    return AnimatedContainer(
      duration: MMotion.t1,
      decoration: BoxDecoration(
        color: MColors.bg,
        boxShadow: sombraEncabezado(hayArriba),
      ),
      child: Column(
        children: [
          SizedBox(
            height: altoBanda + ladoAvatar / 2,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: altoBanda,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [MColors.lav50, MColors.nude100],
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 14,
                  right: 14,
                  child: SafeArea(
                    bottom: false,
                    child: Row(
                      children: [
                        if (onCerrar != null)
                          _BotonFlotante(
                            icono: Icons.chevron_left_rounded,
                            onTap: onCerrar!,
                          ),
                        const Spacer(),
                        _BotonFlotante(
                          icono: Icons.edit_outlined,
                          onTap: onEditar,
                        ),
                        const SizedBox(width: 9),
                        _BotonFlotante(
                          icono: cliente.vip
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color: cliente.vip ? MColors.nude500 : null,
                          onTap: onEditar,
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 20,
                  top: altoBanda - ladoAvatar / 2,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: MColors.bg,
                      shape: BoxShape.circle,
                    ),
                    child: AvatarMirame(
                      nombre: cliente.nombre,
                      lado: ladoAvatar,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cliente.nombre,
                  style: serif(size: enPanel ? 21 : 24, weight: 600),
                ),
                const SizedBox(height: 7),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    if (cliente.vip)
                      const Pildora(
                        texto: 'VIP',
                        fondo: MColors.nude100,
                        color: MColors.nude700,
                        borde: MColors.nude300,
                      ),
                    Pildora(
                      texto: 'Clienta desde ${_desde(cliente.createdAt)}',
                      fondo: MColors.bg2,
                      color: MColors.tSecondary,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _Dato(valor: '$turnos', etiqueta: 'Turnos'),
                    const SizedBox(width: 8),
                    _Dato(
                      valor: formatMoney(total),
                      etiqueta: 'Total',
                      tamanio: enPanel ? 16 : 18,
                    ),
                    const SizedBox(width: 8),
                    _Dato(
                      valor: formatMoney(promedio),
                      etiqueta: enPanel ? 'Prom.' : 'Promedio',
                      tamanio: enPanel ? 16 : 18,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                BarraDeAcciones(
                  lado: enPanel ? 44 : 52,
                  acciones: [
                    ChipIcono(
                      icono: Icons.chat_bubble_outline_rounded,
                      etiqueta: 'WhatsApp',
                      tinte: TinteChip.exito,
                      onTap: onWhatsapp,
                    ),
                    ChipIcono(
                      icono: Icons.phone_outlined,
                      etiqueta: 'Llamar',
                      tinte: TinteChip.lavanda,
                      onTap: onLlamar,
                    ),
                    ChipIcono(
                      icono: Icons.calendar_today_outlined,
                      etiqueta: 'Turno',
                      tinte: TinteChip.nude,
                      onTap: onTurno,
                    ),
                    ChipIcono(
                      icono: Icons.share_outlined,
                      etiqueta: 'Compartir',
                      tinte: TinteChip.cielo,
                      onTap: tieneTelefono ? onWhatsapp : null,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                TabsMirame(
                  // Sin "Fotos": no hay dónde guardarlas todavía. Mejor tres
                  // tabs que funcionan que cuatro con una vacía.
                  tabs: const ['Historial', 'Notas', 'Pagos'],
                  activa: tab,
                  onElegir: onTab,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _desde(DateTime d) => '${_meses[d.month - 1]} ${d.year}';

  static const _meses = [
    'ene',
    'feb',
    'mar',
    'abr',
    'may',
    'jun',
    'jul',
    'ago',
    'sep',
    'oct',
    'nov',
    'dic',
  ];
}

class _BotonFlotante extends StatelessWidget {
  const _BotonFlotante({required this.icono, required this.onTap, this.color});

  final IconData icono;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) => PressableScale(
        onTap: onTap,
        child: Container(
          width: 38,
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: MColors.surface.withValues(alpha: 0.85),
            shape: BoxShape.circle,
            boxShadow: MShadow.xs,
          ),
          child: Icon(icono, size: 19, color: color ?? MColors.tSecondary),
        ),
      );
}

/// El contenido de la tab elegida. Es lo único que scrollea.
class _ContenidoTab extends StatelessWidget {
  const _ContenidoTab({
    required this.tab,
    required this.cliente,
    required this.turnos,
    required this.pagos,
    this.scroll,
  });

  final String tab;
  final db.Client cliente;
  final List<Appointment> turnos;
  final List<db.Transaction> pagos;
  final ScrollController? scroll;

  @override
  Widget build(BuildContext context) {
    final hijos = switch (tab) {
      'Notas' => [
          if (cliente.notas?.isNotEmpty ?? false)
            TarjetaMirame(
              padding: const EdgeInsets.all(14),
              hijo: Text(
                cliente.notas!,
                style: sans(size: 13, color: MColors.tSecondary)
                    .copyWith(height: 1.65),
              ),
            )
          else
            const EstadoVacio(
              emoji: '📝',
              titulo: 'Sin observaciones',
              detalle: 'Lo que anotes acá aparece cada vez que la atiendas.',
            ),
        ],
      'Pagos' => [
          if (pagos.isEmpty)
            const EstadoVacio(
              emoji: '💸',
              titulo: 'Sin pagos registrados',
              detalle: 'Los cobros que cargues en Caja a nombre de esta '
                  'clienta aparecen acá.',
            )
          else ...[
            for (final p in pagos) _FilaPago(pago: p),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total cobrado',
                    style: sans(size: 12, color: MColors.tMuted)),
                Text(
                  formatMoney(
                    pagos.fold<num>(0, (a, p) => a + p.monto),
                  ),
                  style: serif(size: 19, weight: 600),
                ),
              ],
            ),
          ],
        ],
      _ => [
          if (turnos.isEmpty)
            const EstadoVacio(
              emoji: '🌿',
              titulo: 'Todavía no vino',
              detalle: 'Cuando tenga su primer turno, el historial arranca '
                  'acá.',
            )
          else
            for (final t in turnos) _FilaHistorial(turno: t),
        ],
    };

    return ListView(
      controller: scroll,
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 20),
      children: hijos,
    );
  }
}

/// Una fila de la tab Pagos.
class _FilaPago extends StatelessWidget {
  const _FilaPago({required this.pago});

  final db.Transaction pago;

  @override
  Widget build(BuildContext context) {
    final esIngreso = pago.tipo == 'income';
    return TarjetaMirame(
      margenInferior: 7,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      hijo: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: esIngreso ? MColors.successBg : MColors.dangerBg,
              shape: BoxShape.circle,
            ),
            child: Icon(
              esIngreso
                  ? Icons.arrow_upward_rounded
                  : Icons.arrow_downward_rounded,
              size: 16,
              color: esIngreso ? MColors.successText : MColors.dangerText,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  pago.descripcion?.isNotEmpty ?? false
                      ? pago.descripcion!
                      : (pago.categoria ?? 'Movimiento'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: sans(size: 13, weight: 500),
                ),
                Text(
                  pago.fecha,
                  style: sans(size: 11, color: MColors.tMuted),
                ),
              ],
            ),
          ),
          Text(
            formatMoney(pago.monto),
            style: serif(
              size: 17,
              weight: 600,
              color: esIngreso ? MColors.ingreso : MColors.gasto,
            ),
          ),
        ],
      ),
    );
  }
}

class _Dato extends StatelessWidget {
  const _Dato({
    required this.valor,
    required this.etiqueta,
    this.tamanio = 22,
  });

  final String valor;
  final String etiqueta;
  final double tamanio;

  @override
  Widget build(BuildContext context) => Expanded(
        child: TarjetaMirame(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          hijo: Column(
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
                style: sans(size: 10, color: MColors.tMuted),
              ),
            ],
          ),
        ),
      );
}

class _FilaHistorial extends StatelessWidget {
  const _FilaHistorial({required this.turno});

  final Appointment turno;

  @override
  Widget build(BuildContext context) => TarjetaMirame(
        margenInferior: 6,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        hijo: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              decoration: BoxDecoration(
                color: MColors.brandBg,
                borderRadius: BorderRadius.circular(MRadius.sm),
              ),
              child: Text(
                formatDateShort(turno.fecha),
                style: sans(size: 10, weight: 700, color: MColors.brand),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                [
                  turno.hora?.toString(),
                  if (turno.precio > 0) formatMoney(turno.precio),
                ].whereType<String>().join(' · '),
                style: sans(size: 12, color: MColors.tSecondary),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            BadgeEstado(textoDesdeEstado(turno.estado)),
          ],
        ),
      );
}
