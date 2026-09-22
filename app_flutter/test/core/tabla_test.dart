import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mirame/core/theme/app_theme.dart';
import 'package:mirame/shared/widgets/tabla_mirame.dart';

typedef Fila = ({String nombre, int total});

Widget tabla(List<Fila> filas, {void Function(Fila)? onTap, String? sel}) =>
    MaterialApp(
      theme: buildMirameTheme(),
      home: Scaffold(
        body: TablaMirame<Fila>(
          filas: filas,
          claveDe: (f) => f.nombre,
          seleccionada: sel,
          onTap: onTap,
          columnas: [
            ColumnaTabla(
              titulo: 'Nombre',
              ordenarPor: (f) => f.nombre,
              celda: (_, f) => CeldaTexto(f.nombre),
            ),
            ColumnaTabla(
              titulo: 'Total',
              ancho: 100,
              numerica: true,
              ordenarPor: (f) => f.total,
              celda: (_, f) => CeldaTexto('${f.total}', numerica: true),
            ),
          ],
        ),
      ),
    );

void main() {
  _opcionales();
  final datos = <Fila>[
    (nombre: 'Zoe', total: 5),
    (nombre: 'Ana', total: 30),
    (nombre: 'Mia', total: 10),
  ];

  Future<void> montar(WidgetTester t, Widget w) async {
    t.view.physicalSize = const Size(1200, 800);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);
    await t.pumpWidget(w);
    await t.pumpAndSettle();
  }

  List<String> ordenVisible(WidgetTester t) => t
      .widgetList<CeldaTexto>(find.byType(CeldaTexto))
      .map((c) => c.texto)
      .where((s) => int.tryParse(s) == null)
      .toList();

  testWidgets('sin orden, respeta el orden de llegada', (t) async {
    await montar(t, tabla(datos));
    expect(ordenVisible(t), ['Zoe', 'Ana', 'Mia']);
  });

  testWidgets('tocar la cabecera ordena; otra vez, invierte', (t) async {
    await montar(t, tabla(datos));
    await t.tap(find.text('NOMBRE'));
    await t.pumpAndSettle();
    expect(ordenVisible(t), ['Ana', 'Mia', 'Zoe']);
    await t.tap(find.text('NOMBRE'));
    await t.pumpAndSettle();
    expect(ordenVisible(t), ['Zoe', 'Mia', 'Ana']);
  });

  testWidgets('ordena por una columna numérica', (t) async {
    await montar(t, tabla(datos));
    await t.tap(find.text('TOTAL'));
    await t.pumpAndSettle();
    expect(ordenVisible(t), ['Zoe', 'Mia', 'Ana']);
  });

  testWidgets('tocar una fila avisa con esa fila', (t) async {
    Fila? tocada;
    await montar(t, tabla(datos, onTap: (f) => tocada = f));
    await t.tap(find.text('Mia'));
    await t.pumpAndSettle();
    expect(tocada?.nombre, 'Mia');
  });
}

void _opcionales() {
  testWidgets('si no entra, esconde las columnas opcionales', (t) async {
    Widget con(double ancho) => MaterialApp(
          theme: buildMirameTheme(),
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: ancho,
                child: TablaMirame<Fila>(
                  filas: const [(nombre: 'Ana', total: 1)],
                  expandir: false,
                  columnas: [
                    ColumnaTabla(
                      titulo: 'Nombre',
                      ancho: 200,
                      celda: (_, f) => CeldaTexto(f.nombre),
                    ),
                    ColumnaTabla(
                      titulo: 'Extra',
                      ancho: 200,
                      opcional: true,
                      celda: (_, f) => const CeldaTexto('x'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
    await t.pumpWidget(con(600));
    await t.pumpAndSettle();
    expect(find.text('EXTRA'), findsOneWidget);
    await t.pumpWidget(con(300));
    await t.pumpAndSettle();
    expect(find.text('EXTRA'), findsNothing);
    expect(find.text('NOMBRE'), findsOneWidget);
  });
}
