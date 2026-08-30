-- ═══════════════════════════════════════════════════════════════════════════
-- 09 · ROPA — permisos, tienda pública y reservas
-- ═══════════════════════════════════════════════════════════════════════════

-- ── ¿Este usuario atiende este depósito? ──────────────────────────────────
-- Hermano de pertenece_a(). Un vendedor solo ve lo que hay en los depósitos
-- que tiene asignados.
create or replace function public.atiende_deposito(d uuid)
returns boolean language sql stable security definer set search_path = public as $$
  select exists (select 1 from public.deposito_encargados
                 where deposito_id = d and user_id = auth.uid());
$$;

create or replace function public.es_vendedor_en(t uuid)
returns boolean language sql stable security definer set search_path = public as $$
  select coalesce(public.rol_en(t)::text = 'vendedor', false);
$$;

-- ═══════════════════════════════════════════════════════════════════════════
-- Catálogo: lo ve todo el salón, lo escribe quien administra.
--
-- El vendedor NO edita el catálogo ni los precios: vende lo que hay. Dejarlo
-- tocar `pct_salon` sería dejarlo escribir su propia comisión.
-- ═══════════════════════════════════════════════════════════════════════════
do $$
declare t text;
begin
  foreach t in array array['proveedores','depositos','productos','producto_variantes',
    'stock_variantes','producto_fotos','liquidaciones','movimientos_stock']
  loop
    execute format('alter table public.%I enable row level security', t);
    execute format('drop policy if exists %1$s_select on public.%1$I', t);
    execute format($p$create policy %1$s_select on public.%1$I for select to authenticated
      using (public.pertenece_a(tenant_id) or public.es_superadmin()
             or public.es_revendedor_de(tenant_id))$p$, t);
    execute format('drop policy if exists %1$s_insert on public.%1$I', t);
    execute format($p$create policy %1$s_insert on public.%1$I for insert to authenticated
      with check (public.administra(tenant_id) or public.es_superadmin())$p$, t);
    execute format('drop policy if exists %1$s_update on public.%1$I', t);
    execute format($p$create policy %1$s_update on public.%1$I for update to authenticated
      using (public.administra(tenant_id) or public.es_superadmin())
      with check (public.administra(tenant_id) or public.es_superadmin())$p$, t);
  end loop;
end $$;

-- Excepción: el stock SÍ lo mueve el vendedor de su depósito, porque vender es
-- exactamente eso. Se suma a la policy de administración, no la reemplaza.
drop policy if exists stock_variantes_vendedor on public.stock_variantes;
create policy stock_variantes_vendedor on public.stock_variantes for update to authenticated
  using (public.atiende_deposito(deposito_id))
  with check (public.atiende_deposito(deposito_id));

drop policy if exists movimientos_vendedor on public.movimientos_stock;
create policy movimientos_vendedor on public.movimientos_stock for insert to authenticated
  with check (public.atiende_deposito(deposito_id));

-- ═══════════════════════════════════════════════════════════════════════════
-- Ventas: el vendedor ve y carga LAS SUYAS. Quien administra las ve todas.
-- ═══════════════════════════════════════════════════════════════════════════
alter table public.ventas enable row level security;

drop policy if exists ventas_select on public.ventas;
create policy ventas_select on public.ventas for select to authenticated
  using (public.es_superadmin() or public.es_revendedor_de(tenant_id)
         or (public.pertenece_a(tenant_id)
             and (public.administra(tenant_id) or vendedor_id = auth.uid())));

drop policy if exists ventas_insert on public.ventas;
create policy ventas_insert on public.ventas for insert to authenticated
  with check (public.es_superadmin()
    or (public.pertenece_a(tenant_id) and (public.administra(tenant_id)
        -- Un vendedor solo carga ventas A SU NOMBRE y de su depósito: si no,
        -- podría anotarle ventas a otro o inflar su propia liquidación.
        or (vendedor_id = auth.uid() and public.atiende_deposito(deposito_id)))));

drop policy if exists ventas_update on public.ventas;
create policy ventas_update on public.ventas for update to authenticated
  using (public.es_superadmin() or (public.pertenece_a(tenant_id)
         and (public.administra(tenant_id) or vendedor_id = auth.uid())))
  with check (public.es_superadmin() or (public.pertenece_a(tenant_id)
         and (public.administra(tenant_id) or vendedor_id = auth.uid())));

-- Los ítems heredan el permiso de su venta.
alter table public.venta_items enable row level security;
drop policy if exists venta_items_select on public.venta_items;
create policy venta_items_select on public.venta_items for select to authenticated
  using (exists (select 1 from public.ventas v where v.id = venta_id));
drop policy if exists venta_items_write on public.venta_items;
create policy venta_items_write on public.venta_items for all to authenticated
  using (exists (select 1 from public.ventas v where v.id = venta_id))
  with check (exists (select 1 from public.ventas v where v.id = venta_id));

-- Reservas: las administra el salón; la clienta las crea por RPC.
do $$
declare t text;
begin
  foreach t in array array['reservas','reserva_items']
  loop
    execute format('alter table public.%I enable row level security', t);
    execute format('drop policy if exists %1$s_all on public.%1$I', t);
    execute format($p$create policy %1$s_all on public.%1$I for all to authenticated
      using (public.pertenece_a(tenant_id) or public.es_superadmin())
      with check (public.pertenece_a(tenant_id) or public.es_superadmin())$p$, t);
  end loop;
end $$;

alter table public.deposito_encargados enable row level security;
drop policy if exists deposito_encargados_all on public.deposito_encargados;
create policy deposito_encargados_all on public.deposito_encargados for all to authenticated
  using (user_id = auth.uid()
    or exists (select 1 from public.depositos d
               where d.id = deposito_id and public.administra(d.tenant_id))
    or public.es_superadmin())
  with check (exists (select 1 from public.depositos d
                      where d.id = deposito_id and public.administra(d.tenant_id))
    or public.es_superadmin());

-- ═══════════════════════════════════════════════════════════════════════════
-- TIENDA PÚBLICA
-- ═══════════════════════════════════════════════════════════════════════════

-- Cuánto hay realmente disponible: el stock menos lo reservado y vigente.
--
-- Se CALCULA en vez de descontar al reservar. Descontar exige un proceso que
-- devuelva el stock cuando la reserva vence, y el día que ese proceso falla
-- quedan prendas trabadas que nadie puede comprar y nadie entiende por qué.
-- Así, una reserva vencida deja de contar sola.
--
-- Va como FUNCIÓN y no como vista: calcularlo exige leer `reservas`, y una
-- vista que lea reservas obligaría a abrirle esa tabla al anónimo. Una función
-- `security definer` devuelve un único número y no filtra nada más.
create or replace function public.stock_disponible(p_variante uuid)
returns int language sql stable security definer set search_path = public as $$
  select greatest(0,
    coalesce((select sum(cantidad)::int from public.stock_variantes
              where variante_id = p_variante and deleted_at is null), 0)
    - coalesce((select sum(ri.cantidad)::int
                from public.reserva_items ri
                join public.reservas r on r.id = ri.reserva_id
                where ri.variante_id = p_variante and ri.deleted_at is null
                  and r.deleted_at is null
                  and r.estado in ('pendiente','confirmada')
                  and r.vence_at > now()), 0));
$$;

-- Las vistas son `security_invoker`: corren con los permisos de QUIEN
-- consulta, no con los del dueño. Es lo que exige el linter de Supabase, y
-- además deja una segunda barrera — aunque alguien apunte directo a la tabla,
-- solo lee las columnas y las filas que se le concedieron.
create or replace view public.tienda_productos
with (security_invoker = true) as
  select p.id, p.tenant_id, t.slug as tienda, p.nombre, p.descripcion,
         p.categoria, p.codigo, p.precio, p.destacado, p.created_at
  from public.productos p
  join public.tenants t on t.id = p.tenant_id
  where p.deleted_at is null and p.publicado = true
    and t.estado in ('trial','activo');

create or replace view public.tienda_variantes
with (security_invoker = true) as
  select v.id, v.producto_id, v.talle, v.color,
         public.stock_disponible(v.id) as disponible
  from public.producto_variantes v
  join public.tienda_productos p on p.id = v.producto_id
  where v.deleted_at is null;

create or replace view public.tienda_fotos
with (security_invoker = true) as
  select f.id, f.producto_id, f.variante_id, f.path, f.orden
  from public.producto_fotos f
  join public.tienda_productos p on p.id = f.producto_id
  where f.deleted_at is null;

-- La vitrina también necesita saber a qué salón pertenece: el nombre para el
-- título y el teléfono para el botón de WhatsApp. Sin esto la página se llama
-- "Tienda" a secas y el botón de WhatsApp no se muestra nunca, porque la
-- variable que lo condiciona se queda en null.
create or replace view public.tienda_salon
with (security_invoker = true) as
  select t.slug as tienda, t.nombre, t.telefono
  from public.tenants t
  where t.estado in ('trial','activo');

-- ═══════════════════════════════════════════════════════════════════════════
-- ⚠️ PERMISOS POR COLUMNA — hay que REVOCAR antes de conceder
--
-- Supabase le da a `anon` un SELECT sobre TODAS las columnas de todas las
-- tablas de `public`. Mientras ninguna tabla de negocio tuvo policy para
-- `anon`, eso no importaba: RLS no le devolvía ni una fila.
--
-- Pero al abrir la vitrina, `productos` SÍ tiene una policy para `anon`. Con
-- la policy y el grant heredado, un anónimo podía pedir
--   /rest/v1/productos?select=pct_salon,proveedor_id&publicado=eq.true
-- y ver el reparto del negocio. Las vistas no lo tapan: no sirven de nada si
-- la tabla de abajo está abierta.
--
-- Sumar `grant select (columnas)` NO alcanza — agregar permisos no quita el
-- que ya estaba. El `revoke` es lo que hace el trabajo.
-- ═══════════════════════════════════════════════════════════════════════════
revoke select on public.productos from anon;
grant select (id, tenant_id, nombre, descripcion, categoria, codigo, precio,
              destacado, created_at, publicado, deleted_at)
  on public.productos to anon;

revoke select on public.producto_variantes from anon;
grant select (id, tenant_id, producto_id, talle, color, deleted_at)
  on public.producto_variantes to anon;

revoke select on public.producto_fotos from anon;
grant select (id, tenant_id, producto_id, variante_id, path, orden, deleted_at)
  on public.producto_fotos to anon;

-- `tenants` cae en la misma trampa, y ahí ya estaba pasando: desde que existe
-- la policy `tenants_vitrina`, el grant heredado le devolvía a cualquier
-- anónimo el resultado de
--   /rest/v1/tenants?select=creado_por,plan
-- es decir, quién dio de alta cada salón y qué plan paga.
-- `id` y `estado` se conceden porque las vistas `security_invoker` los usan
-- para el join y para el where, corriendo como el llamador.
revoke select on public.tenants from anon;
grant select (id, nombre, slug, telefono, estado) on public.tenants to anon;

-- El teléfono del salón y quién lo creó no son de la vitrina.
revoke select on public.tenants from anon;
grant select (id, slug, nombre, estado) on public.tenants to anon;

grant select on public.tienda_productos, public.tienda_variantes,
                public.tienda_fotos, public.tienda_salon to anon, authenticated;

-- Y las FILAS: solo lo publicado, de un salón operativo.
drop policy if exists productos_vitrina on public.productos;
create policy productos_vitrina on public.productos for select to anon
  using (publicado = true and deleted_at is null
         and exists (select 1 from public.tenants t
                     where t.id = tenant_id and t.estado in ('trial','activo')));

drop policy if exists variantes_vitrina on public.producto_variantes;
create policy variantes_vitrina on public.producto_variantes for select to anon
  using (deleted_at is null
         and exists (select 1 from public.productos p
                     where p.id = producto_id and p.publicado = true
                       and p.deleted_at is null));

drop policy if exists fotos_vitrina on public.producto_fotos;
create policy fotos_vitrina on public.producto_fotos for select to anon
  using (deleted_at is null
         and exists (select 1 from public.productos p
                     where p.id = producto_id and p.publicado = true
                       and p.deleted_at is null));

drop policy if exists tenants_vitrina on public.tenants;
create policy tenants_vitrina on public.tenants for select to anon
  using (estado in ('trial','activo'));

-- Las policies viejas de `tenants` no tenían cláusula `to`, así que aplicaban
-- a PUBLIC — incluido `anon`. Postgres evalúa TODAS las policies aplicables, y
-- estas llaman a `es_superadmin()`, que un anónimo no puede ejecutar: la
-- vitrina moría con "permission denied for function es_superadmin" en vez de
-- simplemente no mostrar nada. Se acotan a `authenticated`, que es a quienes
-- siempre apuntaron.
drop policy if exists tenants_select on public.tenants;
create policy tenants_select on public.tenants for select to authenticated
  using (public.es_superadmin() or creado_por = auth.uid() or public.pertenece_a(id));

drop policy if exists tenants_write on public.tenants;
create policy tenants_write on public.tenants for all to authenticated
  using (public.es_superadmin()) with check (public.es_superadmin());

drop policy if exists tenants_owner_update on public.tenants;
create policy tenants_owner_update on public.tenants for update to authenticated
  using (public.rol_en(id) = 'owner') with check (public.rol_en(id) = 'owner');

-- ── Crear una reserva desde la vitrina ────────────────────────────────────
-- No hay policy de insert para `anon` sobre `reservas` a propósito: sería una
-- invitación a llenar la tabla de basura. Todo pasa por acá, que valida stock
-- y limita el tamaño del pedido.
create or replace function public.crear_reserva(
  p_tienda text, p_nombre text, p_telefono text, p_items jsonb, p_horas int default 48
) returns text language plpgsql security definer set search_path = public as $$
declare v_tenant uuid; v_reserva uuid; v_codigo text; v_item jsonb; v_disp int; v_try int := 0;
begin
  select id into v_tenant from public.tenants
   where slug = p_tienda and estado in ('trial','activo');
  if v_tenant is null then raise exception 'La tienda no esta disponible'; end if;
  if coalesce(trim(p_nombre), '') = '' then raise exception 'Falta el nombre'; end if;
  -- Un pedido de 50 ítems no es una clienta, es un ataque.
  if jsonb_array_length(p_items) not between 1 and 20 then
    raise exception 'El pedido tiene que tener entre 1 y 20 prendas'; end if;

  -- El código sale de `gen_random_uuid()`, que es nativo. `gen_random_bytes`
  -- es de pgcrypto, vive en el esquema `extensions`, y con
  -- `search_path = public` no se encuentra: la función fallaba entera al crear
  -- la primera reserva.
  --
  -- El hexadecimal no tiene O ni l, así que no hay ambigüedad al dictarlo por
  -- teléfono.
  loop
    v_try := v_try + 1;
    v_codigo := upper(substr(replace(gen_random_uuid()::text, '-', ''), 1, 6));
    exit when not exists (select 1 from public.reservas
                          where tenant_id = v_tenant and codigo = v_codigo);
    if v_try > 10 then raise exception 'No se pudo generar el codigo'; end if;
  end loop;

  insert into public.reservas (tenant_id, codigo, nombre, telefono, vence_at)
  values (v_tenant, v_codigo, trim(p_nombre), nullif(trim(p_telefono), ''),
          now() + make_interval(hours => greatest(1, least(p_horas, 168))))
  returning id into v_reserva;

  for v_item in select * from jsonb_array_elements(p_items)
  loop
    -- El stock se valida DENTRO de la transacción: dos clientas que reservan
    -- la última prenda a la vez, y la segunda rebota.
    select public.stock_disponible((v_item->>'variante_id')::uuid) into v_disp;
    if coalesce(v_disp, 0) < (v_item->>'cantidad')::int then
      raise exception 'Se quedo sin stock una de las prendas'; end if;
    insert into public.reserva_items (tenant_id, reserva_id, variante_id, cantidad)
    values (v_tenant, v_reserva, (v_item->>'variante_id')::uuid,
            greatest(1, least((v_item->>'cantidad')::int, 10)));
  end loop;
  return v_codigo;
end; $$;

-- ── Ajuste de stock por delta ─────────────────────────────────────────────
-- Igual que `ajustar_stock` del inventario del salón: dos ventas offline del
-- mismo producto resueltas por last-write-wins pierden una.
create or replace function public.ajustar_stock_variante(
  p_variante uuid, p_deposito uuid, p_delta int,
  p_motivo motivo_stock default 'ajuste', p_ref uuid default null
) returns void language plpgsql security definer set search_path = public as $$
declare v_tenant uuid;
begin
  select tenant_id into v_tenant from public.producto_variantes where id = p_variante;
  if v_tenant is null then raise exception 'La variante no existe'; end if;
  if not (public.pertenece_a(v_tenant) or public.es_superadmin()) then
    raise exception 'Sin permiso'; end if;

  insert into public.stock_variantes (tenant_id, variante_id, deposito_id, cantidad)
  values (v_tenant, p_variante, p_deposito, greatest(0, p_delta))
  on conflict (variante_id, deposito_id) do update
    set cantidad = greatest(0, public.stock_variantes.cantidad + p_delta),
        updated_at = now();

  insert into public.movimientos_stock
    (tenant_id, variante_id, deposito_id, delta, motivo, referencia_id)
  values (v_tenant, p_variante, p_deposito, p_delta, p_motivo, p_ref);
end; $$;

-- ⚠️ `revoke ... from anon` NO alcanza: toda función nace con EXECUTE para
-- PUBLIC y `anon` lo hereda de ahí. Hay que revocar en PUBLIC.
revoke execute on function public.atiende_deposito(uuid) from public;
grant  execute on function public.atiende_deposito(uuid) to authenticated;
revoke execute on function public.es_vendedor_en(uuid) from public;
grant  execute on function public.es_vendedor_en(uuid) to authenticated;
revoke execute on function public.ajustar_stock_variante(uuid, uuid, int, motivo_stock, uuid) from public;
grant  execute on function public.ajustar_stock_variante(uuid, uuid, int, motivo_stock, uuid) to authenticated;

-- Estas dos SÍ quedan abiertas: son la puerta de la vitrina.
-- `stock_disponible` devuelve un único entero y `crear_reserva` valida todo
-- adentro. Es acceso público deliberado, no un descuido.
revoke execute on function public.crear_reserva(text, text, text, jsonb, int) from public;
grant  execute on function public.crear_reserva(text, text, text, jsonb, int) to anon, authenticated;
grant  execute on function public.stock_disponible(uuid) to anon, authenticated;
