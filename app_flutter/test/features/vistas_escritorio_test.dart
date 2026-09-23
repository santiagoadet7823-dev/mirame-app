// Humo: cada vista de negocio se monta en escritorio y en teléfono sin
// excepciones de layout. Sin salón activo los repositorios son null y las
// listas vienen vacías, que es justo lo que hace falta para probar la
// composición sin base ni Supabase.
//
// Atrapa la clase de error que no se ve en `flutter analyze`: un `stretch`
// dentro de un ListView, un `Expanded` fuera de un Row, un overflow.
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
import 'package:mirame/features/stats/stats_view.dart';
import 'package:mirame/features/stock/stock_view.dart';

class _SinSalon extends SessionController {
  @override
  SessionState build() => const SessionState(decision: GoToLogin());
}

Future<void> montar(WidgetTester t, double ancho, Widget vista) async {
  t.view.physicalSize = Size(ancho, 900);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.resetPhysicalSize);
  addTearDown(t.view.resetDevicePixelRatio);
  await t.pumpWidget(
    ProviderScope(
      overrides: [sessionProvider.overrideWith(_SinSalon.new)],
      child: MaterialApp(
        theme: buildMirameTheme(),
        home: Scaffold(body: vista),
      ),
    ),
  );
  await t.pump(const Duration(seconds: 1));
}

void main() {
  final vistas = <String, Widget>{
    'Inicio': const DashboardView(),
    'Agenda': const AgendaView(),
    'Clientas': const ClientsView(),
    'Caja': const CajaView(),
    'Insumos': const StockView(),
    'Stats': const StatsView(),
    'Ajustes': const SettingsView(),
    'Tienda': const RopaView(),
  };

  for (final ancho in [390.0, 1000.0, 1400.0]) {
    group('a $ancho px', () {
      for (final e in vistas.entries) {
        testWidgets('${e.key} se monta sin errores', (t) async {
          await montar(t, ancho, e.value);
          final ex = t.takeException();
          expect(ex, isNull,
              reason: ex is FlutterError ? ex.toStringDeep() : null);
        });
      }
    });
  }

  // La tablet acostada y la PWA en la compu miden lo mismo pero no se
  // componen igual: la tablet usa tarjetas, filtros fijos y filas de 64. Son
  // dos caminos distintos en el código, así que los dos se prueban.
  for (final tactil in [true, false]) {
    group(tactil ? 'tablet acostada (dedo)' : 'escritorio (puntero)', () {
      tearDown(() => modoTactilForzado = null);
      for (final e in vistas.entries) {
        testWidgets('${e.key} se monta sin errores', (t) async {
          modoTactilForzado = tactil;
          await montar(t, 1280, e.value);
          final ex = t.takeException();
          expect(ex, isNull,
              reason: ex is FlutterError ? ex.toStringDeep() : null);
        });
      }
    });
  }
}
