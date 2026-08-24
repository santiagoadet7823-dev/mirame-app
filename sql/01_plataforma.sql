-- ═══════════════════════════════════════════════════════════════════════════
-- 01 · PLATAFORMA — tenants, perfiles, membresías, licencias, auditoría, config
-- ═══════════════════════════════════════════════════════════════════════════
-- Ejecutar en: Supabase Dashboard → SQL Editor → pegar todo → Run.
-- Orden: 00 → 01 → 02 → 03 → 04 → 05 → 06.
-- ═══════════════════════════════════════════════════════════════════════════

create extension if not exists "pgcrypto";

-- ── Utilidad: mantiene updated_at al día ───────────────────────────────────
-- `set search_path` es obligatorio: sin él la función se puede secuestrar con
-- objetos en un esquema anterior del path (lo marca el linter de Supabase).
create or replace function public.set_updated_at()
returns trigger language plpgsql
set search_path = public as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

-- ── Tipos ─────────────────────────────────────────────────────────────────
do $$ begin
  create type tenant_estado as enum ('trial','activo','suspendido','cancelado');
exception when duplicate_object then null; end $$;

do $$ begin
  create type miembro_rol as enum ('owner','admin','profesional','lectura');
exception when duplicate_object then null; end $$;

do $$ begin
  create type miembro_estado as enum ('pending','approved','blocked');
exception when duplicate_object then null; end $$;

-- ── profiles: espejo de auth.users con el rol de plataforma ───────────────
-- plataforma_rol = 'superadmin' es el ÚNICO camino a los privilegios globales.
-- Se asigna a mano por SQL (05_seed_superadmins.sql). Nunca desde la app.
create table if not exists public.profiles (
  id            uuid primary key references auth.users(id) on delete cascade,
  email         text,
  nombre        text,
  avatar_url    text,
  plataforma_rol text check (plataforma_rol in ('superadmin')),
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now()
);

-- Alta automática del profile al registrarse
create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  insert into public.profiles (id, email, nombre, avatar_url)
  values (
    new.id,
    new.email,
    coalesce(new.raw_user_meta_data->>'full_name', new.raw_user_meta_data->>'name'),
    new.raw_user_meta_data->>'avatar_url'
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ── tenants: cada salón ───────────────────────────────────────────────────
create table if not exists public.tenants (
  id          uuid primary key default gen_random_uuid(),
  nombre      text not null,
  slug        text unique not null,
  estado      tenant_estado not null default 'trial',
  plan        text not null default 'basico',
  -- Quién lo dio de alta. Un revendedor solo administra los tenants que creó.
  creado_por  uuid references auth.users(id) on delete set null,
  telefono    text,
  timezone    text not null default 'America/Argentina/Salta',
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

-- ── tenant_members: quién puede entrar a qué salón y con qué rol ──────────
create table if not exists public.tenant_members (
  id         uuid primary key default gen_random_uuid(),
  tenant_id  uuid not null references public.tenants(id) on delete cascade,
  user_id    uuid not null references auth.users(id) on delete cascade,
  rol        miembro_rol not null default 'profesional',
  estado     miembro_estado not null default 'pending',
  invitado_por uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (tenant_id, user_id)
);

-- ── licencias: qué pagó cada tenant y hasta cuándo ────────────────────────
create table if not exists public.licencias (
  id         uuid primary key default gen_random_uuid(),
  tenant_id  uuid not null references public.tenants(id) on delete cascade,
  plan       text not null default 'basico',
  vence_at   timestamptz,
  precio     numeric(12,2),
  moneda     text not null default 'ARS',
  notas      text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create unique index if not exists uq_licencia_tenant on public.licencias(tenant_id);

create table if not exists public.licencia_pagos (
  id         uuid primary key default gen_random_uuid(),
  tenant_id  uuid not null references public.tenants(id) on delete cascade,
  monto      numeric(12,2) not null,
  moneda     text not null default 'ARS',
  metodo     text,
  periodo_desde date,
  periodo_hasta date,
  registrado_por uuid references auth.users(id) on delete set null,
  notas      text,
  created_at timestamptz not null default now()
);

-- ── audit_log: toda lectura o acción cross-tenant queda registrada ────────
-- No es opcional. Es lo que hace defendible que un revendedor pueda ver los
-- datos de negocio (y por lo tanto los datos personales de las clientas) de
-- los salones que vendió. El tenant puede consultarlo.
create table if not exists public.audit_log (
  id         bigint generated always as identity primary key,
  actor_id   uuid references auth.users(id) on delete set null,
  actor_email text,
  tenant_id  uuid references public.tenants(id) on delete cascade,
  accion     text not null,          -- 'impersonar' | 'leer' | 'crear' | 'suspender' | ...
  entidad    text,                   -- 'clients' | 'appointments' | 'tenant' | ...
  entidad_id text,
  meta       jsonb not null default '{}'::jsonb,
  at         timestamptz not null default now()
);
create index if not exists idx_audit_tenant_at on public.audit_log(tenant_id, at desc);
create index if not exists idx_audit_actor_at  on public.audit_log(actor_id, at desc);

-- ── app_config: plano de control de versiones (fila única) ────────────────
-- Contrato calcado del de la-union-app, ya probado en producción.
-- min_version es un PISO, no "la última": si la versión instalada es menor,
-- se le ofrece la actualización.
create table if not exists public.app_config (
  id             boolean primary key default true check (id),
  latest_version text,
  min_version    text,
  apk_url        text,
  pwa_version    text,
  mensaje_global text,
  updated_at     timestamptz not null default now()
);
insert into public.app_config (id, latest_version, min_version)
values (true, '1.0.0', '1.0.0')
on conflict (id) do nothing;

-- ── device_tokens: destinos de push (FCM) ─────────────────────────────────
create table if not exists public.device_tokens (
  id         uuid primary key default gen_random_uuid(),
  user_id    uuid not null references auth.users(id) on delete cascade,
  tenant_id  uuid references public.tenants(id) on delete cascade,
  token      text not null unique,
  plataforma text not null default 'android',
  updated_at timestamptz not null default now()
);
create index if not exists idx_tokens_tenant on public.device_tokens(tenant_id);

-- ── Triggers de updated_at ────────────────────────────────────────────────
do $$
declare t text;
begin
  foreach t in array array['profiles','tenants','tenant_members','licencias','device_tokens']
  loop
    execute format('drop trigger if exists trg_updated_at on public.%I', t);
    execute format(
      'create trigger trg_updated_at before update on public.%I
         for each row execute function public.set_updated_at()', t);
  end loop;
end $$;

-- ── Índices ───────────────────────────────────────────────────────────────
create index if not exists idx_members_user   on public.tenant_members(user_id);
create index if not exists idx_members_tenant on public.tenant_members(tenant_id);
create index if not exists idx_tenants_creador on public.tenants(creado_por);
