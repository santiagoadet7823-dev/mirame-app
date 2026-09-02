#!/usr/bin/env python3
"""Extrae el catalogo Arbell de un PDF y deja tres cosas para revisar a mano:

    catalogo.json   la estructura producto/variante que consume cargar.py
    revision.csv    una fila por codigo -- ESTE es el archivo que se corrige
    revision.html   hoja de contactos: recorte candidato + datos extraidos

El catalogo es una pieza editorial, no una lista de precios: hay paginas donde
el bloque de texto trae codigo y precio juntos, y paginas donde siete productos
comparten un "$3500 CADA UNA" suelto al pie. Por eso el parseo va en dos
pasadas y TODO lo que sale de la segunda queda marcado para revisar.

Uso:
    python extraer.py ../../../cat-4-2026.pdf
    python extraer.py <pdf> --solo-secciones    # verificar secciones.json
    python extraer.py <pdf> --sin-imagenes      # solo el texto, para iterar rapido
"""

import csv
import html
import json
import re
import sys
import unicodedata
from pathlib import Path

import fitz  # PyMuPDF

AQUI = Path(__file__).parent
SALIDA = AQUI / "salida"

# La barra de navegacion se repite identica en las 149 paginas y no aporta
# nada. Es texto, no imagen, asi que hay que filtrarla por contenido.
NAV = {
    "MAQUILLAJE", "CUIDADO", "FACIAL", "CORPORAL", "SUPLE-", "MENTOS",
    "JOYERIA", "FRAGANCIAS", "FEMENINAS", "MASCULINAS", "INSPIRACIONES",
    "NINOS", "NINEZ", "HOGAR", "OFERTAS", "ESPECIALES", "LANZA-", "MIENTOS",
    "QUIERO", "VENDER!", "LANZAMIENTOS",
}

# Los codigos de Arbell: 3154 (linea general), C905 (maquillaje),
# AC3027 (joyeria), VO70 (hogar), AX00465 (juguetes).
# Prefijados: C905, AC3027, AX00465, VO70, V046. Sueltos: SIEMPRE 4 digitos
# (1206, 3154, 9644). Aceptar 3 o 5 digitos sueltos metia "111" y "20000",
# que son una nota al pie y un precio sin signo.
CODIGO = re.compile(r"^(?:C|AC|AX|VO|V)\d{2,5}$|^\d{4}$")
ANIO = re.compile(r"^20[2-3]\d$")   # "2026" es la vigencia, no un producto
PRECIO = re.compile(r"^\$\s?([\d.]+)$")
PREG = re.compile(r"P\.?\s?REG\.?:?\s*\$\s?([\d.]+)", re.I)
PRESENTACION = re.compile(
    r"^\d+([,.]\d+)?\s*(ml|g|gr|grs|cc|c[aa]psulas?|caps|comprimidos|unidades|u)\.?$",
    re.I,
)
# Combos y regalos: el precio que muestran no es el de un codigo suelto.
# Se compara contra texto SIN TILDES (ver es_boiler): asi "LLEVA" agarra
# "LLEVA" y "LLEVA" con acento, sin pelear con la codificacion del archivo.
COMBO = re.compile(r"CODIGO\.?\s*\d{4}|COD\.?\s*\d{4}|2\s?X\s?1|3\s?X\s?2|"
                   r"GRATIS|LLEVA", re.I)

# Un codigo suelto acompanado de un texto corto es un tono, no un producto.
# "C905 Azul" es una variante; "AC3027 SET 4 COLLARES AMALFI" es un producto.
MAX_CHARS_TONO = 20
MAX_PALABRAS_TONO = 2

# En las grillas de tonos el codigo y el nombre del color son bloques
# SEPARADOS y girados ("C905" en uno, "Azul" en el de al lado). Se emparejan
# por cercania: el color esta pegado al codigo, el cuerpo de texto no.
RADIO_TONO = 45      # puntos
CUERPO_TONO = 13     # un color nunca viene en cuerpo grande

# Letra chica de campana. Ensucia todos los nombres si no se saca.
BOILERPLATE = re.compile(
    r"hasta\s+agotar\s+stock|precios?\s+sujetos?|reserve\s+su\s+pedido|"
    r"seg[uu]n\s+cat[aa]logo|algunas\s+unidades|cada\s+un[oa]|"
    r"el\s+precio\s+m[aa]s\s+bajo|imperdible|especial\s+lanzamiento|"
    r"^\d+\s*%|^off$|^gratis$|^nuevos?$|^tonos?$|^especial$|^lanzamiento$|"
    r"^beneficios$|^ver\s+oferta$|^combinal|^llev[aa]\b|"
    r"^p\.?\s?reg|^[.,;:*\-]+$",
    re.I)

# "E. SET 4 COLLARES AMALFI" -- la letra es el indice de la maqueta, no el nombre.
ENUMERADOR = re.compile(r"^[A-Z]\.\s+")

# El nombre entra en la tarjeta de la vitrina; lo que sobra va a descripcion.
MAX_NOMBRE = 60


def sin_tildes(t):
    return "".join(c for c in unicodedata.normalize("NFD", t)
                   if unicodedata.category(c) != "Mn")


def es_nav(t):
    return sin_tildes(t).upper().strip("!?") in NAV


def es_codigo(t):
    return bool(CODIGO.match(t)) and not ANIO.match(t)


def es_boiler(t):
    """Contra el texto sin tildes: el catalogo mezcla LLEVA/LLEVA, MAS/MAS."""
    return bool(BOILERPLATE.search(sin_tildes(t)))


def limpiar(t):
    # Vinetas y guiones de corte: son maqueta, no texto del producto.
    t = re.sub(r"^[•·\-–]+\s*", "", t.replace("­", ""))
    return re.sub(r"\s+", " ", t).strip()


def a_numero(s):
    """'11.990' y '11990' son el mismo precio: el punto es separador de miles."""
    return int(s.replace(".", ""))


def slug(t):
    t = sin_tildes(t).upper()
    t = re.sub(r"[^A-Z0-9]+", "-", t).strip("-")
    return t[:40] or "SIN-NOMBRE"


def cargar_secciones():
    d = json.loads((AQUI / "secciones.json").read_text(encoding="utf-8"))
    mapa = {}
    for r in d["rangos"]:
        for p in range(r["desde"], r["hasta"] + 1):
            mapa[p] = r["categoria"]
    return d, mapa


def leer_bloques(pagina):
    """Bloques de texto de la pagina, sin la navegacion, con bbox y cuerpo."""
    out = []
    for b in pagina.get_text("dict")["blocks"]:
        if b["type"] != 0:
            continue
        partes, cuerpo = [], 0.0
        for linea in b["lines"]:
            for s in linea["spans"]:
                t = limpiar(s["text"])
                if not t or es_nav(t):
                    continue
                partes.append(t)
                cuerpo = max(cuerpo, s["size"])
        if partes:
            out.append({"partes": partes, "bbox": b["bbox"], "cuerpo": cuerpo})
    return out


def precio_de_pagina(bloques):
    """El precio de oferta de la pagina es el '$N' de mayor cuerpo.

    Devuelve (precio, ambiguo). Ambiguo cuando hay dos precios grandes
    distintos compitiendo: ahi el parser no puede decidir, y lo dice.
    """
    grandes = []
    for b in bloques:
        for p in b["partes"]:
            m = PRECIO.match(p)
            if m:
                grandes.append((b["cuerpo"], a_numero(m.group(1))))
    if not grandes:
        return None, False
    tope = max(c for c, _ in grandes)
    cands = {v for c, v in grandes if c >= tope - 2}
    return max(cands), len(cands) > 1


def partir_bloque(partes):
    """Separa un bloque en codigos, nombre, presentacion y precios."""
    codigos, nombre, pres, precio, preg = [], [], None, None, None
    for p in partes:
        m = PREG.search(p)
        if m:
            preg = a_numero(m.group(1))
            # "P.REG.: $12900" puede venir pegado a otra cosa; lo saco y sigo.
            resto = limpiar(PREG.sub("", p))
            if not resto:
                continue
            p = resto
        if es_codigo(p):
            codigos.append(p)
            continue
        mp = PRECIO.match(p)
        if mp:
            v = a_numero(mp.group(1))
            if preg is None or v != preg:
                precio = v if precio is None else min(precio, v)
            continue
        if PRESENTACION.match(p):
            pres = p
            continue
        if es_boiler(p):
            continue
        nombre.append(p)
    return codigos, nombre, pres, precio, preg


def partir_nombre(partes):
    """Nombre corto para la tarjeta; el resto es descripcion.

    Los bloques de joyeria traen nombre y parrafo pegados
    ("SET 4 COLLARES AMALFI Set de Imitacion oro con..."). Cortar por largo
    y no por mayusculas: hay lineas donde el nombre es el texto en minuscula
    ("Hyaluronic") y la mayuscula es la promesa ("REGENERA").
    """
    limpias = [limpiar(ENUMERADOR.sub("", p)) for p in partes]
    # "E." suelto en su propio span: es el indice de la maqueta.
    limpias = [p for p in limpias if p and not re.fullmatch(r"[A-Z]\.", p)]
    nombre, resto, largo = [], [], 0
    for p in limpias:
        if nombre and largo + len(p) + 1 > MAX_NOMBRE:
            resto.append(p)
        else:
            nombre.append(p)
            largo += len(p) + 1
    return limpiar(" ".join(nombre)), limpiar(" ".join(resto)) or None


def centro(bbox):
    return ((bbox[0] + bbox[2]) / 2, (bbox[1] + bbox[3]) / 2)


def emparejar_tonos(code_blocks, bloques, usados):
    """Le pega a cada bloque-codigo el nombre de color que tiene al lado.

    En la grilla de esmaltes hay 25 codigos y 25 colores como bloques
    independientes, girados. La unica relacion que queda en el PDF es la
    distancia: "Azul" esta a 8 puntos de "C905" y a 60 del siguiente.
    """
    etiquetas = [
        b for b in bloques
        if id(b) not in usados and b["cuerpo"] <= CUERPO_TONO
        and not any(es_codigo(p) or PRECIO.match(p) or PREG.search(p)
                    or es_boiler(p) for p in b["partes"])
        and len(" ".join(b["partes"])) <= 22
        and len(" ".join(b["partes"]).split()) <= 2
    ]
    # Asignacion global por distancia creciente, no codigo por codigo. Con el
    # avance codigo por codigo el primero se lleva dos etiquetas ("Rosa Petalo"
    # + "Rosa Dior") y deja al vecino sin color.
    pares = []
    for cb in code_blocks:
        cx, cy = centro(cb["bbox"])
        for i, e in enumerate(etiquetas):
            ex, ey = centro(e["bbox"])
            dist = ((ex - cx) ** 2 + (ey - cy) ** 2) ** 0.5
            if dist <= RADIO_TONO:
                pares.append((dist, id(cb), i))
    pares.sort()

    tomadas, asignadas = set(), {}
    for dist, cid, i in pares:
        if i in tomadas or len(asignadas.get(cid, [])) >= 2:
            continue
        tomadas.add(i)
        asignadas.setdefault(cid, []).append(i)

    return {cid: limpiar(" ".join(" ".join(etiquetas[i]["partes"])
                                  for i in sorted(idx)))
            for cid, idx in asignadas.items()}


def recorte(pagina, bbox, familia=False, dpi=150):
    """La foto candidata: la banda de columna que esta ARRIBA del texto.

    No hay forma de recortar bien un catalogo editorial -- los frascos se
    solapan y hay paginas a sangre sobre fondo negro. Esto genera el
    candidato; la hoja de contactos decide cual sirve.
    """
    x0, y0, x1, y1 = bbox
    # Toda la columna, desde abajo de la navegacion hasta el texto. Un cuadrado
    # pegado al texto agarra solo la base del frasco: los productos del
    # catalogo son altos y el nombre esta al pie de una foto larga.
    # En una familia la foto esta INTERCALADA con los codigos (la grilla de
    # esmaltes tiene el frasco arriba de cada tono), asi que el recorte
    # incluye el bloque; en un producto suelto el nombre esta al pie de la
    # foto, asi que el recorte corta justo antes del texto.
    py1 = (min(pagina.rect.height - 30, y1 + 20) if familia else max(80, y0 - 4))
    py0 = 38          # 35 pt es el alto de la barra de navegacion superior
    alto = py1 - py0
    if alto < 80:
        return None
    # Ensanchar hasta 3:4 para no dejar una tira flaca que la tarjeta 1:1 de la
    # vitrina achicaria hasta lo ilegible.
    ancho = max(x1 - x0 + 40, alto * 0.75)
    cx = (x0 + x1) / 2
    px0 = max(0, cx - ancho / 2)
    px1 = min(pagina.rect.width, cx + ancho / 2)
    return pagina.get_pixmap(clip=fitz.Rect(px0, py0, px1, py1), dpi=dpi)


def extraer(ruta_pdf, solo_secciones=False, sin_imagenes=False):
    meta, secciones = cargar_secciones()
    doc = fitz.open(ruta_pdf)

    if solo_secciones:
        for n in range(1, doc.page_count + 1):
            print(f"{n:>4}  {secciones.get(n, '--- fuera de rango ---')}")
        return

    SALIDA.mkdir(exist_ok=True)
    (SALIDA / "recortes").mkdir(exist_ok=True)
    (SALIDA / "paginas").mkdir(exist_ok=True)
    # Los recortes se nombran por codigo de producto, y el agrupado cambia los
    # codigos entre corridas: sin esto quedan huerfanos de la corrida anterior
    # y la hoja de contactos muestra fotos que ya no corresponden a nada.
    if not sin_imagenes:
        for viejo in (SALIDA / "recortes").glob("*.png"):
            viejo.unlink()

    productos, vistos = [], {}

    def agregar(nombre, categoria, pagina, precio, preg, pres, variantes,
                confianza, motivo, bbox, agrupar=False, descripcion=None):
        """Un producto nuevo, o variantes nuevas sobre uno ya armado.

        La deduplicacion es por codigo porque el catalogo repite paginas
        enteras (la 74 es la 60 otra vez) y porque un mismo tono puede
        aparecer en la pagina de la familia y en la del lanzamiento.

        `agrupar` es lo que hace que los 25 esmaltes sean UN producto con 25
        tonos y no 25 productos: sin eso la vitrina queda ilegible.
        """
        nuevas = [v for v in variantes if v["codigo"] not in vistos]
        if not nuevas:
            return
        clave = slug(nombre)
        unico = not agrupar and len(nuevas) == 1 and len(variantes) == 1
        codigo_prod = f"ARB-{nuevas[0]['codigo']}" if unico else f"ARB-F-{clave}"
        prod = next((p for p in productos if p["codigo"] == codigo_prod), None)
        if prod is None:
            prod = {
                "codigo": codigo_prod, "nombre": nombre,
                "descripcion": descripcion, "categoria": categoria,
                "pagina": pagina, "precio": precio, "p_reg": preg,
                "presentacion": pres, "confianza": confianza, "motivo": motivo,
                "bbox": [round(v, 1) for v in bbox], "variantes": [],
            }
            productos.append(prod)
        else:
            # La foto de una familia no puede salir del bloque de UN tono: en
            # la grilla de esmaltes eso da un recorte de dos centimetros. El
            # recorte se toma sobre la union de todos los bloques del grupo.
            prod["bbox"] = [min(prod["bbox"][0], bbox[0]),
                            min(prod["bbox"][1], bbox[1]),
                            max(prod["bbox"][2], bbox[2]),
                            max(prod["bbox"][3], bbox[3])]
        for v in nuevas:
            vistos[v["codigo"]] = prod["codigo"]
            prod["variantes"].append(v)

    for i in range(doc.page_count):
        n = i + 1
        categoria = secciones.get(n)
        if not categoria:
            continue
        pagina = doc[i]
        bloques = leer_bloques(pagina)
        pg_precio, pg_ambiguo = precio_de_pagina(bloques)
        texto_pagina = " ".join(p for b in bloques for p in b["partes"])
        hay_combo = bool(COMBO.search(sin_tildes(texto_pagina)))

        pendientes, usados = [], set()

        # --- Pasada 1: el bloque se basta solo (codigo + precio juntos) ---
        for b in bloques:
            codigos, nombre, pres, precio, preg = partir_bloque(b["partes"])
            if not codigos:
                continue
            usados.add(id(b))
            if precio is None and preg is None:
                pendientes.append((b, codigos, nombre, pres))
                continue
            motivo = []
            if precio is None:
                precio = preg
                motivo.append("sin precio de oferta, se usa P.REG.")
            if hay_combo:
                motivo.append("la pagina tiene un combo o un regalo")
            if not nombre:
                motivo.append("sin nombre en el bloque")
            texto, desc = partir_nombre(nombre)
            agregar(
                texto or "SIN NOMBRE", categoria, n, precio, preg,
                pres, [{"codigo": c, "color": None} for c in codigos],
                "alta" if not motivo else "media", "; ".join(motivo), b["bbox"],
                descripcion=desc,
            )

        # --- Pasada 2: el precio esta en otro lado de la pagina ---
        # El nombre de familia sale del bloque de mayor cuerpo que no sea
        # precio ni codigo: es el titulo del producto en la maqueta.
        familia, familia_pres = "", None
        for b in sorted(bloques, key=lambda x: -x["cuerpo"]):
            cand = []
            for p in b["partes"]:
                if PRESENTACION.match(p):
                    familia_pres = familia_pres or p
                    continue
                if (es_codigo(p) or PRECIO.match(p) or PREG.search(p)
                        or es_boiler(p) or len(p) <= 3):
                    continue
                cand.append(p)
            if cand:
                familia = limpiar(" ".join(cand))[:80]
                break

        tonos = emparejar_tonos([b for b, *_ in pendientes], bloques, usados)

        for b, codigos, nombre, pres in pendientes:
            propio, desc = partir_nombre(nombre)
            texto = propio or tonos.get(id(b), "")
            es_tono = (bool(texto)
                       and len(texto) <= MAX_CHARS_TONO
                       and len(texto.split()) <= MAX_PALABRAS_TONO)
            motivo = ["precio tomado de la pagina, no del bloque"]
            if pg_ambiguo:
                motivo.append("la pagina tiene mas de un precio grande")
            if hay_combo:
                motivo.append("la pagina tiene un combo o un regalo")
            if pg_precio is None:
                motivo.append("no se encontro precio en la pagina")
            if es_tono and familia:
                agregar(familia, categoria, n, pg_precio, None,
                        pres or familia_pres,
                        [{"codigo": c, "color": texto} for c in codigos],
                        "media", "; ".join(motivo), b["bbox"], agrupar=True)
            else:
                agregar(texto or familia or "SIN NOMBRE", categoria, n,
                        pg_precio, None, pres,
                        [{"codigo": c, "color": None} for c in codigos],
                        "media", "; ".join(motivo), b["bbox"], descripcion=desc)

        destino_pg = SALIDA / "paginas" / f"{n:03d}.png"
        # Renderizar 149 paginas tarda minutos y no cambia entre corridas del
        # mismo PDF: si ya estan, se reusan.
        if not sin_imagenes and not destino_pg.exists():
            pagina.get_pixmap(dpi=110).save(destino_pg)

    # --- Recortes candidatos, uno por producto ---
    for p in ([] if sin_imagenes else productos):
        pix = recorte(doc[p["pagina"] - 1], p["bbox"], len(p["variantes"]) > 1)
        if pix:
            pix.save(SALIDA / "recortes" / f"{p['codigo']}.png")
            p["recorte"] = f"{p['codigo']}.png"

    escribir(productos, meta)
    resumir(productos)


def escribir(productos, meta):
    (SALIDA / "catalogo.json").write_text(
        json.dumps({"periodo": meta["periodo"], "vigencia": meta["vigencia"],
                    "productos": productos}, ensure_ascii=False, indent=2),
        encoding="utf-8")

    # utf-8-sig para que Excel abra los acentos bien sin preguntar nada.
    with (SALIDA / "revision.csv").open("w", newline="", encoding="utf-8-sig") as f:
        w = csv.writer(f, delimiter=";")
        w.writerow(["codigo_arbell", "codigo_producto", "nombre", "color",
                    "descripcion", "presentacion", "precio", "p_reg", "categoria", "pagina",
                    "confianza", "motivo"])
        for p in productos:
            for v in p["variantes"]:
                w.writerow([v["codigo"], p["codigo"], p["nombre"],
                            v.get("color") or "", p.get("descripcion") or "",
                            p.get("presentacion") or "",
                            p.get("precio") or "", p.get("p_reg") or "",
                            p["categoria"], p["pagina"], p["confianza"],
                            p["motivo"]])

    filas = []
    for p in sorted(productos, key=lambda x: (x["pagina"], x["codigo"])):
        img = (f'<img src="recortes/{p["recorte"]}" alt="">'
               if p.get("recorte") else '<div class="sinfoto">sin recorte</div>')
        tonos = "".join(
            f'<li><b>{html.escape(v["codigo"])}</b> '
            f'{html.escape(v.get("color") or "")}</li>' for v in p["variantes"])
        filas.append(
            f'<figure class="{p["confianza"]}" data-cod="{html.escape(p["codigo"])}">'
            f'{img}<figcaption><b>{html.escape(p["nombre"])}</b>'
            f'<span class="meta">{html.escape(p["codigo"])} &middot; '
            f'pag. {p["pagina"]} &middot; {html.escape(p["categoria"])}</span>'
            f'<span class="precio">${p.get("precio") or "?"}</span>'
            f'<ul>{tonos}</ul>'
            f'<span class="motivo">{html.escape(p["motivo"])}</span>'
            f'<label><input type="checkbox" class="ok"> foto sirve</label>'
            f'</figcaption></figure>')

    (SALIDA / "revision.html").write_text(
        HTML.replace("__FILAS__", "\n".join(filas)).replace("__N__", str(len(productos))),
        encoding="utf-8")


def resumir(productos):
    variantes = sum(len(p["variantes"]) for p in productos)
    alta = sum(1 for p in productos if p["confianza"] == "alta")
    sin_precio = [p["codigo"] for p in productos if not p.get("precio")]
    print(f"productos      : {len(productos)}")
    print(f"codigos Arbell : {variantes}")
    print(f"confianza alta : {alta}   a revisar: {len(productos) - alta}")
    print(f"sin precio     : {len(sin_precio)}  {sin_precio[:10]}")
    cats = {}
    for p in productos:
        cats[p["categoria"]] = cats.get(p["categoria"], 0) + 1
    for c, k in sorted(cats.items(), key=lambda x: -x[1]):
        print(f"  {c:<24} {k}")
    print(f"\nsalida en {SALIDA}")
    print("revisar revision.csv y abrir revision.html antes de cargar.")


HTML = """<!doctype html><meta charset="utf-8">
<title>Revision catalogo Arbell</title>
<style>
 body{font:14px/1.5 system-ui,sans-serif;background:#faf8f5;color:#2b2622;margin:0;padding:24px}
 h1{font-weight:500;font-size:22px;margin:0 0 4px}
 .ayuda{color:#6b6259;margin:0 0 20px;max-width:60ch}
 .grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(230px,1fr));gap:16px}
 figure{margin:0;background:#fff;border:1px solid #e6e1d8;border-radius:10px;overflow:hidden;
        display:flex;flex-direction:column}
 figure.media{border-color:#d9a441;box-shadow:inset 3px 0 0 #d9a441}
 img{width:100%;aspect-ratio:1;object-fit:contain;background:#ede9e2;display:block}
 .sinfoto{aspect-ratio:1;display:grid;place-items:center;background:#ede9e2;color:#9c9088;font-size:12px}
 figcaption{padding:10px 12px;display:flex;flex-direction:column;gap:4px;flex:1}
 .meta{color:#6b6259;font-size:11.5px}
 .precio{font-size:18px}
 ul{margin:4px 0;padding-left:18px;color:#6b6259;font-size:12px;max-height:120px;overflow:auto}
 .motivo{color:#a8724a;font-size:11.5px;min-height:1em}
 label{margin-top:auto;padding-top:8px;font-size:12.5px;color:#6b6259}
</style>
<h1>Revision del catalogo Arbell &mdash; __N__ productos</h1>
<p class="ayuda">Las tarjetas con borde ambar salen de la segunda pasada del parser: el precio
no estaba en el mismo bloque que el codigo. Verificalas contra <code>paginas/</code>.
Tildar &laquo;foto sirve&raquo; y despues copiar la lista con el boton.</p>
<p><button onclick="exportar()">Copiar codigos con foto aprobada</button>
<textarea id="out" rows="4" style="width:100%;margin-top:8px"
 placeholder="pegar esto en salida/fotos-aprobadas.txt"></textarea></p>
<div class="grid">__FILAS__</div>
<script>
function exportar(){
  const ok=[...document.querySelectorAll('figure')]
    .filter(f=>f.querySelector('.ok').checked)
    .map(f=>f.dataset.cod);
  document.getElementById('out').value=ok.join('\\n');
}
</script>
"""


if __name__ == "__main__":
    if len(sys.argv) < 2:
        sys.exit(__doc__)
    extraer(sys.argv[1], "--solo-secciones" in sys.argv,
            "--sin-imagenes" in sys.argv)
