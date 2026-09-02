#!/usr/bin/env python3
"""Sube al bucket `productos` los recortes aprobados en la hoja de contactos.

    1. Abrir salida/revision.html, tildar las fotos que sirven.
    2. Apretar "Copiar codigos con foto aprobada" y pegar el texto en
       salida/fotos-aprobadas.txt (un codigo ARB-... por linea).
    3. SUPABASE_SERVICE_KEY=... python subir_fotos.py [--dry-run]

Necesita la service key porque la RLS de `producto_fotos` no le deja escribir
a `anon`, y el MCP de Supabase no expone Storage. La key NO se guarda en
disco: va por variable de entorno y `.env` esta en .gitignore.

Respeta la convencion de features/ropa/fotos.dart:
  ruta en el bucket -> {tenant_id}/{producto_id}/{archivo}
  producto_fotos.path -> la URL publica COMPLETA (asi estan las que ya hay)
"""

import io
import json
import os
import sys
import urllib.error
import urllib.request
from pathlib import Path

from PIL import Image

AQUI = Path(__file__).parent
SALIDA = AQUI / "salida"
APROBADAS = SALIDA / "fotos-aprobadas.txt"

URL = "https://hanljsmsgvezuhmehqla.supabase.co"
TENANT = "f287a618-934d-4877-be79-8f7d2e89d734"
BUCKET = "productos"

# El bucket acepta jpeg/png/webp y corta en 3 MB. WebP a 1200 px deja los
# recortes en decenas de KB, que es lo que sostiene el techo de 1 segundo de
# la vitrina.
LADO_MAX = 1200
CALIDAD = 82


def key():
    k = os.environ.get("SUPABASE_SERVICE_KEY", "").strip()
    if not k:
        sys.exit("falta SUPABASE_SERVICE_KEY en el entorno")
    return k


def pedir(metodo, ruta, datos=None, tipo=None, k=None):
    req = urllib.request.Request(URL + ruta, data=datos, method=metodo)
    req.add_header("apikey", k)
    req.add_header("Authorization", "Bearer " + k)
    if tipo:
        req.add_header("Content-Type", tipo)
    try:
        with urllib.request.urlopen(req, timeout=60) as r:
            cuerpo = r.read().decode("utf-8", "replace")
            return r.status, cuerpo
    except urllib.error.HTTPError as e:
        return e.code, e.read().decode("utf-8", "replace")


def a_webp(png):
    """PNG del recorte -> WebP redimensionado. PyMuPDF no exporta WebP."""
    img = Image.open(png).convert("RGB")
    img.thumbnail((LADO_MAX, LADO_MAX), Image.LANCZOS)
    buf = io.BytesIO()
    img.save(buf, "WEBP", quality=CALIDAD, method=6)
    return buf.getvalue()


def main():
    seco = "--dry-run" in sys.argv
    if not APROBADAS.exists():
        sys.exit(f"falta {APROBADAS} -- ver el paso 2 del encabezado")

    codigos = [l.strip() for l in APROBADAS.read_text(encoding="utf-8").splitlines()
               if l.strip() and not l.startswith("#")]
    if not codigos:
        sys.exit("la lista de aprobadas esta vacia")

    k = key()
    subidas = omitidas = fallidas = 0

    for codigo in codigos:
        png = SALIDA / "recortes" / f"{codigo}.png"
        if not png.exists():
            print(f"  SIN RECORTE  {codigo}")
            fallidas += 1
            continue

        est, cuerpo = pedir("GET", f"/rest/v1/productos?codigo=eq.{codigo}"
                                   f"&tenant_id=eq.{TENANT}&deleted_at=is.null"
                                   f"&select=id", k=k)
        filas = json.loads(cuerpo) if est == 200 else []
        if not filas:
            print(f"  NO EXISTE    {codigo}")
            fallidas += 1
            continue
        pid = filas[0]["id"]

        # Ya tiene foto: no se pisa. La de ella vale mas que el recorte.
        est, cuerpo = pedir("GET", f"/rest/v1/producto_fotos?producto_id=eq.{pid}"
                                   f"&deleted_at=is.null&select=id", k=k)
        if est == 200 and json.loads(cuerpo):
            print(f"  YA TIENE     {codigo}")
            omitidas += 1
            continue

        datos = a_webp(png)
        nombre = f"{codigo.lower()}.webp"
        ruta = f"{TENANT}/{pid}/{nombre}"

        if seco:
            print(f"  (ensayo)     {codigo}  {len(datos) // 1024} KB -> {ruta}")
            subidas += 1
            continue

        est, cuerpo = pedir("POST", f"/storage/v1/object/{BUCKET}/{ruta}",
                            datos, "image/webp", k)
        if est not in (200, 201):
            print(f"  ERROR SUBIDA {codigo}: {est} {cuerpo[:120]}")
            fallidas += 1
            continue

        publica = f"{URL}/storage/v1/object/public/{BUCKET}/{ruta}"
        est, cuerpo = pedir(
            "POST", "/rest/v1/producto_fotos",
            json.dumps({"tenant_id": TENANT, "producto_id": pid,
                        "path": publica, "orden": 0}).encode(),
            "application/json", k)
        if est not in (200, 201, 204):
            print(f"  ERROR FILA   {codigo}: {est} {cuerpo[:120]}")
            fallidas += 1
            continue

        print(f"  OK           {codigo}  {len(datos) // 1024} KB")
        subidas += 1

    print(f"\nsubidas {subidas} · omitidas {omitidas} · fallidas {fallidas}")


if __name__ == "__main__":
    main()
