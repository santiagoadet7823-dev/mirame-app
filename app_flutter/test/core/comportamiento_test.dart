// La capa de comportamiento: lo que solo se ve cuando algo se mueve.
//
// Son tests de píxeles a propósito: el valor de estas piezas está en que la
// sombra aparezca cuando hay contenido arriba y no antes, y eso no se ve en
// una captura.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mirame/core/theme/app_theme.dart';
import 'package:mirame/features/shell/vistas_comunes.dart';
import 'package:mirame/shared/widgets/comportamiento.dart';

Future<void> montar(WidgetTester t, Widget hijo, {double alto = 600}) async {
  t.view.physicalSize = Size(400, alto);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.resetPhysicalSize);
  addTearDown(t.view.resetDevicePixelRatio);
  await t.pumpWidget(
    MaterialApp(theme: buildMirameTheme(), home: Scaffold(body: hijo)),
  );
  await t.pump();
}

void main() {
  group('ListaConEncabezado', () {
    testWidgets('la sombra aparece solo cuando hay contenido arriba',
        (t) async {
      late bool visto;
      await montar(
        t,
        ListaConEncabezado(
          encabezado: (_, hayArriba) {
            visto = hayArriba;
            return Container(height: 40, color: Colors.white);
          },
          lista: ListView(
            children: [
              for (var i = 0; i < 40; i++) SizedBox(height: 50, child: Text('$i')),
            ],
          ),
        ),
      );
      expect(visto, isFalse, reason: 'arriba de todo no hay nada que tapar');

      await t.drag(find.byType(ListView), const Offset(0, -200));
      await t.pump();
      expect(visto, isTrue);

      await t.drag(find.byType(ListView), const Offset(0, 400));
      await t.pump();
      expect(visto, isFalse, reason: 'al volver arriba la sombra se apaga');
    });

    testWidgets('el encabezado no se mueve con la lista', (t) async {
      await montar(
        t,
        ListaConEncabezado(
          encabezado: (_, __) => const SizedBox(
            height: 40,
            child: Text('CABECERA'),
          ),
          lista: ListView(
            children: [
              for (var i = 0; i < 40; i++) SizedBox(height: 50, child: Text('$i')),
            ],
          ),
        ),
      );
      final antes = t.getTopLeft(find.text('CABECERA'));
      await t.drag(find.byType(ListView), const Offset(0, -300));
      await t.pump();
      expect(t.getTopLeft(find.text('CABECERA')), antes);
    });
  });

  group('EsqueletoDeLista', () {
    testWidgets('adentro de otra lista se dibuja como columna', (t) async {
      // El caso que rompía: un ListView dentro de un ListView revienta con
      // "vertical viewport was given unbounded height".
      await montar(
        t,
        ListView(
          children: const [
            SizedBox(height: 40),
            EsqueletoDeLista(filas: 3, desplazable: false),
          ],
        ),
      );
      expect(t.takeException(), isNull);
      expect(find.byType(Esqueleto), findsWidgets);
    });

    testWidgets('suelto se dibuja como lista', (t) async {
      await montar(t, const EsqueletoDeLista(filas: 3));
      expect(t.takeException(), isNull);
      expect(find.byType(Esqueleto), findsWidgets);
    });
  });

  group('EstadoVacio', () {
    testWidgets('sin acción no muestra botón', (t) async {
      await montar(
        t,
        const EstadoVacio(emoji: '📦', titulo: 'Vacío', detalle: 'Nada acá'),
      );
      expect(find.text('Vacío'), findsOneWidget);
      expect(find.text('Ver todos'), findsNothing);
    });

    testWidgets('con acción ofrece la salida y la ejecuta', (t) async {
      var tocado = false;
      await montar(
        t,
        EstadoVacio(
          emoji: '🔍',
          titulo: 'Nada con ese filtro',
          detalle: 'Hay cosas, pero no en este estado.',
          accion: ('Ver todos', () => tocado = true),
        ),
      );
      await t.tap(find.text('Ver todos'));
      expect(tocado, isTrue);
    });
  });

  group('FinDeLista', () {
    testWidgets('cierra la lista con su texto', (t) async {
      await montar(t, const FinDeLista('No hay más turnos este día'));
      expect(find.text('No hay más turnos este día'), findsOneWidget);
    });
  });
}
