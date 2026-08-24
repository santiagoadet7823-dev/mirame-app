---
name: mirame-release
description: Publicar una versión de Mírame — PWA a GitHub Pages y APK a GitHub Releases con auto-actualización. Usar cuando haya que sacar una versión nueva, hacer rollback, tocar app_config, el keystore, el versionado o los workflows de CI.
---

# Publicar una versión de Mírame

Documento completo: `android/07-PWA-Y-APK.md` y `android/08-AUTOUPDATE-APK.md`.

## Dos canales

| Cambio | Canal | Cómo llega |
|---|---|---|
| Cualquier cosa, usuarios de la **PWA** | GitHub Pages | Instantáneo: push a `main` |
| Cualquier cosa, usuarios del **APK** | Release + auto-updater | Tag `apk-<ver>` |
| Solo datos o configuración | `app_config` / Supabase | Instantáneo, sin release |

**Flutter no tiene canal OTA.** Google prohíbe descargar código Dart ejecutable. Todo cambio de
código para el APK implica un APK nuevo.

## Sacar una versión

```bash
bash scripts/bump-version.sh 1.0.1
git commit -am "chore(release): version 1.0.1"
git tag apk-1.0.1
git push origin main --tags
```

El workflow `apk.yml` compila firmado, publica el release y actualiza `app_config`.
El workflow `pwa.yml` se dispara con el push a `main`.

Respaldo manual: `flutter build apk --release` y después `bash scripts/apk-release.sh 1.0.1`.

## `min_version` es un PISO, no "la última"

Los teléfonos con versión **menor** ven el aviso. Se pone en la versión del APK que trae el cambio
que hay que forzar.

**Publicar el release no molesta a nadie. Subir `min_version` sí.** Probá el APK en un teléfono
real antes de tocarlo. Para publicar sin forzar, actualizá solo `latest_version` y `apk_url`.

## Rollback

- **Nadie lo instaló todavía:** bajar `min_version`. El aviso desaparece.
- **Ya se instaló:** publicar una versión **más nueva** con el arreglo. Android no instala un
  `versionCode` menor. No hay downgrade remoto.

## Versionado

Todo sale de una línea de `pubspec.yaml`:

```yaml
version: 1.0.1+2     # versionName=1.0.1  versionCode=2
```

**El `versionCode` nunca baja.** Un error acá deja a la flota trabada sin arreglo remoto.

## El keystore

Punto único de falla. Si se pierde el archivo **o** las contraseñas, ningún APK nuevo se instala
como actualización, y la única salida es que cada usuario desinstale — perdiendo los datos locales
y los cambios sin sincronizar.

Backup en gestor de contraseñas + 2 lugares privados. Nunca en el repo.

## Cosas que ya se pagaron caro (en DisT-At)

| Síntoma | Causa |
|---|---|
| "App no instalada" / conflicto de paquete | Firmado con otra llave. Sin arreglo remoto |
| No aparece el aviso | `min_version` menor o igual a la instalada, o `apk_url` en null |
| El aviso aparece pero no descarga | URL mal, o el release es privado. Abrir la URL en un navegador para verificar |
| "Descarga vacía" | Faltó `setInstanceFollowRedirects(true)`: GitHub redirige a `objects.githubusercontent.com` |
| **La primera actualización pide confirmación** | **No es un bug.** El modo silencioso exige que la app sea su propio instalador de registro. Una app instalada por adb o a mano tiene ese campo en null. De la segunda en adelante es silenciosa |
| Assets 404 en la PWA | `--base-href` no coincide con el nombre del repo |

## Antes del primer release

- [ ] Keystore generado y respaldado en 3 lugares
- [ ] Secrets cargados en GitHub (7, ver `07-PWA-Y-APK.md` §4)
- [ ] `.gitignore` verificado con `git check-ignore` (keystore, `planes/`, `.env`)
- [ ] SHA-1 del keystore de release registrado en Google Cloud Console
- [ ] Prueba end-to-end de actualización en un teléfono real
