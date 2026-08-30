/// Proveedores y depósitos. Se cargan al empezar y después casi no se tocan,
/// así que van en un sheet y no ocupan lugar en el nav.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../data/local/database.dart' as db;
import '../../data/repositories/ropa_repository.dart';
import '../shell/vistas_comunes.dart';
import 'ropa_view.dart';

Future<void> mostrarProveedores(BuildContext context) => showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const _Panel(),
    );

class _Panel extends ConsumerStatefulWidget {
  const _Panel();

  @override
  ConsumerState<_Panel> createState() => _PanelState();
}

class _PanelState extends ConsumerState<_Panel> {
  var _verDepositos = false;

  @override
  Widget build(BuildContext context) {
    final proveedores = ref.watch(proveedoresProvider).value ?? const [];
    final depositos = ref.watch(depositosProvider).value ?? const [];

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.85,
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
                Text(_verDepositos ? 'Depósitos' : 'Proveedores',
                    style: serif(size: 20, weight: 600)),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _verDepositos
                      ? _editarDeposito(context, ref, null)
                      : _editarProveedor(context, ref, null),
                  child: Text('+ Agregar',
                      style: sans(
                          size: 13, weight: 600, color: MColors.brand)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            FilaFiltros(
              opciones: const [
                ('prov', 'Proveedores'),
                ('dep', 'Depósitos'),
              ],
              activo: _verDepositos ? 'dep' : 'prov',
              onElegir: (v) => setState(() => _verDepositos = v == 'dep'),
            ),
            const SizedBox(height: 12),
            Flexible(
              child: _verDepositos
                  ? _lista(
                      vacio: depositos.isEmpty,
                      emoji: '🏠',
                      texto: 'Cargá dónde guardás la mercadería',
                      hijos: [
                        for (final d in depositos)
                          _Fila(
                            titulo: d.nombre,
                            detalle: [
                              if (d.esPrincipal) 'Principal',
                              if (d.direccion case final x?) x,
                            ].join(' · '),
                            onTap: () => _editarDeposito(context, ref, d),
                          ),
                      ],
                    )
                  : _lista(
                      vacio: proveedores.isEmpty,
                      emoji: '🤝',
                      texto: 'Cargá quién te deja mercadería',
                      hijos: [
                        for (final p in proveedores)
                          _Fila(
                            titulo: p.nombre,
                            // El porcentaje es EL dato del proveedor: es lo
                            // que define cuánto gana con cada prenda suya.
                            detalle: 'Te queda el ${p.pctSalon.round()}%'
                                '${p.telefono == null ? '' : ' · ${p.telefono}'}',
                            onTap: () => _editarProveedor(context, ref, p),
                          ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _lista({
    required bool vacio,
    required String emoji,
    required String texto,
    required List<Widget> hijos,
  }) =>
      vacio
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 26),
              child: Column(
                children: [
                  Opacity(
                    opacity: 0.25,
                    child: Text(emoji, style: const TextStyle(fontSize: 40)),
                  ),
                  const SizedBox(height: 8),
                  Text(texto,
                      textAlign: TextAlign.center,
                      style: sans(size: 13, color: MColors.tMuted)),
                ],
              ),
            )
          : ListView(shrinkWrap: true, children: hijos);
}

class _Fila extends StatelessWidget {
  const _Fila({
    required this.titulo,
    required this.detalle,
    required this.onTap,
  });

  final String titulo;
  final String detalle;
  final VoidCallback onTap;

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(titulo,
                  style: sans(size: 13, weight: 600),
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 2),
              Text(detalle,
                  style: sans(size: 11, color: MColors.tMuted),
                  overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      );
}

// ── Formularios ────────────────────────────────────────────────────────────

Future<void> _editarProveedor(
        BuildContext context, WidgetRef ref, db.Proveedore? p) =>
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _FormProveedor(proveedor: p),
    );

class _FormProveedor extends ConsumerStatefulWidget {
  const _FormProveedor({this.proveedor});

  final db.Proveedore? proveedor;

  @override
  ConsumerState<_FormProveedor> createState() => _FormProveedorState();
}

class _FormProveedorState extends ConsumerState<_FormProveedor> {
  late final _nombre = TextEditingController(text: widget.proveedor?.nombre);
  late final _telefono =
      TextEditingController(text: widget.proveedor?.telefono);
  late final _pct = TextEditingController(
      text: (widget.proveedor?.pctSalon ?? 30).round().toString());
  late final _notas = TextEditingController(text: widget.proveedor?.notas);

  late var _absorbe = widget.proveedor?.descuentoLoAbsorbeSalon ?? true;
  var _guardando = false;
  String? _error;

  @override
  void dispose() {
    for (final c in [_nombre, _telefono, _pct, _notas]) {
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
    final pct = num.tryParse(_pct.text.replaceAll(',', '.'));
    if (pct == null || pct < 0 || pct > 100) {
      setState(() => _error = 'El porcentaje va entre 0 y 100');
      return;
    }

    final repo = ref.read(ropaRepoProvider);
    if (repo == null) return;
    setState(() {
      _guardando = true;
      _error = null;
    });
    final nav = Navigator.of(context);
    try {
      await repo.guardarProveedor(
        id: widget.proveedor?.id,
        nombre: nombre,
        telefono: _telefono.text.trim().isEmpty ? null : _telefono.text.trim(),
        pctSalon: pct,
        descuentoLoAbsorbeSalon: _absorbe,
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
  Widget build(BuildContext context) {
    final pct = num.tryParse(_pct.text.replaceAll(',', '.')) ?? 0;

    return SheetFormulario(
      titulo:
          widget.proveedor == null ? 'Nuevo proveedor' : 'Editar proveedor',
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
        CampoTexto(
          controlador: _pct,
          etiqueta: 'Porcentaje que te queda a vos (%)',
          teclado: TextInputType.number,
          onCambio: (_) => setState(() {}),
        ),
        // El ejemplo con plata real evita la duda de si el porcentaje es el
        // suyo o el del proveedor, que es el error de carga más caro acá.
        Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Text(
            'De una prenda de \$20.000: vos \$${(20000 * pct / 100).round()}, '
            'el proveedor \$${(20000 * (100 - pct) / 100).round()}',
            style: sans(size: 11, color: MColors.tMuted),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: SwitchListTile.adaptive(
            value: _absorbe,
            onChanged: (v) => setState(() => _absorbe = v),
            contentPadding: EdgeInsets.zero,
            title: Text('Los descuentos los absorbo yo',
                style: sans(size: 13)),
            subtitle: Text(
              _absorbe
                  ? 'El proveedor cobra sobre el precio de lista'
                  : 'El proveedor también pone parte del descuento',
              style: sans(size: 11, color: MColors.tMuted),
            ),
          ),
        ),
        CampoTexto(controlador: _notas, etiqueta: 'Notas', lineas: 2),
      ],
    );
  }
}

Future<void> _editarDeposito(
        BuildContext context, WidgetRef ref, db.Deposito? d) =>
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _FormDeposito(deposito: d),
    );

class _FormDeposito extends ConsumerStatefulWidget {
  const _FormDeposito({this.deposito});

  final db.Deposito? deposito;

  @override
  ConsumerState<_FormDeposito> createState() => _FormDepositoState();
}

class _FormDepositoState extends ConsumerState<_FormDeposito> {
  late final _nombre = TextEditingController(text: widget.deposito?.nombre);
  late final _direccion =
      TextEditingController(text: widget.deposito?.direccion);
  late var _principal = widget.deposito?.esPrincipal ?? false;
  var _guardando = false;
  String? _error;

  @override
  void dispose() {
    _nombre.dispose();
    _direccion.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    final nombre = _nombre.text.trim();
    if (nombre.isEmpty) {
      setState(() => _error = 'Poné un nombre');
      return;
    }
    final repo = ref.read(ropaRepoProvider);
    if (repo == null) return;
    setState(() {
      _guardando = true;
      _error = null;
    });
    final nav = Navigator.of(context);
    try {
      await repo.guardarDeposito(
        id: widget.deposito?.id,
        nombre: nombre,
        direccion:
            _direccion.text.trim().isEmpty ? null : _direccion.text.trim(),
        esPrincipal: _principal,
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
        titulo:
            widget.deposito == null ? 'Nuevo depósito' : 'Editar depósito',
        guardando: _guardando,
        error: _error,
        onGuardar: _guardar,
        campos: [
          CampoTexto(controlador: _nombre, etiqueta: 'Nombre'),
          CampoTexto(controlador: _direccion, etiqueta: 'Dirección'),
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: SwitchListTile.adaptive(
              value: _principal,
              onChanged: (v) => setState(() => _principal = v),
              contentPadding: EdgeInsets.zero,
              title: Text('Es el principal', style: sans(size: 13)),
              subtitle: Text(
                'Es el que se elige solo al cargar una venta',
                style: sans(size: 11, color: MColors.tMuted),
              ),
            ),
          ),
        ],
      );
}
