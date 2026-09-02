#!/usr/bin/env python3
"""Genera el SQL que sube el catalogo extraido a Supabase.

No se conecta a la base: emite un archivo SQL autocontenido que resuelve la
coincidencia del lado del servidor. Eso lo hace idempotente y ejecutable desde
donde sea (el MCP de Supabase, el SQL Editor del dashboard, psql).

    python cargar.py                 -> salida/carga.sql   (termina en COMMIT)
    python cargar.py --dry-run       -> salida/carga.sql   (termina en ROLLBACK)
    python cargar.py --actualizar-nombres

Orden de coincidencia, de mas fuerte a mas debil:

  1. `producto_variantes.sku` = codigo Arbell  -> ese es el producto destino.
  2. `productos.codigo` = ARB-... existente    -> variante nueva sobre el.
  3. Nada coincide                             -> alta de producto + variantes.

Lo que NO hace nunca: borrar. Un codigo que desaparece del catalogo se
despublica y se informa, porque puede ser algo que ella ya vendio o publico.

Y por defecto tampoco pisa `nombre` ni `categoria`: si Candela corrigio un
nombre a mano, el catalogo siguiente no se lo puede deshacer. Para forzarlo,
--actualizar-nombres.
"""

import json
import sys
from pathlib import Path

AQUI = Path(__file__).parent
SALIDA = AQUI / "salida"

# El salon de Candela ES el tenant `mirame`: ella figura como owner de Mirame
# Lash Studio. No hay un segundo tenant.
TENANT = "f287a618-934d-4877-be79-8f7d2e89d734"
PROVEEDOR = "01a05093-bf4e-7d33-9453-a3121be96945"  # proveedores.nombre = 'arbell'


def q(v):
    """Literal SQL. None -> NULL; el resto va como texto escapado."""
    if v is None or v == "":
        return "null"
    return "'" + str(v).replace("'", "''") + "'"


def generar(cat, dry_run, actualizar_nombres):
    filas, sin_precio = [], []
    for p in cat["productos"]:
        if not p.get("precio"):
            sin_precio.append(p["codigo"])
            continue
        for v in p["variantes"]:
            filas.append((v["codigo"], p["codigo"], p["nombre"], v.get("color"),
                          p.get("descripcion"), p["precio"], p["categoria"]))

    if not filas:
        sys.exit("no hay ninguna fila con precio: revisar salida/revision.csv")

    valores = ",\n  ".join(
        f"({q(a)},{q(b)},{q(c)},{q(d)},{q(e)},{f},{q(g)})" for a, b, c, d, e, f, g in filas)

    nombres = ""
    if actualizar_nombres:
        nombres = """
-- --actualizar-nombres: pisa lo que haya escrito ella. Usar con criterio.
update productos p
   set nombre = g.nombre, descripcion = g.descripcion,
       categoria = g.categoria, updated_at = now()
  from _grupo g
 where p.id = g.producto_id
   and (p.nombre, p.descripcion, p.categoria)
       is distinct from (g.nombre, g.descripcion, g.categoria);
"""

    aviso = ""
    if sin_precio:
        aviso = ("-- SE OMITIERON por no tener precio: "
                 + ", ".join(sin_precio) + "\n")

    return PLANTILLA.format(
        tenant=TENANT, proveedor=PROVEEDOR, valores=valores, nombres=nombres,
        aviso=aviso, filas=len(filas), cierre="rollback" if dry_run else "commit",
        modo="ENSAYO (rollback)" if dry_run else "DEFINITIVO (commit)",
        periodo=cat.get("periodo", "?"), vigencia=cat.get("vigencia", "?"))


PLANTILLA = """-- Carga del catalogo Arbell {periodo} (vigencia {vigencia})
-- Generado por scripts/arbell/cargar.py -- NO editar a mano.
-- Modo: {modo} -- {filas} codigos.
{aviso}
begin;

create temp table _cat (
  codigo_arbell text, codigo_prod text, nombre text, color text,
  descripcion text, precio numeric, categoria text
) on commit drop;

insert into _cat values
  {valores};

-- Paso 1: para cada codigo, de que producto es. El sku manda sobre el codigo
-- de producto porque es lo unico estable entre catalogos.
create temp table _res on commit drop as
select c.*,
       coalesce(
         (select v.producto_id from producto_variantes v
           where v.tenant_id = '{tenant}' and v.sku = c.codigo_arbell
             and v.deleted_at is null),
         (select p.id from productos p
           where p.tenant_id = '{tenant}' and p.codigo = c.codigo_prod
             and p.deleted_at is null)
       ) as producto_id
  from _cat c;

create temp table _grupo on commit drop as
select codigo_prod,
       min(nombre)      as nombre,
       min(descripcion) as descripcion,
       min(categoria)   as categoria,
       max(precio)    as precio,
       (array_agg(producto_id) filter (where producto_id is not null))[1] as producto_id
  from _res group by codigo_prod;

-- Paso 2: el informe se calcula ANTES de tocar nada, si no queda todo en cero.
create temp table _informe on commit drop as
  select 'altas de producto' as que, count(*)::int as n from _grupo where producto_id is null
  union all
  select 'productos ya cargados', count(*)::int from _grupo where producto_id is not null
  union all
  select 'cambios de precio', count(*)::int from _grupo g join productos p on p.id = g.producto_id
   where p.precio is distinct from g.precio
  union all
  select 'variantes nuevas', count(*)::int from _res r
   where not exists (select 1 from producto_variantes v
                      where v.tenant_id = '{tenant}' and v.sku = r.codigo_arbell
                        and v.deleted_at is null)
  union all
  select 'despublicar (ya no estan en el catalogo)', count(*)::int
    from productos p
   where p.tenant_id = '{tenant}' and p.rubro = 'arbell' and p.deleted_at is null
     and p.publicado
     and not exists (select 1 from producto_variantes v
                      where v.producto_id = p.id and v.deleted_at is null
                        and v.sku in (select codigo_arbell from _cat));

-- Paso 3: altas. Entran despublicadas: Candela revisa y publica.
insert into productos (tenant_id, proveedor_id, nombre, descripcion, categoria,
                       codigo, precio, rubro, publicado)
select '{tenant}', '{proveedor}', g.nombre, g.descripcion, g.categoria,
       g.codigo_prod, g.precio, 'arbell', false
  from _grupo g where g.producto_id is null
    on conflict (tenant_id, codigo) do nothing;

update _grupo g set producto_id = p.id
  from productos p
 where p.tenant_id = '{tenant}' and p.codigo = g.codigo_prod
   and p.deleted_at is null and g.producto_id is null;

-- Paso 4: el precio nuevo del catalogo. Es a lo que viene todo esto.
update productos p
   set precio = g.precio, updated_at = now()
  from _grupo g
 where p.id = g.producto_id and p.precio is distinct from g.precio;
{nombres}
-- Paso 5: variantes. El sku guarda el codigo Arbell CRUDO -- es la clave de
-- la proxima actualizacion.
insert into producto_variantes (tenant_id, producto_id, color, sku)
select '{tenant}', g.producto_id, r.color, r.codigo_arbell
  from _res r join _grupo g using (codigo_prod)
 where g.producto_id is not null
   and not exists (select 1 from producto_variantes v
                    where v.tenant_id = '{tenant}' and v.sku = r.codigo_arbell
                      and v.deleted_at is null);

-- Paso 6: stock en 0 en el deposito principal. No se inventan cantidades;
-- ella carga lo que realmente pide. Ojo: publicado con stock 0 se lee
-- "Agotado" en la vitrina (tienda.html:582).
insert into stock_variantes (tenant_id, variante_id, deposito_id, cantidad)
select '{tenant}', v.id, d.id, 0
  from producto_variantes v
  cross join (select id from depositos
               where tenant_id = '{tenant}' and deleted_at is null
               order by es_principal desc, created_at limit 1) d
 where v.tenant_id = '{tenant}' and v.deleted_at is null
   and v.sku in (select codigo_arbell from _cat)
    on conflict (variante_id, deposito_id) do nothing;

-- Paso 7: lo que Arbell discontinuo sale de la vitrina, pero no se borra.
update productos p
   set publicado = false, updated_at = now()
 where p.tenant_id = '{tenant}' and p.rubro = 'arbell' and p.deleted_at is null
   and p.publicado
   and not exists (select 1 from producto_variantes v
                    where v.producto_id = p.id and v.deleted_at is null
                      and v.sku in (select codigo_arbell from _cat));

select * from _informe;

{cierre};
"""


if __name__ == "__main__":
    origen = SALIDA / "catalogo.json"
    if not origen.exists():
        sys.exit(f"falta {origen} -- correr extraer.py primero")
    cat = json.loads(origen.read_text(encoding="utf-8"))
    sql = generar(cat, "--dry-run" in sys.argv, "--actualizar-nombres" in sys.argv)
    destino = SALIDA / "carga.sql"
    destino.write_text(sql, encoding="utf-8")
    print(f"escrito {destino} ({len(sql)} bytes)")
    print("ensayo" if "--dry-run" in sys.argv else "DEFINITIVO -- termina en commit")
