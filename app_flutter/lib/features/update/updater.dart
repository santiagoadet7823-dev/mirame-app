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
import '../../domain/rules/access.dart';
import '../../domain/rules/version.dart';
import '../auth/session_controller.dart';

const _canal = MethodChannel('com.mirame.app/updater');

/// Lo que dice el plano de control.
class InfoActualizacion {
  const InfoActualizacion({
    required this.instalada,
    required this.latestVersion,
    required this.minVersion,
    required this.apkUrl,
    this.apkUrlArm64,
    this.apkUrlArm32,
    this.abi,
    this.mensajeGlobal,
  });

  final String instalada;
  final String latestVersion;
  final String minVersion;

  /// El APK universal: trae las tres arquitecturas y pesa el triple. Sigue
  /// existiendo porque las versiones viejas solo leen esta columna, y porque
  /// es la red de seguridad para un teléfono cuya ABI no reconocemos.
  final String? apkUrl;

  /// Los APK por arquitectura. Un teléfono usa UNA: bajar las tres eran
  /// 91 MB para instalar 37.
  final String? apkUrlArm64;
  final String? apkUrlArm32;

  /// Lo que dijo el sistema: `arm64`, `arm32` u `otra`.
  final String? abi;

  final String? mensajeGlobal;

  /// El APK que le corresponde a ESTE teléfono, con el universal de respaldo.
  String? get urlParaEsteTelefono {
    final propio = switch (abi) {
      'arm64' => apkUrlArm64,
      'arm32' => apkUrlArm32,
      _ => null,
    };
    return (propio?.isNotEmpty ?? false) ? propio : apkUrl;
  }

  bool get obligatoria =>
      debeActualizar(instalada: instalada, minVersion: minVersion);

  bool get hayNueva =>
      hayNovedad(instalada: instalada, latestVersion: latestVersion);

  /// Sin URL no hay nada que ofrecer. Mostrar el aviso igual llevaría a un
  /// botón que falla al tocarlo.
  bool get ofrecible =>
      hayNueva && (urlParaEsteTelefono?.isNotEmpty ?? false);
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
        .select('latest_version, min_version, apk_url, apk_url_arm64, '
            'apk_url_arm32, mensaje_global')
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
      apkUrlArm64: fila['apk_url_arm64'] as String?,
      apkUrlArm32: fila['apk_url_arm32'] as String?,
      abi: await _abi(),
      mensajeGlobal: fila['mensaje_global'] as String?,
    );
  }

  /// Qué arquitectura usa este teléfono, según el sistema.
  ///
  /// Si el canal no contesta —un APK viejo sin este método— se devuelve null
  /// y el updater cae al APK universal, que instala en cualquiera.
  Future<String?> _abi() async {
    try {
      return await _canal.invokeMethod<String>('abi');
    } catch (_) {
      return null;
    }
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

/// Consulta el plano de control. Un fallo acá **nunca** puede trabar la app:
/// si Supabase no responde, no hay actualización que ofrecer y listo.
///
/// ⚠️ Depende del estado de sesión A PROPÓSITO, y no es un detalle: la policy
/// `cfg_select` de `app_config` exige `authenticated`. Una versión anterior no
/// observaba la sesión, así que este provider corría UNA sola vez al arrancar
/// —antes del login—, obtenía vacío y cacheaba ese `null` para siempre: el
/// cartel de actualización no aparecía nunca. Observar la sesión hace que se
/// recalcule al entrar.
final actualizacionProvider = FutureProvider<InfoActualizacion?>((ref) async {
  final sesion = ref.watch(sessionProvider);
  // Solo tiene sentido preguntar con sesión resuelta y adentro.
  final adentro =
      sesion.decision is GoToApp || sesion.decision is GoToPlatformAdmin;
  if (sesion.cargando || !adentro) return null;

  try {
    return await ref.read(updaterProvider).consultar();
  } catch (_) {
    return null;
  }
});
