# 07 · Doble target: PWA y APK

Un solo código Flutter, dos artefactos. La PWA se actualiza al instante; el APK usa el auto-updater
(`08-AUTOUPDATE-APK.md`).

---

## 1. Fase 0 — Toolchain

**Estado al 2026-08-23: ✅ resuelto.** `flutter doctor` da Android en verde.

- **Flutter 3.47.0 / Dart 3.13.0** en `C:\src\flutter`. Sigue **fuera del PATH**: hay que
  invocarlo por ruta completa (`/c/src/flutter/bin/flutter.bat`). No es un problema real.
- **Android SDK 36.1.0** en `%LOCALAPPDATA%\Android\Sdk`, build-tools 36.1.0, licencias aceptadas.
- **JDK: no hizo falta instalar nada.** El JDK del sistema es el 25, que Gradle no soporta, pero
  Flutter usa por su cuenta el **JDK 21 que viene con Android Studio**
  (`C:\Program Files\Android\Android Studio1\jbr`). Si alguna vez aparece
  `Unsupported class file major version`, es que dejó de encontrarlo: se fija con
  `flutter config --jdk-dir`.
- Chrome no está instalado (el usuario usa **Edge**); para probar la PWA:
  `flutter run -d edge` o `-d web-server`.
- Visual Studio no está: solo bloquea el target Windows desktop, que no se usa.
- `gh` CLI: instalado y autenticado como `santiagoadet7823-dev`. `git`: instalado.

Aviso menor de `flutter doctor`: hay **dos `adb.exe`** (el del SDK y el que trae scrcpy por
WinGet). Puede confundir la detección de dispositivos; si `flutter devices` no ve el teléfono,
es el primer sospechoso.

Pasos:

1. Instalar el Flutter SDK estable y agregarlo al PATH.
2. Instalar **JDK 17 o 21**. No hace falta desinstalar el 25: se le indica a Gradle cuál usar.
   ```bash
   flutter config --jdk-dir "C:/Program Files/Eclipse Adoptium/jdk-21..."
   ```
   O bien `-Dorg.gradle.java.home="…"` en cada build, que es lo que hace la-union-app.
   Si aparece `Unsupported class file major version`, es exactamente este problema.
3. Android SDK + platform-tools (Android Studio o command-line tools).
4. `flutter doctor -v` — tiene que salir limpio para **Android** y **Web**.
5. Crear el proyecto (ya hecho):
   ```bash
   flutter create app_flutter --org com.mirame --platforms android,web --project-name mirame
   ```

---

## 1b. Firma del APK

**El keystore es punto único de falla.** Si se pierde, ningún APK futuro se instala como
actualización sobre los ya instalados: la única salida es que cada usuario desinstale, perdiendo
sus datos locales. Por eso se genera una sola vez y se respalda en tres lugares.

Generado el 2026-08-23 en `app_flutter/android/mirame.keystore`:

| | |
|---|---|
| Formato | PKCS12 (no JKS: `keytool` lo marca como formato propietario) |
| Algoritmo | RSA 2048, SHA384withRSA |
| Alias | `mirame` |
| Validez | 10 950 días (~30 años) |
| SHA-256 | `D5:8C:88:FA:9E:F0:35:55:2F:77:1F:D1:F1:85:3C:B8:74:B9:1B:DE:9D:3F:19:F3:B5:5B:8A:12:DF:93:39:DE` |

La contraseña está en `app_flutter/android/key.properties`. **Los dos archivos están en
`.gitignore`** (`key.properties`, `*.keystore`, `*.jks`).

Gradle lee `key.properties` si existe; si no está, el build de release **no falla**: cae a la firma
de debug. Es a propósito, para que un clone recién hecho pueda correr `flutter run --release` —
pero significa que hay que **verificar con qué clave quedó firmado** antes de repartir un APK.
`scripts/build-apk.sh` lo imprime al terminar.

Para CI: subir el keystore como secret en base64
(`base64 -w0 mirame.keystore`) y reconstruirlo en un step del workflow.

---

## 2. PWA

```bash
flutter build web --release \
  --dart-define=SUPABASE_URL=… --dart-define=SUPABASE_ANON_KEY=… \
  --base-href /mirame-app/
```

- `--base-href` tiene que coincidir con el nombre del repo en GitHub Pages, o los assets dan 404.
- **Renderer**: `canvaskit` da fidelidad tipográfica exacta (importante acá: hay que replicar
  Cormorant Garamond al pixel), a costa de ~1.5 MB de descarga inicial. El renderer HTML pesa menos
  pero difiere en el renderizado de texto. **Se elige canvaskit**, y se cachea agresivamente en el
  service worker para que el peso se pague una sola vez.
- Flutter genera su propio `flutter_service_worker.js`. Alcanza para el shell offline; los datos ya
  los cubre Drift.
- El manifest se edita en `web/manifest.json`: `display: standalone`, `orientation: portrait`,
  `theme_color: #faf8f5`, `background_color: #ffffff` — mismos valores que el manifest inline del
  legacy.

### Workflow `.github/workflows/pwa.yml`

Calcado del `deploy.yml` de la-union-app, con Flutter en vez de Node:

```yaml
name: Deploy PWA to GitHub Pages
on:
  push: { branches: [main] }
  workflow_dispatch:
permissions: { contents: read, pages: write, id-token: write }
concurrency: { group: pages, cancel-in-progress: true }

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with: { channel: stable, cache: true }
      - run: flutter pub get
        working-directory: app_flutter
      - run: |
          flutter build web --release \
            --dart-define=SUPABASE_URL=${{ secrets.SUPABASE_URL }} \
            --dart-define=SUPABASE_ANON_KEY=${{ secrets.SUPABASE_ANON_KEY }} \
            --base-href /mirame-app/
        working-directory: app_flutter
      - uses: actions/configure-pages@v5
      - uses: actions/upload-pages-artifact@v3
        with: { path: app_flutter/build/web }

  deploy:
    needs: build
    runs-on: ubuntu-latest
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    steps:
      - id: deployment
        uses: actions/deploy-pages@v4
```

---

## 3. APK

```bash
flutter build apk --release --split-per-abi \
  --dart-define=SUPABASE_URL=… --dart-define=SUPABASE_ANON_KEY=…
```

`--split-per-abi` genera un APK por arquitectura (unos 8 MB cada uno en vez de ~20 MB del
universal). Para distribución fuera de Play Store hay que elegir: **se publica el
`app-arm64-v8a-release.apk`** renombrado a `app-release.apk`, que cubre prácticamente todos los
teléfonos Android desde 2017. Si aparece un dispositivo viejo, se publica también el `armeabi-v7a`.

> Alternativa más simple si aparecen problemas de compatibilidad: build universal (sin
> `--split-per-abi`). Pesa el doble pero funciona en todo. Es una decisión de "cuando duela".

### Firma — `android/app/build.gradle`

```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    namespace "com.mirame.app"
    defaultConfig {
        applicationId "com.mirame.app"
        minSdk 24          // Android 7. Cubre el parque real sin arrastrar APIs muertas
        targetSdk 35
        // versionCode y versionName salen de pubspec.yaml (version: 1.0.1+2)
    }
    signingConfigs {
        release {
            storeFile file(keystoreProperties['storeFile'])
            storePassword keystoreProperties['storePassword']
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
        }
    }
    buildTypes {
        release { signingConfig signingConfigs.release }
        debug   { applicationIdSuffix ".debug" }
    }
}
```

`key.properties` y el `.keystore` **nunca** entran al repo.

### Workflow `.github/workflows/apk.yml`

Esto es lo que **la-union-app no tiene** (allá el APK se compila a mano en la PC). Se construye acá:

```yaml
name: Build & release APK
on:
  push: { tags: ['apk-*'] }
  workflow_dispatch:
    inputs:
      version: { description: 'Versión (ej. 1.0.1)', required: true }

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-java@v4
        with: { distribution: temurin, java-version: '17' }
      - uses: subosito/flutter-action@v2
        with: { channel: stable, cache: true }

      - name: Restaurar keystore
        working-directory: app_flutter/android
        run: |
          echo "${{ secrets.KEYSTORE_BASE64 }}" | base64 -d > app/mirame.keystore
          cat > key.properties <<EOF
          storeFile=mirame.keystore
          storePassword=${{ secrets.KEYSTORE_PASSWORD }}
          keyAlias=${{ secrets.KEY_ALIAS }}
          keyPassword=${{ secrets.KEY_PASSWORD }}
          EOF

      - run: flutter pub get
        working-directory: app_flutter
      - run: |
          flutter build apk --release --split-per-abi \
            --dart-define=SUPABASE_URL=${{ secrets.SUPABASE_URL }} \
            --dart-define=SUPABASE_ANON_KEY=${{ secrets.SUPABASE_ANON_KEY }}
        working-directory: app_flutter

      - name: Publicar release
        run: |
          VER="${GITHUB_REF_NAME#apk-}"
          cp app_flutter/build/app/outputs/flutter-apk/app-arm64-v8a-release.apk app-release.apk
          gh release create "apk-$VER" app-release.apk \
            --title "APK $VER" --notes "Actualización nativa $VER" \
            || gh release upload "apk-$VER" app-release.apk --clobber
        env: { GH_TOKEN: '${{ github.token }}' }

      # Cierra el último paso manual que quedaba en el pipeline de DisT-At
      - name: Activar la actualización en Supabase
        run: |
          VER="${GITHUB_REF_NAME#apk-}"
          URL="https://github.com/${{ github.repository }}/releases/download/apk-$VER/app-release.apk"
          curl -sS -X PATCH \
            "${{ secrets.SUPABASE_URL }}/rest/v1/app_config?id=eq.true" \
            -H "apikey: ${{ secrets.SUPABASE_SERVICE_ROLE }}" \
            -H "Authorization: Bearer ${{ secrets.SUPABASE_SERVICE_ROLE }}" \
            -H "Content-Type: application/json" \
            -d "{\"latest_version\":\"$VER\",\"min_version\":\"$VER\",\"apk_url\":\"$URL\"}"
```

> **Ojo con el último paso:** actualizar `min_version` automáticamente hace que la flota vea el
> aviso apenas termina el workflow, sin que nadie haya probado el APK. Si se prefiere probar
> primero, sacar `min_version` de ese `PATCH` (dejando solo `latest_version` y `apk_url`) y subirlo
> a mano cuando el APK esté verificado. **Recomendado hasta que el pipeline tenga rodaje.**

---

## 4. Secrets de GitHub necesarios

| Secret | Qué es |
|---|---|
| `SUPABASE_URL` | URL del proyecto |
| `SUPABASE_ANON_KEY` | Anon key (pública por diseño, igual va como secret para no publicarla en el YAML) |
| `SUPABASE_SERVICE_ROLE` | **Sensible.** Solo para el paso de `app_config`. Nunca en el cliente |
| `KEYSTORE_BASE64` | El `.keystore` en base64 (`base64 -w0 mirame.keystore`) |
| `KEYSTORE_PASSWORD` | |
| `KEY_ALIAS` | |
| `KEY_PASSWORD` | |

---

## 5. Repositorio

Se crea **`santiagoadet7823-dev/mirame-app`**, público — GitHub Pages y Releases son gratis en
repos públicos, y no hay nada secreto en el código (la anon key es pública por diseño; el keystore
y la service-role key viven en secrets).

El repo actual `mirame-lash-studio` se conserva **como archivo histórico** de la versión HTML. No
se borra: es la referencia de la estética y de las reglas de negocio.

### `.gitignore` — lo mínimo

```gitignore
# Bitácora de planificación: local, nunca al repo
planes/

# Firma
*.keystore
*.jks
key.properties
android/key.properties

# Config con valores
env.json
.env
.env.*
app_flutter/android/app/google-services.json

# Flutter
build/
.dart_tool/
.flutter-plugins*
*.iml
```

Verificar **antes del primer push**:

```bash
git check-ignore -v planes/ && echo "OK: planes/ está ignorado"
```

---

## 6. Qué elegir para cada usuario

| Perfil | Recomendación |
|---|---|
| Dueña del salón, dispositivo principal | **APK** — push confiable, funciona sin abrir el navegador |
| Profesional que consulta la agenda | **PWA** — se actualiza sola, cero instalación |
| Superadmin / revendedor en escritorio | **PWA** — el modo desktop del diseño ya está pensado para esto |
| Prueba o demo a un cliente nuevo | **PWA** — se comparte un link y listo |

Vale la pena decirlo en la comunicación: la PWA no es la versión "de segunda". Es la que se
actualiza al instante.

---

## 6. Instalar el APK en un teléfono para probar

Dos caminos. El primero es el que conviene.

### a) Por cable (`adb install`)

```bash
# En el teléfono: Ajustes > Acerca del teléfono > tocar 7 veces "Número de compilación"
# para habilitar Opciones de desarrollador, y ahí activar "Depuración por USB".
"$LOCALAPPDATA/Android/Sdk/platform-tools/adb.exe" devices          # tiene que listar el equipo
"$LOCALAPPDATA/Android/Sdk/platform-tools/adb.exe" install -r \
  app_flutter/build/app/outputs/flutter-apk/app-release.apk
```

Usar **la ruta completa al `adb` del SDK**: hay un segundo `adb.exe` en el paquete de scrcpy
instalado por WinGet, y si el PATH resuelve al otro, `devices` puede salir vacío.

### b) Copiando el archivo

Pasar el `.apk` por cable, Drive o WhatsApp y abrirlo desde el teléfono. Android va a pedir
habilitar **"Instalar apps desconocidas"** para la app desde la que se abre.

> Efecto colateral a tener presente para la Fase 8: un APK instalado así **no tiene instalador de
> registro**, y el modo silencioso del auto-updater exige que la app sea su propio instalador. En
> la práctica: la primera actualización va a pedir confirmación igual; de la segunda en adelante,
> no. No es un bug.

### Qué se puede probar hoy

Splash → login con Google → panel. Las pantallas de negocio todavía son andamios (Fases 5 y 6).
Lo que interesa verificar en el dispositivo, porque **ningún test lo cubre**:

1. El ícono y el nombre "Mírame" en el launcher.
2. Que el botón de Google abra el navegador y **vuelva a la app** con la sesión (el deep link).
3. Que al cerrar y reabrir la app la sesión siga puesta.
4. Modo avión: hoy todavía **no** entra sin red — el `SessionController` tiene el TODO de leer el
   cache local pendiente para la Fase 3. Que falle ahí es lo esperado, no un hallazgo.


---

## 7. Trampas del primer build (ya pagadas)

Las tres cosas que rompieron el primer APK, en orden de aparición:

1. **`--` en un comentario XML.** `<!-- el token --bg ... -->` es XML inválido y `aapt` lo rechaza
   en `:app:packageReleaseResources`, que corre **al final**. Costó un build completo de 2 h.
   Validar los XML con un parser, no a ojo:
   ```bash
   python -c "import xml.dom.minidom,glob;[xml.dom.minidom.parse(f) for f in glob.glob('**/*.xml',recursive=True)]"
   ```
2. **`flutter_local_notifications` exige core library desugaring.** Usa `java.time`, que no existe
   en las versiones de Android que cubre el `minSdk`. Falla en `:app:checkReleaseAarMetadata`, sin
   tocar código. Se arregla con `isCoreLibraryDesugaringEnabled = true` más
   `coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")`.
3. **`CupertinoIcons` sin paquete.** Algún plugin lo referencia. Solo es un warning, pero aparece
   en cada build. Se agregó `cupertino_icons`; el tree-shaking lo deja en 848 bytes.

**Tiempos reales en esta máquina** (Windows, con Defender activo): primer build **2 h** (incluye
bajar ~7 GB de dependencias de Gradle y 62 MB de Android SDK Platform 35 rev 2, que algún plugin
pide aunque estén instalados el 35 rev 1 y el 36). Segundo build: **10 min**. Incrementales
posteriores: minutos.

## 8. APK 1.0.0 — verificado

```
package        com.mirame.app
versionName    1.0.0        versionCode 1
label          Mírame
targetSdk      36           compileSdk 36
ABIs           arm64-v8a, armeabi-v7a, x86_64   (universal, sin --split-per-abi)
tamaño         62 MB
firma V2       CN=Mirame Lash Studio
SHA-256        d58c88fa9ef035552f771fd1f1853cb874b91bde9d3f19f3b55b8a12df9339de
deep link      com.mirame.app://auth  ✅ presente en el manifest empaquetado
```

El SHA-256 de la firma coincide con el del keystore de §1b: el APK **no** salió firmado con la
clave de debug. Verificarlo siempre antes de repartir:

```bash
"$LOCALAPPDATA/Android/Sdk/build-tools/36.1.0/apksigner.bat" verify --print-certs   app_flutter/build/app/outputs/flutter-apk/app-release.apk
```
