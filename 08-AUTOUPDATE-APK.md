# 08 · Auto-actualización del APK

> Portado del mecanismo **ya probado en producción** en DisT-At / la-union-app
> (`web/src/services/apkUpdate.js` + `ApkUpdaterPlugin.java`). Las trampas de este documento
> están ahí porque ya costaron caro una vez; no se re-descubren.

---

## 1. Qué canal usar

DisT-At tiene dos canales: OTA liviana (Capacitor + capgo, cambia solo el bundle web) y APK
completo. **Flutter no puede tener el canal OTA**: Google prohíbe descargar y ejecutar código Dart
que no venga en el binario.

La tabla adaptada:

| Tu cambio es… | Canal | Cómo llega al usuario |
|---|---|---|
| Cualquier cosa, para usuarios de la **PWA** | GitHub Pages | Instantáneo, sin fricción |
| Cualquier cosa, para usuarios del **APK** | APK nuevo | Auto-updater: silencioso en Android 12+, un toque en el resto |
| Solo datos o configuración (mensaje global, precios) | `app_config` / Supabase | Instantáneo, sin release |

No hay atajo liviano para el APK. Por eso conviene que el equipo de un salón que solo necesita
consultar use la PWA, y el APK quede para quien necesita las capacidades nativas (push confiable,
funcionamiento sin navegador).

---

## 2. Cómo funciona

```
[Local o CI] pubspec.yaml: version: 1.0.1+2
      ↓
[CI] flutter build apk --release  (firmado con el keystore)
      ↓
[CI] GitHub Release tag "apk-1.0.1", asset "app-release.apk"
      ↓
[CI] update app_config set min_version='1.0.1', apk_url='<URL>'
      ↓
[Teléfono] al abrir: package_info.version < min_version ?
      → sheet "Nueva versión de la app"
      → descarga con progreso a getExternalFilesDir/updates/
      → PackageInstaller silencioso (Android 12+)  o  FileProvider + ACTION_VIEW
```

**`app_config` es el plano de control**, no GitHub. GitHub Releases es solo el CDN del archivo.
Esto permite publicar un APK y **decidir después** cuándo se le ofrece a la flota — y hacer
rollback bajando `min_version` sin tocar el release.

### `min_version` es un PISO, no "la última"

Se pone en la versión del APK que trae el cambio que hay que forzar. Todos los teléfonos con una
versión **menor** ven el aviso. Si se quiere publicar sin forzar, se sube `latest_version` y se
deja `min_version` donde está.

---

## 3. Comparación de versiones

```dart
/// Compara versiones semánticas segmento por segmento.
/// NO comparar como strings: '1.5.9' > '1.5.42' lexicográficamente, y es falso.
int cmpVer(String a, String b) {
  final pa = a.split('.').map((s) => int.tryParse(s) ?? 0).toList();
  final pb = b.split('.').map((s) => int.tryParse(s) ?? 0).toList();
  for (var i = 0; i < (pa.length > pb.length ? pa.length : pb.length); i++) {
    final d = (i < pa.length ? pa[i] : 0) - (i < pb.length ? pb[i] : 0);
    if (d != 0) return d;
  }
  return 0;
}
```

La versión instalada se lee de **`package_info_plus`** (que devuelve el `versionName` del APK),
nunca de una constante de Dart. Si se leyera de una constante, un build mal versionado mentiría.

---

## 4. Ventaja de Flutter: un solo lugar para la versión

En DisT-At hay que subir **tres** números a mano en cada release (`versionCode` y `versionName` en
`build.gradle`, más `APP_VERSION` en `src/version.js`), y desincronizarlos es un error frecuente.

En Flutter los tres salen de una línea de `pubspec.yaml`:

```yaml
version: 1.0.1+2      #  versionName=1.0.1   versionCode=2
```

`scripts/bump-version.sh` lo automatiza igual, para que el tag del release y el `app_config`
tampoco se desincronicen.

**El `versionCode` (el número después del `+`) nunca baja.** Android rechaza instalar un
`versionCode` menor, y un error acá deja a la flota trabada sin remedio remoto.

---

## 5. El plugin nativo

`android/app/src/main/kotlin/com/mirame/app/MirameUpdaterPlugin.kt`, portado de
`ApkUpdaterPlugin.java`. Dos caminos de instalación.

### 5.1 Android 12+ — sin toques

`PackageInstaller` con `SessionParams.setRequireUserAction(USER_ACTION_NOT_REQUIRED)` y el permiso
`UPDATE_PACKAGES_WITHOUT_USER_ACTION`.

**Tres trampas que ya se pagaron:**

1. **El `PendingIntent` debe ser `FLAG_MUTABLE`.** Con `FLAG_IMMUTABLE` el broadcast de resultado
   llega vacío y el diálogo de confirmación no se puede abrir nunca. Es un fallo silencioso.
2. **El receiver va declarado en el `AndroidManifest`**, no registrado en runtime. El proceso que
   lo registraría es exactamente el que la instalación mata.
3. **`session.openWrite("app", 0, apk.length())` con el largo real**, no `-1`.

**Y la trampa más importante, porque parece un bug y no lo es:**

> El modo silencioso solo se concede si la app es **su propio instalador de registro**
> (`getInstallSourceInfo().getInstallingPackageName()`). Una app instalada por `adb`, o pasando el
> archivo a mano, tiene ese campo en `null`.
>
> **Consecuencia: la primera actualización SIEMPRE pide confirmación.** De la segunda en adelante
> es silenciosa. Esto le pasó a los 9 teléfonos de DisT-At y se reportó como falla del updater
> cuando era comportamiento esperado de Android.

Hay que decírselo a quien pruebe, o va a volver a reportarse.

### 5.2 Reserva — instalador clásico

`FileProvider` + `Intent.ACTION_VIEW` con `application/vnd.android.package-archive` y el permiso
`REQUEST_INSTALL_PACKAGES`. Pide confirmación al usuario. Es el camino en Android 11 y anterior, y
el fallback si `PackageInstaller` tira excepción.

### 5.3 Descarga

- **Gate de permiso ANTES de descargar.** Si falta "instalar apps desconocidas"
  (`canRequestPackageInstalls()`), se abre `Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES` y se
  devuelve `needsPermission: true`. Descargar 30 MB para descubrir después que no se puede
  instalar es maltratar los datos del usuario.
- **`setInstanceFollowRedirects(true)`** — GitHub Releases redirige a `objects.githubusercontent.com`.
  Sin esto, la descarga trae un cuerpo vacío.
- Destino: `getExternalFilesDir(null)/updates/app-<version>.apk`.
- Borrar los `.apk` previos antes de bajar el nuevo.
- Validar `length() > 0` antes de intentar instalar.
- Fuera del hilo principal (`NetworkOnMainThreadException`).

### 5.4 Manifest

```xml
<!-- Instalador clásico (camino de reserva) -->
<uses-permission android:name="android.permission.REQUEST_INSTALL_PACKAGES" />

<!-- Android 12+: la app se reinstala a sí misma sin diálogo.
     Permiso NORMAL: no se pide en runtime, se declara.
     OJO: declararlo no alcanza — ver §5.1 sobre el install source. -->
<uses-permission android:name="android.permission.UPDATE_PACKAGES_WITHOUT_USER_ACTION" />

<!-- Resultado de la instalación. Declarado acá, NO registrado en runtime. -->
<receiver android:name=".InstalacionReceiver" android:exported="false" />

<provider
    android:name="androidx.core.content.FileProvider"
    android:authorities="${applicationId}.fileprovider"
    android:exported="false"
    android:grantUriPermissions="true">
    <meta-data android:name="android.support.FILE_PROVIDER_PATHS"
               android:resource="@xml/file_paths" />
</provider>
```

`res/xml/file_paths.xml`:

```xml
<paths xmlns:android="http://schemas.android.com/apk/res/android">
    <external-files-path name="updates" path="updates/" />
</paths>
```

---

## 6. Lado Dart

```dart
class UpdateInfo { final String version; final String url; }

Future<UpdateInfo?> checkUpdate() async {
  if (!Platform.isAndroid) return null;

  // Guarda de flota mixta: si el canal nativo no está, no ofrecer algo que
  // fallaría al tocarlo.
  if (!await MirameUpdater.disponible()) return null;

  final cfg = await appConfigRepo.get();
  if (cfg?.apkUrl == null || cfg?.minVersion == null) return null;

  final instalada = (await PackageInfo.fromPlatform()).version;
  if (cmpVer(instalada, cfg!.minVersion!) >= 0) return null;

  return UpdateInfo(version: cfg.minVersion!, url: cfg.apkUrl!);
}
```

El sheet de actualización usa el **lenguaje visual de la app** (bottom sheet con handle, tipografía
Cormorant en el título, botón primary), no un `AlertDialog` del sistema.

Estados y textos (calcados de los que ya funcionan en DisT-At):

| Estado | Título | Texto | Acción |
|---|---|---|---|
| pendiente | Nueva versión de la app | Hay una versión nueva para instalar. Se descarga sola. | Actualizar |
| descargando | Descargando… | Barra de progreso real (`dio` con `onReceiveProgress`) | deshabilitado |
| permiso | Falta un permiso | Activá "Instalar apps desconocidas" para esta app y volvé a tocar Actualizar. | Reintentar |
| instalando | Instalando… | Seguí los pasos del instalador para completar la actualización. | deshabilitado |
| error | Actualización disponible | No se pudo descargar: … | Reintentar |

El botón de descartar solo aparece cuando la actualización **no** es obligatoria.

---

## 7. Publicar una versión

### Camino automatizado (el que queda como norma)

```bash
bash scripts/bump-version.sh 1.0.1
git commit -am "chore(release): version 1.0.1"
git tag apk-1.0.1
git push origin main --tags
```

El workflow `apk.yml` se dispara con el tag: compila firmado, publica el release y actualiza
`app_config` con la service-role key. Nada manual.

### Camino manual (respaldo, o para probar antes de publicar)

```bash
flutter build apk --release
bash scripts/apk-release.sh 1.0.1
```

y pegar en el SQL Editor lo que imprime el script.

---

## 8. Rollback

Si una versión salió mal:

- **Todavía no la instaló nadie:** bajar `min_version` a la anterior. El aviso deja de aparecer.
- **Ya se instaló:** la única salida es publicar una versión **más nueva** con el arreglo. Android
  no instala un `versionCode` menor. No hay downgrade remoto.

Por eso conviene probar el APK en un teléfono real **antes** de tocar `min_version`. Publicar el
release no molesta a nadie; subir `min_version` sí.

---

## 9. El keystore

Punto único de falla. Android exige que cada actualización esté firmada con la misma llave que la
app instalada, y como esto no pasa por Play Store, no hay ningún respaldo de Google.

Si se pierde el archivo **o** las contraseñas:

- La PWA sigue funcionando.
- **Ningún APK nuevo se puede instalar como actualización.** La única salida sería que cada usuario
  desinstale e instale de cero — y desinstalar **borra los datos locales**: la cola de outbox con
  cambios sin subir se pierde.

**Antes del primer release:**

- [ ] Generar `mirame.keystore` con `keytool`.
- [ ] Guardar `storePassword`, `keyPassword` y `keyAlias` en un gestor de contraseñas.
- [ ] Copiar el `.keystore` a **dos** lugares privados (Drive privado y pendrive).
- [ ] Subirlo como secret base64 a GitHub (`KEYSTORE_BASE64`) para que CI pueda firmar.
- [ ] Confirmar que `.gitignore` lo excluye, y verificarlo con `git check-ignore`.
- [ ] Registrar el SHA-1 del keystore de release en Google Cloud Console (para el OAuth nativo).

---

## 10. Fase opcional: actualizar con la app cerrada

DisT-At tiene un `updateNotify.js` que, con un push FCM y un watchdog de `AlarmManager`, despierta
la app cada ~30 minutos y descarga la actualización sola. Con la Edge Function
`push-actualizacion` sellando un aviso por teléfono y por versión.

Es lo que hace que una flota efectivamente se mueva en vez de quedarse en versiones viejas. Pero
tiene costo: batería, complejidad y un watchdog más que mantener.

**Recomendación: no hacerlo ahora.** Con uno o dos salones, el aviso al abrir la app alcanza.
Vale la pena cuando haya varios tenants y se vuelva imposible saber quién está en qué versión.

---

## 11. Verificación de la Fase 8

- [ ] Instalar el APK 1.0.0 en un teléfono real.
- [ ] Publicar 1.0.1 y subir `min_version`.
- [ ] Al abrir, el teléfono ofrece actualizar.
- [ ] La descarga muestra progreso real.
- [ ] La instalación completa **conservando los datos locales y la sesión**.
- [ ] Probar con "instalar apps desconocidas" desactivado → abre Ajustes y el reintento funciona.
- [ ] Publicar 1.0.2 → verificar que **esta sí** es silenciosa (la primera nunca lo es, §5.1).
- [ ] Bajar `min_version` → el aviso deja de aparecer.
- [ ] Verificar que la PWA no muestra nunca el sheet de APK.
