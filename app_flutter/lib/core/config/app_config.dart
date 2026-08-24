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
