/// Entidades de acceso: identidad, membresías, licencias.
///
/// Espejo de las tablas de plataforma (`sql/01_plataforma.sql`). Dart puro:
/// sin Flutter, sin Supabase, sin Drift.
library;

/// Rol a nivel PLATAFORMA. Solo dos personas lo tienen: el dueño del producto
/// y el revendedor. Se siembra por SQL (`sql/06_seed_superadmins.sql`), nunca
/// desde la app — un trigger en Postgres bloquea la auto-promoción.
enum PlataformaRol { superadmin }

/// Rol DENTRO de un salón.
/// Quién es quién adentro de un salón.
///
/// `encargado` es el que maneja el negocio sin ser dueña: opera caja, tienda e
/// insumos, pero no toca usuarios ni ajustes. `profesional` atiende — turnos y
/// clientas — y nada más.
enum MiembroRol { owner, admin, encargado, profesional, lectura }

/// Estado de una membresía.
enum MiembroEstado { pending, approved, blocked }

/// Estado comercial de un salón.
enum TenantEstado { trial, activo, suspendido, cancelado }

class Profile {
  const Profile({
    required this.id,
    this.email,
    this.nombre,
    this.avatarUrl,
    this.plataformaRol,
  });

  final String id;
  final String? email;
  final String? nombre;
  final String? avatarUrl;
  final PlataformaRol? plataformaRol;

  bool get esSuperadmin => plataformaRol == PlataformaRol.superadmin;
}

class Tenant {
  const Tenant({
    required this.id,
    required this.nombre,
    required this.slug,
    this.estado = TenantEstado.trial,
    this.plan = 'basico',
    this.creadoPor,
    this.telefono,
    this.direccion,
    this.instagram,
  });

  final String id;
  final String nombre;
  final String slug;
  final TenantEstado estado;
  final String plan;

  /// Quién dio de alta el salón. Un revendedor solo administra los que creó.
  final String? creadoPor;

  /// Los tres que muestra la vitrina pública.
  final String? telefono;
  final String? direccion;
  final String? instagram;

  /// `suspendido` y `cancelado` cierran la puerta aunque la licencia no haya
  /// vencido: son decisiones de la plataforma, no del calendario.
  bool get operativo =>
      estado == TenantEstado.trial || estado == TenantEstado.activo;
}

class Membership {
  const Membership({
    required this.tenantId,
    required this.userId,
    this.rol = MiembroRol.profesional,
    this.estado = MiembroEstado.pending,
  });

  final String tenantId;
  final String userId;
  final MiembroRol rol;
  final MiembroEstado estado;

  bool get aprobada => estado == MiembroEstado.approved;
}

class License {
  const License({required this.tenantId, this.venceAt, this.plan = 'basico'});

  final String tenantId;

  /// `null` significa sin vencimiento (por ejemplo, el salón propio).
  final DateTime? venceAt;
  final String plan;

  bool vigenteA(DateTime momento) =>
      venceAt == null || venceAt!.isAfter(momento);
}
