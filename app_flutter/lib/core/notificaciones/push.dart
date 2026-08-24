/// Push remoto (FCM). Firebase se usa **solo** para esto: la identidad y los
/// datos son de Supabase.
///
/// Todo está detrás de guardas porque `google-services.json` no se commitea
/// (entra en el APK desde un secret de CI). Sin ese archivo `Firebase
/// .initializeApp()` lanza, y la app tiene que seguir funcionando igual: los
/// avisos que de verdad usa la dueña son los locales, que no dependen de esto.
library;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/rules/avisos.dart';
import 'servicio_avisos.dart';

class Push {
  Push._();

  static final Push instancia = Push._();

  String? _token;
  var _iniciado = false;

  /// `true` si Firebase está configurado en este build.
  var disponible = false;

  /// Arranca FCM y deja el token listo para registrar.
  ///
  /// No pide permisos acá: eso lo hace `ServicioAvisos.pedirPermiso()` en
  /// contexto, y en Android el mismo permiso cubre local y push.
  Future<void> iniciar() async {
    if (kIsWeb || _iniciado) return;
    _iniciado = true;
    try {
      await Firebase.initializeApp();
      final fm = FirebaseMessaging.instance;
      _token = await fm.getToken();

      // El token rota solo (reinstalación, limpieza de datos, actualización de
      // Play Services). Sin esto la flota se va quedando muda de a poco.
      fm.onTokenRefresh.listen((t) {
        _token = t;
        registrar();
      });

      // Con la app abierta, Android NO muestra la notificación de FCM: hay que
      // dibujarla a mano o el mensaje pasa desapercibido.
      FirebaseMessaging.onMessage.listen(_mostrarEnPrimerPlano);
      FirebaseMessaging.onMessageOpenedApp.listen(
        (m) => payloadTocadoNotifier.value = m.data['ir_a'] as String?,
      );

      disponible = true;
    } catch (e) {
      debugPrint('push: Firebase no está configurado en este build ($e)');
    }
  }

  /// Asocia este dispositivo al usuario y al salón activos.
  Future<void> registrar({String? tenantId}) async {
    final token = _token;
    if (token == null) return;
    try {
      await Supabase.instance.client.rpc('registrar_token_push', params: {
        'p_token': token,
        'p_tenant': tenantId,
        'p_plataforma': defaultTargetPlatform.name,
      });
    } catch (e) {
      debugPrint('push: no se pudo registrar el token ($e)');
    }
  }

  /// Al cerrar sesión. Se borra **este** token, no todos los del usuario: quien
  /// use el teléfono después no tiene que recibir avisos ajenos, pero la tablet
  /// del salón sigue avisando.
  Future<void> olvidar() async {
    final token = _token;
    if (token == null) return;
    try {
      await Supabase.instance.client
          .rpc('borrar_token_push', params: {'p_token': token});
    } catch (e) {
      debugPrint('push: no se pudo borrar el token ($e)');
    }
  }

  void _mostrarEnPrimerPlano(RemoteMessage m) {
    final n = m.notification;
    if (n == null) return;
    ServicioAvisos.instancia.mostrarYa(AvisoProgramado(
      id: idEstable('push-${m.messageId ?? n.title ?? ''}'),
      titulo: n.title ?? 'Mírame',
      cuerpo: n.body ?? '',
      cuando: DateTime.now(),
      canal: CanalAviso.agenda,
      payload: m.data['ir_a'] as String?,
    ));
  }
}
