#!/usr/bin/env bash
# ============================================================================
# Sube la versión del proyecto en un solo lugar.
#
# En Flutter, `version: X.Y.Z+N` de pubspec.yaml genera tanto el versionName
# como el versionCode del APK. Eso elimina la desincronización de tres archivos
# que sufre el pipeline de Capacitor (ver 08-AUTOUPDATE-APK.md §4).
#
# El versionCode (el número después del +) SIEMPRE sube en 1 y NUNCA baja:
# Android rechaza instalar un versionCode menor, y eso deja a la flota trabada
# sin arreglo remoto.
#
# Uso:  bash scripts/bump-version.sh 1.0.1
# ============================================================================
set -euo pipefail

VER="${1:-}"
if [ -z "$VER" ]; then
  echo "Uso: bash scripts/bump-version.sh <version>   (ej: 1.0.1)"
  exit 1
fi

if ! echo "$VER" | grep -qE '^[0-9]+\.[0-9]+\.[0-9]+$'; then
  echo "✗ La versión debe ser semántica X.Y.Z (recibí: $VER)"
  exit 1
fi

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PUBSPEC="$ROOT/app_flutter/pubspec.yaml"

if [ ! -f "$PUBSPEC" ]; then
  echo "✗ No encuentro $PUBSPEC"
  echo "  ¿Ya corriste la Fase 0 (flutter create app_flutter)?"
  exit 1
fi

ACTUAL=$(grep -E '^version:' "$PUBSPEC" | head -1 | sed 's/version: *//')
CODE_ACTUAL=$(echo "$ACTUAL" | cut -d+ -f2)
CODE_NUEVO=$((CODE_ACTUAL + 1))

echo "  actual : $ACTUAL"
echo "  nueva  : $VER+$CODE_NUEVO"
echo ""

# sed -i con sufijo vacío para que funcione igual en Git Bash y en Linux
sed -i.bak -E "s/^version: .*/version: $VER+$CODE_NUEVO/" "$PUBSPEC"
rm -f "$PUBSPEC.bak"

echo "✅ pubspec.yaml actualizado."
echo ""
echo "Próximos pasos:"
echo "  git commit -am \"chore(release): version $VER\""
echo "  git tag apk-$VER"
echo "  git push origin main --tags"
echo ""
echo "El workflow apk.yml compila, firma, publica el release y actualiza app_config."
