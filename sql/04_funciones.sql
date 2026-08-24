-- ═══════════════════════════════════════════════════════════════════════════
-- 04 · FUNCIONES RPC
-- ═══════════════════════════════════════════════════════════════════════════

-- ───────────────────────────────────────────────────────────────────────────
-- ajustar_stock — el ajuste de cantidad se aplica como DELTA, no como valor
-- absoluto.
--
-- Por qué: el botón +/- del stock es lo más probable que se toque en dos
-- dispositivos a la vez. Con last-write-wins sobre un valor absoluto, si dos
-- profesionales descuentan una unidad cada una estando offline, al sincronizar
-- queda descontada UNA. Enviando el delta y sumándolo del lado del servidor,
-- quedan las dos. Es la única excepción al LWW del motor de sync.
-- ───────────────────────────────────────────────────────────────────────────
create or replace function public.ajustar_stock(p_item uuid, p_delta int)
returns int
language plpgsql security definer set search_path = public as $$
declare
  v_tenant uuid;
  v_nueva  int;
begin
  select tenant_id into v_tenant from public.stock_items where id = p_item;
  if v_tenant is null then
    raise exception 'Item de stock inexistente: %', p_item;
  end if;

  if (public.puede_escribir(v_tenant) or public.es_superadmin()) is not true then
    raise exception 'Sin permiso para modificar el stock de este salón';
  end if;

  update public.stock_items
    set cantidad = greatest(0, cantidad + p_delta)   -- nunca negativo, igual que adjQ()
  where id = p_item
  returning cantidad into v_nueva;

  return v_nueva;
end;
$$;

-- ───────────────────────────────────────────────────────────────────────────
-- crear_tenant — alta transaccional de un salón nuevo.
-- Crea el tenant, su licencia inicial, el owner como miembro aprobado y un
-- catálogo de servicios de arranque. Todo o nada.
-- Solo la puede llamar un superadmin (vos o el revendedor).
-- ───────────────────────────────────────────────────────────────────────────
create or replace function public.crear_tenant(
  p_nombre    text,
  p_slug      text,
  p_owner     uuid,
  p_plan      text default 'basico',
  p_dias      int  default 30,
  p_telefono  text default null
)
returns uuid
language plpgsql security definer set search_path = public as $$
declare
  v_tenant uuid;
begin
  if public.es_superadmin() is not true then
    raise exception 'Solo un superadmin puede crear salones';
  end if;

  insert into public.tenants (nombre, slug, estado, plan, creado_por, telefono)
  values (p_nombre, p_slug, 'trial', p_plan, auth.uid(), p_telefono)
  returning id into v_tenant;

  insert into public.licencias (tenant_id, plan, vence_at)
  values (v_tenant, p_plan, now() + make_interval(days => p_dias));

  insert into public.tenant_members (tenant_id, user_id, rol, estado, invitado_por)
  values (v_tenant, p_owner, 'owner', 'approved', auth.uid())
  on conflict (tenant_id, user_id) do update
    set rol = 'owner', estado = 'approved';

  -- Catálogo de arranque: mismos valores que el seedDemo() de la app legacy,
  -- para que un salón nuevo no abra en blanco.
  insert into public.services (tenant_id, nombre, precio, duracion_min, retoque_dias, mantenimiento_dias)
  values
    (v_tenant, 'Extensiones Clásicas',  8000,  90, 21, 15),
    (v_tenant, 'Extensiones Volumen',  12000, 120, 21, 15),
    (v_tenant, 'Mega Volumen',         15000, 150, 21, 15),
    (v_tenant, 'Relleno Clásico',       5000,  60, 14, 10),
    (v_tenant, 'Relleno Volumen',       7000,  75, 14, 10),
    (v_tenant, 'Lifting de Pestañas',   6000,  60, 60, 30),
    (v_tenant, 'Diseño de Cejas',       3500,  45, 30, 20);

  insert into public.audit_log (actor_id, tenant_id, accion, entidad, entidad_id, meta)
  values (auth.uid(), v_tenant, 'crear', 'tenant', v_tenant::text,
          jsonb_build_object('nombre', p_nombre, 'plan', p_plan, 'dias', p_dias));

  return v_tenant;
end;
$$;

-- ───────────────────────────────────────────────────────────────────────────
-- renovar_licencia — suma días a partir del máximo entre hoy y el vencimiento
-- actual. Acumula, no reinicia: si renovás una licencia que todavía tiene 10
-- días, quedan 40, no 30. Es el mismo criterio del adminAddDays() legacy.
-- ───────────────────────────────────────────────────────────────────────────
create or replace function public.renovar_licencia(
  p_tenant uuid,
  p_dias   int default 30,
  p_monto  numeric default null,
  p_metodo text default null
)
returns timestamptz
language plpgsql security definer set search_path = public as $$
declare
  v_base  timestamptz;
  v_nuevo timestamptz;
begin
  if (public.es_superadmin() or public.es_revendedor_de(p_tenant)) is not true then
    raise exception 'Sin permiso para renovar la licencia de este salón';
  end if;

  select greatest(now(), coalesce(vence_at, now())) into v_base
    from public.licencias where tenant_id = p_tenant;

  if v_base is null then
    insert into public.licencias (tenant_id, vence_at)
    values (p_tenant, now() + make_interval(days => p_dias))
    returning vence_at into v_nuevo;
  else
    update public.licencias
      set vence_at = v_base + make_interval(days => p_dias)
    where tenant_id = p_tenant
    returning vence_at into v_nuevo;
  end if;

  update public.tenants set estado = 'activo' where id = p_tenant;

  if p_monto is not null then
    insert into public.licencia_pagos (tenant_id, monto, metodo, periodo_desde, periodo_hasta, registrado_por)
    values (p_tenant, p_monto, p_metodo, v_base::date, v_nuevo::date, auth.uid());
  end if;

  insert into public.audit_log (actor_id, tenant_id, accion, entidad, entidad_id, meta)
  values (auth.uid(), p_tenant, 'renovar', 'licencia', p_tenant::text,
          jsonb_build_object('dias', p_dias, 'vence_at', v_nuevo));

  return v_nuevo;
end;
$$;

-- ───────────────────────────────────────────────────────────────────────────
-- registrar_acceso — deja constancia de que alguien de la plataforma miró los
-- datos de un salón que no es suyo. La app la llama al entrar en modo
-- "ver como" y al abrir una vista de negocio ajena.
--
-- No se puede forzar por RLS que el cliente la llame, así que además se
-- audita del lado del servidor en las Edge Functions. Pero el camino normal
-- de la app SIEMPRE la llama: está en el interceptor del repositorio.
-- ───────────────────────────────────────────────────────────────────────────
create or replace function public.registrar_acceso(
  p_tenant  uuid,
  p_accion  text,
  p_entidad text default null,
  p_meta    jsonb default '{}'::jsonb
)
returns void
language plpgsql security definer set search_path = public as $$
begin
  -- No se audita al propio miembro operando su salón: sería ruido puro.
  if public.pertenece_a(p_tenant) then
    return;
  end if;

  insert into public.audit_log (actor_id, actor_email, tenant_id, accion, entidad, meta)
  values (
    auth.uid(),
    (select email from public.profiles where id = auth.uid()),
    p_tenant, p_accion, p_entidad, p_meta
  );
end;
$$;

-- ───────────────────────────────────────────────────────────────────────────
-- vencer_licencias — para el cron diario. Suspende los tenants vencidos.
-- Se invoca desde la Edge Function `chequear-vencimientos` con service-role.
-- ───────────────────────────────────────────────────────────────────────────
create or replace function public.vencer_licencias()
returns int
language plpgsql security definer set search_path = public as $$
declare v_n int;
begin
  update public.tenants t
    set estado = 'suspendido'
  from public.licencias l
  where l.tenant_id = t.id
    and l.vence_at < now()
    and t.estado in ('trial','activo');
  get diagnostics v_n = row_count;
  return v_n;
end;
$$;

-- ── Permisos de ejecución ─────────────────────────────────────────────────
-- OJO: en Postgres el EXECUTE se otorga a PUBLIC por defecto. Un
-- `revoke ... from authenticated` NO alcanza: el permiso sigue llegando por
-- PUBLIC y la función queda expuesta en /rest/v1/rpc/<nombre>.
-- Los grants finos están en 05_permisos.sql, que se corre después.
--
-- Guarda mínima acá, por si alguien corre este archivo suelto:
revoke all on function public.vencer_licencias() from public, anon, authenticated;
grant execute on function public.vencer_licencias() to service_role;
