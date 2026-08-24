-- ═══════════════════════════════════════════════════════════════════════════
-- 02 · NEGOCIO — las 7 entidades del salón
-- ═══════════════════════════════════════════════════════════════════════════
-- Patrón obligatorio de TODA tabla de negocio:
--   id uuid pk · tenant_id not null · created_at · updated_at · deleted_at
--
--   · tenant_id  → sin esto no hay aislamiento entre salones
--   · updated_at → cursor del pull incremental del motor de sync
--   · deleted_at → tombstone: un borrado real no se puede propagar a un
--                  cliente que estaba offline. NUNCA usar DELETE en estas
--                  tablas desde la app; se marca deleted_at.
--
-- Correcciones respecto del modelo legacy (IndexedDB), ver CLAUDE.md:
--   · precios y cantidades como numeric/int, no como string
--   · fechas como date/time, no strings 'YYYY-MM-DD' comparados lexicográficamente
--   · servicios vinculados por ID (appointment_services), no por nombre
--   · vip booleano, no el string 'true'
--   · transactions.client_id se escribe de verdad
-- ═══════════════════════════════════════════════════════════════════════════

do $$ begin
  create type turno_estado as enum ('confirmed','pending','done','cancelled');
exception when duplicate_object then null; end $$;

do $$ begin
  create type tx_tipo as enum ('income','expense');
exception when duplicate_object then null; end $$;

do $$ begin
  create type tx_metodo as enum ('efectivo','transferencia','tarjeta');
exception when duplicate_object then null; end $$;

-- ── professionals ─────────────────────────────────────────────────────────
create table if not exists public.professionals (
  id         uuid primary key default gen_random_uuid(),
  tenant_id  uuid not null references public.tenants(id) on delete cascade,
  nombre     text not null,
  telefono   text,
  activo     boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

-- ── services ──────────────────────────────────────────────────────────────
create table if not exists public.services (
  id                 uuid primary key default gen_random_uuid(),
  tenant_id          uuid not null references public.tenants(id) on delete cascade,
  nombre             text not null,
  precio             numeric(12,2) not null default 0,
  duracion_min       int not null default 60,
  retoque_dias       int,          -- alimenta los recordatorios de retoque
  mantenimiento_dias int,
  notas              text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

-- ── clients ───────────────────────────────────────────────────────────────
create table if not exists public.clients (
  id         uuid primary key default gen_random_uuid(),
  tenant_id  uuid not null references public.tenants(id) on delete cascade,
  nombre     text not null,
  telefono   text,
  email      text,
  cumple     date,
  vip        boolean not null default false,
  notas      text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);
create index if not exists idx_clients_tenant on public.clients(tenant_id) where deleted_at is null;

-- ── appointments ──────────────────────────────────────────────────────────
create table if not exists public.appointments (
  id              uuid primary key default gen_random_uuid(),
  tenant_id       uuid not null references public.tenants(id) on delete cascade,
  client_id       uuid references public.clients(id) on delete set null,
  professional_id uuid references public.professionals(id) on delete set null,
  fecha           date not null,
  hora            time,
  precio          numeric(12,2) not null default 0,
  estado          turno_estado not null default 'confirmed',
  notas           text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);
create index if not exists idx_appt_tenant_fecha
  on public.appointments(tenant_id, fecha) where deleted_at is null;
create index if not exists idx_appt_client on public.appointments(client_id);

-- Tabla puente: un turno puede tener varios servicios.
-- Reemplaza el array de STRINGS del legacy (`services: string[]` + el campo
-- `service` heredado). Vincular por nombre hacía que renombrar un servicio
-- rompiera silenciosamente los recordatorios de retoque.
create table if not exists public.appointment_services (
  appointment_id uuid not null references public.appointments(id) on delete cascade,
  service_id     uuid not null references public.services(id) on delete restrict,
  precio         numeric(12,2),   -- precio congelado al momento del turno
  primary key (appointment_id, service_id)
);

-- ── transactions ──────────────────────────────────────────────────────────
create table if not exists public.transactions (
  id          uuid primary key default gen_random_uuid(),
  tenant_id   uuid not null references public.tenants(id) on delete cascade,
  tipo        tx_tipo not null,
  monto       numeric(12,2) not null default 0,
  descripcion text,
  categoria   text,
  fecha       date not null,
  metodo      tx_metodo not null default 'efectivo',
  -- El legacy leía este campo en el CRM pero nunca lo escribía: "gastado por
  -- clienta" daba siempre $0. Acá se escribe.
  client_id      uuid references public.clients(id) on delete set null,
  appointment_id uuid references public.appointments(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);
create index if not exists idx_tx_tenant_fecha
  on public.transactions(tenant_id, fecha) where deleted_at is null;

-- ── stock_items ───────────────────────────────────────────────────────────
create table if not exists public.stock_items (
  id         uuid primary key default gen_random_uuid(),
  tenant_id  uuid not null references public.tenants(id) on delete cascade,
  nombre     text not null,
  categoria  text,
  cantidad   int not null default 0,
  minimo     int not null default 5,
  unidad     text not null default 'unidades',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);
create index if not exists idx_stock_tenant on public.stock_items(tenant_id) where deleted_at is null;

-- ── settings: configuración clave-valor por tenant ────────────────────────
create table if not exists public.settings (
  tenant_id  uuid not null references public.tenants(id) on delete cascade,
  key        text not null,
  value      jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now(),
  primary key (tenant_id, key)
);

-- ── Triggers de updated_at ────────────────────────────────────────────────
do $$
declare t text;
begin
  foreach t in array array[
    'professionals','services','clients','appointments','transactions','stock_items','settings'
  ]
  loop
    execute format('drop trigger if exists trg_updated_at on public.%I', t);
    execute format(
      'create trigger trg_updated_at before update on public.%I
         for each row execute function public.set_updated_at()', t);
  end loop;
end $$;

-- ── Índices de sync (cursor del pull incremental) ─────────────────────────
do $$
declare t text;
begin
  foreach t in array array[
    'professionals','services','clients','appointments','transactions','stock_items'
  ]
  loop
    execute format(
      'create index if not exists idx_%1$s_sync on public.%1$I(tenant_id, updated_at)', t);
  end loop;
end $$;
