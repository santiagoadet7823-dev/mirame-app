#!/usr/bin/env bash
# Crea el repo `mirame-app`, carga los secrets y activa GitHub Pages.
#
#   bash android/scripts/setup-github.sh
#
# Se corre UNA sola vez. Es idempotente: si algo ya existe, lo saltea.
#
# Por que es un script y no lo hizo Claude: crear un repositorio publico y
# subir secrets son acciones hacia afuera, a nombre del usuario. Quedan a la
# vista y bajo su control.
set -euo pipefail

RAIZ="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$RAIZ"

REPO=mirame-app
DUENIO="$(gh api user --jq .login)"
echo "Cuenta de GitHub: $DUENIO"

# ── 1. El repositorio ──────────────────────────────────────────────────────
if gh repo view "$DUENIO/$REPO" >/dev/null 2>&1; then
  echo "→ El repo ya existe, se saltea."
  git remote get-url origin >/dev/null 2>&1 || \
    git remote add origin "https://github.com/$DUENIO/$REPO.git"
else
  echo "→ Creando $DUENIO/$REPO (publico)..."
  gh repo create "$REPO" --public --source=. --remote=origin \
    --description "Mirame Lash Studio — gestion de salon de belleza. Flutter (APK Android + PWA) con backend Supabase multi-tenant."
fi

# ── 2. Ultima red de seguridad antes de publicar ───────────────────────────
# Es un repo PUBLICO. Si algo con credenciales quedo trackeado, este es el
# ultimo momento en que todavia es privado.
echo "→ Revisando que no haya secretos trackeados..."
if git ls-files | grep -iE 'key\.properties|\.keystore$|\.jks$|env\.json|google-services\.json|^planes/'; then
  echo "ABORTADO: los archivos de arriba tienen credenciales y estan trackeados."
  exit 1
fi
echo "  limpio."

git push -u origin main

# ── 3. Secrets ─────────────────────────────────────────────────────────────
# El keystore viaja en base64 porque los secrets de GitHub son texto.
echo "→ Cargando secrets..."
KS="$RAIZ/app_flutter/android/mirame.keystore"
KP="$RAIZ/app_flutter/android/key.properties"
[ -f "$KS" ] || { echo "Falta $KS"; exit 1; }

base64 -w0 "$KS" | gh secret set KEYSTORE_BASE64 --repo "$DUENIO/$REPO"
grep '^storePassword=' "$KP" | cut -d= -f2- \
  | tr -d '\r\n' | gh secret set KEYSTORE_PASSWORD --repo "$DUENIO/$REPO"

python - "$RAIZ/app_flutter/env.json" <<'PY' > /tmp/mirame-env.sh
import json, sys, shlex
d = json.load(open(sys.argv[1], encoding='utf-8'))
clave = d.get('SUPABASE_PUBLISHABLE_KEY') or d.get('SUPABASE_ANON_KEY', '')
print('SUPABASE_URL=' + shlex.quote(d.get('SUPABASE_URL', '')))
print('SUPABASE_PUBLISHABLE_KEY=' + shlex.quote(clave))
PY
. /tmp/mirame-env.sh
rm -f /tmp/mirame-env.sh

printf '%s' "$SUPABASE_URL"             | gh secret set SUPABASE_URL --repo "$DUENIO/$REPO"
printf '%s' "$SUPABASE_PUBLISHABLE_KEY" | gh secret set SUPABASE_PUBLISHABLE_KEY --repo "$DUENIO/$REPO"

# ── 4. GitHub Pages ────────────────────────────────────────────────────────
echo "→ Activando GitHub Pages (build_type: workflow)..."
gh api -X POST "repos/$DUENIO/$REPO/pages" \
  -f "build_type=workflow" >/dev/null 2>&1 \
  || gh api -X PUT "repos/$DUENIO/$REPO/pages" -f "build_type=workflow" >/dev/null 2>&1 \
  || echo "  (ya estaba activo, o hay que activarlo a mano en Settings > Pages)"

cat <<FIN

════════════════════════════════════════════════════════════════════
Listo.

  PWA        https://$DUENIO.github.io/mirame-app/
  Descargar  https://$DUENIO.github.io/mirame-app/descargar.html
  Acciones   https://github.com/$DUENIO/$REPO/actions

La PWA tarda unos 3-4 minutos en compilar y publicarse.

FALTA UN PASO MANUAL, en Supabase > Authentication > URL Configuration:
agregar a Redirect URLs
    https://$DUENIO.github.io/mirame-app/
y en Google Cloud Console > el OAuth client > Authorized JavaScript origins
    https://$DUENIO.github.io
Sin eso, el login de la PWA falla con redirect_uri_mismatch.

OPCIONAL — para que el APK se publique y avise a la flota sin tocar nada:
    gh secret set SUPABASE_SERVICE_ROLE_KEY --repo $DUENIO/$REPO
(la clave esta en Supabase > Settings > API > service_role. Es una clave que
salta todas las RLS: solo va como secret, nunca en el codigo.)

Para publicar la primera version:
    git tag apk-1.0.2 && git push origin apk-1.0.2
════════════════════════════════════════════════════════════════════
FIN
