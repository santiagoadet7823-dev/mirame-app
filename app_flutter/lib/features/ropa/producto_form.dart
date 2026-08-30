/// Alta y edición de una prenda, con sus talles, colores y fotos.
///
/// Es la pantalla más cargada del módulo, así que se ordena por lo que se hace
/// primero: fotos, datos, talles, y al final la publicación en la tienda.
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../data/local/database.dart' as db;
import '../../data/repositories/ropa_repository.dart';
import '../../domain/rules/rotacion.dart';
import '../shell/vistas_comunes.dart';
import 'fotos.dart';
import 'ropa_view.dart';

Future<void> abrirFormularioProducto(
  BuildContext context,
  WidgetRef ref, {
  db.Producto? producto,
}) =>
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _FormProducto(producto: producto),
    );

/// Una variante mientras se edita, antes de guardarse.
class _VarianteEnEdicion {
  _VarianteEnEdicion({this.id, this.talle, this.color});
  final String? id;
  String? talle;
  String? color;
}

class _FormProducto extends ConsumerStatefulWidget {
  const _FormProducto({this.producto});

  final db.Producto? producto;

  @override
  ConsumerState<_FormProducto> createState() => _FormProductoState();
}

class _FormProductoState extends ConsumerState<_FormProducto> {
  late final _nombre = TextEditingController(text: widget.producto?.nombre);
  late final _descripcion =
      TextEditingController(text: widget.producto?.descripcion);
  late final _precio = TextEditingController(
      text: widget.producto == null
          ? ''
          : widget.producto!.precio.round().toString());
  late final _codigo = TextEditingController(text: widget.producto?.codigo);

  String? _proveedorId;
  late var _publicado = widget.producto?.publicado ?? false;
  late var _destacado = widget.producto?.destacado ?? false;

  final _variantes = <_VarianteEnEdicion>[];
  final _fotosNuevas = <String>[];

  var _guardando = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final p = widget.producto;
    _proveedorId = p?.proveedorId;

    if (p != null) {
      final v = ref.read(variantesProvider).value?[p.id] ?? const [];
      _variantes.addAll(v.map((x) =>
          _VarianteEnEdicion(id: x.id, talle: x.talle, color: x.color)));
    }
    // Una prenda siempre tiene al menos una variante: es lo que se vende y lo
    // que lleva el stock. Sin ninguna, el producto no se podría cargar.
    if (_variantes.isEmpty) _variantes.add(_VarianteEnEdicion());

    // El código se sugiere solo al crear. Se puede pisar, pero tenerlo desde
    // el principio es lo que hace que después se pueda buscar por él.
    if (p == null) {
      final usados =
          (ref.read(productosProvider).value ?? const []).map((x) => x.codigo);
      _codigo.text = proximoCodigo(usados);
    }
  }

  @override
  void dispose() {
    for (final c in [_nombre, _descripcion, _precio, _codigo]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _agregarFoto(bool camara) async {
    final ruta = await elegirYComprimir(desdeCamara: camara);
    if (ruta != null && mounted) setState(() => _fotosNuevas.add(ruta));
  }

  Future<void> _guardar() async {
    final nombre = _nombre.text.trim();
    if (nombre.isEmpty) {
      setState(() => _error = 'Poné un nombre');
      return;
    }
    final precio = num.tryParse(_precio.text.replaceAll(',', '.')) ?? 0;

    // Una variante sin talle ni color es una prenda única: se guarda igual.
    // Lo que no se guarda es una fila vacía de más.
    final variantes = _variantes
        .where((v) =>
            v.id != null ||
            (v.talle?.isNotEmpty ?? false) ||
            (v.color?.isNotEmpty ?? false) ||
            _variantes.length == 1)
        .toList();

    final repo = ref.read(ropaRepoProvider);
    if (repo == null) return;

    setState(() {
      _guardando = true;
      _error = null;
    });
    final nav = Navigator.of(context);

    try {
      final id = await repo.guardarProducto(
        id: widget.producto?.id,
        nombre: nombre,
        proveedorId: _proveedorId,
        descripcion:
            _descripcion.text.trim().isEmpty ? null : _descripcion.text.trim(),
        codigo: _codigo.text.trim().isEmpty ? null : _codigo.text.trim(),
        precio: precio,
        publicado: _publicado,
        destacado: _destacado,
        variantes: [
          for (final v in variantes)
            (
              id: v.id,
              talle: (v.talle?.trim().isEmpty ?? true) ? null : v.talle!.trim(),
              color: (v.color?.trim().isEmpty ?? true) ? null : v.color!.trim(),
            ),
        ],
      );

      // La prenda ya está guardada; las fotos se suben después. Si falla la
      // subida quedan pendientes y la ficha lo dice — pero la prenda NO se
      // pierde por no tener señal.
      for (var i = 0; i < _fotosNuevas.length; i++) {
        final local = _fotosNuevas[i];
        final url = await subirFoto(
          rutaLocal: local,
          tenantId: repo.tenantId,
          productoId: id,
        );
        await repo.guardarFoto(
          productoId: id,
          path: url ?? '',
          rutaLocal: local,
          orden: i,
        );
      }

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
    final proveedores = ref.watch(proveedoresProvider).value ?? const [];

    return SheetFormulario(
      titulo: widget.producto == null ? 'Nueva prenda' : 'Editar prenda',
      guardando: _guardando,
      error: _error,
      onGuardar: _guardar,
      onBorrar: widget.producto == null
          ? null
          : () async {
              final nav = Navigator.of(context);
              await ref
                  .read(ropaRepoProvider)
                  ?.borrar('productos', widget.producto!.id);
              nav.pop();
            },
      campos: [
        _seccion('FOTOS'),
        _fotos(),
        const SizedBox(height: 6),

        _seccion('LA PRENDA'),
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
              child: CampoTexto(controlador: _codigo, etiqueta: 'Código'),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: DropdownButtonFormField<String?>(
            initialValue: _proveedorId,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: 'Proveedor',
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
              for (final p in proveedores)
                DropdownMenuItem(
                  value: p.id,
                  child: Text('${p.nombre} · te queda ${p.pctSalon.round()}%'),
                ),
            ],
            onChanged: (v) => setState(() => _proveedorId = v),
          ),
        ),
        CampoTexto(
            controlador: _descripcion, etiqueta: 'Descripción', lineas: 2),

        _seccion('TALLES Y COLORES'),
        _listaVariantes(),

        _seccion('EN LA TIENDA'),
        SwitchListTile.adaptive(
          value: _publicado,
          onChanged: (v) => setState(() => _publicado = v),
          contentPadding: EdgeInsets.zero,
          title: Text('Mostrar en la tienda', style: sans(size: 13)),
          subtitle: Text(
            _publicado
                ? 'Las clientas la ven en el link'
                : 'Solo la ves vos',
            style: sans(size: 11, color: MColors.tMuted),
          ),
        ),
        if (_publicado)
          SwitchListTile.adaptive(
            value: _destacado,
            onChanged: (v) => setState(() => _destacado = v),
            contentPadding: EdgeInsets.zero,
            title: Text('Destacada', style: sans(size: 13)),
            subtitle: Text('Aparece primero en la tienda',
                style: sans(size: 11, color: MColors.tMuted)),
          ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _seccion(String texto) => Padding(
        padding: const EdgeInsets.only(top: 6, bottom: 10),
        child: Text(
          texto,
          style: sans(
              size: 10,
              weight: 600,
              color: MColors.tMuted,
              letterSpacing: 0.8),
        ),
      );

  Widget _fotos() {
    final yaCargadas = widget.producto == null
        ? const <db.ProductoFoto>[]
        : (ref.watch(portadasProvider).value?[widget.producto!.id] == null
            ? const <db.ProductoFoto>[]
            : [ref.watch(portadasProvider).value![widget.producto!.id]!]);

    return SizedBox(
      height: 92,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _botonFoto(
              icono: Icons.photo_camera_outlined,
              texto: 'Cámara',
              onTap: () => _agregarFoto(true)),
          _botonFoto(
              icono: Icons.image_outlined,
              texto: 'Galería',
              onTap: () => _agregarFoto(false)),
          for (final f in yaCargadas)
            _miniatura(
              hijo: f.pendienteDeSubir && f.rutaLocal != null
                  ? Image.file(File(f.rutaLocal!), fit: BoxFit.cover)
                  : Image.network(f.path, fit: BoxFit.cover),
            ),
          for (var i = 0; i < _fotosNuevas.length; i++)
            _miniatura(
              hijo: Image.file(File(_fotosNuevas[i]), fit: BoxFit.cover),
              onQuitar: () => setState(() => _fotosNuevas.removeAt(i)),
            ),
        ],
      ),
    );
  }

  Widget _botonFoto({
    required IconData icono,
    required String texto,
    required VoidCallback onTap,
  }) =>
      GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          width: 76,
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: MColors.bg2,
            border: Border.all(color: MColors.border),
            borderRadius: BorderRadius.circular(MRadius.sm),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icono, size: 20, color: MColors.tMuted),
              const SizedBox(height: 5),
              Text(texto, style: sans(size: 10, color: MColors.tMuted)),
            ],
          ),
        ),
      );

  Widget _miniatura({required Widget hijo, VoidCallback? onQuitar}) => Container(
        width: 76,
        margin: const EdgeInsets.only(right: 8),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: MColors.bg2,
          borderRadius: BorderRadius.circular(MRadius.sm),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            hijo,
            if (onQuitar != null)
              Positioned(
                right: 3,
                top: 3,
                child: GestureDetector(
                  onTap: onQuitar,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: MColors.surface.withValues(alpha: .9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close_rounded,
                        size: 13, color: MColors.tPrimary),
                  ),
                ),
              ),
          ],
        ),
      );

  Widget _listaVariantes() => Column(
        children: [
          for (var i = 0; i < _variantes.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: _campoChico(
                      valor: _variantes[i].talle,
                      etiqueta: 'Talle',
                      onCambio: (v) => _variantes[i].talle = v,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: _campoChico(
                      valor: _variantes[i].color,
                      etiqueta: 'Color',
                      onCambio: (v) => _variantes[i].color = v,
                    ),
                  ),
                  // La única fila no se puede quitar: sin variantes no hay
                  // nada que vender ni dónde contar el stock.
                  if (_variantes.length > 1)
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => setState(() => _variantes.removeAt(i)),
                      child: const Padding(
                        padding: EdgeInsets.only(left: 6),
                        child: Icon(Icons.remove_circle_outline,
                            size: 19, color: MColors.tLight),
                      ),
                    ),
                ],
              ),
            ),
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => setState(() => _variantes.add(_VarianteEnEdicion())),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Text('+ Agregar talle o color',
                    style:
                        sans(size: 12, weight: 600, color: MColors.brand)),
              ),
            ),
          ),
          const SizedBox(height: 6),
        ],
      );

  Widget _campoChico({
    required String? valor,
    required String etiqueta,
    required ValueChanged<String> onCambio,
  }) =>
      TextFormField(
        initialValue: valor,
        onChanged: onCambio,
        style: sans(size: 13),
        decoration: InputDecoration(
          labelText: etiqueta,
          labelStyle: MText.menor,
          filled: true,
          fillColor: MColors.bg2,
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(MRadius.md),
            borderSide: const BorderSide(color: MColors.border),
          ),
        ),
      );
}
