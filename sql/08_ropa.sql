-- ═══════════════════════════════════════════════════════════════════════════
-- 08 · ROPA — consignación, depósitos, vendedores y tienda pública
-- ═══════════════════════════════════════════════════════════════════════════
-- Mismo patrón obligatorio que sql/02_negocio.sql:
--   id uuid pk · tenant_id not null · created_at · updated_at · deleted_at
--   Nunca DELETE desde la app: tombstone con deleted_at.
--
-- ⚠️ CUIDADO CON LA PALABRA "REVENDEDOR".
--    En esta base ya significa otra cosa: `es_revendedor_de(tenant)` es el
--    socio que revende LA PLATAFORMA y da de alta salones. Quien vende ropa
--    en el salón es un `vendedor`. Mezclar los dos conceptos en un mismo
--    nombre sería un agujero de permisos esperando a pasar.
-- ═══════════════════════════════════════════════════════════════════════════

do $$ begin
  create type venta_estado as enum ('completada','anulada');
exception when duplicate_object then null; end $$;

do $$ begin
  create type reserva_estado as enum ('pendiente','confirmada','entregada','cancelada');
exception when duplicate_object then null; end $$;

do $$ begin
  create type liquidacion_tipo as enum ('proveedor','vendedor');
exception when duplicate_object then null; end $$;

do $$ begin
  create type liquidacion_estado as enum ('borrador','pagada');
exception when duplicate_object then null; end $$;

-- Motivo de cada movimiento de stock. Es lo que permite responder "¿qué pasó
-- con esta prenda?" sin reconstruirlo de otras tablas.
do $$ begin
  create type motivo_stock as enum
    ('ingreso','venta','devolucion_proveedor','transferencia','ajuste','anulacion');
exception when duplicate_object then null; end $$;

-- El rol nuevo. `profesional` no sirve: ese ve toda la agenda y la caja.
do $$ begin
  alter type miembro_rol add value if not exists 'vendedor';
exception when others then null; end $$;

-- ── proveedores ───────────────────────────────────────────────────────────
-- Quien entrega la mercadería a consignación.
create table if not exists public.proveedores (
  id         uuid primary key default gen_random_uuid(),
  tenant_id  uuid not null references public.tenants(id) on delete cascade,
  nombre     text not null,
  telefono   text,
  email      text,
  -- Porcentaje que se queda EL SALÓN. Es el default de sus productos; cada
  -- producto puede pisarlo.
  pct_salon  numeric(5,2) not null default 30 check (pct_salon between 0 and 100),
  -- Si ella hace un descuento, ¿lo absorbe sola o lo comparte el proveedor?
  -- Default: sale de la parte del salón, que es lo habitual en consignación.
  descuento_lo_absorbe_salon boolean not null default true,
  notas      text,
  activo     boolean not null default true,
  -- ESCALABILIDAD: cuando el proveedor sea cliente de la plataforma, acá se
  -- enlaza su propio tenant y puede ver su mercadería repartida entre salones.
  -- Cuesta nada dejarlo ahora y evita una migración con datos reales adentro.
  tenant_proveedor_id uuid references public.tenants(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

-- ── depositos ─────────────────────────────────────────────────────────────
create table if not exists public.depositos (
  id           uuid primary key default gen_random_uuid(),
  tenant_id    uuid not null references public.tenants(id) on delete cascade,
  nombre       text not null,
  direccion    text,
  es_principal boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

-- Qué vendedor atiende qué depósito. Un vendedor puede tener varios.
create table if not exists public.deposito_encargados (
  deposito_id uuid not null references public.depositos(id) on delete cascade,
  user_id     uuid not null references auth.users(id) on delete cascade,
  created_at  timestamptz not null default now(),
  primary key (deposito_id, user_id)
);

-- ── productos ─────────────────────────────────────────────────────────────
create table if not exists public.productos (
  id           uuid primary key default gen_random_uuid(),
  tenant_id    uuid not null references public.tenants(id) on delete cascade,
  proveedor_id uuid references public.proveedores(id) on delete set null,
  nombre       text not null,
  descripcion  text,
  categoria    text,
  -- Código corto tipo MIR-042: para buscarlo al instante y para que la clienta
  -- lo nombre por WhatsApp sin tener que describir la prenda.
  codigo       text,
  precio       numeric(12,2) not null default 0,
  -- Pisa el del proveedor cuando este producto tiene otro acuerdo.
  pct_salon    numeric(5,2) check (pct_salon between 0 and 100),
  publicado    boolean not null default false,
  destacado    boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  unique (tenant_id, codigo)
);

-- ── producto_variantes ────────────────────────────────────────────────────
-- Talle × color. Cada combinación es lo que de verdad se vende y se cuenta.
create table if not exists public.producto_variantes (
  id          uuid primary key default gen_random_uuid(),
  tenant_id   uuid not null references public.tenants(id) on delete cascade,
  producto_id uuid not null references public.productos(id) on delete cascade,
  talle       text,
  color       text,
  sku         text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

-- ── stock_variantes ───────────────────────────────────────────────────────
-- Cuánto hay de cada variante EN CADA DEPÓSITO.
create table if not exists public.stock_variantes (
  id          uuid primary key default gen_random_uuid(),
  tenant_id   uuid not null references public.tenants(id) on delete cascade,
  variante_id uuid not null references public.producto_variantes(id) on delete cascade,
  deposito_id uuid not null references public.depositos(id) on delete cascade,
  cantidad    int not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  unique (variante_id, deposito_id)
);

-- ── producto_fotos ────────────────────────────────────────────────────────
create table if not exists public.producto_fotos (
  id          uuid primary key default gen_random_uuid(),
  tenant_id   uuid not null references public.tenants(id) on delete cascade,
  producto_id uuid not null references public.productos(id) on delete cascade,
  -- Foto de un color puntual. Null = foto del producto en general.
  variante_id uuid references public.producto_variantes(id) on delete cascade,
  path        text not null,      -- ruta en el bucket `productos`
  orden       int not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

-- ── ventas ────────────────────────────────────────────────────────────────
create table if not exists public.ventas (
  id           uuid primary key default gen_random_uuid(),
  tenant_id    uuid not null references public.tenants(id) on delete cascade,
  deposito_id  uuid references public.depositos(id) on delete set null,
  -- Quién vendió. Null = la dueña desde su propia cuenta.
  vendedor_id  uuid references auth.users(id) on delete set null,
  -- Alimenta el "total gastado" que ya muestra la ficha de clienta.
  client_id    uuid references public.clients(id) on delete set null,
  fecha        date not null default current_date,
  total        numeric(12,2) not null default 0,
  descuento    numeric(12,2) not null default 0,
  metodo       tx_metodo not null default 'efectivo',
  estado       venta_estado not null default 'completada',
  notas        text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

-- ── venta_items ───────────────────────────────────────────────────────────
-- Los porcentajes y los montos van CONGELADOS acá.
--
-- Guardar solo una referencia al proveedor haría que cambiarle el porcentaje
-- recalculara ventas viejas, y las liquidaciones ya pagadas dejarían de
-- cuadrar. Es el mismo error de fondo que el legacy cometía al vincular los
-- servicios de un turno por NOMBRE.
create table if not exists public.venta_items (
  id          uuid primary key default gen_random_uuid(),
  tenant_id   uuid not null references public.tenants(id) on delete cascade,
  venta_id    uuid not null references public.ventas(id) on delete cascade,
  variante_id uuid references public.producto_variantes(id) on delete set null,
  -- Denormalizado a propósito: si mañana se borra el producto, la venta vieja
  -- tiene que seguir siendo legible.
  descripcion text,
  cantidad    int not null default 1,
  precio_unit numeric(12,2) not null default 0,
  pct_salon     numeric(5,2) not null default 0,
  pct_vendedor  numeric(5,2) not null default 0,
  monto_proveedor numeric(12,2) not null default 0,
  monto_salon     numeric(12,2) not null default 0,
  monto_vendedor  numeric(12,2) not null default 0,
  -- Se marca al incluirlo en una liquidación, para no pagarlo dos veces.
  liquidacion_id uuid,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

-- ── reservas ──────────────────────────────────────────────────────────────
-- Las crea una clienta desde la tienda pública, sin cuenta.
create table if not exists public.reservas (
  id         uuid primary key default gen_random_uuid(),
  tenant_id  uuid not null references public.tenants(id) on delete cascade,
  -- Corto y legible: la clienta lo dice por WhatsApp o lo muestra al retirar.
  codigo     text not null,
  nombre     text not null,
  telefono   text,
  estado     reserva_estado not null default 'pendiente',
  vence_at   timestamptz not null,
  notas      text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  unique (tenant_id, codigo)
);

create table if not exists public.reserva_items (
  id          uuid primary key default gen_random_uuid(),
  tenant_id   uuid not null references public.tenants(id) on delete cascade,
  reserva_id  uuid not null references public.reservas(id) on delete cascade,
  variante_id uuid not null references public.producto_variantes(id) on delete cascade,
  cantidad    int not null default 1,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

-- ── liquidaciones ─────────────────────────────────────────────────────────
create table if not exists public.liquidaciones (
  id             uuid primary key default gen_random_uuid(),
  tenant_id      uuid not null references public.tenants(id) on delete cascade,
  tipo           liquidacion_tipo not null,
  -- proveedores.id cuando tipo='proveedor'; auth.users.id cuando 'vendedor'.
  -- Sin FK porque apunta a dos tablas distintas segun el tipo.
  destinatario_id uuid not null,
  periodo_desde  date not null,
  periodo_hasta  date not null,
  total          numeric(12,2) not null default 0,
  estado         liquidacion_estado not null default 'borrador',
  pagada_at      timestamptz,
  notas          text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

-- ── movimientos_stock ─────────────────────────────────────────────────────
-- La fuente de verdad del inventario. `stock_variantes.cantidad` es el saldo
-- acumulado; esto es el detalle de cómo se llegó a ese número.
create table if not exists public.movimientos_stock (
  id          uuid primary key default gen_random_uuid(),
  tenant_id   uuid not null references public.tenants(id) on delete cascade,
  variante_id uuid not null references public.producto_variantes(id) on delete cascade,
  deposito_id uuid not null references public.depositos(id) on delete cascade,
  delta       int not null,
  motivo      motivo_stock not null,
  -- La venta, la liquidación o la transferencia que lo originó.
  referencia_id uuid,
  notas       text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

-- ── Índices ───────────────────────────────────────────────────────────────
create index if not exists productos_tenant_idx    on public.productos(tenant_id) where deleted_at is null;
create index if not exists productos_publicado_idx on public.productos(tenant_id, publicado) where deleted_at is null;
create index if not exists variantes_producto_idx  on public.producto_variantes(producto_id) where deleted_at is null;
create index if not exists stock_variante_idx      on public.stock_variantes(variante_id, deposito_id);
create index if not exists fotos_producto_idx      on public.producto_fotos(producto_id, orden) where deleted_at is null;
create index if not exists ventas_tenant_fecha_idx on public.ventas(tenant_id, fecha desc) where deleted_at is null;
create index if not exists venta_items_venta_idx   on public.venta_items(venta_id);
-- Lo que pide la liquidación: ítems de un período todavía sin liquidar.
create index if not exists venta_items_pendientes_idx
  on public.venta_items(tenant_id) where liquidacion_id is null and deleted_at is null;
create index if not exists reservas_vigentes_idx
  on public.reservas(tenant_id, estado, vence_at) where deleted_at is null;
create index if not exists movimientos_variante_idx
  on public.movimientos_stock(variante_id, created_at desc);
