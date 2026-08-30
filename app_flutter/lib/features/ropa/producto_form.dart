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
import '../../domain/rules/formatting.dart';
import '../../domain/rules/rotacion.dart';
import '../shell/vistas_comunes.dart';
import 'escaner.dart';
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
  _VarianteEnEdicion({this.id, this.talle, this.color, this.stock = 0});
  final String? id;
  String? talle;
  String? color;

  /// Cuántas unidades hay de este talle y color. Es un ABSOLUTO: la usuaria ve
  /// el número que tiene y lo corrige; el repositorio calcula la diferencia.
  int stock;
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
  late final _pct = TextEditingController(
      text: widget.producto?.pctSalon?.round().toString() ?? '');

  /// `false` = usa el del proveedor. Se decide con un switch en vez de dejar
  /// el campo vacío: un campo en blanco no dice si es "sin definir" o "cero".
  late var _pctPropio = widget.producto?.pctSalon != null;

  String? _proveedorId;

  /// Dónde entra —o de dónde sale— la mercadería que se carga acá.
  ///
  /// Es del PRODUCTO y no de cada variante: repartir los talles de una misma
  /// prenda entre depósitos distintos es una transferencia, no un alta, y
  /// meterla en este formulario lo convertiría en uno de logística.
  String? _depositoId;
  late var _rubro = widget.producto?.rubro ?? 'ropa';
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
    // El deposito NO se resuelve aca: `depositosProvider` es autoDispose y en
    // `initState` todavia no emitio, asi que devolvia null y el stock se
    // perdia en silencio. Se resuelve al guardar.

    if (p != null) {
      final v = ref.read(variantesProvider).value?[p.id] ?? const [];
      final stock = ref.read(stockRopaProvider).value ?? const {};
      _variantes.addAll(v.map((x) => _VarianteEnEdicion(
            id: x.id,
            talle: x.talle,
            color: x.color,
            stock: stock[x.id] ?? 0,
          )));
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
    for (final c in [_nombre, _descripcion, _precio, _codigo, _pct]) {
      c.dispose();
    }
    super.dispose();
  }

  /// Dónde está esta mercadería.
  ///
  /// Se muestra con UNO solo también: esconderlo hasta que hubiera dos dejaba
  /// a la usuaria sin manera de ver ni cambiar dónde entra el stock, que es
  /// justo lo que vino a mirar.
  Widget _selectorDeposito() {
    final deps = ref.watch(depositosProvider).value ?? const [];
    if (deps.isEmpty) return const SizedBox.shrink();

    // El provider emite despues del primer build, asi que la preseleccion se
    // hace aca y no en `initState`.
    if (_depositoId == null || !deps.any((d) => d.id == _depositoId)) {
      _depositoId = deps
          .firstWhere((d) => d.esPrincipal, orElse: () => deps.first)
          .id;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String?>(
        initialValue: _depositoId,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: 'En qué depósito está',
          labelStyle: MText.menor,
          filled: true,
          fillColor: MColors.bg2,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(MRadius.md),
            borderSide: const BorderSide(color: MColors.border),
          ),
        ),
        items: [
          for (final d in deps)
            DropdownMenuItem(
              value: d.id,
              child: Text(d.esPrincipal ? '${d.nombre} (principal)' : d.nombre),
            ),
        ],
        onChanged: (v) => setState(() => _depositoId = v),
      ),
    );
  }

  /// El depósito donde entra la mercadería nueva.
  String? _depositoPrincipal() {
    final deps = ref.read(depositosProvider).value ?? const [];
    if (deps.isEmpty) return null;
    return deps
        .firstWhere((d) => d.esPrincipal, orElse: () => deps.first)
        .id;
  }

  /// Dónde va a entrar el stock, garantizado.
  ///
  /// Si el salón todavía no creó ningún depósito se crea uno acá. Antes, sin
  /// depósito, las cantidades que la usuaria escribía se descartaban sin
  /// decirle nada — y "depósito" es un concepto que no necesita hasta que
  /// tiene dos lugares.
  Future<String?> _asegurarDeposito() async {
    final elegido = _depositoId ?? _depositoPrincipal();
    if (elegido != null) return elegido;

    final repo = ref.read(ropaRepoProvider);
    if (repo == null) return null;
    return repo.guardarDeposito(nombre: 'Principal', esPrincipal: true);
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
        // `null` = hereda el del proveedor. Es lo que permite cambiarle el
        // acuerdo a un proveedor y que se aplique a todas sus prendas menos
        // las que tengan trato propio.
        pctSalon: _pctPropio
            ? (num.tryParse(_pct.text.replaceAll(',', '.')) ?? 0)
            : null,
        rubro: _rubro,
        depositoId: await _asegurarDeposito(),
        publicado: _publicado,
        destacado: _destacado,
        variantes: [
          for (final v in variantes)
            VarianteParaGuardar(
              id: v.id,
              talle: (v.talle?.trim().isEmpty ?? true) ? null : v.talle!.trim(),
              color: (v.color?.trim().isEmpty ?? true) ? null : v.color!.trim(),
              stock: v.stock,
            ),
        ],
      );

      // La prenda ya está guardada; las fotos se suben después. Si falla la
      // subida quedan pendientes y la ficha lo dice — pero la prenda NO se
      // pierde por no tener señal.
      //
      // El orden arranca después de las que ya estaban. Reiniciándolo en 0,
      // agregar una segunda tanda de fotos chocaba con la primera y la portada
      // pasaba a ser cualquiera.
      final previas = ref.read(fotosProvider).value?[id] ?? const [];
      var orden = previas.fold<int>(-1, (a, f) => f.orden > a ? f.orden : a) + 1;

      for (final local in _fotosNuevas) {
        final url = await subirFoto(
          rutaLocal: local,
          tenantId: repo.tenantId,
          productoId: id,
        );
        await repo.guardarFoto(
          productoId: id,
          path: url ?? '',
          rutaLocal: local,
          orden: orden++,
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

        _seccion('QUÉ ES'),
        Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: FilaFiltros(
            opciones: const [
              ('ropa', '👗 Ropa'),
              ('arbell', '💄 Arbell'),
              ('insumos', '🧴 Insumos'),
            ],
            activo: _rubro,
            onElegir: (v) => setState(() => _rubro = v),
          ),
        ),

        _seccion('EL PRODUCTO'),
        CampoTexto(controlador: _nombre, etiqueta: 'Nombre'),
        Row(
          children: [
            Expanded(
              child: CampoTexto(
                controlador: _precio,
                etiqueta: 'Precio',
                teclado: TextInputType.number,
                onCambio: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: CampoTexto(
                        controlador: _codigo, etiqueta: 'Código'),
                  ),
                  // Escanear el código de fábrica evita tipear trece dígitos y
                  // evita el error de tipearlos mal, que es peor: el producto
                  // queda cargado con un código que no es de nadie.
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () async {
                      final c = await escanearCodigo(context);
                      if (c != null && mounted) {
                        setState(() => _codigo.text = c);
                      }
                    },
                    child: Container(
                      width: 46,
                      height: 46,
                      margin: const EdgeInsets.only(left: 6, bottom: 12),
                      decoration: BoxDecoration(
                        color: MColors.bg2,
                        border: Border.all(color: MColors.border),
                        borderRadius: BorderRadius.circular(MRadius.md),
                      ),
                      child: const Icon(Icons.qr_code_scanner_rounded,
                          size: 20, color: MColors.tSecondary),
                    ),
                  ),
                ],
              ),
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

        _seccion('REPARTO'),
        _reparto(proveedores),

        _seccion(_rubro == 'ropa' ? 'TALLES Y CANTIDADES' : 'PRESENTACIONES'),
        _selectorDeposito(),
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

  /// El porcentaje: el del proveedor, o uno propio de esta prenda.
  Widget _reparto(List<db.Proveedore> proveedores) {
    final prov =
        proveedores.where((p) => p.id == _proveedorId).firstOrNull;
    final pctProveedor = prov?.pctSalon ?? 100;
    final pct = _pctPropio
        ? (num.tryParse(_pct.text.replaceAll(',', '.')) ?? 0)
        : pctProveedor;
    final precio = num.tryParse(_precio.text.replaceAll(',', '.')) ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile.adaptive(
          value: _pctPropio,
          onChanged: (v) => setState(() {
            _pctPropio = v;
            // Al activarlo arranca del valor del proveedor: es el punto de
            // partida obvio y evita que quede en cero por descuido.
            if (v && _pct.text.isEmpty) {
              _pct.text = pctProveedor.round().toString();
            }
          }),
          contentPadding: EdgeInsets.zero,
          title: Text('Esta prenda tiene otro trato', style: sans(size: 13)),
          subtitle: Text(
            _pctPropio
                ? 'Solo para esta prenda'
                : prov == null
                    ? 'Sin proveedor: te queda todo'
                    : 'Usa el ${pctProveedor.round()}% de ${prov.nombre}',
            style: sans(size: 11, color: MColors.tMuted),
          ),
        ),
        if (_pctPropio)
          CampoTexto(
            controlador: _pct,
            etiqueta: 'Te queda a vos (%)',
            teclado: TextInputType.number,
            onCambio: (_) => setState(() {}),
          ),
        // El reparto con plata real. Con porcentajes sueltos es muy fácil
        // cargar el del proveedor donde iba el propio, y eso no se nota hasta
        // la primera liquidación.
        if (precio > 0)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: MColors.lav50,
                border: Border.all(color: MColors.borderLav),
                borderRadius: BorderRadius.circular(MRadius.sm),
              ),
              child: Column(
                children: [
                  _linea('Para el proveedor',
                      precio * (100 - pct.clamp(0, 100)) / 100),
                  const SizedBox(height: 5),
                  _linea('Queda en casa', precio * pct.clamp(0, 100) / 100,
                      fuerte: true),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _linea(String etiqueta, num monto, {bool fuerte = false}) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(etiqueta,
              style: sans(size: 12, color: MColors.tSecondary)),
          Text(formatMoney(monto),
              style: sans(size: 13, weight: fuerte ? 700 : 500)),
        ],
      );

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
        : (ref.watch(fotosProvider).value?[widget.producto!.id] ??
            const <db.ProductoFoto>[]);
    final total = yaCargadas.length + _fotosNuevas.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
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
                  onQuitar: () => _quitarFotoGuardada(f),
                ),
              for (var i = 0; i < _fotosNuevas.length; i++)
                _miniatura(
                  hijo: Image.file(File(_fotosNuevas[i]), fit: BoxFit.cover),
                  onQuitar: () => setState(() => _fotosNuevas.removeAt(i)),
                ),
            ],
          ),
        ),
        if (total > 0)
          Padding(
            padding: const EdgeInsets.only(top: 7, left: 2),
            child: Text(
              total == 1
                  ? 'La primera es la que se ve en la tienda. Podés sumar más.'
                  : '$total fotos. La primera es la portada; en la ficha se '
                      'pasan de a una.',
              style: sans(size: 11, color: MColors.tMuted),
            ),
          ),
      ],
    );
  }

  /// Sacar una foto ya guardada. Pregunta primero: es lo unico de esta
  /// pantalla que no se puede deshacer.
  Future<void> _quitarFotoGuardada(db.ProductoFoto f) async {
    final si = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: MColors.surface,
        title: Text('¿Sacar la foto?', style: serif(size: 20, weight: 600)),
        content: Text('No se puede deshacer desde la app.',
            style: MText.cuerpoSec),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Cancelar', style: MText.menor),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('Sacar',
                style: sans(
                    size: 13, weight: 600, color: MColors.dangerText)),
          ),
        ],
      ),
    );
    if (si != true) return;

    final repo = ref.read(ropaRepoProvider);
    if (repo == null) return;
    await repo.borrar('producto_fotos', f.id);
    // El archivo del bucket va despues del borrado logico: si falla, queda un
    // huerfano ocupando lugar, pero la foto ya no se ve. Al reves seria peor.
    if (f.path.isNotEmpty) await borrarFotoRemota(f.path);
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
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 66,
                    child: _campoChico(
                      valor: '${_variantes[i].stock}',
                      etiqueta: 'Cant.',
                      numerico: true,
                      onCambio: (v) =>
                          _variantes[i].stock = int.tryParse(v) ?? 0,
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
    bool numerico = false,
  }) =>
      TextFormField(
        initialValue: valor,
        onChanged: onCambio,
        keyboardType: numerico ? TextInputType.number : null,
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
