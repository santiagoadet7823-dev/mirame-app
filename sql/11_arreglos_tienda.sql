-- ═══════════════════════════════════════════════════════════════════════════
-- 11 · El código que se reciclaba, y la marca de la vitrina
--
-- Dos agujeros que aparecieron el mismo día usando la app desde el teléfono
-- del estudio, con una cuenta `encargado`.
-- ═══════════════════════════════════════════════════════════════════════════


-- ── 1 · El código de una prenda borrada seguía ocupado ────────────────────
--
-- `UNIQUE (tenant_id, codigo)` no distingue borradas, así que una prenda con
-- `deleted_at` retenía su código para siempre. Del otro lado, `proximoCodigo`
-- numera desde el máximo de las prendas VISIBLES: borradas MIR-001 y MIR-002,
-- el máximo volvió a cero y la prenda nueva nació con un código ya tomado.
--
-- El resultado no era un cartel de error: era un 409 repetido cada 3 minutos
-- en el outbox, arrastrando a las variantes y las fotos por foreign key, hasta
-- que la fila agotaba sus 8 intentos y quedaba muerta en la cola.
--
-- El índice va PARCIAL, como `variantes_tenant_sku_idx`: el código es único
-- entre lo que existe, no entre lo que existió. La otra mitad del arreglo está
-- en la app — el número no se recicla ni aunque la base lo permita.
alter table public.productos
  drop constraint if exists productos_tenant_id_codigo_key;

create unique index if not exists productos_tenant_codigo_idx
  on public.productos (tenant_id, codigo)
  where codigo is not null and deleted_at is null;


-- ── 2 · Que el encargado pueda editar la marca de la vitrina ──────────────
--
-- `tenants` solo lo escribían `tenants_owner_update` (owner) y `tenants_write`
-- (superadmin). Un encargado guardaba el logo y no pasaba nada: cuando la RLS
-- filtra las filas de un UPDATE, PostgREST no devuelve error, devuelve OK con
-- cero filas. La app decía «Datos guardados» y no había guardado nada.
--
-- NO se abre la policy de `tenants` a `opera()`: una policy de UPDATE es por
-- fila, no por columna, y eso le daría al encargado `estado`, `plan` y
-- `creado_por` — o sea, la licencia. Con una función `security definer` las
-- columnas quedan acotadas por construcción.
--
-- Devuelve el `id` y no la fila entera a propósito: `tenants` tiene columnas
-- que un encargado no tiene por qué leer. El cliente solo necesita saber que
-- algo cambió; null significa que no se escribió.
create or replace function public.actualizar_marca_tienda(
  p_tenant       uuid,
  p_telefono     text default null,
  p_direccion    text default null,
  p_instagram    text default null,
  p_hero_titulo  text default null,
  p_hero_bajada  text default null,
  -- `null` en un texto es «vaciar», pero en una imagen es «no la toques»: sin
  -- estos dos booleanos, guardar los textos borraría el logo que se subió en
  -- otra sesión.
  p_tocar_logo   boolean default false,
  p_logo_path    text default null,
  p_tocar_hero   boolean default false,
  p_hero_path    text default null
)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare v_id uuid;
begin
  if not (public.opera(p_tenant) or public.es_superadmin()) then
    raise exception 'sin permiso para editar la tienda de este salon'
      using errcode = '42501';
  end if;

  update public.tenants set
    telefono    = nullif(btrim(coalesce(p_telefono, '')), ''),
    direccion   = nullif(btrim(coalesce(p_direccion, '')), ''),
    -- Sin la arroba: la vitrina la agrega, y guardarla doble la duplicaría.
    instagram   = nullif(regexp_replace(btrim(coalesce(p_instagram, '')),
                                        '^@', ''), ''),
    hero_titulo = nullif(btrim(coalesce(p_hero_titulo, '')), ''),
    hero_bajada = nullif(btrim(coalesce(p_hero_bajada, '')), ''),
    logo_path   = case when p_tocar_logo
                       then nullif(btrim(coalesce(p_logo_path, '')), '')
                       else logo_path end,
    hero_path   = case when p_tocar_hero
                       then nullif(btrim(coalesce(p_hero_path, '')), '')
                       else hero_path end,
    updated_at  = now()
  where id = p_tenant
  returning id into v_id;

  return v_id;
end $$;

-- El anónimo de la vitrina no tiene nada que hacer acá.
revoke execute on function public.actualizar_marca_tienda(
  uuid, text, text, text, text, text, boolean, text, boolean, text)
  from public, anon;
grant execute on function public.actualizar_marca_tienda(
  uuid, text, text, text, text, text, boolean, text, boolean, text)
  to authenticated;
