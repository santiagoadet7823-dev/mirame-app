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
import 'producto_form.dart';
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

class RopaView extends ConsumerStatefulWidget {
  const RopaView({super.key});

  @override
  ConsumerState<RopaView> createState() => _RopaViewState();
}

class _RopaViewState extends ConsumerState<RopaView> {
  final _busqueda = TextEditingController();
  String _filtro = 'todos';

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
    final puedeEscribir = ref.watch(puedeProvider(Permiso.escribirDatos));

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
              child: FabMirame(
                onTap: () => abrirFormularioProducto(context, ref),
              ),
            )
          : null,
      body: ListView(
        padding: padVistaMovil,
        children: [
          FadeSlideIn(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Ropa', style: serif(size: 24, weight: 500)),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => mostrarProveedores(context),
                  child: Text(
                    'Proveedores',
                    style:
                        sans(size: 13, weight: 600, color: MColors.brand),
                  ),
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
          const SizedBox(height: 10),
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
