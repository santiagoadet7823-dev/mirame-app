/// Trae del servidor lo que el gate necesita para decidir.
///
/// Devuelve un [AccessContext] listo para `resolveAccess()`. Toda la política
/// de acceso vive en `domain/rules/access.dart`; acá solo se buscan datos.
library;

import '../../core/config/app_config.dart';
import '../../domain/entities/access.dart';
import '../../domain/rules/access.dart';
import '../remote/access_mappers.dart';
import '../remote/supabase_client.dart';

class AccessRepository {
  const AccessRepository();

  /// Carga perfil, membresías, salones y licencias del usuario logueado.
  ///
  /// Lanza si no hay red o si el servidor falla: el llamador decide si cae al
  /// cache local. Eso no se resuelve acá porque "sin red" no es un error del
  /// repositorio, es un estado normal de la app.
  Future<AccessContext> cargar({
    String? tenantActivoId,
    DateTime? ultimaValidacion,
  }) async {
    final user = sb.auth.currentUser;
    if (user == null) {
      return AccessContext(
        tenantActivoId: tenantActivoId,
        ultimaValidacion: ultimaValidacion,
      );
    }

    // El profile lo crea un trigger al registrarse (`handle_new_user`), pero
    // puede no existir todavía si el trigger falló: se tolera con maybeSingle.
    final profileRow = await sb
        .from('profiles')
        .select('id, email, nombre, avatar_url, plataforma_rol')
        .eq('id', user.id)
        .maybeSingle();

    final profile = profileRow == null
        ? Profile(id: user.id, email: user.email)
        : profileDesdeFila(profileRow);

    // Las RLS ya filtran por usuario: un `select *` acá solo devuelve lo que
    // le corresponde. No hace falta (ni conviene) filtrar de nuevo en el
    // cliente — duplicar la regla es cómo se desincronizan.
    final membershipRows = await sb
        .from('tenant_members')
        .select('tenant_id, user_id, rol, estado')
        .eq('user_id', user.id);

    final memberships = (membershipRows as List)
        .map((f) => membershipDesdeFila(f as Map<String, dynamic>))
        .toList();

    final tenantRows = await sb
        .from('tenants')
        .select('id, nombre, slug, estado, plan, creado_por, telefono');
    final tenants = (tenantRows as List)
        .map((f) => tenantDesdeFila(f as Map<String, dynamic>))
        .toList();

    final licenseRows =
        await sb.from('licencias').select('tenant_id, vence_at, plan');
    final licenses = (licenseRows as List)
        .map((f) => licenseDesdeFila(f as Map<String, dynamic>))
        .toList();

    return AccessContext(
      profile: profile,
      memberships: memberships,
      tenants: tenants,
      licenses: licenses,
      tenantActivoId: tenantActivoId,
      // Se acaba de validar contra el servidor: la gracia arranca de cero.
      ultimaValidacion: DateTime.now(),
      hayRed: true,
    );
  }

  /// Auto-inscripción de un usuario nuevo en un salón, siempre como
  /// `pending`. Es lo único que la policy `members_self_insert` permite, y el
  /// equivalente del doc `{status:'pending'}` que creaba el legacy.
  Future<void> solicitarAcceso(String tenantId) async {
    final user = sb.auth.currentUser;
    if (user == null) return;
    await sb.from('tenant_members').insert({
      'tenant_id': tenantId,
      'user_id': user.id,
      'estado': 'pending',
      'rol': 'profesional',
    });
  }

  /// Deja constancia de que alguien de la plataforma miró un salón ajeno.
  /// La función del servidor se saltea sola si el actor SÍ es miembro.
  Future<void> registrarAcceso(String tenantId, String accion,
      {String? entidad}) async {
    await sb.rpc('registrar_acceso', params: {
      'p_tenant': tenantId,
      'p_accion': accion,
      'p_entidad': entidad,
    });
  }

  /// Versión mínima exigida y URL del APK, para el auto-updater.
  Future<Map<String, dynamic>?> appConfig() async {
    final row = await sb
        .from('app_config')
        .select('latest_version, min_version, apk_url, pwa_version, mensaje_global')
        .maybeSingle();
    return row;
  }
}

/// URL de WhatsApp al administrador desde la pantalla de pendiente.
/// Se conserva del legacy, que usaba el mismo canal.
String urlWhatsappSolicitud(String telefonoAdmin, String? email) {
  final tel = telefonoAdmin.replaceAll(RegExp(r'\D'), '');
  final texto = Uri.encodeComponent(
    'Hola! Solicité acceso a Mírame con el correo ${email ?? ''}. '
    '¿Me lo podés habilitar?',
  );
  return 'https://wa.me/$tel?text=$texto';
}

/// Sanity check para el arranque: si falta la config, es mejor fallar con un
/// mensaje entendible que con un error de red a las tres pantallas.
bool get backendConfigurado => AppConfig.configurado;
