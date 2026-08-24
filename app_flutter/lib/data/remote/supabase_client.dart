/// Inicialización del cliente de Supabase.
library;

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/config/app_config.dart';

/// Instancia única. Solo la usan `data/remote/` y `features/auth/`; ningún
/// widget de negocio importa este archivo — todo pasa por repositorios.
SupabaseClient get sb => Supabase.instance.client;

Future<void> initSupabase() async {
  AppConfig.validar();
  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    publishableKey: AppConfig.supabaseKey,
    authOptions: FlutterAuthClientOptions(
      // PKCE es el flujo correcto para clientes públicos (móvil y SPA): no
      // requiere guardar un secret en el binario.
      authFlowType: AuthFlowType.pkce,
      // NO tocar este flag. Se llama "detectSessionInUri" pero es el
      // interruptor del OBSERVADOR DE DEEP LINKS: si es false,
      // `_startDeeplinkObserver()` nunca arranca (supabase_auth.dart:133) y
      // en Android el `com.mirame.app://auth?code=…` de vuelta del OAuth no
      // lo escucha nadie. Sintoma: la app se queda en el login, sin error.
      // El default es true y sirve para los dos targets. Se deja explicito
      // justamente para que nadie lo "optimice" a kIsWeb otra vez.
      detectSessionInUri: true,
    ),
  );
}

/// Login con Google.
///
/// En web redirige y vuelve a la misma URL; en Android abre el navegador del
/// sistema y regresa por `com.mirame.app://auth`, que debe estar declarado
/// como intent-filter y cargado en las Redirect URLs de Supabase.
Future<void> signInConGoogle() async {
  await sb.auth.signInWithOAuth(
    OAuthProvider.google,
    redirectTo: kIsWeb ? null : AppConfig.authRedirectNativo,
  );
}

/// Respaldo por email. Si Google falla en un dispositivo, hay una segunda
/// puerta y no se pierde el acceso al salón.
Future<void> enviarMagicLink(String email) async {
  await sb.auth.signInWithOtp(
    email: email,
    emailRedirectTo: kIsWeb ? null : AppConfig.authRedirectNativo,
  );
}

Future<void> signOut() => sb.auth.signOut();
