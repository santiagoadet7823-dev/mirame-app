/// El árbol de decisión del acceso: qué pantalla ve alguien al abrir la app.
///
/// Es el reemplazo de `authCheckFirestore()` del `index.html`, con dos
/// agregados: el nivel de plataforma (superadmin) y el de licencia por salón.
///
/// **Por qué vive en `domain/` y es Dart puro:** decide si alguien entra o no
/// entra a un sistema con datos de terceros. Tiene que poder testearse sin
/// emulador, sin red y sin OAuth. Ver `android/04-AUTH-Y-ROLES.md`.
library;

import '../entities/access.dart';

/// Días que la app sigue funcionando sin poder validar la licencia contra el
/// servidor.
///
/// El compromiso: sin gracia, un fin de semana sin señal deja a la dueña
/// afuera de su propia agenda. Sin límite, una licencia impaga nunca se corta.
const kDiasDeGracia = 7;

/// A dónde va el usuario. Es un `sealed class` y no un enum porque dos de los
/// casos llevan datos que la pantalla necesita (la fecha de vencimiento, el
/// salón activo).
sealed class AccessDecision {
  const AccessDecision();
}

/// No hay sesión: pantalla de login con Google.
class GoToLogin extends AccessDecision {
  const GoToLogin();
}

/// Hay sesión pero todavía nadie la aprobó. Muestra el email y el botón de
/// WhatsApp al administrador, igual que el legacy.
class GoToPending extends AccessDecision {
  const GoToPending({this.email});
  final String? email;
}

/// La membresía fue bloqueada por un administrador.
class GoToBlocked extends AccessDecision {
  const GoToBlocked();
}

/// El salón está suspendido, cancelado, o su licencia venció.
class GoToExpired extends AccessDecision {
  const GoToExpired({this.venceAt, this.motivo = MotivoExpiracion.licencia});

  /// Para el texto "Venció el DD/MM/AAAA". `null` si el salón fue suspendido
  /// a mano y no hay fecha que mostrar.
  final DateTime? venceAt;
  final MotivoExpiracion motivo;
}

enum MotivoExpiracion {
  /// La licencia tiene fecha y ya pasó.
  licencia,

  /// La plataforma suspendió o canceló el salón.
  suspendido,

  /// Se agotaron los días de gracia sin poder validar contra el servidor.
  graciaAgotada,
}

/// Entra a la app, con un salón activo.
class GoToApp extends AccessDecision {
  const GoToApp({
    required this.tenant,
    required this.rol,
    this.enGracia = false,
    this.impersonando = false,
  });

  final Tenant tenant;
  final MiembroRol rol;

  /// Entró sin poder validar la licencia. La UI lo muestra discreto, no como
  /// una alarma.
  final bool enGracia;

  /// Un superadmin mirando un salón ajeno. Obliga a mostrar el banner
  /// persistente y a deshabilitar la escritura.
  final bool impersonando;
}

/// Superadmin sin salón elegido: va al panel de plataforma.
class GoToPlatformAdmin extends AccessDecision {
  const GoToPlatformAdmin();
}

/// Lo que se sabe del usuario al momento de decidir. Puede venir del servidor
/// o del cache local (Drift) cuando no hay red.
class AccessContext {
  const AccessContext({
    this.profile,
    this.memberships = const [],
    this.tenants = const [],
    this.licenses = const [],
    this.tenantActivoId,
    this.ultimaValidacion,
    this.hayRed = true,
  });

  /// `null` = no hay sesión.
  final Profile? profile;
  final List<Membership> memberships;
  final List<Tenant> tenants;
  final List<License> licenses;

  /// Salón elegido (persistido entre arranques). Si es null se resuelve solo
  /// cuando hay una única membresía aprobada.
  final String? tenantActivoId;

  /// Último momento en que se pudo validar la licencia contra el servidor.
  /// Alimenta la gracia de [kDiasDeGracia] días.
  final DateTime? ultimaValidacion;

  final bool hayRed;

  Tenant? tenantPorId(String id) {
    for (final t in tenants) {
      if (t.id == id) return t;
    }
    return null;
  }

  License? licenciaDe(String tenantId) {
    for (final l in licenses) {
      if (l.tenantId == tenantId) return l;
    }
    return null;
  }

  Membership? membresiaEn(String tenantId) {
    for (final m in memberships) {
      if (m.tenantId == tenantId) return m;
    }
    return null;
  }
}

/// Decide la pantalla. **Función pura**: mismos datos, misma respuesta.
///
/// El orden de las ramas importa y replica el del legacy:
///   1. sin sesión
///   2. superadmin (ve todo, no depende de membresías ni licencias)
///   3. bloqueado  — antes que pendiente: un bloqueo es más fuerte
///   4. sin membresías aprobadas → pendiente
///   5. salón no operativo o licencia vencida → vencido
///   6. adentro
AccessDecision resolveAccess(AccessContext ctx, DateTime ahora) {
  final profile = ctx.profile;
  if (profile == null) return const GoToLogin();

  // Un superadmin entra siempre: administra la plataforma, no pertenece a un
  // salón. Si eligió uno, lo abre en modo "ver como".
  if (profile.esSuperadmin) {
    final id = ctx.tenantActivoId;
    if (id == null) return const GoToPlatformAdmin();
    final tenant = ctx.tenantPorId(id);
    if (tenant == null) return const GoToPlatformAdmin();

    // Si además es miembro del salón, opera como tal y no se lo audita.
    final propia = ctx.membresiaEn(id);
    final esMiembro = propia != null && propia.aprobada;
    return GoToApp(
      tenant: tenant,
      rol: esMiembro ? propia.rol : MiembroRol.lectura,
      impersonando: !esMiembro,
    );
  }

  if (ctx.memberships.isEmpty) {
    return GoToPending(email: profile.email);
  }

  // Un bloqueo pesa más que cualquier otra membresía: si alguien fue bloqueado
  // en un salón, no puede colarse por otro que tenga pendiente.
  final aprobadas =
      ctx.memberships.where((m) => m.estado == MiembroEstado.approved).toList();
  if (aprobadas.isEmpty) {
    final bloqueado =
        ctx.memberships.any((m) => m.estado == MiembroEstado.blocked);
    if (bloqueado) return const GoToBlocked();
    return GoToPending(email: profile.email);
  }

  // Salón activo: el elegido, o el único aprobado que tenga.
  final elegido = ctx.tenantActivoId;
  Membership membresia;
  if (elegido != null) {
    final m = aprobadas.where((m) => m.tenantId == elegido);
    // Si el salón guardado ya no le corresponde, se cae al primero aprobado
    // en vez de dejarlo afuera.
    membresia = m.isNotEmpty ? m.first : aprobadas.first;
  } else {
    membresia = aprobadas.first;
  }

  final tenant = ctx.tenantPorId(membresia.tenantId);
  if (tenant == null) {
    // Aprobado en un salón que no se pudo cargar. Sin datos no se puede
    // afirmar que tenga acceso.
    return GoToPending(email: profile.email);
  }

  if (!tenant.operativo) {
    return GoToExpired(
      venceAt: ctx.licenciaDe(tenant.id)?.venceAt,
      motivo: MotivoExpiracion.suspendido,
    );
  }

  final licencia = ctx.licenciaDe(tenant.id);

  // Sin red: se entra con lo cacheado, mientras la gracia alcance.
  if (!ctx.hayRed) {
    if (graciaAgotada(ctx.ultimaValidacion, ahora)) {
      return GoToExpired(
        venceAt: licencia?.venceAt,
        motivo: MotivoExpiracion.graciaAgotada,
      );
    }
    // Una licencia que YA se sabía vencida no se perdona por estar offline.
    if (licencia != null && !licencia.vigenteA(ahora)) {
      return GoToExpired(venceAt: licencia.venceAt);
    }
    return GoToApp(tenant: tenant, rol: membresia.rol, enGracia: true);
  }

  if (licencia != null && !licencia.vigenteA(ahora)) {
    return GoToExpired(venceAt: licencia.venceAt);
  }

  return GoToApp(tenant: tenant, rol: membresia.rol);
}

/// Se agotó la ventana para operar sin validar contra el servidor.
///
/// Sin ninguna validación previa (`null`) se considera agotada: nunca se pudo
/// confirmar que la licencia exista.
bool graciaAgotada(DateTime? ultimaValidacion, DateTime ahora) {
  if (ultimaValidacion == null) return true;
  return ahora.difference(ultimaValidacion).inDays >= kDiasDeGracia;
}

/// Días que quedan de gracia, para mostrarlo discreto en la UI.
int diasDeGraciaRestantes(DateTime? ultimaValidacion, DateTime ahora) {
  if (ultimaValidacion == null) return 0;
  final usados = ahora.difference(ultimaValidacion).inDays;
  final quedan = kDiasDeGracia - usados;
  return quedan < 0 ? 0 : quedan;
}

// ─────────────────────────────────────────────────────────────────────────────
// Permisos
// ─────────────────────────────────────────────────────────────────────────────

/// Lo que puede hacer alguien dentro de un salón.
///
/// **Esto NO es la seguridad.** La seguridad son las RLS de Postgres. Esto es
/// para que la UI no ofrezca botones que el servidor va a rechazar: pedir algo
/// y que falle es peor experiencia que no verlo.
///
/// Espeja `puede_escribir()` y `administra()` de `sql/03_rls.sql`. Si cambia
/// una, tiene que cambiar la otra.
enum Permiso {
  /// Crear y editar turnos, clientas, movimientos y stock.
  escribirDatos,

  /// Invitar, aprobar, bloquear usuarios y cambiar sus roles.
  gestionarUsuarios,

  /// Nombre del salón, profesionales, servicios.
  editarAjustes,

  /// Ver estadísticas y el cierre de caja.
  verReportes,

  /// Borrar el salón entero.
  borrarTenant,
}

bool puede(MiembroRol rol, Permiso permiso) => switch (permiso) {
      Permiso.escribirDatos => rol == MiembroRol.owner ||
          rol == MiembroRol.admin ||
          rol == MiembroRol.profesional,
      Permiso.gestionarUsuarios =>
        rol == MiembroRol.owner || rol == MiembroRol.admin,
      Permiso.editarAjustes =>
        rol == MiembroRol.owner || rol == MiembroRol.admin,
      // Incluso `lectura` ve los reportes: para eso existe el rol.
      Permiso.verReportes => true,
      Permiso.borrarTenant => rol == MiembroRol.owner,
    };

/// Un superadmin que NO es miembro del salón puede mirar, nunca escribir.
/// Es lo mismo que hacen las policies: el revendedor lee para dar soporte, no
/// opera el salón de otro.
bool puedeEnDecision(GoToApp acceso, Permiso permiso) {
  if (acceso.impersonando) return permiso == Permiso.verReportes;
  return puede(acceso.rol, permiso);
}
