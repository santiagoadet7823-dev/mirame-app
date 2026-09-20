/// El único lugar que decide a qué pantalla va el usuario.
///
/// El router lo lee; ninguna pantalla recalcula el gate por su cuenta. Si esa
/// regla se rompe, dos partes de la app empiezan a discrepar sobre quién está
/// adentro.
library;

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show AuthChangeEvent;

import '../../core/notificaciones/push.dart';
import '../../data/remote/supabase_client.dart';
import '../../data/repositories/access_cache.dart';
import '../../data/repositories/access_repository.dart';
import '../../data/sync/sync_engine.dart';
import '../../domain/rules/access.dart';

const _kTenantActivo = 'mirame.tenant_activo';
const _kUltimaValidacion = 'mirame.ultima_validacion';

/// Tope para la validación contra el servidor al arrancar. Pasado esto se
/// decide con el cache y la gracia, como si no hubiera red.
const kEsperaServidor = Duration(seconds: 15);

class SessionState {
  const SessionState({
    required this.decision,
    this.cargando = false,
    this.error,
    this.esSuperadmin = false,
  });

  final AccessDecision decision;
  final bool cargando;

  /// Se guarda aparte de la decisión porque un superadmin que además es
  /// miembro del salón entra como `GoToApp` con `impersonando: false`, igual
  /// que un owner cualquiera: desde la decisión sola no se distingue, y el
  /// header necesita saberlo para ofrecer "volver al panel".
  final bool esSuperadmin;

  /// Solo para errores que NO son de red. Quedarse sin señal es un estado
  /// normal en una app local-first, no un error que mostrar.
  final String? error;

  SessionState copyWith({
    AccessDecision? decision,
    bool? cargando,
    String? error,
    bool? esSuperadmin,
    bool limpiarError = false,
  }) =>
      SessionState(
        decision: decision ?? this.decision,
        cargando: cargando ?? this.cargando,
        error: limpiarError ? null : (error ?? this.error),
        esSuperadmin: esSuperadmin ?? this.esSuperadmin,
      );
}

class SessionController extends Notifier<SessionState> {
  late final AccessRepository _repo;
  late final AccessCache _cache;
  SharedPreferences? _prefs;

  @override
  SessionState build() {
    _repo = const AccessRepository();
    _cache = AccessCache(ref.read(dbProvider));

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
  ///
  /// **Invariante: siempre termina con `cargando: false`.** Mientras es
  /// `true` el router deja al usuario en el splash, sin botón ni mensaje, así
  /// que cualquier camino que salga de acá sin publicar una decisión es un
  /// teléfono trabado en el logo para siempre. Pasó de verdad: la carga
  /// contra el servidor no tenía tope de tiempo, y si la base local fallaba
  /// dentro del `catch` la excepción se escapaba sin que nadie la viera.
  Future<void> refrescar() async {
    state = state.copyWith(cargando: true, limpiarError: true);
    try {
      await _refrescar();
    } catch (e) {
      // Lo que llegue acá no es "sin red" (eso lo absorbe `_refrescar`): es
      // la base local, las preferencias o el propio gate rompiéndose. Se va
      // al login, que es el lado seguro, y se deja el motivo escrito para que
      // el splash lo muestre y soporte sepa qué pasó en ese teléfono.
      state = SessionState(
        decision: const GoToLogin(),
        error: 'No se pudo abrir la sesión en este dispositivo.\n'
            '${e.runtimeType}: $e',
      );
      ref.read(syncProvider.notifier).detener();
    }
  }

  Future<void> _refrescar() async {
    final prefs = await _p;
    final tenantActivo = prefs.getString(_kTenantActivo);
    final ultimaMs = prefs.getInt(_kUltimaValidacion);
    final ultima =
        ultimaMs == null ? null : DateTime.fromMillisecondsSinceEpoch(ultimaMs);

    if (sb.auth.currentSession == null) {
      state = const SessionState(decision: GoToLogin());
      return;
    }

    AccessContext ctx;
    try {
      // Con tope: sin él, una red "colgada" (portal cautivo, DNS que no
      // contesta, VPN a medias) no da error nunca, y un error es lo que hace
      // falta para caer al cache. Quince segundos alcanzan para un 3G malo;
      // más que eso ya se ve como una app rota.
      ctx = await _repo
          .cargar(tenantActivoId: tenantActivo, ultimaValidacion: ultima)
          .timeout(kEsperaServidor);
      await prefs.setInt(
          _kUltimaValidacion, DateTime.now().millisecondsSinceEpoch);
      // Se guarda DESPUÉS de resolver bien: cachear un contexto a medias
      // dejaría a la app abriendo offline con datos peores que los que ya
      // tenía. Y si la base local no se deja escribir, la decisión del
      // servidor vale igual: no se descarta por eso.
      try {
        await _cache.guardar(ctx);
      } catch (_) {}
    } catch (_) {
      // Sin red o servidor caído: se decide con lo último que se supo.
      AccessContext? cacheado;
      try {
        cacheado = await _cache.leer(
          tenantActivoId: tenantActivo,
          ultimaValidacion: ultima,
        );
      } catch (_) {
        // Una base local rota no puede trabar el arranque: se sigue como si
        // no hubiera cache.
      }
      ctx = cacheado ??
          // Sin cache no se puede afirmar nada del usuario, y el gate manda a
          // login: el lado seguro.
          AccessContext(
            tenantActivoId: tenantActivo,
            ultimaValidacion: ultima,
            hayRed: false,
          );
    }

    final decision = resolveAccess(ctx, DateTime.now());
    state = SessionState(
      decision: decision,
      esSuperadmin: ctx.profile?.esSuperadmin ?? false,
    );
    _arrancarSyncSiCorresponde(decision);
  }

  /// El sync solo corre estando adentro de un salón, y **nunca** cuando un
  /// superadmin está mirando uno ajeno: bajar a disco los datos de un salón
  /// de terceros para dar soporte sería guardar lo que no corresponde.
  void _arrancarSyncSiCorresponde(AccessDecision d) {
    final sync = ref.read(syncProvider.notifier);
    if (d is GoToApp && !d.impersonando) {
      sync.arrancar(d.tenant.id);
    } else {
      sync.detener();
    }
  }

  /// Cambia el salón activo y recalcula. Invalida los datos en memoria para
  /// que ninguna lista quede mostrando filas del salón anterior.
  Future<void> elegirTenant(String tenantId) async {
    final prefs = await _p;
    await prefs.setString(_kTenantActivo, tenantId);
    await refrescar();

    // El token de push se ata al salón activo: así el servidor puede avisarle
    // a "todo el salón" sin resolver membresías en cada envío.
    unawaited(Push.instancia.registrar(tenantId: tenantId));

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
    ref.read(syncProvider.notifier).detener();
    // Nada de lo previo al signOut puede impedirlo: si la base local o el
    // push fallan en este teléfono, salir de la sesión es justamente la
    // salida que le queda al usuario, y tiene que funcionar.
    try {
      // El cache se borra al salir: en un dispositivo compartido, dejarlo
      // permitiría abrir offline con la sesión de quien lo usó antes.
      await _cache.limpiar();
    } catch (_) {}
    try {
      final prefs = await _p;
      await prefs.remove(_kTenantActivo);
      await prefs.remove(_kUltimaValidacion);
    } catch (_) {}
    try {
      // ANTES del signOut: la RPC valida `auth.uid()`, y sin sesión no
      // borraría nada y el teléfono seguiría recibiendo avisos de quien ya se
      // fue.
      await Push.instancia.olvidar().timeout(kEsperaServidor);
    } catch (_) {}
    try {
      await signOut().timeout(kEsperaServidor);
    } catch (_) {
      // Sin red el servidor no se entera, pero la sesión local sí se borra:
      // `signOut` limpia el storage antes de fallar contra el servidor.
    }
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
/// `ref.watch(puedeProvider(Permiso.operarNegocio))`.
final puedeProvider = Provider.family<bool, Permiso>((ref, permiso) {
  final d = ref.watch(sessionProvider).decision;
  if (d is! GoToApp) return false;
  return puedeEnDecision(d, permiso);
});

/// ¿Este usuario puede salir del salón y volver al panel de plataforma?
///
/// Solo un superadmin: para un `owner` el botón no tendría a dónde llevarlo,
/// y mostrarlo deshabilitado es peor que no mostrarlo.
final puedeVolverAlPanelProvider = Provider<bool>((ref) {
  final d = ref.watch(sessionProvider).decision;
  return d is GoToApp && ref.watch(esSuperadminProvider);
});

final esSuperadminProvider = Provider<bool>((ref) => ref.watch(
      sessionProvider.select((s) => s.esSuperadmin),
    ));
