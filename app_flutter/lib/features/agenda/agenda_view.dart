/// Agenda: los turnos del día elegido.
///
/// La detección de solapamientos sale de `domain/rules/agenda.dart` — es una
/// corrección respecto del legacy, que no la tenía y dejaba pisar turnos.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/notificaciones/pedir_permiso.dart';
import '../../core/theme/motion.dart';
import '../../core/theme/shadows.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../data/local/database.dart' as db;
import '../../data/local/mappers.dart';
import '../../data/repositories/business_repository.dart';
import '../../domain/entities/entities.dart';
import '../../domain/rules/access.dart';
import '../../domain/rules/formatting.dart';
import '../../domain/rules/period.dart';
import '../auth/session_controller.dart';
import '../dashboard/dashboard_view.dart';
import 'calendario.dart';
import '../shell/app_shell.dart';
import '../shell/vistas_comunes.dart';

/// Turnos del día que se está mirando.
final turnosDelDiaProvider =
    StreamProvider.autoDispose.family<List<db.Appointment>, String>(
  (ref, claveDia) {
    final repo = ref.watch(businessRepoProvider);
    if (repo == null) return const Stream.empty();
    // La clave es el 'YYYY-MM-DD' y no un DateTime: dos DateTime del mismo día
    // con distinta hora son objetos distintos, y `family` crearía un provider
    // nuevo en cada rebuild.
    return repo.verTurnosDe(fechaDesdeTexto(claveDia));
  },
);

/// Turnos del mes visible, solo para marcar con un punto los días que tienen
/// algo. Va aparte de los del día para que cambiar de día no vuelva a
/// consultar el mes entero.
final turnosDelMesVisibleProvider =
    StreamProvider.autoDispose.family<List<db.Appointment>, String>(
        (ref, claveMes) {
  final repo = ref.watch(businessRepoProvider);
  if (repo == null) return const Stream.empty();
  final partes = claveMes.split('-');
  final y = int.parse(partes[0]);
  final m = int.parse(partes[1]);
  return repo.verTurnosEntre(DateTime(y, m, 1), DateTime(y, m + 1, 0));
});

class AgendaView extends ConsumerStatefulWidget {
  const AgendaView({super.key});

  @override
  ConsumerState<AgendaView> createState() => _AgendaViewState();
}

class _AgendaViewState extends ConsumerState<AgendaView> {
  DateTime _dia = DateTime.now();
  late DateTime _mes = DateTime(_dia.year, _dia.month, 1);
  String _filtro = 'all';

  @override
  Widget build(BuildContext context) {
    final clave = claveFecha(_dia);
    final claveMes =
        '${_mes.year}-${_mes.month.toString().padLeft(2, '0')}';
    final filas =
        ref.watch(turnosDelDiaProvider(clave)).value ?? const <db.Appointment>[];
    final todos = filas.map((f) => aAppointment(f)).toList();
    // El filtro se aplica a la lista, NO al calendario: los puntos del mes
    // tienen que seguir mostrando que ahí hay algo aunque el filtro activo lo
    // esconda de la lista.
    final turnos = _filtro == 'all'
        ? todos
        : todos.where((t) => textoDesdeEstado(t.estado) == _filtro).toList();

    final delMes =
        ref.watch(turnosDelMesVisibleProvider(claveMes)).value ??
            const <db.Appointment>[];
    final diasConTurno = {for (final t in delMes) t.fecha};
    final clientes = ref.watch(clientesProvider).value ?? const <db.Client>[];
    final puedeEscribir = ref.watch(puedeProvider(Permiso.escribirDatos));

    final nombrePorId = {for (final c in clientes) c.id: c.nombre};

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: puedeEscribir
          ? Padding(
              // `bottom: 80px + safe` y `right: 18px` del CSS. El
              // Scaffold ya separa 16 del borde, así que acá van 2.
              padding: const EdgeInsets.only(right: 2, bottom: 8),
              child: FabMirame(onTap: () => _mostrarFormulario(context, ref, dia: _dia)),
            )
          : null,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              children: [
                CalendarioMes(
                  mes: _mes,
                  diaElegido: _dia,
                  diasConTurno: diasConTurno,
                  onElegirDia: (d) => setState(() {
                    _dia = d;
                    _mes = DateTime(d.year, d.month, 1);
                  }),
                  onCambiarMes: (delta) => setState(() {
                    _mes = DateTime(_mes.year, _mes.month + delta, 1);
                  }),
                ),
                FilaFiltros(
                  opciones: const [
                    ('all', 'Todos'),
                    ('confirmed', 'Confirmados'),
                    ('pending', 'Pendientes'),
                    ('done', 'Completados'),
                  ],
                  activo: _filtro,
                  onElegir: (f) => setState(() => _filtro = f),
                ),
                const SizedBox(height: 14),
              ],
            ),
          ),
          Expanded(
            child: turnos.isEmpty
                ? EstadoVacio(
                    // Textos literales de `renderAgenda`.
                    emoji: '📅',
                    titulo: 'Sin turnos',
                    detalle: _filtro == 'all'
                        ? 'No hay turnos para este día'
                        : 'Ningún turno en este estado',
                  )
                : _Timeline(
                    turnos: turnos,
                    nombrePorId: nombrePorId,
                  ),
          ),
        ],
      ),
    );
  }
}

/// `.timeline` del original: los turnos se agrupan por HORA, con la hora en
/// una columna angosta a la izquierda y una línea vertical que la separa.
///
/// No es decorativo: agrupar por hora es lo que deja ver de un vistazo si dos
/// turnos caen en la misma franja.
class _Timeline extends StatelessWidget {
  const _Timeline({required this.turnos, required this.nombrePorId});

  final List<Appointment> turnos;
  final Map<String, String> nombrePorId;

  @override
  Widget build(BuildContext context) {
    // `byH` en el original: clave = la hora, sin los minutos.
    final porHora = <int, List<Appointment>>{};
    for (final t in turnos) {
      porHora.putIfAbsent(t.hora?.hour ?? 9, () => []).add(t);
    }
    final horas = porHora.keys.toList()..sort();

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
      itemCount: horas.length,
      itemBuilder: (_, i) {
        final h = horas[i];
        final delHora = porHora[h]!;
        // 12 horas con AM/PM, como `${+h%12||12}` del original.
        final h12 = h % 12 == 0 ? 12 : h % 12;
        final ampm = h >= 12 ? 'PM' : 'AM';

        return FadeSlideIn(
          delay: Duration(milliseconds: (i < 8 ? i : 8) * 35),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // `.tl-time { width:38px; text-align:right; 11px t-muted }`
                SizedBox(
                  width: 38,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '$h12',
                          style: sans(
                              size: 11, weight: 500, color: MColors.tMuted),
                        ),
                        Text(
                          ampm,
                          style: sans(
                              size: 9, weight: 500, color: MColors.tMuted),
                        ),
                      ],
                    ),
                  ),
                ),
                // `.tl-row::before` — la línea vertical a 38px del borde.
                Container(width: 1, color: MColors.bg3),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 0, 2),
                    child: Column(
                      children: [
                        for (final t in delHora)
                          _EventoTimeline(
                            turno: t,
                            nombreCliente: nombrePorId[t.clientId],
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// `.tl-ev` — tarjeta del turno, con la **barra lavanda de 3px a la
/// izquierda**, que es lo que le da el aire de agenda.
class _EventoTimeline extends ConsumerWidget {
  const _EventoTimeline({required this.turno, this.nombreCliente});

  final Appointment turno;
  final String? nombreCliente;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cancelado = turno.estado == TurnoEstado.cancelled;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: PressableScale(
        onTap: () => _mostrarFormulario(context, ref, turno: turno),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: MColors.surface,
            border: Border(
              top: const BorderSide(color: MColors.border),
              right: const BorderSide(color: MColors.border),
              bottom: const BorderSide(color: MColors.border),
              left: BorderSide(
                color: cancelado ? MColors.tLight : MColors.brand,
                width: 3,
              ),
            ),
            borderRadius: BorderRadius.circular(MRadius.md),
            boxShadow: MShadow.xs,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      nombreCliente ?? 'Clienta',
                      style: sans(size: 13, weight: 600).copyWith(
                        decoration:
                            cancelado ? TextDecoration.lineThrough : null,
                        color: cancelado ? MColors.tMuted : null,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  BadgeEstado(textoDesdeEstado(turno.estado)),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                // `.tl-ev-info` — servicios · hora · profesional · precio.
                [
                  turno.hora?.toString(),
                  if (turno.precio > 0) formatMoney(turno.precio),
                  if (turno.notas?.isNotEmpty ?? false) turno.notas,
                ].whereType<String>().join(' · '),
                style: sans(size: 11, color: MColors.tSecondary),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> _mostrarFormulario(
  BuildContext context,
  WidgetRef ref, {
  Appointment? turno,
  DateTime? dia,
}) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FormularioTurno(turno: turno, dia: dia),
    );

class _FormularioTurno extends ConsumerStatefulWidget {
  const _FormularioTurno({this.turno, this.dia});

  final Appointment? turno;
  final DateTime? dia;

  @override
  ConsumerState<_FormularioTurno> createState() => _FormTurnoState();
}

class _FormTurnoState extends ConsumerState<_FormularioTurno> {
  late final TextEditingController _precio;
  late final TextEditingController _notas;
  late DateTime _fecha;
  late TimeOfDay _hora;
  String? _clientId;
  bool _guardando = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final t = widget.turno;
    _precio = TextEditingController(
      text: t == null ? '' : t.precio.toStringAsFixed(0),
    );
    _notas = TextEditingController(text: t?.notas ?? '');
    _fecha = t?.fecha ?? widget.dia ?? DateTime.now();
    _hora = t?.hora == null
        ? const TimeOfDay(hour: 10, minute: 0)
        : TimeOfDay(hour: t!.hora!.hour, minute: t.hora!.minute);
    _clientId = t?.clientId;
  }

  @override
  void dispose() {
    _precio.dispose();
    _notas.dispose();
    super.dispose();
  }

  String get _horaTexto =>
      '${_hora.hour.toString().padLeft(2, '0')}:'
      '${_hora.minute.toString().padLeft(2, '0')}';

  Future<void> _guardar() async {
    final repo = ref.read(businessRepoProvider);
    if (repo == null) return;
    final crudo = _precio.text.trim().replaceAll('.', '').replaceAll(',', '.');

    setState(() {
      _guardando = true;
      _error = null;
    });
    final nav = Navigator.of(context);
    try {
      await repo.guardarTurno(
        id: widget.turno?.id,
        clientId: _clientId,
        fecha: _fecha,
        hora: _horaTexto,
        precio: double.tryParse(crudo) ?? 0,
        notas: _notas.text.trim().isEmpty ? null : _notas.text.trim(),
      );
      nav.pop();
      // Momento del pedido de permiso: acaba de agendar algo, así que el
      // "te aviso el día anterior" tiene sentido. Pedirlo al arrancar la app
      // se rechaza y después no hay segunda oportunidad.
      if (mounted) await pedirPermisoDeAvisos(context);
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
  Widget build(BuildContext context) {
    final clientes = ref.watch(clientesProvider).value ?? const <db.Client>[];

    return SheetFormulario(
      titulo: widget.turno == null ? 'Nuevo turno' : 'Editar turno',
      error: _error,
      guardando: _guardando,
      onGuardar: _guardar,
      onBorrar: widget.turno == null
          ? null
          : () async {
              final nav = Navigator.of(context);
              await ref
                  .read(businessRepoProvider)
                  ?.borrar('appointments', widget.turno!.id);
              nav.pop();
            },
      campos: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: DropdownButtonFormField<String?>(
            initialValue: _clientId,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: 'Clienta',
              labelStyle: MText.menor,
              filled: true,
              fillColor: MColors.bg2,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(MRadius.md),
                borderSide: const BorderSide(color: MColors.border),
              ),
            ),
            items: [
              const DropdownMenuItem(value: null, child: Text('Sin asignar')),
              for (final c in clientes)
                DropdownMenuItem(value: c.id, child: Text(c.nombre)),
            ],
            onChanged: (v) => setState(() => _clientId = v),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: _BotonCampo(
                etiqueta: 'Fecha',
                valor: formatDateShort(_fecha),
                onTap: () async {
                  final d = await showDatePicker(
                    context: context,
                    initialDate: _fecha,
                    firstDate: DateTime(DateTime.now().year - 2),
                    lastDate: DateTime(DateTime.now().year + 3),
                  );
                  if (d != null) setState(() => _fecha = d);
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _BotonCampo(
                etiqueta: 'Hora',
                valor: _horaTexto,
                onTap: () async {
                  final h = await showTimePicker(
                    context: context,
                    initialTime: _hora,
                  );
                  if (h != null) setState(() => _hora = h);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        CampoTexto(
          controlador: _precio,
          etiqueta: 'Precio',
          prefijo: r'$ ',
          teclado: const TextInputType.numberWithOptions(decimal: true),
        ),
        CampoTexto(controlador: _notas, etiqueta: 'Notas', lineas: 2),
      ],
    );
  }
}

class _BotonCampo extends StatelessWidget {
  const _BotonCampo({
    required this.etiqueta,
    required this.valor,
    required this.onTap,
  });

  final String etiqueta;
  final String valor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: MColors.bg2,
            borderRadius: BorderRadius.circular(MRadius.lg),
            border: Border.all(color: MColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(etiqueta, style: MText.pie),
              const SizedBox(height: 2),
              Text(valor, style: sans(size: 14, weight: 600)),
            ],
          ),
        ),
      );
}
