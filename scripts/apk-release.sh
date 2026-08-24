#!/usr/bin/env bash
# ============================================================================
# Publica un APK ya compilado en un GitHub Release e imprime la URL + el SQL
# para activar la actualización en los teléfonos.
#
# Este es el camino MANUAL (respaldo). El camino normal es empujar un tag
# `apk-<ver>` y dejar que .github/workflows/apk.yml haga todo. Usá este script
# cuando quieras probar una versión antes de publicarla, o si CI está caído.
#
# Portado de scripts/apk-release.sh de la-union-app, que lleva ~20 releases.
#
# Requisitos: gh (GitHub CLI) logueado + el APK ya compilado y FIRMADO:
#   cd app_flutter && flutter build apk --release --split-per-abi \
#     --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
#
# Uso:  bash scripts/apk-release.sh 1.0.1
# ============================================================================
set -euo pipefail

VER="${1:-}"
if [ -z "$VER" ]; then
  echo "Uso: bash scripts/apk-release.sh <version>   (ej: 1.0.1)"
  exit 1
fi

REPO="santiagoadet7823-dev/mirame-app"
TAG="apk-$VER"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT="$ROOT/app_flutter/build/app/outputs/flutter-apk"

# arm64-v8a cubre prácticamente todo el parque Android desde 2017.
# Si aparece un dispositivo viejo, publicar también armeabi-v7a.
SRC="$OUT/app-arm64-v8a-release.apk"
[ -f "$SRC" ] || SRC="$OUT/app-release.apk"

if [ ! -f "$SRC" ]; then
  echo "✗ No encuentro el APK firmado. Busqué en:"
  echo "    $OUT/app-arm64-v8a-release.apk"
  echo "    $OUT/app-release.apk"
  echo "  Compilalo primero (ver el encabezado de este script)."
  exit 1
fi

# El asset del release SIEMPRE se llama app-release.apk: la URL tiene que ser
# predecible para que apk_url se pueda armar sin consultar la API de GitHub.
TMP="$(mktemp -d)"
cp "$SRC" "$TMP/app-release.apk"

echo "→ Publicando $TAG en $REPO…"
if gh release create "$TAG" "$TMP/app-release.apk" --repo "$REPO" \
     --title "APK $VER" --notes "Actualización nativa $VER" 2>/dev/null; then
  :
else
  gh release upload "$TAG" "$TMP/app-release.apk" --repo "$REPO" --clobber
fi
rm -rf "$TMP"

URL="https://github.com/$REPO/releases/download/$TAG/app-release.apk"

cat <<EOF

✅ APK publicado:
   $URL

ÚLTIMO PASO — pegá esto en el SQL Editor de Supabase para avisar a los teléfonos:

   update public.app_config
   set latest_version = '$VER',
       min_version    = '$VER',
       apk_url        = '$URL',
       updated_at     = now();

IMPORTANTE
 · 'min_version' es el PISO: los equipos con versión menor a $VER verán el aviso.
 · Publicar el release NO molesta a nadie. Subir min_version SÍ. Probá el APK en
   un teléfono real antes de correr ese update.
 · Para publicar sin forzar, actualizá solo latest_version y apk_url.
 · El .apk debe estar firmado con el MISMO keystore que el instalado, o Android
   rechaza la actualización con "App no instalada".
EOF
