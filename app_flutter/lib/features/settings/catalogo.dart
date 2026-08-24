/// Servicios y profesionales. Puerto de `manageServices()` y `managePros()`.
///
/// Son dos listas con la misma forma, así que comparten el sheet: cambia el
/// formulario de edición, no el envoltorio.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../data/local/database.dart' as db;
import '../../data/repositories/business_repository.dart';
import '../../domain/rules/formatting.dart';
import '../dashboard/dashboard_view.dart';
import '../shell/vistas_comunes.dart';

final profesionalesProvider =
    StreamProvider.autoDispose<List<db.Professional>>((ref) {
  final repo = ref.watch(businessRepoProvider);
  if (repo == null) return Stream.value(const []);
  return repo.verProfesionales();
});

// ─────────────────────────────────────────────────────────────────────────────
// Servicios
// ─────────────────────────────────────────────────────────────────────────────

Future<void> mostrarServicios(BuildContext context) => showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const _ListaServicios(),
    );

class _ListaServicios extends ConsumerWidget {
  const _ListaServicios();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servicios = ref.watch(serviciosProvider).value ?? const [];

    return _Envoltorio(
      titulo: 'Servicios',
      onNuevo: () => _editarServicio(context, ref, null),
      vacio: servicios.isEmpty,
      emojiVacio: '💅',
      textoVacio: 'Todavía no cargaste ningún servicio',
      hijos: [
        for (final s in servicios)
          _Fila(
            titulo: s.nombre,
            // El retoque se muestra acá porque es lo que decide si esa clienta
            // va a aparecer en los recordatorios; sin verlo, un servicio sin
            // días configurados pasa desapercibido para siempre.
            detalle: [
              formatMoney(s.precio),
              '${s.duracionMin} min',
              if (s.retoqueDias != null) 'retoque ${s.retoqueDias}d',
            ].join(' · '),
            onTap: () => _editarServicio(context, ref, s),
            onBorrar: () => _confirmarBorrado(
              context,
              ref,
              tabla: 'services',
              id: s.id,
              nombre: s.nombre,
            ),
          ),
      ],
    );
  }
}

Future<void> _editarServicio(
  BuildContext context,
  WidgetRef ref,
  db.Service? servicio,
) =>
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _FormServicio(servicio: servicio),
    );

class _FormServicio extends ConsumerStatefulWidget {
  const _FormServicio({this.servicio});

  final db.Service? servicio;

  @override
  ConsumerState<_FormServicio> createState() => _FormServicioState();
}

class _FormServicioState extends ConsumerState<_FormServicio> {
  late final _nombre = TextEditingController(text: widget.servicio?.nombre);
  late final _precio = TextEditingController(
      text: widget.servicio == null ? '' : _sinCeroSuelto(widget.servicio!.precio));
  late final _duracion = TextEditingController(
      text: '${widget.servicio?.duracionMin ?? 60}');
  late final _retoque =
      TextEditingController(text: widget.servicio?.retoqueDias?.toString() ?? '');
  late final _notas = TextEditingController(text: widget.servicio?.notas);

  var _guardando = false;
  String? _error;

  @override
  void dispose() {
    for (final c in [_nombre, _precio, _duracion, _retoque, _notas]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _guardar() async {
    final nombre = _nombre.text.trim();
    if (nombre.isEmpty) {
      setState(() => _error = 'Poné un nombre');
      return;
    }
    final repo = ref.read(businessRepoProvider);
    if (repo == null) return;

    setState(() {
      _guardando = true;
      _error = null;
    });
    final nav = Navigator.of(context);
    try {
      await repo.guardarServicio(
        id: widget.servicio?.id,
        nombre: nombre,
        precio: double.tryParse(_precio.text.replaceAll(',', '.')) ?? 0,
        duracionMin: int.tryParse(_duracion.text) ?? 60,
        // Vacío es null, no cero: cero significaría "volver hoy".
        retoqueDias: int.tryParse(_retoque.text),
        notas: _notas.text.trim().isEmpty ? null : _notas.text.trim(),
      );
      nav.pop();
    } catch (_) {
      if (mounted) {
        setState(() {
          _guardando = false;
          _error = 'No se pudo guardar';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => SheetFormulario(
        titulo: widget.servicio == null ? 'Nuevo servicio' : 'Editar servicio',
        guardando: _guardando,
        error: _error,
        onGuardar: _guardar,
        campos: [
          CampoTexto(controlador: _nombre, etiqueta: 'Nombre'),
          Row(
            children: [
              Expanded(
                child: CampoTexto(
                  controlador: _precio,
                  etiqueta: 'Precio',
                  teclado: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CampoTexto(
                  controlador: _duracion,
                  etiqueta: 'Duración (min)',
                  teclado: TextInputType.number,
                ),
              ),
            ],
          ),
          CampoTexto(
            controlador: _retoque,
            etiqueta: 'Retoque (días) — vacío = sin recordatorio',
            teclado: TextInputType.number,
          ),
          CampoTexto(controlador: _notas, etiqueta: 'Notas', lineas: 2),
        ],
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Profesionales
// ─────────────────────────────────────────────────────────────────────────────

Future<void> mostrarProfesionales(BuildContext context) => showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const _ListaProfesionales(),
    );

class _ListaProfesionales extends ConsumerWidget {
  const _ListaProfesionales();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pros = ref.watch(profesionalesProvider).value ?? const [];

    return _Envoltorio(
      titulo: 'Profesionales',
      onNuevo: () => _editarProfesional(context, ref, null),
      vacio: pros.isEmpty,
      emojiVacio: '👩',
      textoVacio: 'Todavía no cargaste ninguna profesional',
      hijos: [
        for (final p in pros)
          _Fila(
            titulo: p.nombre,
            detalle: p.telefono ?? 'Sin teléfono',
            onTap: () => _editarProfesional(context, ref, p),
            onBorrar: () => _confirmarBorrado(
              context,
              ref,
              tabla: 'professionals',
              id: p.id,
              nombre: p.nombre,
            ),
          ),
      ],
    );
  }
}

Future<void> _editarProfesional(
  BuildContext context,
  WidgetRef ref,
  db.Professional? pro,
) =>
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _FormProfesional(pro: pro),
    );

class _FormProfesional extends ConsumerStatefulWidget {
  const _FormProfesional({this.pro});

  final db.Professional? pro;

  @override
  ConsumerState<_FormProfesional> createState() => _FormProfesionalState();
}

class _FormProfesionalState extends ConsumerState<_FormProfesional> {
  late final _nombre = TextEditingController(text: widget.pro?.nombre);
  late final _telefono = TextEditingController(text: widget.pro?.telefono);

  var _guardando = false;
  String? _error;

  @override
  void dispose() {
    _nombre.dispose();
    _telefono.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    final nombre = _nombre.text.trim();
    if (nombre.isEmpty) {
      setState(() => _error = 'Poné un nombre');
      return;
    }
    final repo = ref.read(businessRepoProvider);
    if (repo == null) return;

    setState(() {
      _guardando = true;
      _error = null;
    });
    final nav = Navigator.of(context);
    try {
      await repo.guardarProfesional(
        id: widget.pro?.id,
        nombre: nombre,
        telefono: _telefono.text.trim().isEmpty ? null : _telefono.text.trim(),
      );
      nav.pop();
    } catch (_) {
      if (mounted) {
        setState(() {
          _guardando = false;
          _error = 'No se pudo guardar';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => SheetFormulario(
        titulo: widget.pro == null ? 'Nueva profesional' : 'Editar profesional',
        guardando: _guardando,
        error: _error,
        onGuardar: _guardar,
        campos: [
          CampoTexto(controlador: _nombre, etiqueta: 'Nombre'),
          CampoTexto(
            controlador: _telefono,
            etiqueta: 'Teléfono',
            teclado: TextInputType.phone,
          ),
        ],
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Compartido
// ─────────────────────────────────────────────────────────────────────────────

/// Borra en blando (tombstone), como todo el resto: el turno viejo que
/// referencia ese servicio tiene que seguir siendo legible.
Future<void> _confirmarBorrado(
  BuildContext context,
  WidgetRef ref, {
  required String tabla,
  required String id,
  required String nombre,
}) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: MColors.surface,
      title: Text('¿Borrar $nombre?', style: serif(size: 17, weight: 600)),
      content: Text(
        'Los turnos que ya lo usan no se tocan.',
        style: sans(size: 13, color: MColors.tSecondary),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: Text('Cancelar', style: sans(size: 13, color: MColors.tMuted)),
        ),
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: Text('Borrar',
              style: sans(size: 13, weight: 600, color: MColors.dangerText)),
        ),
      ],
    ),
  );
  if (ok != true) return;
  await ref.read(businessRepoProvider)?.borrar(tabla, id);
}

class _Envoltorio extends StatelessWidget {
  const _Envoltorio({
    required this.titulo,
    required this.onNuevo,
    required this.hijos,
    required this.vacio,
    required this.emojiVacio,
    required this.textoVacio,
  });

  final String titulo;
  final VoidCallback onNuevo;
  final List<Widget> hijos;
  final bool vacio;
  final String emojiVacio;
  final String textoVacio;

  @override
  Widget build(BuildContext context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.8,
        ),
        decoration: const BoxDecoration(
          color: MColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(MRadius.xl)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(titulo, style: serif(size: 20, weight: 600)),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: onNuevo,
                    child: Text(
                      '+ Agregar',
                      style:
                          sans(size: 13, weight: 600, color: MColors.brand),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              if (vacio)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 26),
                  child: Column(
                    children: [
                      Opacity(
                        opacity: 0.25,
                        child: Text(emojiVacio,
                            style: const TextStyle(fontSize: 40)),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        textoVacio,
                        textAlign: TextAlign.center,
                        style: sans(size: 13, color: MColors.tMuted),
                      ),
                    ],
                  ),
                )
              else
                Flexible(child: ListView(shrinkWrap: true, children: hijos)),
            ],
          ),
        ),
      );
}

class _Fila extends StatelessWidget {
  const _Fila({
    required this.titulo,
    required this.detalle,
    required this.onTap,
    required this.onBorrar,
  });

  final String titulo;
  final String detalle;
  final VoidCallback onTap;
  final VoidCallback onBorrar;

  @override
  Widget build(BuildContext context) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 7),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: MColors.bg2,
            borderRadius: BorderRadius.circular(MRadius.sm),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: sans(size: 13, weight: 600),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      detalle,
                      style: sans(size: 11, color: MColors.tMuted),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onBorrar,
                child: const Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Icon(Icons.delete_outline_rounded,
                      size: 18, color: MColors.tLight),
                ),
              ),
            ],
          ),
        ),
      );
}

/// `1500.0` se muestra como `1500`, no como `1500.0`, al editar.
String _sinCeroSuelto(num n) =>
    n == n.roundToDouble() ? n.round().toString() : n.toString();
