/// Configuración por `--dart-define`. Nada de esto se commitea con valores.
///
/// ```bash
/// flutter run --dart-define-from-file=env.json
/// ```
///
/// `env.json` está en `.gitignore`; en CI los valores vienen de secrets.
library;

abstract final class AppConfig {
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');

  static const _publishable =
      String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');
  static const _anon = String.fromEnvironment('SUPABASE_ANON_KEY');

  /// Clave pública del proyecto. Supabase la renombró de *anon key* a
  /// *publishable key*; se aceptan los dos nombres de `--dart-define` para no
  /// romper builds ni documentación existente.
  ///
  /// Es **pública por diseño**: va horneada en el bundle web y en el APK, y no
  /// pasa nada — la seguridad la dan las RLS. La que nunca puede tocar el
  /// cliente es la service-role key.
  static String get supabaseKey =>
      _publishable.isNotEmpty ? _publishable : _anon;

  /// `dev` | `prod`. Solo para diferenciar logs y el sufijo de package.
  static const flavor = String.fromEnvironment('FLAVOR', defaultValue: 'dev');

  /// Deep link de vuelta del OAuth en Android. Tiene que coincidir con el
  /// intent-filter del manifest y con las Redirect URLs de Supabase.
  static const authRedirectNativo = 'com.mirame.app://auth';

  /// Base publica de la PWA. Es tambien la landing de descarga del APK, y por
  /// eso vive en `--dart-define`: al cambiar de dominio no hay que recompilar
  /// nada mas que esto.
  static const urlPublica = String.fromEnvironment(
    'URL_PUBLICA',
    defaultValue: 'https://santiagoadet7823-dev.github.io/mirame-app/',
  );

  /// Link que se comparte y que codifica el QR de invitacion.
  ///
  /// Apunta a la PWA y NO al `.apk` directo: un `.apk` abierto desde la camara
  /// de un iPhone, o desde un navegador sin permiso de instalacion, es un
  /// callejon sin salida. La pagina funciona siempre y desde ahi se elige.
  static String urlInvitacion(String? slug) {
    final base = urlPublica.endsWith('/') ? urlPublica : '$urlPublica/';
    // OJO: `descargar.html`, no la raiz. La raiz es la PWA, y quien escanea
    // el QR caeria directo en el login sin que nadie le ofrezca instalar la
    // app. Una version anterior apuntaba ahi — el comentario decia "landing"
    // pero el codigo mandaba a la raiz.
    final pagina = '${base}descargar.html';
    return slug == null || slug.isEmpty ? pagina : '$pagina?salon=$slug';
  }

  /// El link de la vitrina que la duena le manda a sus clientas.
  ///
  /// Apunta a `tienda.html`, que es HTML plano y abre en ~1 segundo. Mandar
  /// a la raiz —la PWA— haria que una clienta con datos moviles descargue
  /// varios MB de app de gestion para ver un vestido.
  static String urlTienda(String? slug) {
    final base = urlPublica.endsWith('/') ? urlPublica : '$urlPublica/';
    final pagina = '${base}tienda.html';
    return slug == null || slug.isEmpty ? pagina : '$pagina?t=$slug';
  }

  static bool get configurado =>
      supabaseUrl.isNotEmpty && supabaseKey.isNotEmpty;

  /// Falla temprano y con un mensaje claro. Un `--dart-define` olvidado se
  /// manifiesta si no como un error de red incomprensible.
  static void validar() {
    if (!configurado) {
      throw StateError(
        'Faltan SUPABASE_URL y/o SUPABASE_PUBLISHABLE_KEY.\n'
        'Corré con: flutter run --dart-define-from-file=env.json',
      );
    }
  }
}
