-- ═══════════════════════════════════════════════════════════════════════════
-- 06 · SEED DE SUPERADMINS
-- ═══════════════════════════════════════════════════════════════════════════
-- Este es el ÚNICO camino para crear un superadmin. No hay ninguna pantalla en
-- la app que lo haga, y el trigger `proteger_rol_plataforma` lo impide.
-- Es a propósito: un superadmin ve los datos de todos los salones.
--
-- Requisito: la persona tiene que haber entrado a la app con Google al menos
-- una vez, para que exista su fila en `auth.users` (y su `profiles`, que crea
-- el trigger `handle_new_user`).
--
-- Para encontrar el UID:
--   select id, email, nombre from public.profiles order by created_at desc;
-- ═══════════════════════════════════════════════════════════════════════════

-- ───────────────────────────────────────────────────────────────────────────
-- EL PROBLEMA DEL HUEVO Y LA GALLINA
-- ───────────────────────────────────────────────────────────────────────────
-- `proteger_rol_plataforma` exige que quien cambia `plataforma_rol` YA sea
-- superadmin. Desde el SQL Editor no hay sesión, así que `auth.uid()` es null,
-- `es_superadmin()` da false y el update se rechaza.
--
-- Para el PRIMER superadmin no hay alternativa: hay que desactivar el trigger
-- un instante. Va todo en UNA transacción, de modo que si algo falla el
-- trigger no queda desactivado.
--
-- Del SEGUNDO en adelante NO hace falta: un superadmin ya puede promover a
-- otro desde la app o con su propia sesión.
-- ───────────────────────────────────────────────────────────────────────────

begin;

alter table public.profiles disable trigger trg_proteger_rol;

-- ── Superadmin 1 — dueño del producto ─────────────────────────────────────
-- Aplicado el 2026-08-23.
update public.profiles
set plataforma_rol = 'superadmin'
where id = '6e87e720-77c7-44b1-b1c2-68780c13cde5';   -- santiagoadet7823@gmail.com

-- ── Superadmin 2 — revendedor ─────────────────────────────────────────────
-- PENDIENTE: descomentar y poner el UID cuando el revendedor haya entrado
-- una vez a la app.
-- update public.profiles
-- set plataforma_rol = 'superadmin'
-- where id = 'PEGAR-UID-DEL-REVENDEDOR';

alter table public.profiles enable trigger trg_proteger_rol;

commit;

-- ═══════════════════════════════════════════════════════════════════════════
-- VERIFICACIÓN — no saltear
-- ═══════════════════════════════════════════════════════════════════════════

-- 1. Los superadmins esperados, y solo ellos.
select id, email, nombre, plataforma_rol
from public.profiles
where plataforma_rol = 'superadmin';

-- 2. El trigger tiene que haber quedado ACTIVO. Si dice DESACTIVADO, la
--    protección contra auto-promoción no está corriendo.
select t.tgname,
       case t.tgenabled when 'O' then 'ACTIVO' else 'DESACTIVADO ⚠️' end as estado
from pg_trigger t
join pg_class c on c.oid = t.tgrelid
where c.relname = 'profiles' and t.tgname = 'trg_proteger_rol';

-- ═══════════════════════════════════════════════════════════════════════════
-- SIGUIENTE PASO: crear el primer salón
-- ═══════════════════════════════════════════════════════════════════════════
-- `crear_tenant` valida `es_superadmin()` con `auth.uid()`, así que desde el
-- SQL Editor (sin sesión) NO funciona. Se llama desde la app ya logueado como
-- superadmin, o se inserta a mano:
--
-- YA APLICADO el 2026-08-23. El salón quedó así:
--   id     f287a618-934d-4877-be79-8f7d2e89d734
--   slug   mirame · estado activo · plan premium · licencia hasta 2027-08-23
--   owner  6e87e720-… (santiagoadet7823@gmail.com, provisorio)
--
-- Se hizo con un CTE en una sola sentencia para que tenant, licencia y
-- membresía no puedan quedar a medias:
--
--   with t as (
--     insert into public.tenants (nombre, slug, estado, plan, creado_por)
--     values ('Mírame Lash Studio', 'mirame', 'activo', 'premium',
--             '6e87e720-77c7-44b1-b1c2-68780c13cde5')
--     returning id
--   ), l as (
--     insert into public.licencias (tenant_id, plan, vence_at)
--     select id, 'premium', now() + interval '365 days' from t
--     returning tenant_id
--   )
--   insert into public.tenant_members (tenant_id, user_id, rol, estado)
--   select id, '6e87e720-77c7-44b1-b1c2-68780c13cde5', 'owner', 'approved'
--   from t;
--
-- PENDIENTE: cuando la dueña entre a la app una vez, pasarle a ella el rol
-- `owner` y dejar al dueño del producto solo como superadmin de plataforma:
--
--   update public.tenant_members set user_id = '<uid-de-la-dueña>'
--   where tenant_id = 'f287a618-934d-4877-be79-8f7d2e89d734' and rol = 'owner';
-- ═══════════════════════════════════════════════════════════════════════════

-- ═══════════════════════════════════════════════════════════════════════════
-- VINCULAR DOS CUENTAS AL MISMO SALÓN
-- ═══════════════════════════════════════════════════════════════════════════
-- No hace falta ningún mecanismo de "compartir": el modelo ya es compartido.
-- Los datos de negocio no cuelgan de un usuario, cuelgan del TENANT. Dos
-- personas que son `tenant_members` aprobadas del mismo tenant ven exactamente
-- las mismas clientas, turnos, caja y stock — es lo que hacen las policies
-- `pertenece_a(tenant_id)`.
--
-- Ser superadmin NO da acceso a los datos de un salón como miembro: da acceso
-- de plataforma (y de lectura auditada). Son dos cosas distintas a propósito,
-- porque si no un superadmin sería miembro implícito de todos los salones del
-- mundo y no habría forma de auditar nada.
--
-- Entonces, para la dueña real (superadmin 2), hacen falta las DOS cosas:
--   1. `plataforma_rol = 'superadmin'`  → puede administrar y redistribuir
--   2. una fila en `tenant_members`     → puede trabajar en el salón
--
-- Requisito previo: que haya entrado a la app con Google UNA vez, para que
-- exista su fila. Buscar el UID así:
--
--   select id, email, nombre, created_at from public.profiles
--   order by created_at desc;
--
-- Y después, en una sola transacción (reemplazar el UID):
--
--   begin;
--   -- 1) rol de plataforma. Un superadmin ya sentado puede hacerlo sin
--   --    desactivar el trigger; desde el SQL Editor (sin auth.uid()) hay que
--   --    desactivarlo igual que para el primero.
--   alter table public.profiles disable trigger trg_proteger_rol;
--   update public.profiles set plataforma_rol = 'superadmin'
--   where id = 'UID-DE-LA-DUEÑA';
--   alter table public.profiles enable trigger trg_proteger_rol;
--
--   -- 2) membresía en el salón: acá es donde se comparten los datos.
--   insert into public.tenant_members (tenant_id, user_id, rol, estado)
--   values ('f287a618-934d-4877-be79-8f7d2e89d734', 'UID-DE-LA-DUEÑA',
--           'owner', 'approved')
--   on conflict (tenant_id, user_id) do update
--     set rol = 'owner', estado = 'approved';
--   commit;
--
-- Verificación:
--   select p.email, p.plataforma_rol, m.rol, m.estado
--   from public.profiles p
--   left join public.tenant_members m on m.user_id = p.id
--   where m.tenant_id = 'f287a618-934d-4877-be79-8f7d2e89d734'
--      or p.plataforma_rol = 'superadmin';
--
-- NOTA sobre el reparto de roles a futuro: cuando el salón sea realmente de
-- ella, conviene que el dueño del producto DEJE de ser `owner` del tenant y
-- quede solo como superadmin de plataforma. Así el acceso a los datos del
-- salón queda auditado, que es como tiene que ser.
