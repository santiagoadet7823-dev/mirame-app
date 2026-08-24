/// Cache local del acceso, para poder abrir la app sin red.
///
/// Sin esto, quedarse sin señal manda al login aunque la sesión siga siendo
/// válida — que es justo lo que no puede pasar en un salón con mal wifi.
/// Es la contraparte de la gracia de [kDiasDeGracia]: la gracia dice *hasta
/// cuándo* se puede entrar sin validar, y esto provee *con qué datos*.
library;

import 'dart:convert';

import 'package:drift/drift.dart';

import '../../domain/rules/access.dart';
import '../local/database.dart';
import '../remote/access_mappers.dart';

const _clave = 'contexto';

class AccessCache {
  const AccessCache(this._db);

  final MirameDb _db;

  /// Guarda lo último que dijo el servidor.
  ///
  /// Se persiste el JSON crudo y no las entidades ya construidas: si mañana
  /// una entidad gana un campo, el cache viejo se sigue leyendo sin migración.
  Future<void> guardar(AccessContext ctx) async {
    final profile = ctx.profile;
    if (profile == null) return;
    final json = jsonEncode({
      'profile': {
        'id': profile.id,
        'email': profile.email,
        'nombre': profile.nombre,
        'avatar_url': profile.avatarUrl,
        'plataforma_rol': profile.esSuperadmin ? 'superadmin' : null,
      },
      'memberships': [
        for (final m in ctx.memberships)
          {
            'tenant_id': m.tenantId,
            'user_id': m.userId,
            'rol': m.rol.name,
            'estado': m.estado.name,
          },
      ],
      'tenants': [
        for (final t in ctx.tenants)
          {
            'id': t.id,
            'nombre': t.nombre,
            'slug': t.slug,
            'estado': t.estado.name,
            'plan': t.plan,
          },
      ],
      'licenses': [
        for (final l in ctx.licenses)
          {
            'tenant_id': l.tenantId,
            'vence_at': l.venceAt?.toIso8601String(),
            'plan': l.plan,
          },
      ],
    });

    await _db.into(_db.accessCache).insertOnConflictUpdate(
          AccessCacheCompanion.insert(
            clave: _clave,
            json: json,
            guardadoAt: Value(DateTime.now()),
          ),
        );
  }

  /// Reconstruye el contexto desde el cache.
  ///
  /// Devuelve `null` si no hay nada guardado — nunca un contexto vacío que se
  /// pueda confundir con "el usuario no tiene permisos". Esa diferencia
  /// importa: un contexto vacío haría que `resolveAccess` mande a "pendiente"
  /// a alguien que en realidad está aprobado y solo se quedó sin señal.
  Future<AccessContext?> leer({
    String? tenantActivoId,
    DateTime? ultimaValidacion,
  }) async {
    final fila = await (_db.select(_db.accessCache)
          ..where((a) => a.clave.equals(_clave)))
        .getSingleOrNull();
    if (fila == null) return null;

    try {
      final d = jsonDecode(fila.json) as Map<String, dynamic>;
      return AccessContext(
        profile: profileDesdeFila(d['profile'] as Map<String, dynamic>),
        memberships: [
          for (final m in (d['memberships'] as List? ?? const []))
            membershipDesdeFila(m as Map<String, dynamic>),
        ],
        tenants: [
          for (final t in (d['tenants'] as List? ?? const []))
            tenantDesdeFila(t as Map<String, dynamic>),
        ],
        licenses: [
          for (final l in (d['licenses'] as List? ?? const []))
            licenseDesdeFila(l as Map<String, dynamic>),
        ],
        tenantActivoId: tenantActivoId,
        ultimaValidacion: ultimaValidacion,
        // Lo importante: se marca que NO hay red, para que el gate aplique la
        // gracia en vez de dar la licencia por validada.
        hayRed: false,
      );
    } catch (_) {
      // Un cache corrupto no puede trabar el arranque. Sin él se cae al
      // camino de siempre, que manda al login: el lado seguro.
      return null;
    }
  }

  Future<void> limpiar() => _db.delete(_db.accessCache).go();
}
