package com.mirame.mirame

import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.pm.PackageInstaller
import android.net.Uri
import android.os.Build
import androidx.core.content.FileProvider
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File

/**
 * Instalacion del APK de actualizacion.
 *
 * Dos caminos:
 *  - Android 12+ (S): PackageInstaller con setRequireUserAction(NOT_REQUIRED).
 *    La instalacion ocurre sin que el usuario toque nada.
 *  - Resto: FileProvider + ACTION_VIEW, que muestra el dialogo del sistema.
 *
 * CAVEAT del modo silencioso: solo aplica si la app es su propio "installer of
 * record". Un APK instalado por adb o abriendo el archivo a mano tiene ese
 * campo en null, asi que LA PRIMERA actualizacion pide confirmacion igual. De
 * la segunda en adelante, no. No es un bug: documentarlo evita perseguirlo.
 */
class MirameUpdater : FlutterPlugin, MethodChannel.MethodCallHandler {

    private lateinit var canal: MethodChannel
    private lateinit var contexto: Context

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        contexto = binding.applicationContext
        canal = MethodChannel(binding.binaryMessenger, CANAL)
        canal.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        canal.setMethodCallHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "puedeInstalar" -> result.success(puedeInstalar())

            "abrirAjustesPermiso" -> {
                abrirAjustesPermiso()
                result.success(null)
            }

            "instalar" -> {
                val ruta = call.argument<String>("ruta")
                if (ruta == null) {
                    result.error("SIN_RUTA", "Falta la ruta del APK", null)
                    return
                }
                val archivo = File(ruta)
                if (!archivo.exists() || archivo.length() == 0L) {
                    result.error("NO_EXISTE", "El APK descargado no esta o esta vacio", null)
                    return
                }
                // El gate de permiso va ANTES de intentar instalar: si no, el
                // usuario ve fallar la instalacion sin saber por que.
                if (!puedeInstalar()) {
                    result.success("necesitaPermiso")
                    return
                }
                try {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                        instalarSilencioso(archivo)
                        result.success("silencioso")
                    } else {
                        instalarConDialogo(archivo)
                        result.success("dialogo")
                    }
                } catch (e: Exception) {
                    result.error("FALLO_INSTALACION", e.message, null)
                }
            }

            else -> result.notImplemented()
        }
    }

    private fun puedeInstalar(): Boolean =
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            contexto.packageManager.canRequestPackageInstalls()
        } else {
            true
        }

    private fun abrirAjustesPermiso() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val i = Intent(
            android.provider.Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES,
            Uri.parse("package:" + contexto.packageName),
        ).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        contexto.startActivity(i)
    }

    private fun instalarSilencioso(apk: File) {
        val installer = contexto.packageManager.packageInstaller
        val params = PackageInstaller.SessionParams(
            PackageInstaller.SessionParams.MODE_FULL_INSTALL,
        ).apply {
            setAppPackageName(contexto.packageName)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                setRequireUserAction(PackageInstaller.SessionParams.USER_ACTION_NOT_REQUIRED)
            }
        }

        val idSesion = installer.createSession(params)
        installer.openSession(idSesion).use { sesion ->
            sesion.openWrite("mirame", 0, apk.length()).use { salida ->
                apk.inputStream().use { it.copyTo(salida) }
                sesion.fsync(salida)
            }

            // FLAG_MUTABLE es OBLIGATORIO. Con FLAG_IMMUTABLE el sistema no
            // puede completar el Intent del broadcast: el receiver llega sin
            // status y la instalacion queda colgada, en silencio.
            val intent = Intent(contexto, InstalacionReceiver::class.java)
                .setAction(ACCION_RESULTADO)
            val pending = PendingIntent.getBroadcast(
                contexto,
                idSesion,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_MUTABLE,
            )
            sesion.commit(pending.intentSender)
        }
    }

    private fun instalarConDialogo(apk: File) {
        val uri = FileProvider.getUriForFile(
            contexto,
            contexto.packageName + ".fileprovider",
            apk,
        )
        val i = Intent(Intent.ACTION_VIEW)
            .setDataAndType(uri, "application/vnd.android.package-archive")
            .addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        contexto.startActivity(i)
    }

    companion object {
        const val CANAL = "com.mirame.app/updater"
        const val ACCION_RESULTADO = "com.mirame.app.INSTALACION_RESULTADO"
    }
}

/**
 * Resultado de la instalacion.
 *
 * Va DECLARADO EN EL MANIFEST, no registrado en runtime: la instalacion mata
 * el proceso de la app, y con el se iria el receiver justo antes de que
 * llegue el resultado.
 */
class InstalacionReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val status = intent.getIntExtra(
            PackageInstaller.EXTRA_STATUS,
            PackageInstaller.STATUS_FAILURE,
        )
        if (status == PackageInstaller.STATUS_PENDING_USER_ACTION) {
            // El sistema decidio pedir confirmacion igual (tipico cuando la
            // app no es su propio installer of record). Hay que relanzar el
            // Intent que viene adentro.
            val confirmar: Intent? =
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                    intent.getParcelableExtra(Intent.EXTRA_INTENT, Intent::class.java)
                } else {
                    @Suppress("DEPRECATION")
                    intent.getParcelableExtra(Intent.EXTRA_INTENT)
                }
            confirmar?.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            if (confirmar != null) context.startActivity(confirmar)
        }
    }
}
