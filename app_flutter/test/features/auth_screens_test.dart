import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mirame/core/router.dart';
import 'package:mirame/core/theme/app_theme.dart';
import 'package:mirame/domain/entities/access.dart';
import 'package:mirame/domain/rules/access.dart';
import 'package:mirame/features/auth/auth_screens.dart';

/// Monta una pantalla con el tema real de la app.
///
/// Solo se prueban las pantallas que NO observan `sessionProvider` al
/// construirse: `LoginScreen` sí lo hace y necesitaría un Supabase
/// inicializado. Su comportamiento ya está cubierto por los tests de
/// `resolveAccess`, que es quien decide si se muestra.
Future<void> montar(WidgetTester tester, Widget pantalla) async {
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(theme: buildMirameTheme(), home: pantalla),
    ),
  );
  // Las pantallas animan la entrada con delays de hasta 400 ms.
  await tester.pump(const Duration(seconds: 1));
}

void main() {
  group('SplashScreen', () {
    testWidgets('muestra el wordmark y el tagline', (t) async {
      await montar(t, const SplashScreen());
      expect(find.text('Mírame'), findsOneWidget);
      expect(find.text('LASH STUDIO'), findsOneWidget);
    });
  });

  group('PendingScreen', () {
    testWidgets('usa los textos exactos del original', (t) async {
      await montar(t, const PendingScreen(email: 'ana@mail.com'));
      expect(find.text('Solicitud enviada'), findsOneWidget);
      expect(
        find.textContaining('pendiente de aprobación'),
        findsOneWidget,
      );
      expect(find.text('Avisar por WhatsApp'), findsOneWidget);
      expect(find.text('Cerrar sesión'), findsOneWidget);
    });

    testWidgets('muestra el email del solicitante', (t) async {
      await montar(t, const PendingScreen(email: 'ana@mail.com'));
      expect(find.text('ana@mail.com'), findsOneWidget);
    });

    testWidgets('sin email no muestra la píldora vacía', (t) async {
      await montar(t, const PendingScreen());
      expect(find.text('Solicitud enviada'), findsOneWidget);
      // No debe quedar una píldora en blanco colgando.
      expect(find.textContaining('@'), findsNothing);
    });
  });

  group('BlockedScreen', () {
    testWidgets('usa los textos exactos del original', (t) async {
      await montar(t, const BlockedScreen());
      expect(find.text('Acceso denegado'), findsOneWidget);
      expect(find.textContaining('no tiene acceso'), findsOneWidget);
      expect(find.text('Cerrar sesión'), findsOneWidget);
    });

    testWidgets('no ofrece WhatsApp: no hay nada que gestionar', (t) async {
      await montar(t, const BlockedScreen());
      expect(find.text('Avisar por WhatsApp'), findsNothing);
    });
  });

  group('ExpiredScreen', () {
    testWidgets('muestra la fecha de vencimiento en formato local', (t) async {
      await montar(
        t,
        ExpiredScreen(
          venceAt: DateTime(2026, 8, 1),
          motivo: MotivoExpiracion.licencia,
        ),
      );
      expect(find.text('Mensualidad vencida'), findsOneWidget);
      expect(find.text('Venció el 01/08/2026'), findsOneWidget);
    });

    testWidgets('cada motivo dice algo distinto', (t) async {
      // Mandar a "renovar" a alguien que solo se quedó sin señal lo hace
      // llamar por nada.
      await montar(
        t,
        const ExpiredScreen(motivo: MotivoExpiracion.graciaAgotada),
      );
      expect(find.textContaining('Conectate a internet'), findsOneWidget);
      expect(find.textContaining('Tu suscripción venció'), findsNothing);

      await montar(
        t,
        const ExpiredScreen(motivo: MotivoExpiracion.suspendido),
      );
      expect(find.textContaining('está suspendido'), findsOneWidget);

      await montar(
        t,
        const ExpiredScreen(motivo: MotivoExpiracion.licencia),
      );
      expect(find.textContaining('Tu suscripción venció'), findsOneWidget);
    });

    testWidgets('sin fecha no muestra la píldora', (t) async {
      await montar(
        t,
        const ExpiredScreen(motivo: MotivoExpiracion.suspendido),
      );
      expect(find.textContaining('Venció el'), findsNothing);
    });
  });

  group('rutaDe — la decisión se traduce, no se recalcula', () {
    test('cada decisión tiene su ruta', () {
      expect(rutaDe(const GoToLogin()), Rutas.login);
      expect(rutaDe(const GoToPending()), Rutas.pendiente);
      expect(rutaDe(const GoToBlocked()), Rutas.bloqueado);
      expect(rutaDe(const GoToExpired()), Rutas.vencido);
      expect(rutaDe(const GoToPlatformAdmin()), Rutas.admin);
      expect(
        rutaDe(const GoToApp(
          tenant: Tenant(id: 't', nombre: 'X', slug: 'x'),
          rol: MiembroRol.owner,
        )),
        Rutas.app,
      );
    });
  });
}
