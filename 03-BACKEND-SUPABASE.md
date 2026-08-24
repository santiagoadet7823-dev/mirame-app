# 03 · Backend Supabase

> SQL ejecutable en `sql/`. Este documento explica **por qué** está así y cómo extenderlo.

---

## 1. Proyecto

| | |
|---|---|
| Ref | `hanljsmsgvezuhmehqla` |
| Nombre | `mirame-lash-studio` |
| Región | `sa-east-1` (São Paulo — la más cercana a Argentina) |
| Estado | **ACTIVO** · esquema desplegado y verificado el 2026-08-23 |

⚠️ El free tier permite **2 proyectos activos**. Hoy `la-union-pwa` ocupa uno y `rindemax` está
pausado. Reactivar Mírame es posible; si más adelante hace falta un tercero, hay que pagar.

### Lo que se descarta

`../mirame-lash-studio/supabase/schema.sql` (fork de julio 2026) usa un diseño de
`id · user_id · data jsonb · updated_at` por tabla. Era razonable para migrar rápido una app de un
solo usuario, pero **no sirve acá**:

- no hay `tenant_id`, así que no hay aislamiento entre salones;
- no se puede indexar ni filtrar por campos de negocio (todo vive dentro del `jsonb`);
- las RLS no pueden discriminar por rol a nivel de campo;
- el sync incremental no puede detectar qué cambió realmente.

Se reemplaza por el esquema relacional de `sql/`.

---

## 2. Orden de ejecución

```
sql/00_limpieza.sql        ⚠️ borra el esquema `data jsonb` viejo. Aborta si tiene filas
sql/01_plataforma.sql      tenants · profiles · tenant_members · licencias · audit_log · app_config · device_tokens
sql/02_negocio.sql         professionals · services · clients · appointments · appointment_services · transactions · stock_items · settings
sql/03_rls.sql             helpers + policies
sql/04_funciones.sql       ajustar_stock · crear_tenant · renovar_licencia · registrar_acceso · vencer_licencias
sql/05_permisos.sql        grants finos: revoca EXECUTE de PUBLIC y otorga a quien corresponde
sql/06_seed_superadmins.sql  ⚠️ editar los 2 UIDs antes de correr. PENDIENTE
```

Se pegan en el SQL Editor en ese orden. Son idempotentes (`if not exists`, `drop policy if exists`):
se pueden volver a correr sin romper nada.

Migraciones futuras: archivo nuevo numerado (`06_…`, `07_…`), **nunca** editar uno ya aplicado.
Es la misma convención que usa `la-union-app` en su carpeta `db/`.

---

## 3. Patrón obligatorio de toda tabla de negocio

```sql
id         uuid primary key default gen_random_uuid(),
tenant_id  uuid not null references public.tenants(id) on delete cascade,
-- … campos propios …
created_at timestamptz not null default now(),
updated_at timestamptz not null default now(),
deleted_at timestamptz
```

Más: trigger de `updated_at`, índice `(tenant_id, updated_at)` para el pull del sync, RLS activada
y las tres policies del bloque `do $$` de `03_rls.sql`.

**`deleted_at` no es opcional.** Un `DELETE` real no se le puede propagar a un cliente que estaba
offline: cuando vuelva, el pull no tiene forma de saber que la fila existía. Por eso los borrados
son *tombstones* (update de `deleted_at`) y no hay policy de `DELETE` en ninguna tabla de negocio.

---

## 4. Los tres niveles de acceso

```
es_superadmin()          profiles.plataforma_rol = 'superadmin'
es_revendedor_de(t)      tenants.creado_por = auth.uid()
pertenece_a(t)           tenant_members approved
rol_en(t)                'owner' | 'admin' | 'profesional' | 'lectura' | null
administra(t)            rol_en(t) in ('owner','admin')
puede_escribir(t)        rol_en(t) in ('owner','admin','profesional')
licencia_vigente(t)      tenant activo/trial y licencia sin vencer
```

Todas son `stable security definer`. **Ese `stable` importa**: sin él, Postgres evalúa la función
por fila y una lista de 500 turnos dispara 500 subconsultas.

`security definer` además evita la recursión: `es_superadmin()` consulta `profiles`, que tiene RLS
activada. Como la función corre como el dueño de la tabla, no vuelve a pasar por las policies.

### Lo que NO se puede hacer con una policy

Una policy sobre una tabla **no puede consultar esa misma tabla**: RLS entra en recursión infinita.
Dos reglas del proyecto caen en ese caso y por eso van como **triggers**, que ven `OLD` y `NEW` sin
reentrar:

| Regla | Implementación |
|---|---|
| Nadie se auto-promueve a `superadmin` | trigger `proteger_rol_plataforma` en `profiles` |
| El owner no cambia el `estado` ni el `plan` de su salón | trigger `proteger_estado_tenant` en `tenants` |

Si en el futuro hace falta "este campo solo lo cambia tal rol", el patrón es el trigger, no el
`with check`.

### Dos trampas encontradas al desplegar (2026-08-23)

Ambas se descubrieron probando de verdad, no leyendo el SQL. Están arregladas, pero el patrón que
las causó es fácil de reintroducir.

**1. `NULL` no es `false`, y una guarda en plpgsql no dispara con `NULL`.**

`rol_en(t)` devuelve `NULL` cuando el usuario no es miembro del tenant, y
`NULL in ('owner','admin')` evalúa a `NULL`. En una policy eso es inofensivo — RLS trata `NULL`
como deny. Pero en plpgsql:

```sql
if not (public.puede_escribir(t) or public.es_superadmin()) then   -- ❌
  raise exception 'sin permiso';
end if;
```

`not (NULL or false)` es `NULL`, y `if NULL then` **no ejecuta**. Como `ajustar_stock` es
`SECURITY DEFINER` (y por lo tanto saltea RLS), el owner del Salón A pudo bajar el stock del
Salón B de 10 a 3. Verificado en la base real antes del fix.

Arreglo, en dos capas:
- los helpers devuelven `coalesce(..., false)`, nunca `NULL`;
- las guardas usan `(...) is not true` en vez de `not (...)`.

> Regla: en una función `SECURITY DEFINER` que valida permisos, siempre `is not true`.

**2. `EXECUTE` se otorga a `PUBLIC` por defecto.**

Este `revoke` no hace nada útil:

```sql
revoke execute on function public.vencer_licencias() from authenticated;   -- ❌
```

El permiso sigue llegando por `PUBLIC`, así que la función queda invocable desde
`/rest/v1/rpc/vencer_licencias` — incluso **sin sesión**. Y `vencer_licencias()` es el cron que
suspende salones por falta de pago.

Arreglo: `revoke all ... from public, anon, authenticated` y después `grant` solo a quien
corresponde. Está en `sql/05_permisos.sql`.

> Regla: `revoke` siempre incluye `public`. Correr `get_advisors` después de agregar funciones.

Policy estándar de negocio:

| Operación | Quién |
|---|---|
| `select` | miembro del tenant · superadmin · revendedor que lo creó |
| `insert` / `update` | miembro con rol de escritura · superadmin |
| `delete` | **nadie** (tombstones) |

El revendedor **lee pero no escribe** los datos de negocio ajenos. Puede ver la agenda de un salón
para dar soporte; no puede operarlo.

---

## 5. Auditoría del acceso cross-tenant

Que el revendedor pueda ver la agenda y las clientas de salones de terceros es una capacidad
sensible: son datos personales de gente que no le dio permiso a él, sino al salón.

La forma responsable de darla es dejar rastro:

- `registrar_acceso(tenant, accion, entidad, meta)` se llama al entrar en modo "ver como" y al
  abrir cualquier vista de negocio de un tenant al que **no se pertenece**. La función se saltea
  sola si el usuario sí es miembro (auditar la operación normal sería ruido puro).
- Se invoca desde un interceptor en la capa de repositorios, no widget por widget. Un solo lugar.
- **El tenant puede leer su propio `audit_log`** (policy `audit_select` incluye `administra`).
  Esto es lo que lo hace defendible: el salón puede ver quién miró sus datos y cuándo.
- Nadie puede editar ni borrar el log.

Las Edge Functions auditan además del lado del servidor, porque un cliente modificado podría no
llamar a `registrar_acceso`.

---

## 6. Funciones RPC

| Función | Para qué | Nota |
|---|---|---|
| `ajustar_stock(item, delta)` | +/- de cantidad | **Delta, no valor absoluto.** Ver §7 |
| `crear_tenant(nombre, slug, owner, plan, dias, tel)` | alta transaccional de un salón | Crea tenant + licencia + owner + 7 servicios del catálogo legacy |
| `renovar_licencia(tenant, dias, monto, metodo)` | sumar días | **Acumula**: base = `max(now, vence_at)`. Renovar una licencia con 10 días restantes da 40, no 30 |
| `registrar_acceso(...)` | auditoría | Se saltea si el actor pertenece al tenant |
| `vencer_licencias()` | cron diario | Suspende tenants vencidos. No ejecutable por `authenticated` |

---

## 7. Por qué el stock usa deltas

Es la única excepción al last-write-wins del motor de sync, y vale la pena entender el caso:

> Dos profesionales, ambas sin señal. Cada una descuenta una unidad del mismo adhesivo. El valor
> local de la primera pasa de 10 a 9; el de la segunda, también de 10 a 9. Al reconectar, LWW
> aplica un 9 y después otro 9. **Quedan 9 en vez de 8.** Se perdió un descuento.

Enviando `delta: -1` y resolviéndolo server-side con `greatest(0, cantidad + delta)`, quedan los
dos descuentos. El `greatest(0, …)` replica el comportamiento de `adjQ()` del legacy, que nunca
dejaba bajar de cero.

---

## 8. Edge Functions (Fase 6-7)

En `supabase/functions/`, Deno:

| Función | Trigger | Qué hace |
|---|---|---|
| `crear-tenant` | invocada desde el panel | Envuelve el RPC + invita al owner por email |
| `renovar-licencia` | panel | RPC + registro de pago + push al tenant |
| `enviar-push` | invocada / cron | Fan-out FCM a los `device_tokens` de un tenant |
| `chequear-vencimientos` | cron diario | `vencer_licencias()` + avisa a los que vencen en 7 días |
| `recordatorios` | cron diario | Retoques, turnos de mañana, stock bajo |

Ojo con lo aprendido en la-union-app: si se invocan desde `pg_net`, el `timeout_milliseconds` es
obligatorio; sin él, la llamada puede quedar colgada.

---

## 9. Auth: configuración del proyecto

1. **Authentication → Providers → Google**: activar, con el Client ID y Secret del proyecto de
   Google Cloud.
2. **Authentication → URL Configuration → Redirect URLs**: agregar
   - la URL de GitHub Pages de la PWA,
   - `http://localhost:*` para desarrollo,
   - el deep link nativo `com.mirame.app://auth`.
3. **Email**: dejar el magic link habilitado como respaldo si Google falla.

---

## 10. Verificación de las RLS (no saltear)

Antes de dar la Fase 1 por terminada, probar las policies simulando cada rol. En el SQL Editor:

```sql
-- Simular un usuario concreto
select set_config('request.jwt.claims',
  json_build_object('sub','UID-A-PROBAR','role','authenticated')::text, true);
select set_config('role', 'authenticated', true);

-- Ahora las queries se evalúan como ese usuario
select count(*) from public.clients;
```

Checklist:

- [ ] Un `owner` del tenant A ejecuta `select * from clients` y **no ve ninguna fila del tenant B**.
- [ ] Un `lectura` intenta un `insert` en `appointments` → **falla**.
- [ ] Un `profesional` inserta un turno en su tenant → **funciona**.
- [ ] El revendedor hace `select` sobre `clients` de un tenant que creó → **ve**.
- [ ] El revendedor intenta `update` sobre esos `clients` → **falla**.
- [ ] El revendedor hace `select` sobre un tenant que **no** creó → **no ve nada**.
- [ ] Un usuario cualquiera intenta ponerse `plataforma_rol = 'superadmin'` → **falla**.
- [ ] Un usuario nuevo puede insertarse en `tenant_members` solo como `pending` / `profesional`.
- [ ] Un `owner` puede leer el `audit_log` de su tenant.
- [ ] Nadie puede hacer `delete` en una tabla de negocio.

Cada casilla se marca habiendo corrido la query, no por lectura del SQL.

### Resultado de la corrida del 2026-08-23

Ejecutado contra la base real con 4 usuarios de prueba y 2 tenants (borrados al terminar):

| Caso | Resultado |
|---|---|
| Owner del A lista `clients` | ve 1 (la suya), 0 del B ✅ |
| Owner del A lista `tenants` | ve 1 ✅ |
| Rol `lectura` inserta una clienta | rechazado por RLS ✅ |
| Rol `lectura` lee | ve 1 ✅ |
| Revendedor lee el salón que vendió | ve 1 ✅ |
| Revendedor lee un salón ajeno | ve 0 ✅ |
| Revendedor escribe en el salón que vendió | 0 filas afectadas, dato intacto ✅ |
| Owner del A ajusta el stock del B | **falló primero** → arreglado → ahora rechazado ✅ |
| Cualquiera se auto-promueve a superadmin | rechazado por el trigger ✅ |
| Owner borra una clienta | 0 filas, la clienta sobrevive (tombstones) ✅ |
| `get_advisors` security | sin warnings de `anon`; quedan 11 de `authenticated`, intencionales |

Los fixtures se eliminaron: la base quedó con 0 usuarios, 0 tenants y solo la fila de `app_config`.

---

## 11. Cómo agregar una tabla de negocio nueva

1. Archivo `sql/NN_…sql` nuevo, nunca editar uno aplicado.
2. Copiar el patrón del §3 completo (los 6 campos, el trigger, el índice de sync).
3. Agregar el nombre de la tabla al array del bloque `do $$` de `03_rls.sql` y volver a correrlo.
4. Espejar la tabla en Drift (`05-OFFLINE-SYNC.md` §Cómo agregar una entidad).
5. Registrarla en el `SyncEngine` (lista de tablas a pullear).
6. Commit `feat(sql): agrega tabla <nombre>`.

Si la tabla no tiene `tenant_id`, no entra. Sin excepciones.
