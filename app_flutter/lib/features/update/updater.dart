/// Auto-actualización del APK.
///
/// GitHub Releases es el CDN; la tabla `app_config` de Supabase es el plano de
/// control. Publicar un APK y exigirlo son dos pasos separados a propósito:
/// primero se sube y se prueba, y recién después se sube `min_version`.
///
/// En web esto no corre: la PWA se actualiza sola por el service worker.
library;

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

import '../../data/remote/supabase_client.dart';
import '../../domain/rules/version.dart';

const _canal = MethodChannel('com.mirame.app/updater');

/// Lo que dice el plano de control.
class InfoActualizacion {
  const InfoActualizacion({
    required this.instalada,
    required this.latestVersion,
    required this.minVersion,
    required this.apkUrl,
    this.mensajeGlobal,
  });

  final String instalada;
  final String latestVersion;
  final String minVersion;
  final String? apkUrl;
  final String? mensajeGlobal;

  bool get obligatoria =>
      debeActualizar(instalada: instalada, minVersion: minVersion);

  bool get hayNueva =>
      hayNovedad(instalada: instalada, latestVersion: latestVersion);

  /// Sin URL no hay nada que ofrecer. Mostrar el aviso igual llevaría a un
  /// botón que falla al tocarlo.
  bool get ofrecible => hayNueva && (apkUrl?.isNotEmpty ?? false);
}

enum ResultadoInstalacion { silenciosa, conDialogo, necesitaPermiso, error }

class Updater {
  const Updater();

  /// `true` solo en Android con el plugin presente.
  ///
  /// Guarda contra la flota mixta: si un APK viejo no trae el plugin, no hay
  /// que ofrecerle una actualización que va a fallar al tocarla.
  Future<bool> disponible() async {
    if (kIsWeb || !Platform.isAndroid) return false;
    try {
      await _canal.invokeMethod<bool>('puedeInstalar');
      return true;
    } on MissingPluginException {
      return false;
    } catch (_) {
      // Cualquier otro error significa que el plugin está pero algo falló;
      // sigue siendo utilizable.
      return true;
    }
  }

  Future<InfoActualizacion?> consultar() async {
    if (!await disponible()) return null;
    final info = await PackageInfo.fromPlatform();
    final fila = await sb
        .from('app_config')
        .select('latest_version, min_version, apk_url, mensaje_global')
        .limit(1)
        .maybeSingle();
    if (fila == null) return null;
    return InfoActualizacion(
      // La versión sale de `package_info_plus`, es decir del versionName real
      // del APK instalado. Una constante en Dart se olvida de actualizar y
      // deja a la flota creyendo que está al día.
      instalada: info.version,
      latestVersion: (fila['latest_version'] as String?) ?? info.version,
      minVersion: (fila['min_version'] as String?) ?? '0.0.0',
      apkUrl: fila['apk_url'] as String?,
      mensajeGlobal: fila['mensaje_global'] as String?,
    );
  }

  /// Descarga el APK informando progreso de 0 a 1.
  Future<File> descargar(
    String url, {
    void Function(double)? onProgreso,
  }) async {
    final base = await getExternalStorageDirectory();
    if (base == null) {
      throw StateError('Sin almacenamiento externo para dejar el APK');
    }
    final dir = Directory('${base.path}/updates');
    if (dir.existsSync()) {
      // Los APK viejos ocupan decenas de MB cada uno y no sirven para nada.
      for (final f in dir.listSync()) {
        if (f is File) f.deleteSync();
      }
    } else {
      dir.createSync(recursive: true);
    }

    final destino = File('${dir.path}/mirame-update.apk');
    final dio = Dio(
      BaseOptions(
        // GitHub Releases redirige a objects.githubusercontent.com. Sin
        // seguir redirecciones se baja un HTML de 0 KB que después falla al
        // instalar con un error que no menciona la descarga.
        followRedirects: true,
        maxRedirects: 5,
        receiveTimeout: const Duration(minutes: 10),
      ),
    );
    await dio.download(
      url,
      destino.path,
      onReceiveProgress: (recibido, total) {
        if (total > 0) onProgreso?.call(recibido / total);
      },
    );

    if (!destino.existsSync() || destino.lengthSync() < 1024 * 1024) {
      throw StateError('La descarga quedó incompleta');
    }
    return destino;
  }

  Future<ResultadoInstalacion> instalar(File apk) async {
    try {
      final r = await _canal.invokeMethod<String>(
        'instalar',
        {'ruta': apk.path},
      );
      return switch (r) {
        'silencioso' => ResultadoInstalacion.silenciosa,
        'dialogo' => ResultadoInstalacion.conDialogo,
        'necesitaPermiso' => ResultadoInstalacion.necesitaPermiso,
        _ => ResultadoInstalacion.error,
      };
    } catch (_) {
      return ResultadoInstalacion.error;
    }
  }

  Future<void> abrirAjustesPermiso() =>
      _canal.invokeMethod<void>('abrirAjustesPermiso');
}

final updaterProvider = Provider<Updater>((_) => const Updater());

/// Se consulta al arrancar. Un fallo acá **nunca** puede trabar la app: si
/// Supabase no responde, no hay actualización que ofrecer y listo.
final actualizacionProvider = FutureProvider<InfoActualizacion?>((ref) async {
  try {
    return await ref.read(updaterProvider).consultar();
  } catch (_) {
    return null;
  }
});
