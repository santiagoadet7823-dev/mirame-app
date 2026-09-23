// El shell tiene que llegar a REPOSO.
//
// `pumpAndSettle` falla si el árbol no deja de animar, y eso es exactamente lo
// que se siente como una app trabada: algo repinta o pide foco en cada frame,
// el hilo de UI queda ocupado y los clics entran tarde.
//
// Este test existe porque eso pasó de verdad en la PWA: adentro del salón se
// ponía pesada mientras el APK iba fluido, y la diferencia era el layout de
// escritorio. Es el test que hubiera evitado publicarlo.
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

Future<void> montarShell(WidgetTester t, Size tamano) async {
  t.view.physicalSize = tamano;
  t.view.devicePixelRatio = 1;
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
}

void main() {
  tearDown(() => modoTactilForzado = null);

  testWidgets('el shell de escritorio queda en reposo', (t) async {
    modoTactilForzado = false;
    await montarShell(t, const Size(1280, 800));
    // Si esto se cuelga, hay algo animando o pidiendo foco para siempre.
    await t.pumpAndSettle(const Duration(milliseconds: 100));
    expect(t.takeException(), isNull);
  });

  testWidgets('el shell del teléfono queda en reposo', (t) async {
    modoTactilForzado = true;
    await montarShell(t, const Size(390, 844));
    await t.pumpAndSettle(const Duration(milliseconds: 100));
    expect(t.takeException(), isNull);
  });

  testWidgets('el shell de la tablet táctil queda en reposo', (t) async {
    modoTactilForzado = true;
    await montarShell(t, const Size(1280, 800));
    await t.pumpAndSettle(const Duration(milliseconds: 100));
    expect(t.takeException(), isNull);
  });

  testWidgets('solo una vista pide el foco a la vez', (t) async {
    // Con el `IndexedStack` las ocho vistas están montadas siempre. Si más de
    // una hace `autofocus`, se sacan el foco entre ellas en cada frame.
    modoTactilForzado = false;
    await montarShell(t, const Size(1280, 800));
    await t.pumpAndSettle(const Duration(milliseconds: 100));

    // `skipOffstage: false` a propósito: el `IndexedStack` deja las siete
    // vistas que no se ven fuera de pantalla, y son justo esas las que no
    // tienen que pedir el foco.
    final conAutofocus = t
        .widgetList<Focus>(find.byType(Focus, skipOffstage: false))
        .where((f) => f.autofocus)
        .length;
    expect(
      conAutofocus,
      lessThanOrEqualTo(1),
      reason: 'dos nodos con autofocus se pelean el foco en cada frame',
    );
  });
}
