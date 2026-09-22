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
  group('modoPara', () {
    test('tres modos, dos umbrales', () {
      expect(modoPara(390), ModoLayout.movil);
      expect(modoPara(599), ModoLayout.movil);
      expect(modoPara(600), ModoLayout.tablet);
      expect(modoPara(899), ModoLayout.tablet);
      expect(modoPara(900), ModoLayout.escritorio);
      expect(modoPara(2560), ModoLayout.escritorio);
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
