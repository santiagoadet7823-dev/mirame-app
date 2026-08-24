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

/// El único valor que falta. Lo genera la consola al registrar la app Android
/// `com.mirame.app` dentro de `mirame-lash-studio-41ba9`, y tiene esta forma:
///
/// ```
/// 1:998613317742:android:xxxxxxxxxxxxxxxxxxxxxx
/// ```
///
/// Se pasa en el build:
/// ```
/// flutter build apk --dart-define=FIREBASE_ANDROID_APP_ID=1:998613317742:android:…
/// ```
///
/// Mientras esté vacío el push queda apagado y la app funciona igual con las
/// notificaciones locales, que son las que se usan todos los días.
const _appIdAndroid = String.fromEnvironment('FIREBASE_ANDROID_APP_ID');

/// El de la web ya existe: es el que usa el `index.html` legacy.
const _appIdWeb = '1:998613317742:web:bc5a3c9c87f74c8a844e7f';

const _apiKey = 'AIzaSyAECl9vKR2RU_PiWLWRxUHh13QDpNfvKn4';
const _senderId = '998613317742';
const _projectId = 'mirame-lash-studio-41ba9';

/// `null` cuando falta el App ID de Android — el llamador lo trata como
/// "push no configurado en este build" y sigue de largo.
FirebaseOptions? get opcionesFirebaseAndroid => _appIdAndroid.isEmpty
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
