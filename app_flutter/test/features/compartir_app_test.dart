// Pasarle la app a otra persona.
//
// Lo que se fija acá es sobre todo **a dónde apunta el link**, que es la parte
// que es fácil romper sin que se note: tiene que ir a `descargar.html` y no al
// `.apk` directo (un apk abierto desde la cámara de un iPhone no lleva a
// ninguna parte), y no tiene que arrastrar el slug del salón, porque esto es
// "bajate la app" y no "entrá a mi salón".
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mirame/core/config/app_config.dart';
import 'package:mirame/core/theme/app_theme.dart';
import 'package:mirame/features/settings/compartir_app.dart';
import 'package:qr_flutter/qr_flutter.dart';

Future<void> montar(WidgetTester t) async {
  await t.pumpWidget(
    MaterialApp(
      theme: buildMirameTheme(),
      home: const Scaffold(
        body: Center(child: TarjetaCompartirApp()),
      ),
    ),
  );
  await t.pumpAndSettle();
}

void main() {
  test('el link va a la pagina de descarga, no al apk', () {
    final url = AppConfig.urlInvitacion(null);
    expect(url, contains('descargar.html'));
    expect(url, isNot(contains('.apk')));
    // Sin slug: compartir la app no es invitar a un salón. Para eso está
    // Equipo, que sí manda el `?salon=`.
    expect(url, isNot(contains('salon=')));
  });

  test('con slug sí lleva el salón: ese es el otro camino', () {
    expect(AppConfig.urlInvitacion('mirame'), contains('salon=mirame'));
  });

  testWidgets('la tarjeta muestra el link y ofrece compartirlo', (t) async {
    await montar(t);
    expect(find.text('Pasar la app'), findsOneWidget);
    expect(find.textContaining('descargar.html'), findsOneWidget);
    expect(find.text('Compartir'), findsOneWidget);
    expect(find.text('Copiar'), findsOneWidget);
  });

  testWidgets('Ver QR abre el código para escanear', (t) async {
    await montar(t);
    await t.tap(find.text('Ver QR'));
    await t.pumpAndSettle();

    expect(find.byType(QrImageView), findsOneWidget);
    expect(find.text('Que escanee este código'), findsOneWidget);
    // Que el QR codifique el link no se puede afirmar desde afuera: `data` es
    // privado en `qr_flutter`. Lo cubre el primer test, que fija la URL, más
    // que los dos lugares la saquen de la misma función.
    expect(find.textContaining('descargar.html'), findsWidgets);
  });
}
