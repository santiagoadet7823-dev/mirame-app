#!/usr/bin/env bash
# Compila el APK de release firmado.
#
#   bash android/scripts/build-apk.sh            # un APK universal
#   bash android/scripts/build-apk.sh --split    # uno por ABI (mas chico)
#
# Requiere android/app_flutter/env.json y android/app_flutter/android/key.properties
# (los dos estan en .gitignore). Sin key.properties el build NO falla: cae a la
# firma de debug, y ese APK no sirve como actualizacion de uno firmado de
# verdad. Por eso se avisa fuerte.
set -euo pipefail

FLUTTER="${FLUTTER:-/c/src/flutter/bin/flutter.bat}"
APP="$(cd "$(dirname "${BASH_SOURCE[0]}")/../app_flutter" && pwd)"
cd "$APP"

[[ -f env.json ]] || { echo "ERROR: falta env.json"; exit 1; }
if [[ ! -f android/key.properties ]]; then
  echo "AVISO: falta android/key.properties — el APK saldra firmado con la"
  echo "clave de DEBUG y no se podra instalar encima de uno de release."
fi

ARGS=(build apk --release --dart-define-from-file=env.json)
[[ "${1:-}" == "--split" ]] && ARGS+=(--split-per-abi)

"$FLUTTER" "${ARGS[@]}"

echo
echo "Artefactos:"
ls -lh build/app/outputs/flutter-apk/*.apk

# Verificacion que se saltea siempre y siempre duele: confirmar CON QUE clave
# quedo firmado antes de repartirlo.
APKSIGNER=$(ls "$ANDROID_HOME"/build-tools/*/apksigner.bat 2>/dev/null | tail -1 || true)
if [[ -n "$APKSIGNER" ]]; then
  echo
  echo "Firma:"
  "$APKSIGNER" verify --print-certs \
    build/app/outputs/flutter-apk/app-release.apk 2>/dev/null | grep -i "SHA-256" || true
fi
