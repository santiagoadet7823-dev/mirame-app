// El escritorio como lo entregó el diseñador (PWA, 1280 puntero).
//
// Fuente: `diseno/prototipo/D-Inicio-Propuesta.dc.html` y `13-BRIEF-UI-UX.md`
// §3.7. Los cinco puntos de esa entrega son: buscador global en el header con
// atajo `/`, cuatro KPI en UNA fila, gráfico de área de dos series en 3/5,
// agenda del día en 2/5, y el bloque de usuaria al pie del sidebar.
//
// Lo que afirma este archivo es justo lo que no se veía leyendo el código: que
// los cuatro KPI quedan a la misma altura (estaban entrando 3 + 1 en dos filas
// porque la grilla se armaba por celda de 320 px) y que el buscador aparece en
// pantalla grande y no en el teléfono.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mirame/core/layout/layout.dart';
import 'package:mirame/core/theme/app_theme.dart';
import 'package:mirame/domain/entities/access.dart';
import 'package:mirame/domain/rules/access.dart';
import 'package:mirame/features/agenda/agenda_view.dart';
import 'package:mirame/features/auth/session_controller.dart';
import 'package:mirame/features/caja/caja_view.dart';
import 'package:mirame/features/crm/clients_view.dart';
import 'package:mirame/features/dashboard/dashboard_view.dart';
import 'package:mirame/features/dashboard/inicio_escritorio.dart';
import 'package:mirame/features/ropa/ropa_view.dart';
import 'package:mirame/features/settings/settings_view.dart';
import 'package:mirame/features/shell/app_shell.dart';
import 'package:mirame/features/stats/stats_view.dart';
import 'package:mirame/features/stock/stock_view.dart';

/// Adentro del salón y con rol de dueña: sin esto no hay chip de usuaria.
///
/// Ojo: con salón activo los providers piden repositorio, el repositorio abre
/// Drift y en un test eso no emite nunca, así que los esqueletos laten para
/// siempre y `pumpAndSettle` no termina. En el aparato la base sí abre. Los
/// casos que no necesitan saber quién entró usan [_SinSalon], que resuelve a
/// listas vacías.
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

class _SinSalon extends SessionController {
  @override
  SessionState build() => const SessionState(decision: GoToLogin());
}

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

Future<void> montar(
  WidgetTester t, {
  required Size tamano,
  required bool tactil,
  bool conSalon = true,
}) async {
  modoTactilForzado = tactil;
  t.view.physicalSize = tamano;
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.resetPhysicalSize);
  addTearDown(t.view.resetDevicePixelRatio);
  await t.pumpWidget(
    ProviderScope(
      overrides: [
        sessionProvider
            .overrideWith(conSalon ? _ConSalon.new : _SinSalon.new),
      ],
      child: MaterialApp(
        theme: buildMirameTheme(),
        home: AppShell(vistas: _vistas),
      ),
    ),
  );
  await t.pumpAndSettle(const Duration(milliseconds: 100));
}

void main() {
  tearDown(() => modoTactilForzado = null);

  testWidgets('el buscador global vive en el header de pantalla grande',
      (t) async {
    await montar(t, tamano: const Size(1280, 800), tactil: false);
    expect(find.text('Buscar clienta, turno o producto'), findsOneWidget);
    // Con puntero se dibuja la tecla del atajo.
    expect(find.text('/'), findsOneWidget);
  });

  testWidgets('en la tablet el buscador está pero sin tecla de atajo',
      (t) async {
    // El brief de la tablet lo pide explícito: no hay teclado, así que una
    // tecla dibujada que no se puede apretar es una promesa falsa.
    await montar(t, tamano: const Size(1280, 800), tactil: true);
    expect(find.text('Buscar clienta, turno o producto'), findsOneWidget);
    expect(find.text('/'), findsNothing);
  });

  testWidgets('en el teléfono no hay buscador en el header', (t) async {
    // No hay 300 px libres al lado del logo, y ahí cada vista tiene el suyo.
    await montar(
      t,
      tamano: const Size(390, 844),
      tactil: true,
      conSalon: false,
    );
    expect(find.text('Buscar clienta, turno o producto'), findsNothing);
  });

  testWidgets('los cuatro KPI van en UNA fila', (t) async {
    await montar(t, tamano: const Size(1280, 800), tactil: false);

    final kpis = find.byType(TarjetaKpi);
    expect(kpis, findsNWidgets(4));

    // Misma altura los cuatro. Con la grilla por celda de 320 px, a 1032 px de
    // ancho entraban tres y la cuarta bajaba sola a un segundo renglón.
    final y = [
      for (var i = 0; i < 4; i++) t.getTopLeft(kpis.at(i)).dy,
    ];
    expect(y.every((v) => (v - y.first).abs() < 1), isTrue,
        reason: 'los cuatro KPI tendrían que estar a la misma altura: $y');
  });

  testWidgets('el gráfico del Inicio tiene las dos series con leyenda',
      (t) async {
    await montar(t, tamano: const Size(1280, 800), tactil: false);
    expect(find.text('Ingresos por semana'), findsOneWidget);
    // Servicios y Tienda son las dos series que pide la entrega. Se pasaba
    // `serieB: const []`, así que la leyenda de Tienda no decía nada.
    expect(find.text('Servicios'), findsWidgets);
    expect(find.text('Tienda'), findsWidgets);
  });

  testWidgets('el sidebar termina con quién está usando la app', (t) async {
    await montar(t, tamano: const Size(1280, 800), tactil: false);
    // El rol se nombra igual que en Equipo: dos nombres distintos para el mismo
    // rol en dos pantallas hace dudar de si son lo mismo.
    expect(find.text('Dueña'), findsOneWidget);
  });
}
