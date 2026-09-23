// La tablet de verdad, con la densidad que el aparato reporta de verdad.
//
// Por qué existe este archivo aparte: los tests de tablet que había fijaban
// `devicePixelRatio = 1` y montaban las vistas **sin el shell**. Con eso, la
// única configuración que se ejercitaba era la única en la que el código de
// tablet era alcanzable — y el aparato del mostrador no es esa. Una tablet de
// 1280×800 que reporta densidad 1,5 entrega 853×533 píxeles lógicos, caía en la
// composición del teléfono, y las seis composiciones de tablet quedaban
// escritas y sin ejecutarse nunca. La app se veía vertical con los laterales
// vacíos y los tests seguían en verde.
//
// Así que acá se monta el `AppShell` entero, con métricas físicas y densidad
// como las manda el aparato, y se afirman dos cosas que antes nadie afirmaba:
// **qué navegación se dibuja** y **cuánto ancho recibe el contenido**.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mirame/core/layout/layout.dart';
import 'package:mirame/core/theme/app_theme.dart';
import 'package:mirame/domain/rules/access.dart';
import 'package:mirame/features/agenda/agenda_view.dart';
import 'package:mirame/features/auth/session_controller.dart';
import 'package:mirame/features/caja/caja_view.dart';
import 'package:mirame/features/crm/clients_view.dart';
import 'package:mirame/features/dashboard/dashboard_view.dart';
import 'package:mirame/features/ropa/ropa_view.dart';
import 'package:mirame/features/settings/settings_view.dart';
import 'package:mirame/features/shell/app_shell.dart';
import 'package:mirame/features/stats/stats_view.dart';
import 'package:mirame/features/stock/stock_view.dart';

class _SinSalon extends SessionController {
  @override
  SessionState build() => const SessionState(decision: GoToLogin());
}

/// Las ocho vistas, en el mismo orden que el router.
List<Widget> get _vistas => const [
      DashboardView(),
      AgendaView(),
      ClientsView(),
      CajaView(),
      StockView(),
      StatsView(),
      SettingsView(),
      RopaView(),
    ];

/// Monta el shell con las métricas **físicas** de un aparato y su densidad.
///
/// Los dos argumentos separados son el punto del archivo: `fisico / densidad`
/// es lo que la app ve, y es justo la cuenta que los tests viejos salteaban.
Future<void> montar(
  WidgetTester t, {
  required Size fisico,
  required double densidad,
  required bool tactil,
}) async {
  modoTactilForzado = tactil;
  t.view.physicalSize = fisico;
  t.view.devicePixelRatio = densidad;
  addTearDown(t.view.resetPhysicalSize);
  addTearDown(t.view.resetDevicePixelRatio);
  await t.pumpWidget(
    ProviderScope(
      overrides: [sessionProvider.overrideWith(_SinSalon.new)],
      child: MaterialApp(
        theme: buildMirameTheme(),
        home: AppShell(vistas: _vistas),
      ),
    ),
  );
  await t.pumpAndSettle(const Duration(milliseconds: 100));
}

/// Ancho que el shell le deja al contenido.
double anchoDelContenido(WidgetTester t) =>
    t.getSize(find.byType(IndexedStack)).width;

/// `Stats` y `Tienda` solo tienen etiqueta visible en el riel de la tablet y en
/// el sidebar de la compu: la barra inferior del teléfono tiene cinco ítems y
/// esas dos no están. Sirve como marca de "acá hay navegación al costado".
bool hayNavegacionAlCostado() =>
    find.text('Stats').evaluate().isNotEmpty &&
    find.text('Tienda').evaluate().isNotEmpty;

void main() {
  tearDown(() => modoTactilForzado = null);

  testWidgets('la tablet del mostrador: 1280×800 con densidad 1,5', (t) async {
    // Este es el aparato que falló. 1280/1,5 = 853 lógicos de ancho, 533 de
    // alto: con los umbrales viejos (900 y 600) era la composición del
    // teléfono, centrada en una columna de 430 con los laterales vacíos.
    await montar(
      t,
      fisico: const Size(1280, 800),
      densidad: 1.5,
      tactil: true,
    );

    expect(
      hayNavegacionAlCostado(),
      isTrue,
      reason: 'tendría que estar el riel de la tablet, no la barra inferior',
    );

    // 853 lógicos menos los 92 del riel. Lo que importa es que NO sean 430:
    // eso era la app vertical con los laterales vacíos.
    expect(anchoDelContenido(t), closeTo(853 - 92, 2));
  });

  testWidgets('el teléfono sigue siendo el teléfono', (t) async {
    await montar(
      t,
      fisico: const Size(1170, 2532),
      densidad: 3,
      tactil: true,
    );
    expect(hayNavegacionAlCostado(), isFalse);
    expect(anchoDelContenido(t), closeTo(390, 2));
  });

  testWidgets('un celular acostado NO recibe el riel de la tablet', (t) async {
    // Pixel 7 horizontal: 915 lógicos de ancho pero 412 de lado corto. Antes
    // el shell miraba solo el ancho, así que le ponía el riel de la tablet y
    // adentro las vistas del teléfono — más el FAB y 96 px muertos abajo.
    await montar(
      t,
      fisico: const Size(2400, 1080),
      densidad: 2.625,
      tactil: true,
    );
    expect(hayNavegacionAlCostado(), isFalse);

    // Y ocupa la pantalla: con el dedo no se centra nada en 430.
    expect(anchoDelContenido(t), closeTo(2400 / 2.625, 2));
  });

  testWidgets('la PWA en la compu recibe el sidebar, no el riel', (t) async {
    await montar(
      t,
      fisico: const Size(1280, 800),
      densidad: 1,
      tactil: false,
    );
    expect(hayNavegacionAlCostado(), isTrue);
    // 1280 menos el sidebar completo de 248 (a 1280 no va plegado).
    expect(anchoDelContenido(t), closeTo(1280 - 248, 2));
  });

  testWidgets('la PWA en una ventana angosta sí se centra en 430', (t) async {
    // Acá el tope de 430 sigue siendo lo correcto: es el `#app` del original,
    // que emula un teléfono dentro de una ventana ancha del navegador.
    await montar(
      t,
      fisico: const Size(700, 900),
      densidad: 1,
      tactil: false,
    );
    expect(hayNavegacionAlCostado(), isFalse);
    expect(anchoDelContenido(t), closeTo(430, 2));
  });

  testWidgets('forzar Tablet a mano alcanza en cualquier aparato', (t) async {
    // La salida de emergencia: si un aparato raro igual cae en el layout del
    // teléfono, el interruptor de Ajustes lo resuelve sin esperar otra versión.
    modoTactilForzado = true;
    t.view.physicalSize = const Size(1200, 1920);
    t.view.devicePixelRatio = 2;
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);
    await t.pumpWidget(
      ProviderScope(
        overrides: [sessionProvider.overrideWith(_SinSalon.new)],
        child: MaterialApp(
          theme: buildMirameTheme(),
          home: PantallaPreferida(
            modo: ModoPantalla.tablet,
            child: AppShell(vistas: _vistas),
          ),
        ),
      ),
    );
    await t.pumpAndSettle(const Duration(milliseconds: 100));

    // 600×960 lógicos: por tamaño sería teléfono, pero se pidió tablet.
    expect(hayNavegacionAlCostado(), isTrue);
    expect(anchoDelContenido(t), closeTo(600 - 92, 2));
  });
}
