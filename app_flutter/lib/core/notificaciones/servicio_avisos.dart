/// Notificaciones locales: el *cómo*. El *qué* está en
/// `domain/rules/avisos.dart`, que es Dart puro y testeable.
///
/// Todo lo de acá está envuelto en guardas: en la PWA el plugin no existe, y
/// una notificación que falla nunca puede tumbar la app.
library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../../domain/rules/avisos.dart';

/// Zona del salón. Se fija en vez de leerla del sistema: el negocio es de
/// Salta, y una usuaria que viaja no quiere que el cierre de caja se le
/// dispare a las 21:00 de otro huso.
const kZonaSalon = 'America/Argentina/Salta';

/// Adónde llevar cuando se toca una notificación. Lo consume el shell.
final payloadTocadoNotifier = ValueNotifier<String?>(null);

class ServicioAvisos {
  ServicioAvisos._();

  static final ServicioAvisos instancia = ServicioAvisos._();

  final _plugin = FlutterLocalNotificationsPlugin();
  var _listo = false;

  /// `true` si el sistema dejó mostrar notificaciones. Mientras sea `false` se
  /// programa igual (no cuesta nada) pero no se muestra nada.
  var permitido = false;

  bool get disponible => !kIsWeb && _listo;

  Future<void> iniciar() async {
    if (kIsWeb || _listo) return;
    try {
      tzdata.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation(kZonaSalon));

      await _plugin.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        ),
        onDidReceiveNotificationResponse: (r) =>
            payloadTocadoNotifier.value = r.payload,
      );

      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      // Los canales se crean acá y no al notificar: si se crean tarde, la
      // primera notificación de cada tipo sale sin sonido.
      for (final c in CanalAviso.values) {
        await android?.createNotificationChannel(AndroidNotificationChannel(
          c.id,
          c.nombre,
          description: c.descripcion,
          importance: Importance.defaultImportance,
        ));
      }
      permitido = await android?.areNotificationsEnabled() ?? false;
      _listo = true;
    } catch (e) {
      // Sin google-services, sin permisos, sin nada: la app sigue. El panel de
      // notificaciones de adentro de la app cubre lo importante.
      debugPrint('avisos: no se pudo iniciar ($e)');
    }
  }

  /// Pide el permiso de Android 13+. **En contexto**, nunca al arrancar: un
  /// permiso pedido en frío se rechaza y después no hay segunda oportunidad
  /// fácil.
  Future<bool> pedirPermiso() async {
    if (!disponible) return false;
    try {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      permitido = await android?.requestNotificationsPermission() ?? false;
      return permitido;
    } catch (_) {
      return false;
    }
  }

  /// Reemplaza la agenda de avisos por la que se le pase.
  ///
  /// Cancela todo primero a propósito: reprogramar sumando dejaría un aviso
  /// viejo de un turno que ya se canceló. Los ids son deterministas, así que
  /// cancelar-y-volver-a-poner no parpadea nada visible.
  Future<void> reprogramar(List<AvisoProgramado> avisos) async {
    if (!disponible) return;
    try {
      await _plugin.cancelAll();
      for (final a in avisos) {
        await _plugin.zonedSchedule(
          id: a.id,
          title: a.titulo,
          body: a.cuerpo,
          scheduledDate: tz.TZDateTime.from(a.cuando, tz.local),
          notificationDetails: _detalles(a),
          payload: a.payload,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        );
      }
    } catch (e) {
      debugPrint('avisos: no se pudo reprogramar ($e)');
    }
  }

  Future<void> mostrarYa(AvisoProgramado a) async {
    if (!disponible || !permitido) return;
    try {
      await _plugin.show(
        id: a.id,
        title: a.titulo,
        body: a.cuerpo,
        notificationDetails: _detalles(a),
        payload: a.payload,
      );
    } catch (e) {
      debugPrint('avisos: no se pudo mostrar ($e)');
    }
  }

  NotificationDetails _detalles(AvisoProgramado a) => NotificationDetails(
        android: AndroidNotificationDetails(
          a.canal.id,
          a.canal.nombre,
          channelDescription: a.canal.descripcion,
          // El cuerpo lista nombres de clientas y no entra en una línea.
          styleInformation: BigTextStyleInformation(a.cuerpo),
        ),
      );
}
