#!/usr/bin/env bash
# Sube la version y deja todo listo para publicar.
#
#   bash android/scripts/bump-version.sh 1.0.3
#
# En Flutter versionName y versionCode salen los DOS de pubspec.yaml, asi que
# no existe la desincronizacion entre tres archivos que hay en proyectos
# Capacitor. El versionCode (lo que va despues del +) sube en 1 y NUNCA baja:
# Android rechaza instalar uno menor y eso deja la flota trabada sin arreglo
# remoto posible.
set -euo pipefail

NUEVA="${1:-}"
[[ "$NUEVA" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || {
  echo "Uso: bump-version.sh X.Y.Z"; exit 1; }

PUB="$(cd "$(dirname "${BASH_SOURCE[0]}")/../app_flutter" && pwd)/pubspec.yaml"
ACTUAL=$(grep '^version:' "$PUB" | sed 's/version: *//')
VIEJA="${ACTUAL%%+*}"
CODE="${ACTUAL##*+}"

# Comparacion numerica por segmento: como string, 1.5.9 saldria mayor que
# 1.5.42 y se podria bajar la version sin darse cuenta.
mayor() { [ "$(printf '%s\n%s\n' "$1" "$2" | sort -V | tail -1)" = "$1" ] && [ "$1" != "$2" ]; }
mayor "$NUEVA" "$VIEJA" || { echo "ERROR: $NUEVA no es posterior a $VIEJA"; exit 1; }

sed -i "s/^version: .*/version: $NUEVA+$((CODE + 1))/" "$PUB"
echo "$VIEJA+$CODE  →  $NUEVA+$((CODE + 1))"
cat <<FIN

Ahora:
  git commit -am "build: sube a $NUEVA"
  git push
  git tag apk-$NUEVA && git push origin apk-$NUEVA

El tag dispara el workflow: compila, firma, verifica la firma, publica el
release y actualiza app_config. La PWA ya se publico sola con el push.
FIN
