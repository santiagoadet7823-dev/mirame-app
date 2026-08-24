#!/usr/bin/env python3
"""Convierte un backup JSON de la app HTML en SQL para Supabase.

    python android/scripts/migrar-backup.py backup.json <tenant_id> > migracion.sql

Correcciones que aplica (la deuda del modelo legacy, ver android/CLAUDE.md):

  · `price` / `amount` / `qty` / `min` eran STRINGS de `input.value`  → numeric
  · `vip` era el string 'false'                                      → boolean
  · el turno guardaba el NOMBRE del servicio                         → vinculo por id
  · los ids eran autoincrementales de IndexedDB                      → uuid

Los uuid son DETERMINISTICOS (uuid5 sobre el id viejo). Dos consecuencias
buenas: las relaciones se mantienen sin tener que resolver nada, y correr la
migracion dos veces no duplica datos — el `on conflict do nothing` la vuelve
idempotente.

Lo que NO se puede migrar: `transactions.client_id`. El legacy leia ese campo
pero nunca lo escribia, asi que en el backup no existe. Por eso el gasto por
clienta se calcula desde los turnos.
"""
import io
import json
import sys
import uuid

# En Windows stdout usa cp1252 por defecto y los acentos salen corruptos: el
# SQL generado deja de ser UTF-8 y los nombres llegan rotos a la base. Pasó.
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', newline='')
sys.stderr = io.TextIOWrapper(sys.stderr.buffer, encoding='utf-8', newline='')

NS = uuid.UUID('6ba7b810-9dad-11d1-80b4-00c04fd430c8')


def uid(tenant: str, tabla: str, viejo) -> str:
    """uuid5 determinista, con el tenant adentro para que dos salones que
    migren backups distintos no colisionen en el mismo id."""
    return str(uuid.uuid5(NS, f'{tenant}:{tabla}:{viejo}'))


def q(v) -> str:
    """Literal SQL. `''` se trata como NULL: el legacy usaba el string vacio
    para 'sin dato', y guardarlo tal cual llenaria la base de campos que
    parecen tener contenido."""
    if v is None:
        return 'null'
    s = str(v).strip()
    if s == '':
        return 'null'
    return "'" + s.replace("'", "''") + "'"


def num(v, defecto=0):
    """Los montos venian como string. Un valor no numerico cae al defecto en
    vez de romper la migracion entera por una fila sucia."""
    if v is None or str(v).strip() == '':
        return defecto
    try:
        return float(str(v).replace(',', '.'))
    except ValueError:
        return defecto


def entero(v, defecto=0):
    return int(num(v, defecto))


ESTADOS = {'confirmed': 'confirmed', 'pending': 'pending',
           'done': 'done', 'cancelled': 'cancelled'}


def main() -> None:
    if len(sys.argv) < 3:
        sys.exit(__doc__)
    datos = json.load(open(sys.argv[1], encoding='utf-8'))
    t = sys.argv[2]

    out = sys.stdout
    out.write('-- Generado por migrar-backup.py. Idempotente.\n')
    out.write('begin;\n\n')

    # ── Profesionales ──────────────────────────────────────────────────────
    for p in datos.get('p') or []:
        out.write(
            'insert into public.professionals (id, tenant_id, nombre, telefono) '
            f"values ({q(uid(t,'p',p['id']))}, {q(t)}, {q(p.get('name'))}, "
            f"{q(p.get('phone'))}) on conflict (id) do nothing;\n")

    # ── Servicios ──────────────────────────────────────────────────────────
    # El nombre se indexa para poder resolver los servicios de cada turno, que
    # en el legacy se guardaban por NOMBRE.
    por_nombre = {}
    for s in datos.get('sv') or []:
        sid = uid(t, 'sv', s['id'])
        if s.get('name'):
            por_nombre[s['name'].strip()] = sid
        out.write(
            'insert into public.services (id, tenant_id, nombre, precio, '
            'duracion_min, retoque_dias, mantenimiento_dias, notas) values ('
            f"{q(sid)}, {q(t)}, {q(s.get('name'))}, {num(s.get('price'))}, "
            f"{entero(s.get('duration'), 60)}, "
            f"{entero(s.get('retoque')) or 'null'}, "
            f"{entero(s.get('mantenimiento')) or 'null'}, "
            f"{q(s.get('notes'))}) on conflict (id) do nothing;\n")

    # ── Clientas ───────────────────────────────────────────────────────────
    for c in datos.get('c') or []:
        vip = str(c.get('vip')).lower() == 'true'
        out.write(
            'insert into public.clients (id, tenant_id, nombre, telefono, '
            'email, cumple, vip, notas) values ('
            f"{q(uid(t,'c',c['id']))}, {q(t)}, {q(c.get('name'))}, "
            f"{q(c.get('phone'))}, {q(c.get('email'))}, "
            f"{q(c.get('birthday'))}, {str(vip).lower()}, "
            f"{q(c.get('notes'))}) on conflict (id) do nothing;\n")

    # ── Turnos ─────────────────────────────────────────────────────────────
    puentes = []
    for a in datos.get('a') or []:
        aid = uid(t, 'a', a['id'])
        cid = q(uid(t, 'c', a['clientId'])) if a.get('clientId') else 'null'
        pid = q(uid(t, 'p', a['proId'])) if a.get('proId') else 'null'
        estado = ESTADOS.get(a.get('status'), 'pending')
        out.write(
            'insert into public.appointments (id, tenant_id, client_id, '
            'professional_id, fecha, hora, precio, estado, notas) values ('
            f"{q(aid)}, {q(t)}, {cid}, {pid}, {q(a.get('date'))}, "
            f"{q(a.get('time'))}, {num(a.get('price'))}, '{estado}', "
            f"{q(a.get('notes'))}) on conflict (id) do nothing;\n")

        # `services` (lista de nombres) o, en los turnos viejos, `service`.
        nombres = a.get('services') or ([a['service']] if a.get('service') else [])
        for i, nombre in enumerate(nombres):
            sid = por_nombre.get(str(nombre).strip())
            # Un servicio que ya no existe en la lista se saltea: inventarlo
            # ensuciaria el catalogo del salon con nombres muertos.
            if sid:
                puentes.append((uid(t, 'as', f'{a["id"]}:{i}'), aid, sid))

    for pid_, aid, sid in puentes:
        out.write(
            'insert into public.appointment_services (id, tenant_id, '
            'appointment_id, service_id) values ('
            f"{q(pid_)}, {q(t)}, {q(aid)}, {q(sid)}) "
            'on conflict (id) do nothing;\n')

    # ── Caja ───────────────────────────────────────────────────────────────
    for x in datos.get('tx') or []:
        tipo = 'ingreso' if x.get('type') == 'income' else 'gasto'
        out.write(
            'insert into public.transactions (id, tenant_id, tipo, monto, '
            'descripcion, categoria, fecha, metodo) values ('
            f"{q(uid(t,'tx',x['id']))}, {q(t)}, '{tipo}', "
            f"{num(x.get('amount'))}, {q(x.get('desc'))}, "
            f"{q(x.get('category'))}, {q(x.get('date'))}, "
            f"{q(x.get('payment'))}) on conflict (id) do nothing;\n")

    # ── Stock ──────────────────────────────────────────────────────────────
    for s in datos.get('s') or []:
        out.write(
            'insert into public.stock_items (id, tenant_id, nombre, categoria, '
            'cantidad, minimo, unidad) values ('
            f"{q(uid(t,'s',s['id']))}, {q(t)}, {q(s.get('name'))}, "
            f"{q(s.get('category'))}, {entero(s.get('qty'))}, "
            f"{entero(s.get('min'))}, {q(s.get('unit'))}) "
            'on conflict (id) do nothing;\n')

    out.write('\ncommit;\n')

    r = (f"-- profesionales {len(datos.get('p') or [])} · "
         f"servicios {len(datos.get('sv') or [])} · "
         f"clientas {len(datos.get('c') or [])} · "
         f"turnos {len(datos.get('a') or [])} "
         f"(+{len(puentes)} servicios vinculados) · "
         f"caja {len(datos.get('tx') or [])} · "
         f"stock {len(datos.get('s') or [])}\n")
    out.write(r)
    sys.stderr.write(r)


if __name__ == '__main__':
    main()
