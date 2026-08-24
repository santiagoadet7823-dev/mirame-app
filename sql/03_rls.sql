-- ═══════════════════════════════════════════════════════════════════════════
-- 03 · ROW LEVEL SECURITY
-- ═══════════════════════════════════════════════════════════════════════════
-- Tres niveles de acceso:
--   1. superadmin        → todo (vos y el revendedor)
--   2. revendedor_de(t)  → LEE los tenants que creó, no escribe sus datos de
--                          negocio, y toda lectura queda en audit_log
--   3. miembro de(t)     → su propio salón, según su rol
--
-- Las funciones son SECURITY DEFINER y STABLE: se evalúan una vez por query
-- en vez de por fila. Sin esto, una lista de 500 turnos dispara 500
-- subconsultas y la app se arrastra.
-- ═══════════════════════════════════════════════════════════════════════════

-- ── Helpers ───────────────────────────────────────────────────────────────

create or replace function public.es_superadmin()
returns boolean language sql stable security definer set search_path = public as $$
  select exists (
    select 1 from public.profiles
    where id = auth.uid() and plataforma_rol = 'superadmin'
  );
$$;

create or replace function public.es_revendedor_de(t uuid)
returns boolean language sql stable security definer set search_path = public as $$
  select exists (
    select 1 from public.tenants
    where id = t and creado_por = auth.uid()
  );
$$;

create or replace function public.pertenece_a(t uuid)
returns boolean language sql stable security definer set search_path = public as $$
  select exists (
    select 1 from public.tenant_members
    where tenant_id = t and user_id = auth.uid() and estado = 'approved'
  );
$$;

-- Rol del usuario actual dentro de un tenant (null si no pertenece)
create or replace function public.rol_en(t uuid)
returns miembro_rol language sql stable security definer set search_path = public as $$
  select rol from public.tenant_members
  where tenant_id = t and user_id = auth.uid() and estado = 'approved';
$$;

-- ¿Puede administrar el salón? (owner o admin)
--
-- El `coalesce` NO es cosmético: `rol_en()` devuelve NULL si el usuario no es
-- miembro, y `NULL in ('owner','admin')` evalúa a NULL, no a false. En una
-- policy eso es inofensivo (RLS trata NULL como deny), pero en plpgsql
-- `if not (NULL) then raise` NUNCA dispara. Sin esto, las guardas de las
-- funciones SECURITY DEFINER de 04_funciones.sql quedan inertes y un miembro
-- de un salón puede escribir en OTRO.
create or replace function public.administra(t uuid)
returns boolean language sql stable security definer set search_path = public as $$
  select coalesce(public.rol_en(t) in ('owner','admin'), false);
$$;

-- ¿Puede escribir datos de negocio? (todos menos 'lectura')
create or replace function public.puede_escribir(t uuid)
returns boolean language sql stable security definer set search_path = public as $$
  select coalesce(public.rol_en(t) in ('owner','admin','profesional'), false);
$$;

-- La licencia del tenant está vigente
create or replace function public.licencia_vigente(t uuid)
returns boolean language sql stable security definer set search_path = public as $$
  select exists (
    select 1
    from public.tenants tn
    left join public.licencias l on l.tenant_id = tn.id
    where tn.id = t
      and tn.estado in ('trial','activo')
      and (l.vence_at is null or l.vence_at > now())
  );
$$;

-- ═══════════════════════════════════════════════════════════════════════════
-- PLATAFORMA
-- ═══════════════════════════════════════════════════════════════════════════

alter table public.profiles        enable row level security;
alter table public.tenants         enable row level security;
alter table public.tenant_members  enable row level security;
alter table public.licencias       enable row level security;
alter table public.licencia_pagos  enable row level security;
alter table public.audit_log       enable row level security;
alter table public.app_config      enable row level security;
alter table public.device_tokens   enable row level security;

-- profiles: cada uno ve el suyo; el superadmin ve todos
drop policy if exists profiles_select on public.profiles;
create policy profiles_select on public.profiles for select
  using (id = auth.uid() or public.es_superadmin());

drop policy if exists profiles_update on public.profiles;
create policy profiles_update on public.profiles for update
  using (id = auth.uid() or public.es_superadmin())
  with check (id = auth.uid() or public.es_superadmin());

drop policy if exists profiles_admin_all on public.profiles;
create policy profiles_admin_all on public.profiles for all
  using (public.es_superadmin()) with check (public.es_superadmin());

-- Nadie se auto-promueve a superadmin.
--
-- Esto NO se puede hacer con un `with check` que compare contra el valor
-- anterior: una policy sobre `profiles` que consulta `profiles` provoca
-- recursión infinita en RLS. Va como trigger, que sí ve OLD y NEW.
create or replace function public.proteger_rol_plataforma()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  if new.plataforma_rol is distinct from old.plataforma_rol
     and public.es_superadmin() is not true then
    raise exception 'Solo un superadmin puede cambiar el rol de plataforma';
  end if;
  return new;
end;
$$;

drop trigger if exists trg_proteger_rol on public.profiles;
create trigger trg_proteger_rol before update on public.profiles
  for each row execute function public.proteger_rol_plataforma();

-- tenants
drop policy if exists tenants_select on public.tenants;
create policy tenants_select on public.tenants for select
  using (public.es_superadmin() or creado_por = auth.uid() or public.pertenece_a(id));

drop policy if exists tenants_write on public.tenants;
create policy tenants_write on public.tenants for all
  using (public.es_superadmin())
  with check (public.es_superadmin());

-- El owner puede editar los datos de su propio salón (nombre, teléfono),
-- pero no su estado ni su plan: eso es de la plataforma.
drop policy if exists tenants_owner_update on public.tenants;
create policy tenants_owner_update on public.tenants for update
  using (public.rol_en(id) = 'owner')
  with check (public.rol_en(id) = 'owner');

-- El bloqueo de estado/plan va en un trigger, no en el `with check`: una
-- policy sobre `tenants` que consulta `tenants` provoca recursión infinita
-- en RLS. El trigger ve OLD y NEW sin volver a pasar por las policies.
create or replace function public.proteger_estado_tenant()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  if (new.estado is distinct from old.estado or new.plan is distinct from old.plan)
     and (public.es_superadmin() or public.es_revendedor_de(old.id)) is not true then
    raise exception 'El estado y el plan del salón los administra la plataforma';
  end if;
  return new;
end;
$$;

drop trigger if exists trg_proteger_estado on public.tenants;
create trigger trg_proteger_estado before update on public.tenants
  for each row execute function public.proteger_estado_tenant();

-- tenant_members
drop policy if exists members_select on public.tenant_members;
create policy members_select on public.tenant_members for select
  using (
    user_id = auth.uid()
    or public.es_superadmin()
    or public.es_revendedor_de(tenant_id)
    or public.administra(tenant_id)
  );

-- Alta propia: un usuario nuevo se auto-inscribe SIEMPRE como 'pending'.
-- Es el equivalente del doc {status:'pending'} que creaba la app legacy.
drop policy if exists members_self_insert on public.tenant_members;
create policy members_self_insert on public.tenant_members for insert
  with check (user_id = auth.uid() and estado = 'pending' and rol = 'profesional');

drop policy if exists members_manage on public.tenant_members;
create policy members_manage on public.tenant_members for all
  using (public.es_superadmin() or public.es_revendedor_de(tenant_id) or public.administra(tenant_id))
  with check (public.es_superadmin() or public.es_revendedor_de(tenant_id) or public.administra(tenant_id));

-- licencias y pagos: los ve el tenant, los escribe la plataforma
drop policy if exists licencias_select on public.licencias;
create policy licencias_select on public.licencias for select
  using (public.es_superadmin() or public.es_revendedor_de(tenant_id) or public.pertenece_a(tenant_id));

drop policy if exists licencias_write on public.licencias;
create policy licencias_write on public.licencias for all
  using (public.es_superadmin() or public.es_revendedor_de(tenant_id))
  with check (public.es_superadmin() or public.es_revendedor_de(tenant_id));

drop policy if exists pagos_select on public.licencia_pagos;
create policy pagos_select on public.licencia_pagos for select
  using (public.es_superadmin() or public.es_revendedor_de(tenant_id) or public.administra(tenant_id));

drop policy if exists pagos_write on public.licencia_pagos;
create policy pagos_write on public.licencia_pagos for all
  using (public.es_superadmin() or public.es_revendedor_de(tenant_id))
  with check (public.es_superadmin() or public.es_revendedor_de(tenant_id));

-- audit_log: el tenant PUEDE ver quién miró sus datos. Nadie lo edita ni lo borra.
drop policy if exists audit_select on public.audit_log;
create policy audit_select on public.audit_log for select
  using (public.es_superadmin() or public.administra(tenant_id));

drop policy if exists audit_insert on public.audit_log;
create policy audit_insert on public.audit_log for insert
  with check (actor_id = auth.uid());

-- app_config: lo lee todo el mundo autenticado (el updater lo necesita),
-- lo escribe solo la plataforma (o el workflow con la service-role key).
drop policy if exists cfg_select on public.app_config;
create policy cfg_select on public.app_config for select
  using (auth.role() = 'authenticated');

-- `to authenticated` NO es decorativo. Sin eso la policy aplica al rol
-- `public`, y como es `for all` su USING se evalúa TAMBIÉN en los select:
-- llama a es_superadmin(), que `anon` no puede ejecutar (ver sql/05), y leer
-- app_config sin sesión falla con «permission denied for function» en vez de
-- devolver vacío. Lo pagó el auto-updater: consultaba antes del login y se
-- comía un error duro.
drop policy if exists cfg_write on public.app_config;
create policy cfg_write on public.app_config for all to authenticated
  using (public.es_superadmin()) with check (public.es_superadmin());

-- device_tokens: cada uno gestiona los suyos
drop policy if exists tokens_own on public.device_tokens;
create policy tokens_own on public.device_tokens for all
  using (user_id = auth.uid() or public.es_superadmin())
  with check (user_id = auth.uid() or public.es_superadmin());

-- ═══════════════════════════════════════════════════════════════════════════
-- NEGOCIO — una policy de lectura y una de escritura por tabla, idénticas.
-- ═══════════════════════════════════════════════════════════════════════════
-- LECTURA : miembro del tenant, superadmin, o revendedor que lo creó.
-- ESCRITURA: miembro con rol de escritura, o superadmin.
--            El revendedor NO escribe datos de negocio ajenos: puede ver para
--            dar soporte, no operar el salón de otro.
-- ═══════════════════════════════════════════════════════════════════════════

do $$
declare t text;
begin
  foreach t in array array[
    'professionals','services','clients','appointments','transactions','stock_items','settings'
  ]
  loop
    execute format('alter table public.%I enable row level security', t);

    execute format('drop policy if exists %1$s_select on public.%1$I', t);
    execute format($p$
      create policy %1$s_select on public.%1$I for select
        using (
          public.pertenece_a(tenant_id)
          or public.es_superadmin()
          or public.es_revendedor_de(tenant_id)
        )$p$, t);

    execute format('drop policy if exists %1$s_insert on public.%1$I', t);
    execute format($p$
      create policy %1$s_insert on public.%1$I for insert
        with check (public.puede_escribir(tenant_id) or public.es_superadmin())$p$, t);

    execute format('drop policy if exists %1$s_update on public.%1$I', t);
    execute format($p$
      create policy %1$s_update on public.%1$I for update
        using (public.puede_escribir(tenant_id) or public.es_superadmin())
        with check (public.puede_escribir(tenant_id) or public.es_superadmin())$p$, t);

    -- No hay policy de DELETE a propósito: los borrados son tombstones
    -- (update de deleted_at). Un DELETE real no se puede propagar a un
    -- cliente que estaba offline.
  end loop;
end $$;

-- appointment_services hereda el permiso del turno padre
alter table public.appointment_services enable row level security;

drop policy if exists appt_svc_select on public.appointment_services;
create policy appt_svc_select on public.appointment_services for select
  using (exists (
    select 1 from public.appointments a
    where a.id = appointment_id
      and (public.pertenece_a(a.tenant_id) or public.es_superadmin()
           or public.es_revendedor_de(a.tenant_id))
  ));

drop policy if exists appt_svc_write on public.appointment_services;
create policy appt_svc_write on public.appointment_services for all
  using (exists (
    select 1 from public.appointments a
    where a.id = appointment_id
      and (public.puede_escribir(a.tenant_id) or public.es_superadmin())
  ))
  with check (exists (
    select 1 from public.appointments a
    where a.id = appointment_id
      and (public.puede_escribir(a.tenant_id) or public.es_superadmin())
  ));
