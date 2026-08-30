/// El catálogo de ropa: la pantalla principal del módulo.
///
/// Va en grilla de dos columnas y no en lista, que es lo que usa el resto de
/// la app: la ropa se elige mirando, y una lista de texto con una miniatura al
/// costado obliga a leer para encontrar lo que la foto dice sola.
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/motion.dart';
import '../../core/theme/shadows.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../data/local/database.dart' as db;
import '../../data/repositories/ropa_repository.dart';
import '../../domain/rules/access.dart';
import '../../domain/rules/formatting.dart';
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

  @override
  void dispose() {
    _busqueda.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productos = ref.watch(productosProvider).value ?? const [];
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

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: puedeEscribir
          ? Padding(
              padding: const EdgeInsets.only(right: 2, bottom: 8),
              child: FabMirame(onTap: () => _queHago(context, ref)),
            )
          : null,
      body: ListView(
        padding: padVistaMovil,
        children: [
          FadeSlideIn(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Productos', style: serif(size: 24, weight: 500)),
                Row(
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
                              size: 13, weight: 600, color: MColors.tMuted)),
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => mostrarProveedores(context),
                      child: Text('Proveedores',
                          style: sans(
                              size: 13, weight: 600, color: MColors.tMuted)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          FadeSlideIn(
            delay: const Duration(milliseconds: 40),
            child: CampoTexto(
              controlador: _busqueda,
              etiqueta: 'Buscar por nombre o código',
              onCambio: (_) => setState(() {}),
            ),
          ),
          const SizedBox(height: 6),
          // El rubro primero y el estado despues: se piensa "quiero ver la
          // ropa" antes que "quiero ver lo que no publique".
          FadeSlideIn(
            delay: const Duration(milliseconds: 60),
            child: FilaFiltros(
              opciones: const [
                ('todo', 'Todo'),
                ('ropa', '👗 Ropa'),
                ('arbell', '💄 Arbell'),
                ('insumos', '🧴 Insumos'),
              ],
              activo: _rubro,
              onElegir: (v) => setState(() => _rubro = v),
            ),
          ),
          const SizedBox(height: 6),
          FadeSlideIn(
            delay: const Duration(milliseconds: 70),
            child: FilaFiltros(
              opciones: const [
                ('todos', 'Todos'),
                ('publicados', 'En la tienda'),
                ('sin_publicar', 'Sin publicar'),
                ('sin_stock', 'Sin stock'),
              ],
              activo: _filtro,
              onElegir: (f) => setState(() => _filtro = f),
            ),
          ),
          const SizedBox(height: 14),
          if (visibles.isEmpty)
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
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                // Más alto que ancho: la foto es vertical y abajo entran
                // nombre, precio y stock.
                childAspectRatio: 0.62,
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
                    onTap: () =>
                        abrirFormularioProducto(context, ref, producto: p),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

/// El + ofrece las dos cosas que se hacen acá. Vender va primero porque pasa
/// muchas más veces que cargar una prenda nueva.
Future<void> _queHago(BuildContext context, WidgetRef ref) async {
  final r = await showModalBottomSheet<String>(
    context: context,
    backgroundColor: Colors.transparent,
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
                  Text(detalle,
                      style: sans(size: 11, color: MColors.tMuted)),
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
                          color: sinStock
                              ? MColors.dangerText
                              : MColors.tMuted,
                        ),
                      ),
                      if (variantes > 1) ...[
                        Text(' · ',
                            style: sans(size: 10, color: MColors.tLight)),
                        Text('$variantes talles',
                            style:
                                sans(size: 10, color: MColors.tMuted)),
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: MColors.dangerBg,
                border: Border.all(color: MColors.dangerBorder),
                borderRadius: BorderRadius.circular(MRadius.full),
              ),
              child: Text(
                'Agotado',
                style: sans(
                    size: 10, weight: 600, color: MColors.dangerText),
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: MColors.warningBg,
                border: Border.all(color: MColors.warningBorder),
                borderRadius: BorderRadius.circular(MRadius.full),
              ),
              child: Text('Falta subir',
                  style: sans(
                      size: 9,
                      weight: 600,
                      color: MColors.warningText)),
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
