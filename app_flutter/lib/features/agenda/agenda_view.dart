/// Agenda: los turnos del día elegido.
///
/// La detección de solapamientos sale de `domain/rules/agenda.dart` — es una
/// corrección respecto del legacy, que no la tenía y dejaba pisar turnos.
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
import '../../domain/entities/entities.dart';
import '../../domain/rules/access.dart';
import '../../domain/rules/formatting.dart';
import '../auth/session_controller.dart';
import '../dashboard/dashboard_view.dart';
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

class AgendaView extends ConsumerStatefulWidget {
  const AgendaView({super.key});

  @override
  ConsumerState<AgendaView> createState() => _AgendaViewState();
}

class _AgendaViewState extends ConsumerState<AgendaView> {
  DateTime _dia = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final clave = claveFecha(_dia);
    final filas =
        ref.watch(turnosDelDiaProvider(clave)).value ?? const <db.Appointment>[];
    final turnos = filas.map((f) => aAppointment(f)).toList();
    final clientes = ref.watch(clientesProvider).value ?? const <db.Client>[];
    final puedeEscribir = ref.watch(puedeProvider(Permiso.escribirDatos));

    final nombrePorId = {for (final c in clientes) c.id: c.nombre};

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: puedeEscribir
          ? FloatingActionButton(
              backgroundColor: MColors.brand,
              foregroundColor: MColors.tWhite,
              onPressed: () => _mostrarFormulario(context, ref, dia: _dia),
              child: const Icon(Icons.add_rounded),
            )
          : null,
      body: Column(
        children: [
          _SelectorDia(
            dia: _dia,
            onCambiar: (d) => setState(() => _dia = d),
          ),
          Expanded(
            child: turnos.isEmpty
                ? const EstadoVacio(
                    emoji: '🌿',
                    titulo: 'Sin turnos este día',
                    detalle: 'Tocá + para agendar uno.',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 90),
                    itemCount: turnos.length,
                    itemBuilder: (_, i) {
                      final t = turnos[i];
                      // Un turno se marca en conflicto si comparte horario con
                      // otro del mismo día. Verlo en la lista evita el llamado
                      // incómodo de "vení media hora antes".
                      final choca = turnos.any(
                        (o) =>
                            o.id != t.id &&
                            o.hora != null &&
                            t.hora != null &&
                            o.hora!.hour == t.hora!.hour &&
                            o.hora!.minute == t.hora!.minute &&
                            o.estado != TurnoEstado.cancelled &&
                            t.estado != TurnoEstado.cancelled,
                      );
                      return FadeSlideIn(
                        delay:
                            Duration(milliseconds: (i < 8 ? i : 8) * 35),
                        child: _FilaTurno(
                          turno: t,
                          nombreCliente: nombrePorId[t.clientId],
                          enConflicto: choca,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _SelectorDia extends StatelessWidget {
  const _SelectorDia({required this.dia, required this.onCambiar});

  final DateTime dia;
  final ValueChanged<DateTime> onCambiar;

  @override
  Widget build(BuildContext context) {
    final hoy = DateTime.now();
    final esHoy = dia.year == hoy.year &&
        dia.month == hoy.month &&
        dia.day == hoy.day;

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 2, 14, 6),
      child: Row(
        children: [
          IconButton(
            onPressed: () =>
                onCambiar(dia.subtract(const Duration(days: 1))),
            icon: const Icon(Icons.chevron_left_rounded,
                color: MColors.tSecondary),
          ),
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () async {
                final elegido = await showDatePicker(
                  context: context,
                  initialDate: dia,
                  firstDate: DateTime(hoy.year - 2),
                  lastDate: DateTime(hoy.year + 3),
                );
                if (elegido != null) onCambiar(elegido);
              },
              child: Column(
                children: [
                  Text(
                    formatDateShort(dia),
                    textAlign: TextAlign.center,
                    style: sans(size: 15, weight: 600),
                  ),
                  if (!esHoy)
                    Text('Tocá para elegir otro día', style: MText.pie),
                ],
              ),
            ),
          ),
          IconButton(
            onPressed: () => onCambiar(dia.add(const Duration(days: 1))),
            icon: const Icon(Icons.chevron_right_rounded,
                color: MColors.tSecondary),
          ),
        ],
      ),
    );
  }
}

class _FilaTurno extends ConsumerWidget {
  const _FilaTurno({
    required this.turno,
    required this.enConflicto,
    this.nombreCliente,
  });

  final Appointment turno;
  final String? nombreCliente;
  final bool enConflicto;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cancelado = turno.estado == TurnoEstado.cancelled;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: PressableScale(
        onTap: () => _mostrarFormulario(context, ref, turno: turno),
        child: Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: MColors.surface,
            borderRadius: BorderRadius.circular(MRadius.md),
            border: Border.all(
              color: enConflicto ? MColors.warningText : MColors.border,
            ),
            boxShadow: MShadow.xs,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: cancelado ? MColors.bg3 : MColors.brandBg,
                  borderRadius: BorderRadius.circular(MRadius.sm),
                ),
                child: Text(
                  turno.hora?.toString() ?? '--:--',
                  style: sans(
                    size: 13,
                    weight: 600,
                    color:
                        cancelado ? MColors.tMuted : MColors.brandDark,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nombreCliente ?? 'Sin clienta asignada',
                      style: sans(size: 14, weight: 600).copyWith(
                        decoration:
                            cancelado ? TextDecoration.lineThrough : null,
                        color: cancelado ? MColors.tMuted : null,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (enConflicto)
                      Text(
                        'Se superpone con otro turno',
                        style: sans(
                            size: 11.5,
                            weight: 600,
                            color: MColors.warningText),
                      )
                    else if (turno.notas?.isNotEmpty ?? false)
                      Text(
                        turno.notas!,
                        style: MText.menor,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              if (turno.precio > 0)
                Text(formatMoney(turno.precio), style: MText.menor),
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
            borderRadius: BorderRadius.circular(MRadius.md),
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
