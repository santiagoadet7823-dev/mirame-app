// La Tienda en la tablet del mostrador, CON prendas adentro.
//
// Los tests que ya había montaban `RopaView` sin un solo producto: la grilla
// nunca se dibujaba, así que la geometría de la tarjeta —lo único que se puede
// romper acá— no la miraba nadie. El bug que esto fija: con `crossAxisCount: 4`
// fijo y la foto en un `Expanded`, abrir el panel lateral de 400 px no sacaba
// columnas, achicaba las celdas, y la foto se quedaba con lo que el bloque de
// texto le dejara: una tira de 62 px de la prenda.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mirame/core/layout/layout.dart';
import 'package:mirame/core/theme/app_theme.dart';
import 'package:mirame/data/local/database.dart' as db;
import 'package:mirame/domain/entities/access.dart';
import 'package:mirame/domain/rules/access.dart';
import 'package:mirame/features/auth/session_controller.dart';
import 'package:mirame/features/ropa/ropa_view.dart';

class _ConSalon extends SessionController {
  @override
  SessionState build() => const SessionState(
        decision: GoToApp(
          tenant: Tenant(
            id: 't1',
            nombre: 'Mírame',
            slug: 'mirame',
            estado: TenantEstado.activo,
          ),
          rol: MiembroRol.owner,
        ),
      );
}

final _fecha = DateTime(2026, 9, 1);

/// Ninguno se llama "Arbell" ni "Ropa": son etiquetas del grupo RUBRO y
/// `find.text` no distinguiría el chip del proveedor.
final _proveedores = [
  db.Proveedore(
    id: 'v1',
    tenantId: 't1',
    createdAt: _fecha,
    updatedAt: _fecha,
    nombre: 'Distribuidora Norte',
    pctSalon: 30,
    descuentoLoAbsorbeSalon: true,
    activo: true,
  ),
  db.Proveedore(
    id: 'v2',
    tenantId: 't1',
    createdAt: _fecha,
    updatedAt: _fecha,
    nombre: 'Tienda Sur',
    pctSalon: 40,
    descuentoLoAbsorbeSalon: true,
    activo: true,
  ),
];

db.Producto _prenda({
  required String id,
  required String nombre,
  required String codigo,
  required double precio,
  required String proveedorId,
  required DateTime creada,
}) =>
    db.Producto(
      id: id,
      tenantId: 't1',
      createdAt: creada,
      updatedAt: creada,
      proveedorId: proveedorId,
      nombre: nombre,
      codigo: codigo,
      precio: precio,
      rubro: 'ropa',
      publicado: true,
      destacado: false,
    );

/// En el orden en que los entrega el repositorio: `createdAt desc`, que es lo
/// que la vista llama "Más nuevas" y no vuelve a ordenar.
///
/// Los tres órdenes dan tres resultados distintos a propósito: si precio y
/// stock coincidieran con el default, un `sort` roto pasaría igual.
final _prendas = [
  _prenda(
    id: 'p1',
    nombre: 'Vestido Lino',
    codigo: 'MIR-001',
    precio: 42000,
    proveedorId: 'v1',
    creada: DateTime(2026, 9, 20),
  ),
  _prenda(
    id: 'p2',
    nombre: 'Blusa Seda',
    codigo: 'MIR-002',
    precio: 12500,
    proveedorId: 'v2',
    creada: DateTime(2026, 9, 10),
  ),
  _prenda(
    id: 'p3',
    nombre: 'Pollera Cuero',
    codigo: 'MIR-003',
    precio: 88000,
    proveedorId: 'v1',
    creada: DateTime(2026, 9, 5),
  ),
];

db.ProductoVariante _variante(String id, String productoId, String talle) =>
    db.ProductoVariante(
      id: id,
      tenantId: 't1',
      createdAt: _fecha,
      updatedAt: _fecha,
      productoId: productoId,
      talle: talle,
    );

final _variantes = {
  'p1': [_variante('s1', 'p1', 'M'), _variante('s2', 'p1', 'L')],
  'p2': [_variante('s3', 'p2', 'Única')],
  'p3': [_variante('s4', 'p3', 'S')],
};

/// Stock por variante: Vestido 5, Blusa 9, Pollera 12.
const _stock = {'s1': 3, 's2': 2, 's3': 9, 's4': 12};

Future<void> _montarTienda(
  WidgetTester t, {
  double escala = 1,
  bool conProveedores = true,
}) async {
  modoTactilForzado = true;
  t.view.physicalSize = const Size(1280, 800);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.resetPhysicalSize);
  addTearDown(t.view.resetDevicePixelRatio);
  await t.pumpWidget(
    ProviderScope(
      overrides: [
        sessionProvider.overrideWith(_ConSalon.new),
        productosProvider.overrideWith((ref) => Stream.value(_prendas)),
        variantesProvider.overrideWith((ref) => Stream.value(_variantes)),
        stockRopaProvider.overrideWith((ref) => Stream.value(_stock)),
        proveedoresProvider.overrideWith(
            (ref) => Stream.value(conProveedores ? _proveedores : const [])),
      ],
      child: MaterialApp(
        theme: buildMirameTheme(),
        // La fuente del sistema se fija acá y no en el `MediaQuery` del test
        // para que la vea todo el árbol, incluidas las tarjetas que se
        // construyen dentro del `GridView`.
        builder: (ctx, hijo) => MediaQuery.withClampedTextScaling(
          minScaleFactor: escala,
          maxScaleFactor: escala,
          child: hijo!,
        ),
        home: Scaffold(body: const RopaView()),
      ),
    ),
  );
  // Las tarjetas entran con `FadeSlideIn`, que las desplaza: hasta que no
  // termina, las posiciones que se midan son las del medio de la animación.
  await t.pump(const Duration(seconds: 1));
}

/// Los rectángulos de las fotos de las tarjetas de la grilla. Se buscan por el
/// `AspectRatio`, que es justo lo que el bug no tenía, y se filtra por el
/// `GridView` para no levantar también la foto del panel lateral.
List<Rect> _fotos(WidgetTester t) {
  final f = find.descendant(
    of: find.byType(GridView),
    matching: find.byType(AspectRatio),
  );
  return [for (var i = 0; i < f.evaluate().length; i++) t.getRect(f.at(i))];
}

/// Cuántas columnas tiene la grilla, sacadas del ancho real y del paso entre
/// dos fotos vecinas. Contar filas no alcanza: con tres prendas, tres, cuatro o
/// cinco columnas dan la misma única fila.
int _columnas(WidgetTester t) {
  final fotos = _fotos(t);
  final ancho = t.getSize(find.byType(GridView)).width;
  return (ancho / (fotos[1].left - fotos[0].left)).round();
}

/// Toca una opción de la columna de filtros.
///
/// Con los cuatro grupos, la columna mide más de 800: ORDEN queda abajo del
/// borde de una tablet acostada y hay que traerlo con su propio scroll, que es
/// lo que hace `ensureVisible`. Sin esto el `tap` cae fuera de la pantalla.
Future<void> _tocarFiltro(WidgetTester t, String texto) async {
  await t.ensureVisible(find.text(texto));
  await t.pumpAndSettle();
  await t.tap(find.text(texto));
  await t.pumpAndSettle();
}

/// En qué orden están las prendas en la grilla: izquierda a derecha, arriba a
/// abajo. El `sort` de la vista se ve acá y en ningún otro lado.
List<String> _ordenEnPantalla(WidgetTester t) {
  final pos = <String, Offset>{};
  for (final nombre in ['Vestido Lino', 'Blusa Seda', 'Pollera Cuero']) {
    final f = find.text(nombre);
    if (f.evaluate().isNotEmpty) pos[nombre] = t.getTopLeft(f);
  }
  final nombres = pos.keys.toList()
    ..sort((a, b) {
      final fila = pos[a]!.dy.compareTo(pos[b]!.dy);
      return fila != 0 ? fila : pos[a]!.dx.compareTo(pos[b]!.dx);
    });
  return nombres;
}

void main() {
  tearDown(() => modoTactilForzado = null);

  testWidgets('Las cuatro columnas de la tablet, con foto cuadrada', (t) async {
    await _montarTienda(t);
    final fotos = _fotos(t);
    expect(fotos.length, 3);
    // Las cuatro que pidió el diseñador, y las tres prendas en una sola fila.
    expect(_columnas(t), 4);
    expect(fotos.map((r) => r.top).toSet().length, 1);
    for (final r in fotos) {
      expect(r.height, closeTo(r.width, 1));
      expect(r.height, greaterThan(200));
    }
  });

  testWidgets('Con el panel abierto la grilla baja de columnas y la foto '
      'sigue entera', (t) async {
    await _montarTienda(t);
    final antes = _fotos(t);

    // `pumpAndSettle` y no `pump`: el panel entra con un `AnimatedSize`, y un
    // solo frame arranca la animación sin avanzarla — la grilla se seguía
    // midiendo con el ancho de antes.
    await t.tap(find.text('Vestido Lino'));
    await t.pumpAndSettle();
    // El panel está abierto: 'PRODUCTO' es su título — `PanelLateral` lo pone
    // en mayúscula, así que no se confunde con el 'Productos' del encabezado.
    expect(find.text('PRODUCTO'), findsOneWidget);

    final despues = _fotos(t);
    expect(despues.length, 3);
    // La grilla sacó columnas en vez de achicar las celdas: de cuatro a dos, y
    // las tres prendas pasan a ocupar dos filas.
    expect(_columnas(t), 2);
    expect(despues.map((r) => r.top).toSet().length, greaterThan(1));
    // El bug dejaba la foto en 62 px de alto contra 115 de ancho. Ahora sigue
    // cuadrada, y no más chica que antes.
    for (final r in despues) {
      expect(r.height, closeTo(r.width, 1));
      expect(r.height, greaterThan(150));
    }
    expect(despues.first.height, greaterThan(antes.first.height * 0.75));
  });

  testWidgets('La tarjeta aguanta la fuente del sistema al 130 %', (t) async {
    await _montarTienda(t, escala: 1.3);
    expect(t.takeException(), isNull);
    // Con el panel abierto es el caso peor: celda angosta y texto grande.
    await t.tap(find.text('Vestido Lino'));
    await t.pumpAndSettle();
    expect(t.takeException(), isNull);
    for (final r in _fotos(t)) {
      expect(r.height, greaterThan(150));
    }
  });

  testWidgets('La columna de filtros tiene los cuatro grupos', (t) async {
    await _montarTienda(t);
    expect(find.text('RUBRO'), findsOneWidget);
    expect(find.text('ESTADO'), findsOneWidget);
    expect(find.text('PROVEEDOR'), findsOneWidget);
    expect(find.text('ORDEN'), findsOneWidget);
    // Los proveedores son los que existen, no una lista inventada.
    expect(find.text('Distribuidora Norte'), findsOneWidget);
    expect(find.text('Tienda Sur'), findsOneWidget);
    expect(find.text('Más nuevas'), findsOneWidget);
    expect(find.text('Precio'), findsOneWidget);
    expect(find.text('Stock'), findsOneWidget);
  });

  testWidgets('Sin proveedores cargados no hay grupo Proveedor', (t) async {
    await _montarTienda(t, conProveedores: false);
    expect(find.text('ESTADO'), findsOneWidget);
    // Un grupo con una sola opción ("Todos") no filtra nada.
    expect(find.text('PROVEEDOR'), findsNothing);
    expect(find.text('ORDEN'), findsOneWidget);
  });

  testWidgets('Filtrar por proveedor deja solo sus prendas', (t) async {
    await _montarTienda(t);
    expect(_ordenEnPantalla(t).length, 3);

    await _tocarFiltro(t, 'Tienda Sur');
    expect(_ordenEnPantalla(t), ['Blusa Seda']);

    await _tocarFiltro(t, 'Distribuidora Norte');
    expect(_ordenEnPantalla(t), ['Vestido Lino', 'Pollera Cuero']);
  });

  testWidgets('Ordenar por precio y por stock cambia la grilla', (t) async {
    await _montarTienda(t);
    // El default es lo que ya entrega el repositorio: `createdAt desc`.
    expect(
      _ordenEnPantalla(t),
      ['Vestido Lino', 'Blusa Seda', 'Pollera Cuero'],
    );

    await _tocarFiltro(t, 'Precio');
    // Ascendente: de lo más barato a lo más caro.
    expect(
      _ordenEnPantalla(t),
      ['Blusa Seda', 'Vestido Lino', 'Pollera Cuero'],
    );

    await _tocarFiltro(t, 'Stock');
    // Descendente: 12, 9, 5.
    expect(
      _ordenEnPantalla(t),
      ['Pollera Cuero', 'Blusa Seda', 'Vestido Lino'],
    );
  });
}
