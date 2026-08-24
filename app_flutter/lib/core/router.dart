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
import '../features/admin/platform_screen.dart';
import '../features/auth/auth_screens.dart';
import '../features/auth/session_controller.dart';
import 'theme/tokens.dart';

abstract final class Rutas {
  static const splash = '/';
  static const login = '/login';
  static const pendiente = '/pendiente';
  static const bloqueado = '/bloqueado';
  static const vencido = '/vencido';
  static const app = '/app';
  static const admin = '/admin';
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

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
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
      // Andamios provisorios: las pantallas reales llegan en las fases 5 y 6.
      GoRoute(path: Rutas.app, builder: (_, __) => const _Placeholder('App')),
      GoRoute(
          path: Rutas.admin, builder: (_, __) => const PlatformScreen()),
    ],
  );
});

/// Puente entre Riverpod y `go_router`, que espera un `Listenable`.
class _SessionListenable extends ChangeNotifier {
  _SessionListenable(Ref ref) {
    ref.listen(sessionProvider, (_, __) => notifyListeners());
  }
}

class _Placeholder extends ConsumerWidget {
  const _Placeholder(this.titulo);
  final String titulo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tenant = ref.watch(tenantActivoProvider);
    return Scaffold(
      backgroundColor: MColors.bg,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(titulo, style: Theme.of(context).textTheme.headlineMedium),
              if (tenant != null) ...[
                const SizedBox(height: 8),
                Text(tenant.nombre,
                    style: Theme.of(context).textTheme.bodyMedium),
              ],
              const SizedBox(height: 24),
              TextButton(
                onPressed: () =>
                    ref.read(sessionProvider.notifier).cerrarSesion(),
                child: const Text('Cerrar sesión'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
