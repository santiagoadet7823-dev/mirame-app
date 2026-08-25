/// Config de Firebase para el push, **sin `google-services.json`**.
///
/// Se pasa por Dart en vez de por el archivo del plugin de Gradle porque así
/// no hay nada que commitear ni que cargar como secret en CI: estos valores
/// son identificadores públicos, no credenciales. De hecho ya están a la vista
/// en el `index.html` de la app vieja, que cualquiera puede leer. Lo que sí es
/// secreto —la service account— vive solo en la Edge Function.
///
/// **Proyecto: `mirame-lash-studio-41ba9`**, el que la app legacy ya usa para
/// Auth. Se reutiliza a propósito y NO se toca `gestor-local-celulares`, que
/// es el de DisT-At: mezclar las dos flotas en un mismo proyecto haría que un
/// error de segmentación le mande a los repartidores un aviso de retoque de
/// pestañas.
library;

import 'package:firebase_core/firebase_core.dart';

/// La app Android `com.mirame.app` registrada en `mirame-lash-studio-41ba9`.
///
/// Va hardcodeado y NO como secret de CI a propósito: este identificador viaja
/// dentro de cada APK que se publica, así que "esconderlo" en un secret daría
/// una sensación de seguridad falsa a cambio de una cosa más que mantener. Lo
/// que sí es secreto —la service account que firma los envíos— vive solo en la
/// Edge Function.
///
/// El `--dart-define` sigue disponible para apuntar a otro proyecto (un build
/// de prueba, un tenant propio) sin tocar el código.
const _appIdAndroid = String.fromEnvironment(
  'FIREBASE_ANDROID_APP_ID',
  defaultValue: '1:998613317742:android:0d77c08dd9373a5f844e7f',
);

/// El de la web ya existe: es el que usa el `index.html` legacy.
const _appIdWeb = '1:998613317742:web:bc5a3c9c87f74c8a844e7f';

/// Fuera del repo por pedido del dueño, después de que el escáner de secretos
/// de GitHub la marcara.
///
/// Aclaración para quien lea esto más adelante: una API key de Firebase **no
/// es una credencial**. Identifica al proyecto y viaja dentro de cada APK y de
/// cada página de la PWA; la seguridad la dan las reglas de Firestore y las
/// restricciones de la key en Google Cloud. Sacarla de acá calla la alerta,
/// pero lo que de verdad protege es restringirla por package name y por API.
///
/// Sin ella el push queda apagado y las notificaciones locales siguen andando.
const _apiKey = String.fromEnvironment('FIREBASE_API_KEY');
const _senderId = '998613317742';
const _projectId = 'mirame-lash-studio-41ba9';

/// `null` cuando falta el App ID o la API key — el llamador lo trata como
/// "push no configurado en este build" y sigue de largo.
FirebaseOptions? get opcionesFirebaseAndroid =>
    _appIdAndroid.isEmpty || _apiKey.isEmpty
    ? null
    : const FirebaseOptions(
        apiKey: _apiKey,
        appId: _appIdAndroid,
        messagingSenderId: _senderId,
        projectId: _projectId,
        storageBucket: '$_projectId.firebasestorage.app',
      );

/// Para la PWA. Además del App ID necesita una VAPID key, que también sale de
/// la consola; hasta entonces el push web queda apagado.
const opcionesFirebaseWeb = FirebaseOptions(
  apiKey: _apiKey,
  appId: _appIdWeb,
  messagingSenderId: _senderId,
  projectId: _projectId,
  authDomain: '$_projectId.firebaseapp.com',
  storageBucket: '$_projectId.firebasestorage.app',
);
