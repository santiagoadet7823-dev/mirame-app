import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mirame/core/layout/layout.dart';
import 'package:mirame/core/theme/app_theme.dart';
import 'package:mirame/features/shell/vistas_comunes.dart';

/// Monta [hijo] en una ventana de [ancho] px lógicos.
Future<void> montarCon(WidgetTester t, double ancho, Widget hijo) async {
  t.view.physicalSize = Size(ancho, 800);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.resetPhysicalSize);
  addTearDown(t.view.resetDevicePixelRatio);
  await t.pumpWidget(MaterialApp(theme: buildMirameTheme(), home: hijo));
}

void main() {
  _modoTactil();
  group('modoPara', () {
    // Alto grande: un monitor o una tablet acostada.
    ModoLayout porAncho(double ancho) => modoPara(Size(ancho, 900));

    test('dos modos, un umbral de ancho', () {
      expect(porAncho(390), ModoLayout.movil);
      expect(porAncho(839), ModoLayout.movil);
      expect(porAncho(840), ModoLayout.grande);
      expect(porAncho(2560), ModoLayout.grande);
    });

    test('un celular acostado NO es pantalla grande', () {
      // Pixel 7 horizontal: 915 de ancho, pero el lado corto son 412.
      expect(modoPara(const Size(915, 412)), ModoLayout.movil);
      // iPhone 14 Pro Max horizontal, el lado corto más grande que hay: 430.
      expect(modoPara(const Size(932, 430)), ModoLayout.movil);
      // Y parado, móvil de toda la vida.
      expect(modoPara(const Size(412, 915)), ModoLayout.movil);
    });

    test('una tablet acostada sí, incluso mintiendo la densidad', () {
      // 1280 × 800 con densidad 1: la del folleto.
      expect(modoPara(const Size(1280, 800)), ModoLayout.grande);

      // **El caso que motivó todo esto.** La tablet del mostrador es de
      // 1280 × 800 pero reporta densidad 1,5, así que entrega 853 × 533
      // lógicos. Con los umbrales viejos (900 de ancho, 600 de lado corto)
      // caía en la composición del teléfono y apagaba de un saque las seis
      // composiciones de tablet, que quedaban escritas y sin ejecutarse.
      expect(modoPara(const Size(853, 533)), ModoLayout.grande);

      // Y una de 1024 × 600 con densidad 1,33, que es el otro tamaño barato.
      expect(modoPara(const Size(1024, 600)), ModoLayout.grande);

      // La misma tablet parada: vuelve al layout de celular, sin diseño
      // aparte. Lo pide el brief.
      expect(modoPara(const Size(800, 1280)), ModoLayout.movil);
      expect(modoPara(const Size(533, 853)), ModoLayout.movil);
    });
  });

  group('la preferencia de Ajustes le gana al tamaño', () {
    // Ningún umbral acierta con todos los aparatos. Esta es la salida de
    // emergencia: si una tablet rara igual cae en el layout del teléfono, se
    // fuerza a mano y se arregla en el momento.
    Future<String> modoCon(
      WidgetTester t,
      ModoPantalla elegido,
      double ancho,
    ) async {
      late String visto;
      await montarCon(
        t,
        ancho,
        PantallaPreferida(
          modo: elegido,
          child: Builder(
            builder: (ctx) {
              visto = esPantallaGrande(ctx) ? 'grande' : 'movil';
              return const SizedBox();
            },
          ),
        ),
      );
      return visto;
    }

    testWidgets('forzar Tablet en un tamaño de teléfono', (t) async {
      expect(await modoCon(t, ModoPantalla.tablet, 390), 'grande');
    });

    testWidgets('forzar Teléfono en un tamaño grande', (t) async {
      expect(await modoCon(t, ModoPantalla.telefono, 1280), 'movil');
    });

    testWidgets('en automático manda el tamaño', (t) async {
      expect(await modoCon(t, ModoPantalla.automatico, 390), 'movil');
      expect(await modoCon(t, ModoPantalla.automatico, 1280), 'grande');
    });
  });

  group('columnasPara', () {
    test('entran tantas como el ancho mínimo permita', () {
      expect(columnasPara(1040, minAncho: 260), 4);
      expect(columnasPara(1300, minAncho: 260), 5);
      expect(columnasPara(700, minAncho: 260), 2);
    });

    test('nunca menos de 1 ni más del tope', () {
      expect(columnasPara(100, minAncho: 260), 1);
      expect(columnasPara(0, minAncho: 260), 1);
      expect(columnasPara(5000, minAncho: 200, max: 6), 6);
    });
  });

  group('ContenidoEscritorio', () {
    testWidgets('en escritorio limita el ancho al tope', (t) async {
      await montarCon(
        t,
        1600,
        const ContenidoEscritorio.tabla(child: SizedBox.expand(key: Key('c'))),
      );
      expect(t.getSize(find.byKey(const Key('c'))).width, 1360);
    });

    testWidgets('en el teléfono no toca nada', (t) async {
      await montarCon(
        t,
        390,
        const ContenidoEscritorio.tabla(child: SizedBox.expand(key: Key('c'))),
      );
      expect(t.getSize(find.byKey(const Key('c'))).width, 390);
    });
  });

  group('showAppSheet', () {
    Widget disparador() => Builder(
          builder: (ctx) => TextButton(
            onPressed: () => showAppSheet<void>(
              ctx,
              builder: (_) => const SheetFormulario(
                titulo: 'Prueba',
                campos: [],
                onGuardar: _nada,
              ),
            ),
            child: const Text('abrir'),
          ),
        );

    testWidgets('en escritorio abre un diálogo centrado, sin manija',
        (t) async {
      await montarCon(t, 1280, Scaffold(body: disparador()));
      await t.tap(find.text('abrir'));
      await t.pumpAndSettle();
      expect(find.byType(Dialog), findsOneWidget);
      expect(find.byType(BottomSheet), findsNothing);
      expect(find.text('Prueba'), findsOneWidget);
      // El diálogo nunca es más ancho que el tope.
      expect(t.getSize(find.byType(SheetFormulario)).width,
          lessThanOrEqualTo(560));
    });

    testWidgets('en el teléfono sigue siendo un sheet', (t) async {
      await montarCon(t, 390, Scaffold(body: disparador()));
      await t.tap(find.text('abrir'));
      await t.pumpAndSettle();
      expect(find.byType(BottomSheet), findsOneWidget);
      expect(find.byType(Dialog), findsNothing);
    });
  });

  group('BarraVista', () {
    testWidgets('en escritorio muestra la acción; en el teléfono no',
        (t) async {
      final barra = BarraVista(
        buscador: const TextField(),
        accion: BotonPrimario(texto: 'Nueva', onTap: _nada),
      );
      await montarCon(t, 1280, Scaffold(body: barra));
      expect(find.text('Nueva'), findsOneWidget);
      // El buscador no se estira a toda la ventana.
      expect(t.getSize(find.byType(TextField)).width, lessThan(400));

      await montarCon(t, 390, Scaffold(body: barra));
      expect(find.text('Nueva'), findsNothing);
    });
  });
}

void _nada() {}

void _modoTactil() {
  group('dedo vs puntero', () {
    tearDown(() => modoTactilForzado = null);

    testWidgets('la tablet táctil usa riel, no el sidebar de la compu',
        (t) async {
      modoTactilForzado = true;
      t.view.physicalSize = const Size(1280, 800);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.resetPhysicalSize);
      addTearDown(t.view.resetDevicePixelRatio);
      await t.pumpWidget(
        MaterialApp(
          theme: buildMirameTheme(),
          home: Builder(
            builder: (ctx) => Scaffold(
              body: Text(
                esTabletTactil(ctx) ? 'riel' : 'sidebar',
              ),
            ),
          ),
        ),
      );
      expect(find.text('riel'), findsOneWidget);
    });

    testWidgets('el mismo ancho con puntero es escritorio', (t) async {
      modoTactilForzado = false;
      t.view.physicalSize = const Size(1280, 800);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.resetPhysicalSize);
      addTearDown(t.view.resetDevicePixelRatio);
      await t.pumpWidget(
        MaterialApp(
          theme: buildMirameTheme(),
          home: Builder(
            builder: (ctx) => Scaffold(
              body: Text(
                esEscritorioPuntero(ctx) ? 'sidebar' : 'riel',
              ),
            ),
          ),
        ),
      );
      expect(find.text('sidebar'), findsOneWidget);
    });
  });
}
