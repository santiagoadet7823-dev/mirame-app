---
name: mirame-supabase
description: Esquema, RLS y tenancy del backend de Mírame. Usar antes de crear o modificar cualquier tabla, policy, función RPC o Edge Function del proyecto, y antes de tocar roles o permisos. Evita romper el aislamiento entre salones o el motor de sincronización.
---

# Backend de Mírame

Documento completo: `android/03-BACKEND-SUPABASE.md`. SQL en `android/sql/`.

## Regla número uno

**Toda tabla de negocio lleva `tenant_id`, RLS y `deleted_at`.** Sin excepciones. Una tabla sin
`tenant_id` filtra datos entre salones; una sin `deleted_at` rompe el sync offline.

## Patrón obligatorio

```sql
create table public.<nombre> (
  id         uuid primary key default gen_random_uuid(),
  tenant_id  uuid not null references public.tenants(id) on delete cascade,
  -- campos propios
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);
create trigger trg_updated_at before update on public.<nombre>
  for each row execute function public.set_updated_at();
create index idx_<nombre>_sync on public.<nombre>(tenant_id, updated_at);
```

Después: agregar el nombre al array del bloque `do $$` de `sql/03_rls.sql` y volver a correrlo.

## Los tres niveles de acceso

```sql
es_superadmin()        -- profiles.plataforma_rol = 'superadmin'  (2 personas)
es_revendedor_de(t)    -- tenants.creado_por = auth.uid()
pertenece_a(t)         -- tenant_members approved
puede_escribir(t)      -- rol_en(t) in ('owner','admin','profesional')
administra(t)          -- rol_en(t) in ('owner','admin')
```

Policy estándar: `select` para miembro / superadmin / revendedor · `insert` y `update` para quien
puede escribir o superadmin · **`delete` para nadie** (tombstones).

El revendedor **lee pero no escribe** datos de negocio ajenos.

## Cosas que se rompen fácil

| Error | Consecuencia |
|---|---|
| Función helper sin `stable` | Se evalúa por fila: 500 turnos = 500 subconsultas |
| Usar `DELETE` en una tabla de negocio | El borrado no llega a un cliente que estaba offline |
| Olvidar el índice `(tenant_id, updated_at)` | El pull incremental hace full scan |
| Editar un archivo SQL ya aplicado | Se desincroniza con lo que hay en producción. **Archivo nuevo numerado, siempre** |
| Policy que permite cambiar `plataforma_rol` | Auto-promoción a superadmin |
| Cambiar el stock con un valor absoluto | Se pierden ajustes concurrentes. Usar `ajustar_stock(item, delta)` |
| `if not (permiso...)` en una función `SECURITY DEFINER` | **`NULL` no dispara la guarda.** Ver abajo |
| `revoke execute ... from authenticated` | **No sirve:** PUBLIC tiene EXECUTE por defecto. Ver abajo |

## Las dos que ya explotaron (2026-08-23)

Ambas se encontraron probando contra la base, no leyendo el SQL. Están arregladas; el patrón que
las causó es fácil de reintroducir.

**`NULL` no es `false`.** `rol_en(t)` da `NULL` si el usuario no es miembro, y
`NULL in ('owner',...)` es `NULL`. En una policy da igual (RLS trata NULL como deny), pero en
plpgsql `if not (NULL) then` **no ejecuta**. Como las RPC son `SECURITY DEFINER` (saltean RLS), el
owner de un salón pudo modificar el stock de otro.

```sql
if not (public.puede_escribir(t) or public.es_superadmin()) then   -- ❌ inerte con NULL
if (public.puede_escribir(t) or public.es_superadmin()) is not true then   -- ✅
```

Los helpers ya devuelven `coalesce(..., false)`, pero usá `is not true` igual: defensa en profundidad.

**`EXECUTE` se otorga a `PUBLIC` por defecto.** Revocar solo de `authenticated` deja la función
expuesta en `/rest/v1/rpc/<nombre>` incluso sin sesión. Siempre:

```sql
revoke all on function public.<f>(...) from public, anon, authenticated;
grant execute on function public.<f>(...) to authenticated;  -- solo a quien corresponda
```

Después de agregar cualquier función, correr `get_advisors` con `type: "security"`. Lo esperado es
que solo queden warnings de `authenticated_security_definer_function_executable` sobre los helpers
de RLS y las 4 RPC de mutación. **Cualquier warning sobre `anon` es un problema real.**

## Auditoría cross-tenant

`registrar_acceso(tenant, accion, entidad, meta)` se llama desde el interceptor de repositorios al
tocar datos de un tenant al que no se pertenece. Se saltea sola si el actor sí es miembro.

**El propio salón puede leer su `audit_log`.** Eso es lo que hace defendible que el revendedor vea
sus datos. No sacarlo.

## Antes de dar por cerrada una migración

Correr el checklist de RLS de `03-BACKEND-SUPABASE.md` §10, simulando cada rol con
`set_config('request.jwt.claims', …)`. Marcar cada casilla habiendo corrido la query, no leyendo
el SQL.

## Proyecto

Ref `hanljsmsgvezuhmehqla`, región `sa-east-1`. **Activo**, con el esquema desplegado desde el
2026-08-23 (16 tablas, RLS verificada con los 5 roles).

Si `list_tables` devuelve vacío justo después de un restore, **no le creas**: durante el
`COMING_UP` la vista es incompleta. Esperá a que la API REST responda y volvé a consultar. Pasó en
este proyecto y casi lleva a borrar tablas creyendo que no existían.
