/// Traducción entre las filas de Postgres y las entidades de `domain/`.
///
/// Vive acá y no en `domain/` a propósito: el dominio no sabe que existe
/// Supabase. Si mañana cambia el backend, se reescribe este archivo y nada más.
library;

import '../../domain/entities/access.dart';

/// Los enums de Postgres llegan como texto. Un valor desconocido cae al más
/// restrictivo en vez de lanzar: si el servidor agrega un rol que este cliente
/// no conoce, es preferible que el usuario vea de menos y no que la app muera.
MiembroRol rolDesdeTexto(String? v) => switch (v) {
      'owner' => MiembroRol.owner,
      'admin' => MiembroRol.admin,
      'profesional' => MiembroRol.profesional,
      _ => MiembroRol.lectura,
    };

MiembroEstado estadoMiembroDesdeTexto(String? v) => switch (v) {
      'approved' => MiembroEstado.approved,
      'blocked' => MiembroEstado.blocked,
      _ => MiembroEstado.pending,
    };

/// Un estado desconocido se trata como `cancelado`: cierra la puerta. Es la
/// opción segura frente a datos que este cliente no entiende.
TenantEstado estadoTenantDesdeTexto(String? v) => switch (v) {
      'trial' => TenantEstado.trial,
      'activo' => TenantEstado.activo,
      'suspendido' => TenantEstado.suspendido,
      _ => TenantEstado.cancelado,
    };

Profile profileDesdeFila(Map<String, dynamic> f) => Profile(
      id: f['id'] as String,
      email: f['email'] as String?,
      nombre: f['nombre'] as String?,
      avatarUrl: f['avatar_url'] as String?,
      plataformaRol: f['plataforma_rol'] == 'superadmin'
          ? PlataformaRol.superadmin
          : null,
    );

Membership membershipDesdeFila(Map<String, dynamic> f) => Membership(
      tenantId: f['tenant_id'] as String,
      userId: f['user_id'] as String,
      rol: rolDesdeTexto(f['rol'] as String?),
      estado: estadoMiembroDesdeTexto(f['estado'] as String?),
    );

Tenant tenantDesdeFila(Map<String, dynamic> f) => Tenant(
      id: f['id'] as String,
      nombre: f['nombre'] as String? ?? '',
      slug: f['slug'] as String? ?? '',
      estado: estadoTenantDesdeTexto(f['estado'] as String?),
      plan: f['plan'] as String? ?? 'basico',
      creadoPor: f['creado_por'] as String?,
      telefono: f['telefono'] as String?,
    );

License licenseDesdeFila(Map<String, dynamic> f) => License(
      tenantId: f['tenant_id'] as String,
      venceAt: _fecha(f['vence_at']),
      plan: f['plan'] as String? ?? 'basico',
    );

/// Postgres devuelve `timestamptz` en UTC. Se convierte a local porque toda la
/// lógica de fechas del dominio trabaja en hora local — el legacy tenía
/// justamente ese bug (ver `CLAUDE.md` § Deuda heredada).
DateTime? _fecha(Object? v) {
  if (v == null) return null;
  if (v is DateTime) return v.toLocal();
  final s = v.toString();
  if (s.isEmpty) return null;
  return DateTime.tryParse(s)?.toLocal();
}
