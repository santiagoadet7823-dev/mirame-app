-- ═══════════════════════════════════════════════════════════════════════════
-- 05 · PERMISOS DE EJECUCIÓN de las funciones
-- ═══════════════════════════════════════════════════════════════════════════
-- Se corre DESPUÉS de 04_funciones.sql.
--
-- El problema que resuelve: en Postgres, `EXECUTE` sobre una función se otorga
-- a **PUBLIC** por defecto. Un `revoke execute ... from authenticated` no hace
-- nada útil, porque el permiso sigue llegando por PUBLIC. Resultado: cualquier
-- función queda invocable desde `/rest/v1/rpc/<nombre>`, incluso sin sesión.
--
-- Lo detectó el linter de Supabase sobre este mismo proyecto: `vencer_licencias`
-- (el cron que suspende salones por falta de pago) era ejecutable por `anon`.
--
-- Criterio: revocar de PUBLIC en todo, y volver a otorgar solo a quien
-- realmente lo necesita.
-- ═══════════════════════════════════════════════════════════════════════════

-- ── Funciones de TRIGGER ──────────────────────────────────────────────────
-- Nadie las invoca por RPC. Los triggers corren por cuenta del motor, así que
-- revocar el EXECUTE no los rompe.
do $$
declare f text;
begin
  foreach f in array array[
    'public.set_updated_at()',
    'public.handle_new_user()',
    'public.proteger_rol_plataforma()',
    'public.proteger_estado_tenant()'
  ] loop
    execute format('revoke all on function %s from public, anon, authenticated', f);
  end loop;
end $$;

-- ── Cron interno ──────────────────────────────────────────────────────────
-- Solo la Edge Function con service-role la llama.
revoke all on function public.vencer_licencias() from public, anon, authenticated;
grant execute on function public.vencer_licencias() to service_role;

-- ── RPC que MUTAN datos ───────────────────────────────────────────────────
-- Cada una valida permisos por dentro, pero un anónimo no tiene nada que hacer
-- acá. Defensa en profundidad.
do $$
declare f text;
begin
  foreach f in array array[
    'public.ajustar_stock(uuid,int)',
    'public.crear_tenant(text,text,uuid,text,int,text)',
    'public.renovar_licencia(uuid,int,numeric,text)',
    'public.registrar_acceso(uuid,text,text,jsonb)'
  ] loop
    execute format('revoke all on function %s from public, anon', f);
    execute format('grant execute on function %s to authenticated, service_role', f);
  end loop;
end $$;

-- ── Helpers de RLS ────────────────────────────────────────────────────────
-- `authenticated` SÍ los necesita: las expresiones de las policies se evalúan
-- con los privilegios de quien consulta, así que sin EXECUTE ninguna query
-- sobre las tablas de negocio funciona.
--
-- `anon` no: la app nunca toca datos de negocio sin sesión, y si lo hiciera es
-- preferible que falle ruidosamente antes que devolver vacío como si todo
-- estuviera bien.
do $$
declare f text;
begin
  foreach f in array array[
    'public.es_superadmin()',
    'public.es_revendedor_de(uuid)',
    'public.pertenece_a(uuid)',
    'public.rol_en(uuid)',
    'public.administra(uuid)',
    'public.puede_escribir(uuid)',
    'public.licencia_vigente(uuid)'
  ] loop
    execute format('revoke all on function %s from public, anon', f);
    execute format('grant execute on function %s to authenticated, service_role', f);
  end loop;
end $$;

-- ═══════════════════════════════════════════════════════════════════════════
-- Advertencias que QUEDAN, y por qué son aceptables
-- ═══════════════════════════════════════════════════════════════════════════
-- El linter va a seguir marcando 11 funciones como
-- `authenticated_security_definer_function_executable`. Es intencional:
--
--   · los 7 helpers de RLS DEBEN ser ejecutables por `authenticated`, o las
--     policies no se pueden evaluar;
--   · las 4 RPC de mutación son la API de la app y validan permisos adentro.
--
-- Lo que NO debe volver a aparecer: cualquier advertencia sobre `anon`, o
-- sobre `vencer_licencias` / funciones de trigger. Eso sí sería un problema.

-- Verificación: ninguna de estas debería tener `=X/` (PUBLIC) en su ACL.
select p.proname,
       coalesce(array_to_string(p.proacl, ' | '), 'SIN ACL → PUBLIC ejecuta') as permisos
from pg_proc p
join pg_namespace n on n.oid = p.pronamespace
where n.nspname = 'public'
order by p.proname;
