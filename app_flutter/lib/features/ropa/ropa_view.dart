/// El catálogo de ropa: la pantalla principal del módulo.
///
/// Va en grilla de dos columnas y no en lista, que es lo que usa el resto de
/// la app: la ropa se elige mirando, y una lista de texto con una miniatura al
/// costado obliga a leer para encontrar lo que la foto dice sola.
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/layout/layout.dart';
import '../../core/theme/motion.dart';
import '../../core/theme/shadows.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../data/local/database.dart' as db;
import '../../data/repositories/ropa_repository.dart';
import '../../domain/rules/access.dart';
import '../../domain/rules/formatting.dart';
import '../../shared/widgets/comportamiento.dart';
import '../../shared/widgets/piezas.dart';
import '../../shared/widgets/panel_lateral.dart';
import '../auth/session_controller.dart';
import '../shell/app_shell.dart';
import '../shell/vistas_comunes.dart';
import 'liquidaciones_view.dart';
import 'mi_tienda.dart';
import 'producto_form.dart';
import 'venta_form.dart';
import 'proveedores_view.dart';

final proveedoresProvider =
    StreamProvider.autoDispose<List<db.Proveedore>>((ref) {
  final repo = ref.watch(ropaRepoProvider);
  if (repo == null) return Stream.value(const []);
  return repo.verProveedores();
});

final depositosProvider = StreamProvider.autoDispose<List<db.Deposito>>((ref) {
  final repo = ref.watch(ropaRepoProvider);
  if (repo == null) return Stream.value(const []);
  return repo.verDepositos();
});

final productosProvider = StreamProvider.autoDispose<List<db.Producto>>((ref) {
  final repo = ref.watch(ropaRepoProvider);
  if (repo == null) return Stream.value(const []);
  return repo.verProductos();
});

final variantesProvider =
    StreamProvider.autoDispose<Map<String, List<db.ProductoVariante>>>((ref) {
  final repo = ref.watch(ropaRepoProvider);
  if (repo == null) return Stream.value(const {});
  return repo.verVariantesPorProducto();
});

final stockRopaProvider = StreamProvider.autoDispose<Map<String, int>>((ref) {
  final repo = ref.watch(ropaRepoProvider);
  if (repo == null) return Stream.value(const {});
  return repo.verStockPorVariante();
});

final portadasProvider =
    StreamProvider.autoDispose<Map<String, db.ProductoFoto>>((ref) {
  final repo = ref.watch(ropaRepoProvider);
  if (repo == null) return Stream.value(const {});
  return repo.verPortadas();
});

/// Todas las fotos de cada producto, en orden. El formulario necesita la lista
/// completa: con solo la portada parecia que no se podia cargar mas de una.
final fotosProvider =
    StreamProvider.autoDispose<Map<String, List<db.ProductoFoto>>>((ref) {
  final repo = ref.watch(ropaRepoProvider);
  if (repo == null) return Stream.value(const {});
  return repo.verFotos().map((filas) {
    final out = <String, List<db.ProductoFoto>>{};
    for (final f in filas) {
      (out[f.productoId] ??= <db.ProductoFoto>[]).add(f);
    }
    return out;
  });
});

class RopaView extends ConsumerStatefulWidget {
  const RopaView({super.key});

  @override
  ConsumerState<RopaView> createState() => _RopaViewState();
}

/// Las mismas opciones en el sheet del teléfono y en la columna de la tablet.
/// Estaban escritas dos veces y ya se habían despegado: la columna tenía RUBRO
/// y el sheet no.
const _rubros = [
  ('todo', 'Todo'),
  ('ropa', 'Ropa'),
  ('arbell', 'Arbell'),
  ('insumos', 'Insumos'),
];

const _estados = [
  ('todos', 'Todos'),
  ('publicados', 'En la tienda'),
  ('sin_publicar', 'Sin publicar'),
  ('sin_stock', 'Sin stock'),
];

/// `nuevas` es el orden con el que el repositorio ya entrega los productos
/// (`createdAt desc`), así que es el default y no ordena nada.
const _ordenes = [
  ('nuevas', 'Más nuevas'),
  ('precio', 'Precio'),
  ('stock', 'Stock'),
];

class _RopaViewState extends ConsumerState<RopaView> {
  final _busqueda = TextEditingController();
  String _filtro = 'todos';
  String _rubro = 'todo';
  String _proveedor = 'todos';
  String _orden = 'nuevas';

  /// Producto abierto en el panel lateral (solo escritorio). Por id: si se
  /// edita, el panel muestra la fila nueva.
  String? _abiertoId;

  @override
  void dispose() {
    _busqueda.dispose();
    super.dispose();
  }

  /// Sheet de filtros. El CTA cuenta el resultado ANTES de aplicar: elegir a
  /// ciegas y descubrir que no quedó nada es el camino largo.
  ///
  /// Los tres grupos vuelven juntos en un registro: con un `String` suelto
  /// había que abrir un sheet por filtro, y el contador del CTA solo podía
  /// contar uno de ellos.
  Future<void> _abrirFiltros(BuildContext context) async {
    var estado = _filtro;
    var proveedor = _proveedor;
    var orden = _orden;
    final proveedores = ref.read(proveedoresProvider).value ?? const [];
    final r = await showAppSheet<(String, String, String)>(
      context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Container(
          decoration: const BoxDecoration(
            color: MColors.bg,
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(MRadius.xl)),
          ),
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ManijaSheet(),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child:
                          Text('Filtros', style: serif(size: 22, weight: 600)),
                    ),
                    PressableScale(
                      onTap: () => setSheet(() {
                        estado = 'todos';
                        proveedor = 'todos';
                        orden = 'nuevas';
                      }),
                      child: Text(
                        'Limpiar',
                        style: sans(
                            size: 12.5, weight: 600, color: MColors.brandDark),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const EtiquetaSeccion('ESTADO'),
                Wrap(
                  spacing: 7,
                  runSpacing: 7,
                  children: [
                    for (final (clave, etiqueta) in _estados)
                      _ChipFiltro(
                        texto: etiqueta,
                        activo: estado == clave,
                        onTap: () => setSheet(() => estado = clave),
                      ),
                  ],
                ),
                // Un grupo con una sola opción no es un filtro: si no hay
                // proveedores cargados, "Todos" solo ocupa lugar.
                if (proveedores.isNotEmpty) ...[
                  const SizedBox(height: 18),
                  const EtiquetaSeccion('PROVEEDOR'),
                  Wrap(
                    spacing: 7,
                    runSpacing: 7,
                    children: [
                      _ChipFiltro(
                        texto: 'Todos',
                        activo: proveedor == 'todos',
                        onTap: () => setSheet(() => proveedor = 'todos'),
                      ),
                      for (final p in proveedores)
                        _ChipFiltro(
                          texto: p.nombre,
                          activo: proveedor == p.id,
                          onTap: () => setSheet(() => proveedor = p.id),
                        ),
                    ],
                  ),
                ],
                const SizedBox(height: 18),
                const EtiquetaSeccion('ORDEN'),
                Wrap(
                  spacing: 7,
                  runSpacing: 7,
                  children: [
                    for (final (clave, etiqueta) in _ordenes)
                      _ChipFiltro(
                        texto: etiqueta,
                        activo: orden == clave,
                        onTap: () => setSheet(() => orden = clave),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                CtaFijo(
                  // El orden no cambia cuántos quedan, así que no entra en la
                  // cuenta: solo estado y proveedor.
                  texto: switch (_cuantosCon(estado, proveedor)) {
                    1 => 'Ver 1 artículo',
                    final n => 'Ver $n artículos',
                  },
                  conDegrade: false,
                  onTap: () =>
                      Navigator.of(ctx).pop((estado, proveedor, orden)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (r != null && mounted) {
      setState(() {
        _filtro = r.$1;
        _proveedor = r.$2;
        _orden = r.$3;
      });
    }
  }

  /// Cuántos quedarían con ese estado y ese proveedor, sin tocar los filtros
  /// todavía.
  int _cuantosCon(String estado, String proveedor) {
    final productos = ref.read(productosProvider).value ?? const [];
    final variantes = ref.read(variantesProvider).value ?? const {};
    final stock = ref.read(stockRopaProvider).value ?? const {};
    int stockDe(String id) =>
        (variantes[id] ?? const []).fold(0, (a, v) => a + (stock[v.id] ?? 0));
    return productos.where((p) {
      if (_rubro != 'todo' && p.rubro != _rubro) return false;
      if (proveedor != 'todos' && p.proveedorId != proveedor) return false;
      return switch (estado) {
        'publicados' => p.publicado,
        'sin_publicar' => !p.publicado,
        'sin_stock' => stockDe(p.id) <= 0,
        _ => true,
      };
    }).length;
  }

  @override
  Widget build(BuildContext context) {
    final asincronos = ref.watch(productosProvider);
    final cargando = asincronos.isLoading && !asincronos.hasValue;
    final productos = asincronos.value ?? const [];
    final variantes = ref.watch(variantesProvider).value ?? const {};
    final stock = ref.watch(stockRopaProvider).value ?? const {};
    final portadas = ref.watch(portadasProvider).value ?? const {};
    final proveedores = ref.watch(proveedoresProvider).value ?? const [];
    final puedeEscribir = ref.watch(puedeProvider(Permiso.operarNegocio));

    // Si el proveedor elegido se borró, el filtro dejaría la grilla vacía sin
    // que nada lo explique: se cae a "Todos" solo.
    final proveedor = proveedores.any((p) => p.id == _proveedor)
        ? _proveedor
        : 'todos';

    /// Cuántas unidades hay de un producto, sumando todas sus variantes.
    int stockDe(String productoId) => (variantes[productoId] ?? const [])
        .fold(0, (a, v) => a + (stock[v.id] ?? 0));

    final texto = _busqueda.text.trim().toLowerCase();
    final visibles = productos.where((p) {
      if (texto.isNotEmpty) {
        // Se busca también por código: es más rápido tipear `042` que el
        // nombre completo de una prenda.
        final enNombre = p.nombre.toLowerCase().contains(texto);
        final enCodigo = (p.codigo ?? '').toLowerCase().contains(texto);
        if (!enNombre && !enCodigo) return false;
      }
      if (_rubro != 'todo' && p.rubro != _rubro) return false;
      if (proveedor != 'todos' && p.proveedorId != proveedor) return false;
      return switch (_filtro) {
        'publicados' => p.publicado,
        'sin_publicar' => !p.publicado,
        'sin_stock' => stockDe(p.id) <= 0,
        _ => true,
      };
    }).toList();

    // "Más nuevas" no ordena nada: es el orden con el que el repositorio ya
    // entrega los productos (`createdAt desc`). Los otros dos se ordenan en
    // memoria, como Clientas y Stats — y el stock no puede ser de otra forma:
    // no es una columna, se suma por variante, así que SQL no lo ve.
    switch (_orden) {
      case 'precio':
        // Ascendente: la pregunta que se hace en el mostrador es "¿qué tenés
        // más barato?". Para encontrar lo caro nadie necesita ayuda.
        visibles.sort((a, b) => a.precio.compareTo(b.precio));
      case 'stock':
        // Descendente: ordenar por stock es para mover lo que sobra (de ahí
        // Liquidar). Lo que falta ya tiene su propio filtro, Estado → Sin
        // stock, y arriba de la grilla no sirve de nada.
        visibles.sort((a, b) => stockDe(b.id).compareTo(stockDe(a.id)));
    }

    final escritorio = esPantallaGrande(context);
    // La tablet del mostrador: el ancho que sobra se usa para dejar los
    // filtros siempre a la vista, en vez de esconderlos en un sheet.
    final tablet = esTabletTactil(context);
    db.Producto? abierto;
    if (_abiertoId != null) {
      for (final p in productos) {
        if (p.id == _abiertoId) abierto = p;
      }
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: fabVista(
        context,
        visible: puedeEscribir,
        onTap: () => _queHago(context, ref),
      ),
      body: ContenidoEscritorio.tabla(
        child: MaestroDetalle(
          panel: abierto == null
              ? null
              : Padding(
                  padding: padVista(context).copyWith(left: 0),
                  child: PanelLateral(
                    titulo: 'Producto',
                    onCerrar: () => setState(() => _abiertoId = null),
                    child: _PanelProducto(
                      key: ValueKey(abierto.id),
                      producto: abierto,
                      portada: portadas[abierto.id],
                      variantes: variantes[abierto.id] ?? const [],
                      stockPorVariante: stock,
                      puedeEscribir: puedeEscribir,
                    ),
                  ),
                ),
          lista: _conColumnaDeFiltros(
            tablet: tablet,
            proveedores: proveedores,
            proveedor: proveedor,
            grilla: ListView(
              padding: tablet
                  ? padVista(context).copyWith(left: 0)
                  : padVista(context),
              children: [
              FadeSlideIn(
                // `Wrap` y no `Row`: el título más los tres atajos no entran
                // en 390 px, y el que quedaba afuera era "Proveedores". Así
                // bajan a una segunda línea en vez de cortarse.
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    Text('Productos', style: serif(size: 24, weight: 500)),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 16,
                      runSpacing: 6,
                      children: [
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => mostrarMiTienda(context),
                          child: Text('Mi tienda',
                              style: sans(
                                  size: 13, weight: 600, color: MColors.brand)),
                        ),
                        const SizedBox(width: 16),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => mostrarLiquidaciones(context),
                          child: Text('Liquidar',
                              style: sans(
                                  size: 13,
                                  weight: 600,
                                  color: MColors.tMuted)),
                        ),
                        const SizedBox(width: 16),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => mostrarProveedores(context),
                          child: Text('Proveedores',
                              style: sans(
                                  size: 13,
                                  weight: 600,
                                  color: MColors.tMuted)),
                        ),
                        if (escritorio && puedeEscribir) ...[
                          const SizedBox(width: 22),
                          BotonPrimario(
                            texto: 'Vender / cargar',
                            onTap: () => _queHago(context, ref),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              FadeSlideIn(
                delay: const Duration(milliseconds: 40),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: ConstrainedBox(
                    // Un buscador de 1300 px es el sello de la app de celular
                    // estirada; con 340 se lee como un campo de escritorio.
                    constraints: BoxConstraints(
                        maxWidth: escritorio ? 340 : double.infinity),
                    child: CampoTexto(
                      controlador: _busqueda,
                      etiqueta: 'Buscar por nombre o código',
                      onCambio: (_) => setState(() {}),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              // Una sola fila de chips, y lo que no entra va al sheet de
              // filtros. Dos filas de chips comían un tercio de la pantalla
              // antes de ver la primera prenda.
              // En la tablet los filtros viven en la columna de la
              // izquierda, así que acá no van.
              if (!tablet)
                FadeSlideIn(
                  delay: const Duration(milliseconds: 60),
                  child: Row(
                    children: [
                      Expanded(
                        child: FilaFiltros(
                          opciones: _rubros,
                          activo: _rubro,
                          onElegir: (v) => setState(() => _rubro = v),
                        ),
                      ),
                      const SizedBox(width: 9),
                      _BotonFiltros(
                        activos: [
                          _filtro != 'todos',
                          proveedor != 'todos',
                          _orden != 'nuevas',
                        ].where((v) => v).length,
                        onTap: () => _abrirFiltros(context),
                      ),
                    ],
                  ),
                ),
              SizedBox(height: tablet ? 4 : 14),
              if (cargando)
                const EsqueletoDeLista(
                  filas: 3,
                  alto: 92,
                  padding: EdgeInsets.zero,
                  desplazable: false,
                )
              else if (visibles.isEmpty)
                EstadoVacio(
                  emoji: '👗',
                  titulo: productos.isEmpty
                      ? 'Todavía no cargaste ropa'
                      : 'Nada con ese filtro',
                  detalle: productos.isEmpty
                      ? 'Tocá + para cargar la primera prenda'
                      : 'Probá con otra búsqueda',
                )
              else
                // `GridView` adentro de un `ListView`: shrinkWrap y sin scroll
                // propio, para que la página entera se desplace como una sola.
                //
                // Y adentro de un `LayoutBuilder`, porque el ancho de la grilla
                // no es el de la pantalla: le comieron la columna de filtros y
                // —cuando está abierto— el panel lateral de 400 px.
                LayoutBuilder(
                  builder: (ctx, limites) => GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    gridDelegate: _grillaPrendas(
                      ctx,
                      ancho: limites.maxWidth,
                      espacio: escritorio ? 14 : 12,
                      // En el teléfono son dos y punto: por ancho mínimo daría
                      // una sola columna, o sea una lista con fotos enormes.
                      columnas: !escritorio
                          ? 2
                          : columnasPara(
                              limites.maxWidth,
                              minAncho: 220,
                              // A los 924 px que le quedan a la tablet de 1280
                              // esto da las cuatro que pidió el diseñador; con
                              // el panel abierto baja solo.
                              max: tablet ? 4 : 6,
                            ),
                    ),
                    itemCount: visibles.length,
                    itemBuilder: (_, i) {
                      final p = visibles[i];
                      return FadeSlideIn(
                        delay:
                            Duration(milliseconds: 100 + (i < 8 ? i : 8) * 30),
                        child: _TarjetaPrenda(
                          producto: p,
                          portada: portadas[p.id],
                          stock: stockDe(p.id),
                          variantes: (variantes[p.id] ?? const []).length,
                          // En escritorio, tocar abre el panel de al lado; en
                          // el teléfono va directo al formulario, como siempre.
                          onTap: escritorio
                              ? () => setState(() =>
                                  _abiertoId = _abiertoId == p.id ? null : p.id)
                              : () => abrirFormularioProducto(context, ref,
                                  producto: p),
                        ),
                      );
                    },
                  ),
                ),
            ],
            ),
          ),
        ),
      ),
    );
  }

  /// En la tablet los filtros van fijos a la izquierda de la grilla: con la
  /// clienta enfrente, abrir un sheet para cambiar de rubro y volver a
  /// cerrarlo es el camino largo, y el ancho está.
  Widget _conColumnaDeFiltros({
    required bool tablet,
    required List<db.Proveedore> proveedores,
    required String proveedor,
    required Widget grilla,
  }) {
    if (!tablet) return grilla;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 210,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(32, 30, 0, 40),
            child: _ColumnaFiltros(
              rubro: _rubro,
              estado: _filtro,
              proveedor: proveedor,
              proveedores: proveedores,
              orden: _orden,
              onRubro: (v) => setState(() => _rubro = v),
              onEstado: (v) => setState(() => _filtro = v),
              onProveedor: (v) => setState(() => _proveedor = v),
              onOrden: (v) => setState(() => _orden = v),
            ),
          ),
        ),
        const SizedBox(width: 22),
        Expanded(child: grilla),
      ],
    );
  }
}

/// La columna de filtros de la tablet. Las mismas opciones del sheet, pero
/// siempre visibles y en filas de 44, que es lo que pide un dedo.
class _ColumnaFiltros extends StatelessWidget {
  const _ColumnaFiltros({
    required this.rubro,
    required this.estado,
    required this.proveedor,
    required this.proveedores,
    required this.orden,
    required this.onRubro,
    required this.onEstado,
    required this.onProveedor,
    required this.onOrden,
  });

  final String rubro;
  final String estado;
  final String proveedor;
  final List<db.Proveedore> proveedores;
  final String orden;
  final ValueChanged<String> onRubro;
  final ValueChanged<String> onEstado;
  final ValueChanged<String> onProveedor;
  final ValueChanged<String> onOrden;

  @override
  // Sin aire extra entre grupos: `EtiquetaSeccion` ya trae 20 arriba y 8
  // abajo, y los cuatro grupos suman unos 900 px. Una tablet de 1280x800 que
  // reporta densidad 1,5 tiene **533** de alto, o sea ~405 utiles: la columna
  // scrollea igual, pero cada pixel que se ahorra es una fila mas de filtro
  // que se ve sin tener que descubrir que se puede scrollear.
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Filtros', style: serif(size: 20, weight: 600)),
          const SizedBox(height: 16),
          const EtiquetaSeccion('RUBRO'),
          for (final (clave, etiqueta) in _rubros)
            _FilaFiltro(
              texto: etiqueta,
              activo: rubro == clave,
              onTap: () => onRubro(clave),
            ),
          const EtiquetaSeccion('ESTADO'),
          for (final (clave, etiqueta) in _estados)
            _FilaFiltro(
              texto: etiqueta,
              activo: estado == clave,
              onTap: () => onEstado(clave),
            ),
          // Sin proveedores cargados el grupo sería "Todos" solo: una opción
          // única no filtra nada, ocupa 44 px y hace dudar de si falta algo.
          if (proveedores.isNotEmpty) ...[
              const EtiquetaSeccion('PROVEEDOR'),
            _FilaFiltro(
              texto: 'Todos',
              activo: proveedor == 'todos',
              onTap: () => onProveedor('todos'),
            ),
            for (final p in proveedores)
              _FilaFiltro(
                texto: p.nombre,
                activo: proveedor == p.id,
                onTap: () => onProveedor(p.id),
              ),
          ],
          const EtiquetaSeccion('ORDEN'),
          for (final (clave, etiqueta) in _ordenes)
            _FilaFiltro(
              texto: etiqueta,
              activo: orden == clave,
              onTap: () => onOrden(clave),
            ),
        ],
      );
}

/// Una opción de la columna: 44 px de alto, y la activa con el fondo lavanda.
class _FilaFiltro extends StatelessWidget {
  const _FilaFiltro({
    required this.texto,
    required this.activo,
    required this.onTap,
  });

  final String texto;
  final bool activo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: PressableScale(
          onTap: onTap,
          child: Container(
            height: 44,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: activo ? MColors.brandBg : Colors.transparent,
              border: Border.all(
                color: activo ? MColors.borderLav : Colors.transparent,
              ),
              borderRadius: BorderRadius.circular(MRadius.md),
            ),
            child: Text(
              texto,
              // El nombre de un proveedor lo escribe la dueña y la columna
              // mide 210: sin esto, "Distribuidora del Norte SRL" desbordaba.
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: sans(
                size: 13.5,
                weight: activo ? 600 : 500,
                color: activo ? MColors.brandDark : MColors.tSecondary,
              ),
            ),
          ),
        ),
      );
}

/// El chip del sheet de filtros del teléfono. Existe para no repetir el mismo
/// `Container` en los tres grupos: cada copia era una chance de que una quedara
/// con el borde viejo.
class _ChipFiltro extends StatelessWidget {
  const _ChipFiltro({
    required this.texto,
    required this.activo,
    required this.onTap,
  });

  final String texto;
  final bool activo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => PressableScale(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: activo ? MColors.brandBg : MColors.surface,
            border: Border.all(
              color: activo ? MColors.borderLav : MColors.border,
            ),
            borderRadius: BorderRadius.circular(MRadius.full),
          ),
          child: Text(
            texto,
            style: sans(
              size: 12.5,
              weight: activo ? 600 : 500,
              color: activo ? MColors.brandDark : MColors.tSecondary,
            ),
          ),
        ),
      );
}

/// Detalle de un producto en el panel lateral de escritorio: la foto grande,
/// los datos, las variantes con su stock, y las dos cosas que se hacen con
/// una prenda: venderla o editarla.
class _PanelProducto extends ConsumerWidget {
  const _PanelProducto({
    super.key,
    required this.producto,
    required this.portada,
    required this.variantes,
    required this.stockPorVariante,
    required this.puedeEscribir,
  });

  final db.Producto producto;
  final db.ProductoFoto? portada;
  final List<db.ProductoVariante> variantes;
  final Map<String, int> stockPorVariante;
  final bool puedeEscribir;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final total =
        variantes.fold<int>(0, (a, v) => a + (stockPorVariante[v.id] ?? 0));
    final sinStock = total <= 0;

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(MRadius.md),
          child: AspectRatio(
            aspectRatio: 1,
            child: _Portada(foto: portada, sinStock: sinStock),
          ),
        ),
        const SizedBox(height: 16),
        if (producto.codigo case final c?)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              c,
              style: sans(
                size: 10,
                weight: 600,
                color: MColors.tLight,
                letterSpacing: 0.5,
              ),
            ),
          ),
        Text(producto.nombre, style: serif(size: 22, weight: 600)),
        const SizedBox(height: 6),
        Text(formatMoney(producto.precio), style: serif(size: 26, weight: 600)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            Pildora(
              texto: producto.publicado ? 'En la tienda' : 'Sin publicar',
              fondo: producto.publicado ? MColors.successBg : MColors.bg3,
              color:
                  producto.publicado ? MColors.successText : MColors.tSecondary,
            ),
            Pildora(
              texto: sinStock ? 'Sin stock' : '$total en stock',
              fondo: sinStock ? MColors.dangerBg : MColors.bg2,
              color: sinStock ? MColors.dangerText : MColors.tSecondary,
            ),
            if (producto.categoria case final cat?)
              if (cat.isNotEmpty)
                Pildora(
                  texto: cat,
                  fondo: MColors.lav50,
                  color: MColors.brandDark,
                ),
          ],
        ),
        if (producto.descripcion case final d?)
          if (d.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              d,
              style: sans(size: 13, color: MColors.tSecondary)
                  .copyWith(height: 1.55),
            ),
          ],
        const SizedBox(height: 18),
        const EtiquetaSeccion('VARIANTES'),
        if (variantes.isEmpty)
          Text('Sin variantes', style: sans(size: 13, color: MColors.tMuted))
        else
          for (final v in variantes)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      [
                        if (v.talle case final t?)
                          if (t.isNotEmpty) t,
                        if (v.color case final c?)
                          if (c.isNotEmpty) c,
                      ].join(' · ').ifEmpty('Única'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: sans(size: 13, weight: 500),
                    ),
                  ),
                  Text(
                    '${stockPorVariante[v.id] ?? 0}',
                    style: sans(
                      size: 14,
                      weight: 700,
                      tabular: true,
                      color: (stockPorVariante[v.id] ?? 0) <= 0
                          ? MColors.dangerText
                          : MColors.tPrimary,
                    ),
                  ),
                ],
              ),
            ),
        const SizedBox(height: 18),
        if (puedeEscribir) ...[
          BotonPrimario(
            texto: 'Vender',
            icono: Icons.point_of_sale_rounded,
            onTap: sinStock
                ? null
                : () => abrirVenta(context, variante: _primeraConStock()),
          ),
          const SizedBox(height: 8),
          PressableScale(
            onTap: () =>
                abrirFormularioProducto(context, ref, producto: producto),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: MColors.bg2,
                border: Border.all(color: MColors.borderMd),
                borderRadius: BorderRadius.circular(MRadius.full),
              ),
              child: Text(
                'Editar producto',
                textAlign: TextAlign.center,
                style: sans(size: 14, weight: 600, color: MColors.tSecondary),
              ),
            ),
          ),
        ],
      ],
    );
  }

  db.ProductoVariante? _primeraConStock() {
    for (final v in variantes) {
      if ((stockPorVariante[v.id] ?? 0) > 0) return v;
    }
    return null;
  }
}

extension on String {
  String ifEmpty(String otro) => isEmpty ? otro : this;
}

/// El botón cuadrado que abre los filtros, con el contador de los activos.
///
/// El contador es lo que evita el clásico "no aparece nada y no sé por qué":
/// un filtro puesto hace media hora sigue filtrando y nada lo recuerda.
class _BotonFiltros extends StatelessWidget {
  const _BotonFiltros({required this.activos, required this.onTap});

  final int activos;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => PressableScale(
        onTap: onTap,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: MColors.brand,
                borderRadius: BorderRadius.circular(MRadius.md),
                boxShadow: MShadow.brand,
              ),
              child: const Icon(Icons.tune_rounded,
                  size: 19, color: MColors.tWhite),
            ),
            if (activos > 0)
              Positioned(
                top: -3,
                right: -3,
                child: Container(
                  constraints: const BoxConstraints(minWidth: 17),
                  height: 17,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: MColors.nude500,
                    borderRadius: BorderRadius.circular(MRadius.full),
                    border: Border.all(color: MColors.surface, width: 2),
                  ),
                  child: Text(
                    '$activos',
                    style: sans(size: 9.5, weight: 700, color: MColors.tWhite),
                  ),
                ),
              ),
          ],
        ),
      );
}

/// El + ofrece las dos cosas que se hacen acá. Vender va primero porque pasa
/// muchas más veces que cargar una prenda nueva.
Future<void> _queHago(BuildContext context, WidgetRef ref) async {
  final r = await showAppSheet<String>(
    context,
    builder: (ctx) => Container(
      decoration: const BoxDecoration(
        color: MColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(MRadius.xl)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Opcion(
              emoji: '💵',
              titulo: 'Vender',
              detalle: 'Cargar una venta',
              onTap: () => Navigator.of(ctx).pop('venta'),
            ),
            const SizedBox(height: 10),
            _Opcion(
              emoji: '👗',
              titulo: 'Nueva prenda',
              detalle: 'Sumar al catálogo',
              onTap: () => Navigator.of(ctx).pop('prenda'),
            ),
          ],
        ),
      ),
    ),
  );
  if (r == null || !context.mounted) return;
  if (r == 'venta') {
    await abrirVenta(context);
  } else {
    await abrirFormularioProducto(context, ref);
  }
}

class _Opcion extends StatelessWidget {
  const _Opcion({
    required this.emoji,
    required this.titulo,
    required this.detalle,
    required this.onTap,
  });

  final String emoji;
  final String titulo;
  final String detalle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          decoration: BoxDecoration(
            color: MColors.bg2,
            border: Border.all(color: MColors.border),
            borderRadius: BorderRadius.circular(MRadius.md),
          ),
          child: Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 13),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(titulo, style: sans(size: 14, weight: 600)),
                  Text(detalle, style: sans(size: 11, color: MColors.tMuted)),
                ],
              ),
            ],
          ),
        ),
      );
}

/// Lo que mide el bloque de texto de una tarjeta: código + nombre en dos
/// líneas + precio + stock, con su padding.
///
/// Se **reserva**, no se mide: el `GridView` necesita la relación de aspecto de
/// la celda antes de construir una sola tarjeta. Pero no es un ojímetro, es una
/// cuenta exacta, y se puede porque el tema pone `MText.cuerpoSec` en
/// `bodyMedium` y todos los `sans()`/`serif()` sin `height` propio heredan su
/// 1,6: cada línea mide tamaño × 1,6 justo, sin depender de las métricas de la
/// fuente. Las cuatro líneas son 9 (código), 13 × 2 (el nombre, con
/// `maxLines: 2`), 17 (precio) y 10 (stock), y se escalan de a una porque la
/// fuente del sistema no escala lineal en Android 14.
///
/// Los `scale` van sobre cada tamaño y no sobre la suma, y sobran 5 px: pasarse
/// deja un poco de aire abajo, quedarse corto rompe la `Column` de la tarjeta.
double _altoTextoTarjeta(BuildContext context) {
  final f = MediaQuery.textScalerOf(context);
  final texto =
      1.6 * (f.scale(9) + 2 * f.scale(13) + f.scale(17) + f.scale(10));
  // 22 del padding (10 + 12), 3 abajo del código y los dos `SizedBox` de 5 y 6.
  return 36 + texto + 5;
}

/// La grilla de prendas: la celda se calcula, no se fija.
///
/// Con `childAspectRatio` a mano la foto se quedaba con lo que sobrara después
/// del texto, y el texto mide siempre lo mismo. En la tablet, al abrirse el
/// panel lateral de 400 px, la celda pasaba de 220×334 a 115×175 y a la foto le
/// quedaban 62 px: una tira horizontal de la prenda. Con la fuente al 130 % le
/// quedaban cero y la `Column` desbordaba, clipeada en silencio.
///
/// Ahora manda la foto —cuadrada, como en el panel lateral— y el alto de la
/// celda sale de sumarle el texto.
SliverGridDelegate _grillaPrendas(
  BuildContext context, {
  required double ancho,
  required int columnas,
  required double espacio,
}) {
  final anchoCelda = (ancho - espacio * (columnas - 1)) / columnas;
  return SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: columnas,
    crossAxisSpacing: espacio,
    mainAxisSpacing: espacio,
    childAspectRatio: anchoCelda / (anchoCelda + _altoTextoTarjeta(context)),
  );
}

class _TarjetaPrenda extends StatelessWidget {
  const _TarjetaPrenda({
    required this.producto,
    required this.portada,
    required this.stock,
    required this.variantes,
    required this.onTap,
  });

  final db.Producto producto;
  final db.ProductoFoto? portada;
  final int stock;
  final int variantes;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final sinStock = stock <= 0;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: MColors.surface,
          borderRadius: BorderRadius.circular(MRadius.md),
          border: Border.all(color: MColors.border),
          boxShadow: MShadow.xs,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cuadrada y no `Expanded`: la foto manda su alto, igual que en el
            // panel lateral. Con `Expanded` se quedaba con el resto, y el resto
            // depende del texto — ver `_grillaPrendas`. El `Container` de
            // arriba ya clipea, así que no hace falta un `ClipRRect` acá.
            AspectRatio(
              aspectRatio: 1,
              child: _Portada(foto: portada, sinStock: sinStock),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(11, 10, 11, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (producto.codigo case final c?)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 3),
                      child: Text(
                        c,
                        // Una línea: el alto de la tarjeta cuenta con que sean
                        // cuatro líneas y un código largo sumaría una quinta.
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: sans(
                          size: 9,
                          weight: 600,
                          color: MColors.tLight,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  Text(
                    producto.nombre,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: sans(size: 13, weight: 600),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    formatMoney(producto.precio),
                    // En una línea o nada: con la fuente al 130 %, un precio de
                    // seis cifras pasaba a dos líneas y esa línea de más es la
                    // que rompía la tarjeta.
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: serif(size: 17, weight: 600),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          sinStock ? 'Sin stock' : '$stock en stock',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: sans(
                            size: 10,
                            weight: sinStock ? 600 : 400,
                            color:
                                sinStock ? MColors.dangerText : MColors.tMuted,
                          ),
                        ),
                      ),
                      if (variantes > 1) ...[
                        Text(' · ',
                            style: sans(size: 10, color: MColors.tLight)),
                        Flexible(
                          child: Text('$variantes talles',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: sans(size: 10, color: MColors.tMuted)),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// La foto de portada, o el hueco cuando todavía no hay.
class _Portada extends StatelessWidget {
  const _Portada({required this.foto, required this.sinStock});

  final db.ProductoFoto? foto;
  final bool sinStock;

  @override
  Widget build(BuildContext context) {
    final f = foto;

    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          color: MColors.bg2,
          child: f == null
              ? Center(
                  child: Opacity(
                    opacity: 0.25,
                    child: Text('👗', style: const TextStyle(fontSize: 34)),
                  ),
                )
              : _Imagen(foto: f),
        ),
        // Una prenda agotada se ve agotada de un vistazo, sin leer el número.
        if (sinStock)
          Container(
            color: MColors.surface.withValues(alpha: 0.55),
            alignment: Alignment.center,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: MColors.dangerBg,
                border: Border.all(color: MColors.dangerBorder),
                borderRadius: BorderRadius.circular(MRadius.full),
              ),
              child: Text(
                'Agotado',
                style: sans(size: 10, weight: 600, color: MColors.dangerText),
              ),
            ),
          ),
      ],
    );
  }
}

class _Imagen extends StatelessWidget {
  const _Imagen({required this.foto});

  final db.ProductoFoto foto;

  @override
  Widget build(BuildContext context) {
    // Mientras no se subió, la foto vive en el teléfono. Se muestra igual: la
    // prenda ya se puede vender aunque la imagen todavía no esté en la nube.
    if (foto.pendienteDeSubir) {
      return Stack(
        fit: StackFit.expand,
        children: [
          if (foto.rutaLocal case final r?)
            Image.file(
              File(r),
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox(),
            ),
          Positioned(
            left: 6,
            top: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: MColors.warningBg,
                border: Border.all(color: MColors.warningBorder),
                borderRadius: BorderRadius.circular(MRadius.full),
              ),
              child: Text('Falta subir',
                  style:
                      sans(size: 9, weight: 600, color: MColors.warningText)),
            ),
          ),
        ],
      );
    }

    return Image.network(
      foto.path,
      fit: BoxFit.cover,
      // Sin esto, una foto que todavía no bajó deja un rectángulo blanco que
      // parece un error de la app.
      loadingBuilder: (_, hijo, progreso) => progreso == null
          ? hijo
          : Center(
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: MColors.tLight,
                ),
              ),
            ),
      errorBuilder: (_, __, ___) => Center(
        child: Opacity(
          opacity: 0.25,
          child: Text('👗', style: const TextStyle(fontSize: 34)),
        ),
      ),
    );
  }
}
