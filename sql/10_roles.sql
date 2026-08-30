-- ═══════════════════════════════════════════════════════════════════════════
-- 10 · Quien atiende vs. quien maneja el negocio
--
-- Hasta acá `profesional` escribía casi todo, pero TODO el módulo de la tienda
-- exigía `administra()` — owner o admin. La app le ofrecía a un profesional
-- editar productos, el cambio se guardaba local, y el sync le fallaba en
-- silencio quedando trabado en el outbox. Nadie se enteraba.
--
-- Esto alinea las dos cosas y crea el rol que faltaba en el medio.
--
-- Se aplica en DOS migraciones: `alter type ... add value` no puede correr en
-- la misma transacción que un uso del valor nuevo.
-- ═══════════════════════════════════════════════════════════════════════════

-- ── Migración 1 · el valor del enum, solo ─────────────────────────────────
alter type miembro_rol add value if not exists 'encargado' after 'admin';


-- ── Migración 2 · las funciones y las policies ────────────────────────────

-- Opera el negocio: caja, tienda e insumos. NO usuarios ni ajustes.
create or replace function public.opera(t uuid)
returns boolean language sql stable security definer set search_path = public as $$
  select coalesce(public.rol_en(t) in ('owner','admin','encargado'), false);
$$;

-- El encargado también atiende.
create or replace function public.puede_escribir(t uuid)
returns boolean language sql stable security definer set search_path = public as $$
  select coalesce(
    public.rol_en(t) in ('owner','admin','encargado','profesional'), false);
$$;

grant execute on function public.opera(uuid) to authenticated;

-- La matriz que queda, verificada con `set request.jwt.claims`:
--
--   rol           pertenece  puede_escribir  opera  administra
--   owner            sí           sí          sí        sí
--   admin            sí           sí          sí        sí
--   encargado        sí           sí          sí        NO
--   profesional      sí           sí          NO        NO
--   lectura          sí           NO          NO        NO

-- ── El módulo de la tienda pasa de `administra` a `opera` ─────────────────
-- productos · producto_variantes · producto_fotos · proveedores · depositos ·
-- stock_variantes · movimientos_stock · liquidaciones · ventas
--
-- Cada tabla repite el mismo par insert/update; se muestra el patrón con
-- `productos` y el resto es idéntico (ver la migración aplicada).
drop policy if exists productos_insert on public.productos;
create policy productos_insert on public.productos for insert to authenticated
  with check (public.opera(tenant_id) or public.es_superadmin());
drop policy if exists productos_update on public.productos;
create policy productos_update on public.productos for update to authenticated
  using (public.opera(tenant_id) or public.es_superadmin())
  with check (public.opera(tenant_id) or public.es_superadmin());

-- `ventas` conserva su regla propia: el vendedor solo ve y carga las suyas.
drop policy if exists ventas_select on public.ventas;
create policy ventas_select on public.ventas for select to authenticated
  using (public.es_superadmin() or public.es_revendedor_de(tenant_id)
    or (public.pertenece_a(tenant_id)
        and (public.opera(tenant_id) or vendedor_id = auth.uid())));

-- ── Caja e insumos: el profesional deja de tocarlos ───────────────────────
drop policy if exists transactions_insert on public.transactions;
create policy transactions_insert on public.transactions for insert
  with check (public.opera(tenant_id) or public.es_superadmin());
drop policy if exists transactions_update on public.transactions;
create policy transactions_update on public.transactions for update
  using (public.opera(tenant_id) or public.es_superadmin())
  with check (public.opera(tenant_id) or public.es_superadmin());
-- `stock_items` igual.

-- ── Servicios, profesionales y ajustes son configuración, no operación ────
-- Pasan de `puede_escribir` a `administra`: un profesional no define el
-- catálogo de servicios del salón.
drop policy if exists services_insert on public.services;
create policy services_insert on public.services for insert
  with check (public.administra(tenant_id) or public.es_superadmin());
drop policy if exists services_update on public.services;
create policy services_update on public.services for update
  using (public.administra(tenant_id) or public.es_superadmin())
  with check (public.administra(tenant_id) or public.es_superadmin());
-- `professionals` y `settings` igual.

-- Sin cambios: appointments, appointment_services, clients (siguen en
-- `puede_escribir`), y tenant_members, audit_log, licencia_pagos,
-- deposito_encargados (siguen en `administra`).
