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

class _RopaViewState extends ConsumerState<RopaView> {
  final _busqueda = TextEditingController();
  String _filtro = 'todos';
  String _rubro = 'todo';

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
  Future<void> _abrirFiltros(BuildContext context) async {
    var elegido = _filtro;
    final r = await showAppSheet<String>(
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
                      onTap: () => setSheet(() => elegido = 'todos'),
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
                    for (final (clave, etiqueta) in const [
                      ('todos', 'Todos'),
                      ('publicados', 'En la tienda'),
                      ('sin_publicar', 'Sin publicar'),
                      ('sin_stock', 'Sin stock'),
                    ])
                      PressableScale(
                        onTap: () => setSheet(() => elegido = clave),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 9),
                          decoration: BoxDecoration(
                            color: elegido == clave
                                ? MColors.brandBg
                                : MColors.surface,
                            border: Border.all(
                              color: elegido == clave
                                  ? MColors.borderLav
                                  : MColors.border,
                            ),
                            borderRadius: BorderRadius.circular(MRadius.full),
                          ),
                          child: Text(
                            etiqueta,
                            style: sans(
                              size: 12.5,
                              weight: elegido == clave ? 600 : 500,
                              color: elegido == clave
                                  ? MColors.brandDark
                                  : MColors.tSecondary,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                CtaFijo(
                  texto: 'Ver ${_cuantosCon(elegido)} '
                      '${_cuantosCon(elegido) == 1 ? "artículo" : "artículos"}',
                  conDegrade: false,
                  onTap: () => Navigator.of(ctx).pop(elegido),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (r != null && mounted) setState(() => _filtro = r);
  }

  /// Cuántos quedarían con ese estado, sin tocar el filtro todavía.
  int _cuantosCon(String estado) {
    final productos = ref.read(productosProvider).value ?? const [];
    final variantes = ref.read(variantesProvider).value ?? const {};
    final stock = ref.read(stockRopaProvider).value ?? const {};
    int stockDe(String id) =>
        (variantes[id] ?? const []).fold(0, (a, v) => a + (stock[v.id] ?? 0));
    return productos.where((p) {
      if (_rubro != 'todo' && p.rubro != _rubro) return false;
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
    final puedeEscribir = ref.watch(puedeProvider(Permiso.operarNegocio));

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
      return switch (_filtro) {
        'publicados' => p.publicado,
        'sin_publicar' => !p.publicado,
        'sin_stock' => stockDe(p.id) <= 0,
        _ => true,
      };
    }).toList();

    final escritorio = esEscritorio(context);
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
          lista: ListView(
            padding: padVista(context),
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
              FadeSlideIn(
                delay: const Duration(milliseconds: 60),
                child: Row(
                  children: [
                    Expanded(
                      child: FilaFiltros(
                        opciones: const [
                          ('todo', 'Todo'),
                          ('ropa', 'Ropa'),
                          ('arbell', 'Arbell'),
                          ('insumos', 'Insumos'),
                        ],
                        activo: _rubro,
                        onElegir: (v) => setState(() => _rubro = v),
                      ),
                    ),
                    const SizedBox(width: 9),
                    _BotonFiltros(
                      activos: _filtro == 'todos' ? 0 : 1,
                      onTap: () => _abrirFiltros(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
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
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  gridDelegate: escritorio
                      // Por ancho máximo de tarjeta, no por cantidad: así entran
                      // 4 en una notebook y 6 en un monitor grande sin un caso
                      // especial para cada pantalla.
                      ? const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 230,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          childAspectRatio: 0.62,
                        )
                      : const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          // Más alto que ancho: la foto es vertical y abajo
                          // entran nombre, precio y stock.
                          childAspectRatio: 0.62,
                        ),
                  itemCount: visibles.length,
                  itemBuilder: (_, i) {
                    final p = visibles[i];
                    return FadeSlideIn(
                      delay: Duration(milliseconds: 100 + (i < 8 ? i : 8) * 30),
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
            ],
          ),
        ),
      ),
    );
  }
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
            Expanded(child: _Portada(foto: portada, sinStock: sinStock)),
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
                    style: serif(size: 17, weight: 600),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        sinStock ? 'Sin stock' : '$stock en stock',
                        style: sans(
                          size: 10,
                          weight: sinStock ? 600 : 400,
                          color: sinStock ? MColors.dangerText : MColors.tMuted,
                        ),
                      ),
                      if (variantes > 1) ...[
                        Text(' · ',
                            style: sans(size: 10, color: MColors.tLight)),
                        Text('$variantes talles',
                            style: sans(size: 10, color: MColors.tMuted)),
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
