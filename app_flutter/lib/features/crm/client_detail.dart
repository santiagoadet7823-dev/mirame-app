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
import '../shell/vistas_comunes.dart';
import 'clients_view.dart';

/// Historial de una clienta, del más nuevo al más viejo.
final historialClienteProvider =
    StreamProvider.autoDispose.family<List<db.Appointment>, String>(
        (ref, clienteId) {
  final repo = ref.watch(businessRepoProvider);
  if (repo == null) return const Stream.empty();
  return repo.verTurnosDeCliente(clienteId);
});

Future<void> mostrarFichaCliente(BuildContext context, db.Client cliente) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        // El historial puede ser largo; que arranque alto y se pueda estirar
        // evita que la persona tenga que hacer scroll dentro de un sheet chico.
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scroll) =>
            _FichaCliente(cliente: cliente, scroll: scroll),
      ),
    );

class _FichaCliente extends ConsumerWidget {
  const _FichaCliente({required this.cliente, required this.scroll});

  final db.Client cliente;
  final ScrollController scroll;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final turnos =
        (ref.watch(historialClienteProvider(cliente.id)).value ??
                const <db.Appointment>[])
            .map((f) => aAppointment(f))
            .toList();

    final total = turnos.fold<num>(0, (a, t) => a + t.precio);
    final promedio = turnos.isEmpty ? 0 : (total / turnos.length).round();

    return Container(
      decoration: const BoxDecoration(
        color: MColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(MRadius.xl)),
      ),
      child: ListView(
        controller: scroll,
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
        children: [
          Center(
            child: Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: MColors.borderMd,
                borderRadius: BorderRadius.circular(MRadius.full),
              ),
            ),
          ),

          // 1 · Cabecera
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: MGradient.avatar(avatarIndex(cliente.nombre)),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    initials(cliente.nombre),
                    style:
                        sans(size: 26, weight: 700, color: MColors.tWhite),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  cliente.nombre,
                  textAlign: TextAlign.center,
                  style: serif(size: 22, weight: 500),
                ),
                if (cliente.vip) ...[
                  const SizedBox(height: 6),
                  const TagVip(),
                ],
              ],
            ),
          ),

          // 2 · Los tres números
          Row(
            children: [
              _Dato(valor: '${turnos.length}', etiqueta: 'Turnos'),
              const SizedBox(width: 8),
              _Dato(
                valor: formatMoney(total),
                etiqueta: 'Total',
                tamanio: 16,
              ),
              const SizedBox(width: 8),
              _Dato(
                valor: formatMoney(promedio),
                etiqueta: 'Promedio',
                tamanio: 16,
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 3 · WhatsApp
          if (cliente.telefono?.isNotEmpty ?? false)
            TarjetaMirame(
              margenInferior: 10,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              hijo: Row(
                children: [
                  const Text('📱', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('WhatsApp',
                            style: sans(size: 11, color: MColors.tMuted)),
                        Text(cliente.telefono!,
                            style: sans(size: 14, weight: 500)),
                      ],
                    ),
                  ),
                  _BotonWa(telefono: cliente.telefono!),
                ],
              ),
            ),

          // 4 · Observaciones
          if (cliente.notas?.isNotEmpty ?? false)
            TarjetaMirame(
              margenInferior: 12,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              hijo: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'OBSERVACIONES',
                    style: sans(size: 10, weight: 600, color: MColors.tMuted)
                        .copyWith(letterSpacing: 1),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    cliente.notas!,
                    style: sans(size: 13, color: MColors.tSecondary)
                        .copyWith(height: 1.6),
                  ),
                ],
              ),
            ),

          // 5 · Historial
          Text(
            'HISTORIAL',
            style: sans(size: 11, weight: 600, color: MColors.tMuted)
                .copyWith(letterSpacing: 0.8),
          ),
          const SizedBox(height: 8),
          if (turnos.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 18),
              child: Text(
                'Todavía no vino',
                textAlign: TextAlign.center,
                style: sans(size: 13, color: MColors.tMuted),
              ),
            )
          else
            // Los últimos 5, como el original: la ficha es un vistazo, no un
            // libro de contabilidad.
            for (final t in turnos.take(5)) _FilaHistorial(turno: t),

          const SizedBox(height: 14),
          PressableScale(
            onTap: () {
              Navigator.of(context).pop();
              mostrarFormularioCliente(context, ref, cliente: cliente);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 13),
              decoration: BoxDecoration(
                color: MColors.bg2,
                border: Border.all(color: MColors.borderMd),
                borderRadius: BorderRadius.circular(MRadius.full),
              ),
              child: Text(
                'Editar datos',
                textAlign: TextAlign.center,
                style:
                    sans(size: 14, weight: 600, color: MColors.tSecondary),
              ),
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

class _BotonWa extends StatelessWidget {
  const _BotonWa({required this.telefono});

  final String telefono;

  @override
  Widget build(BuildContext context) => PressableScale(
        onTap: () async {
          final limpio = telefono.replaceAll(RegExp(r'\D'), '');
          if (limpio.isEmpty) return;
          await launchUrl(
            Uri.parse('https://wa.me/$limpio'),
            mode: LaunchMode.externalApplication,
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: MColors.successBg,
            border: Border.all(color: MColors.successBorder),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'WA',
            style:
                sans(size: 12, weight: 600, color: MColors.successText),
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              decoration: BoxDecoration(
                color: MColors.brandBg,
                borderRadius: BorderRadius.circular(MRadius.sm),
              ),
              child: Text(
                formatDateShort(turno.fecha),
                style:
                    sans(size: 10, weight: 700, color: MColors.brand),
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
