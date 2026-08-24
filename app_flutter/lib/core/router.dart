/// Rutas y guardas.
///
/// La decisión de a dónde va el usuario NO se toma acá: la toma
/// `resolveAccess()` y la publica el `SessionController`. Este archivo solo la
/// traduce a una URL. Si el router empezara a decidir por su cuenta, habría
/// dos fuentes de verdad sobre quién está adentro.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/rules/access.dart';
import '../features/admin/invite_screen.dart';
import '../features/admin/platform_screen.dart';
import '../features/auth/auth_screens.dart';
import '../features/agenda/agenda_view.dart';
import '../features/caja/caja_view.dart';
import '../features/crm/clients_view.dart';
import '../features/dashboard/dashboard_view.dart';
import '../features/settings/settings_view.dart';
import '../features/stats/stats_view.dart';
import '../features/stock/stock_view.dart';
import '../features/shell/app_shell.dart';
import '../features/auth/session_controller.dart';

abstract final class Rutas {
  static const splash = '/';
  static const login = '/login';
  static const pendiente = '/pendiente';
  static const bloqueado = '/bloqueado';
  static const vencido = '/vencido';
  static const app = '/app';
  static const admin = '/admin';
  static const invitar = '/admin/invitar';
}

/// Traduce la decisión del gate a una ruta.
String rutaDe(AccessDecision d) => switch (d) {
      GoToLogin() => Rutas.login,
      GoToPending() => Rutas.pendiente,
      GoToBlocked() => Rutas.bloqueado,
      GoToExpired() => Rutas.vencido,
      GoToApp() => Rutas.app,
      GoToPlatformAdmin() => Rutas.admin,
    };

/// Clave del Navigator raíz.
///
/// Hace falta para abrir sheets desde widgets que viven en el `builder` de
/// `MaterialApp.router` — es decir, POR ENCIMA del Navigator. Con el contexto
/// de esos widgets, `showModalBottomSheet` no encuentra Navigator ancestro y
/// lanza. Es exactamente lo que le pasaba al aviso de actualización.
final navigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: Rutas.splash,
    // `refreshListenable` reevalúa el redirect cada vez que cambia la sesión.
    refreshListenable: _SessionListenable(ref),
    redirect: (context, state) {
      final sesion = ref.read(sessionProvider);

      // Mientras se resuelve el gate se queda en el splash: mandarlo a login
      // y rebotarlo un instante después se ve como un parpadeo.
      if (sesion.cargando) {
        return state.matchedLocation == Rutas.splash ? null : Rutas.splash;
      }

      final destino = rutaDe(sesion.decision);
      // Se permite navegar dentro del área ya autorizada (`/app/agenda`, etc.)
      // sin que el redirect lo devuelva a la raíz de esa área.
      if (state.matchedLocation.startsWith(destino) && destino != Rutas.splash) {
        return null;
      }
      return destino;
    },
    routes: [
      GoRoute(
          path: Rutas.splash,
          builder: (_, __) => const SplashScreen()),
      GoRoute(path: Rutas.login, builder: (_, __) => const LoginScreen()),
      GoRoute(
        path: Rutas.pendiente,
        builder: (context, _) {
          final d = ProviderScope.containerOf(context)
              .read(sessionProvider)
              .decision;
          return PendingScreen(email: d is GoToPending ? d.email : null);
        },
      ),
      GoRoute(
          path: Rutas.bloqueado, builder: (_, __) => const BlockedScreen()),
      GoRoute(
        path: Rutas.vencido,
        builder: (context, _) {
          final d = ProviderScope.containerOf(context)
              .read(sessionProvider)
              .decision;
          return d is GoToExpired
              ? ExpiredScreen(venceAt: d.venceAt, motivo: d.motivo)
              : const ExpiredScreen(motivo: MotivoExpiracion.licencia);
        },
      ),
      GoRoute(
        path: Rutas.app,
        builder: (_, __) => const AppShell(
          vistas: [
            DashboardView(),
            AgendaView(),
            ClientsView(),
            CajaView(),
            StockView(),
            StatsView(),
            SettingsView(),
          ],
        ),
      ),
      GoRoute(
        path: Rutas.admin,
        builder: (_, __) => const PlatformScreen(),
        routes: [
          // Anidada bajo /admin para que el redirect del gate la trate como
          // "dentro del area autorizada" y no la rebote a la raiz.
          GoRoute(
            path: 'invitar',
            builder: (_, __) => const InviteScreen(),
          ),
        ],
      ),
    ],
  );
});

/// Puente entre Riverpod y `go_router`, que espera un `Listenable`.
class _SessionListenable extends ChangeNotifier {
  _SessionListenable(Ref ref) {
    ref.listen(sessionProvider, (_, __) => notifyListeners());
  }
}
