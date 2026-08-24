/// El único lugar que decide a qué pantalla va el usuario.
///
/// El router lo lee; ninguna pantalla recalcula el gate por su cuenta. Si esa
/// regla se rompe, dos partes de la app empiezan a discrepar sobre quién está
/// adentro.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show AuthChangeEvent;

import '../../data/remote/supabase_client.dart';
import '../../data/repositories/access_repository.dart';
import '../../domain/rules/access.dart';

const _kTenantActivo = 'mirame.tenant_activo';
const _kUltimaValidacion = 'mirame.ultima_validacion';

class SessionState {
  const SessionState({
    required this.decision,
    this.cargando = false,
    this.error,
  });

  final AccessDecision decision;
  final bool cargando;

  /// Solo para errores que NO son de red. Quedarse sin señal es un estado
  /// normal en una app local-first, no un error que mostrar.
  final String? error;

  SessionState copyWith({
    AccessDecision? decision,
    bool? cargando,
    String? error,
    bool limpiarError = false,
  }) =>
      SessionState(
        decision: decision ?? this.decision,
        cargando: cargando ?? this.cargando,
        error: limpiarError ? null : (error ?? this.error),
      );
}

class SessionController extends Notifier<SessionState> {
  late final AccessRepository _repo;
  SharedPreferences? _prefs;

  @override
  SessionState build() {
    _repo = const AccessRepository();

    // Reevaluar en cada cambio de sesión: login, logout, refresh del token.
    final sub = sb.auth.onAuthStateChange.listen((data) {
      switch (data.event) {
        case AuthChangeEvent.signedIn:
        case AuthChangeEvent.signedOut:
        case AuthChangeEvent.userUpdated:
          refrescar();
        default:
          break;
      }
    });
    ref.onDispose(sub.cancel);

    Future.microtask(refrescar);
    return const SessionState(decision: GoToLogin(), cargando: true);
  }

  Future<SharedPreferences> get _p async =>
      _prefs ??= await SharedPreferences.getInstance();

  /// Recalcula el gate. Si el servidor no responde, cae al último estado
  /// conocido y deja que la gracia decida — es exactamente lo que hace falta
  /// para abrir la app en un salón sin señal.
  Future<void> refrescar() async {
    state = state.copyWith(cargando: true, limpiarError: true);
    final prefs = await _p;
    final tenantActivo = prefs.getString(_kTenantActivo);
    final ultimaMs = prefs.getInt(_kUltimaValidacion);
    final ultima =
        ultimaMs == null ? null : DateTime.fromMillisecondsSinceEpoch(ultimaMs);

    if (sb.auth.currentSession == null) {
      state = const SessionState(decision: GoToLogin());
      return;
    }

    try {
      final ctx = await _repo.cargar(
        tenantActivoId: tenantActivo,
        ultimaValidacion: ultima,
      );
      await prefs.setInt(
          _kUltimaValidacion, DateTime.now().millisecondsSinceEpoch);
      state = SessionState(decision: resolveAccess(ctx, DateTime.now()));
    } catch (_) {
      // Sin red o servidor caído: se decide con lo que hay en disco.
      // TODO(fase-3): leer profile/membresías del cache de Drift en vez de
      // resolver con un contexto vacío. Hasta entonces, sin red no hay datos
      // locales y el gate manda a login — que es el lado seguro.
      final ctx = AccessContext(
        tenantActivoId: tenantActivo,
        ultimaValidacion: ultima,
        hayRed: false,
      );
      state = SessionState(decision: resolveAccess(ctx, DateTime.now()));
    }
  }

  /// Cambia el salón activo y recalcula. Invalida los datos en memoria para
  /// que ninguna lista quede mostrando filas del salón anterior.
  Future<void> elegirTenant(String tenantId) async {
    final prefs = await _p;
    await prefs.setString(_kTenantActivo, tenantId);
    await refrescar();

    // Si entró a un salón ajeno, queda constancia. La función del servidor se
    // saltea sola cuando el actor sí es miembro.
    final d = state.decision;
    if (d is GoToApp && d.impersonando) {
      try {
        await _repo.registrarAcceso(tenantId, 'impersonar');
      } catch (_) {
        // La auditoría no debe impedir el acceso; el servidor también audita.
      }
    }
  }

  /// Vuelve al panel de plataforma (solo tiene sentido para un superadmin).
  Future<void> salirDelTenant() async {
    final prefs = await _p;
    await prefs.remove(_kTenantActivo);
    await refrescar();
  }

  Future<void> entrarConGoogle() async {
    state = state.copyWith(cargando: true, limpiarError: true);
    try {
      await signInConGoogle();
    } catch (e) {
      state = state.copyWith(
        cargando: false,
        error: 'No se pudo iniciar sesión con Google. Probá de nuevo.',
      );
    }
  }

  Future<void> cerrarSesion() async {
    final prefs = await _p;
    await prefs.remove(_kTenantActivo);
    await prefs.remove(_kUltimaValidacion);
    await signOut();
    state = const SessionState(decision: GoToLogin());
  }
}

final sessionProvider =
    NotifierProvider<SessionController, SessionState>(SessionController.new);

/// Atajos para la UI. Evitan que cada widget haga su propio `is GoToApp`.
final tenantActivoProvider = Provider((ref) {
  final d = ref.watch(sessionProvider).decision;
  return d is GoToApp ? d.tenant : null;
});

final impersonandoProvider = Provider((ref) {
  final d = ref.watch(sessionProvider).decision;
  return d is GoToApp && d.impersonando;
});

/// Chequeo de permiso listo para usar en la UI:
/// `ref.watch(puedeProvider(Permiso.escribirDatos))`.
final puedeProvider = Provider.family<bool, Permiso>((ref, permiso) {
  final d = ref.watch(sessionProvider).decision;
  if (d is! GoToApp) return false;
  return puedeEnDecision(d, permiso);
});
