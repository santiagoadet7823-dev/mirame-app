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

/// A dónde vuelve el OAuth.
///
/// En Android es el deep link `com.mirame.app://auth`. En web es la URL de la
/// propia PWA, **explícita**: con `null`, Supabase manda al *Site URL* del
/// proyecto, y ese campo apuntaba a `localhost` de cuando se desarrollaba —
/// así que en producción Google autenticaba y el navegador terminaba en un
/// localhost que no existe. Se manda solo origen + ruta: sin el fragmento
/// (`#/login`), porque Supabase pega `?code=…` y con un `#` en el medio el
/// código queda en el lugar equivocado; y sin la query, porque la URL tiene
/// que coincidir EXACTA con la lista blanca y un `?algo` cualquiera la
/// sacaría de ahí.
///
/// La URL tiene que estar en Authentication → URL Configuration → Redirect
/// URLs (ver `04-AUTH-Y-ROLES.md`); si no está, Supabase cae al Site URL en
/// silencio.
String get _authRedirect {
  if (!kIsWeb) return AppConfig.authRedirectNativo;
  final b = Uri.base;
  return Uri(scheme: b.scheme, host: b.host, port: b.port, path: b.path)
      .toString();
}

/// Login con Google.
///
/// En web redirige y vuelve a la misma URL; en Android abre el navegador del
/// sistema y regresa por `com.mirame.app://auth`, que debe estar declarado
/// como intent-filter y cargado en las Redirect URLs de Supabase.
Future<void> signInConGoogle() async {
  await sb.auth.signInWithOAuth(
    OAuthProvider.google,
    redirectTo: _authRedirect,
  );
}

/// Respaldo por email. Si Google falla en un dispositivo, hay una segunda
/// puerta y no se pierde el acceso al salón.
Future<void> enviarMagicLink(String email) async {
  await sb.auth.signInWithOtp(
    email: email,
    emailRedirectTo: _authRedirect,
  );
}

Future<void> signOut() => sb.auth.signOut();
