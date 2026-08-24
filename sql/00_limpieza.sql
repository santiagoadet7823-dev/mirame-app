-- ═══════════════════════════════════════════════════════════════════════════
-- 00 · LIMPIEZA del esquema viejo  ⚠️ DESTRUCTIVO
-- ═══════════════════════════════════════════════════════════════════════════
-- Se ejecuta ANTES de 01_plataforma.sql, y SOLO UNA VEZ.
--
-- Qué borra: las 7 tablas del intento de migración de julio 2026
-- (`../mirame-lash-studio/supabase/schema.sql`), que usaban el diseño
-- `id · user_id · data jsonb · updated_at`.
--
-- Por qué no se pueden conservar:
--   · no tienen `tenant_id`, así que no hay aislamiento entre salones
--   · el contenido vive dentro de un `jsonb`, así que no se puede indexar,
--     filtrar ni aplicar RLS por campo
--   · el sync incremental no puede detectar qué cambió realmente
--   · 6 de los 7 nombres chocan con las tablas nuevas
--
-- ───────────────────────────────────────────────────────────────────────────
-- GUARDA DE SEGURIDAD
-- ───────────────────────────────────────────────────────────────────────────
-- El bloque de abajo CUENTA las filas antes de borrar y ABORTA si encuentra
-- alguna. Si eso pasa, NO forzar el borrado: exportar los datos primero.
--
-- Para saltear la guarda a propósito (solo si ya verificaste que los datos no
-- sirven), comentar el `raise exception`.
-- ═══════════════════════════════════════════════════════════════════════════

do $$
declare
  t          text;
  n          bigint;
  total      bigint := 0;
  detalle    text := '';
  legacy     text[] := array[
    'appointments','clients','transactions','stock','professionals','services','settings'
  ];
begin
  foreach t in array legacy loop
    -- Solo mirar las tablas que existen Y que tienen la forma vieja (columna
    -- `data jsonb`). Así este script es inofensivo si se corre por error
    -- después de haber creado el esquema nuevo.
    if exists (
      select 1 from information_schema.columns
      where table_schema = 'public' and table_name = t
        and column_name = 'data' and data_type = 'jsonb'
    ) then
      execute format('select count(*) from public.%I', t) into n;
      total := total + n;
      detalle := detalle || format('  %s: %s filas%s', t, n, chr(10));
    end if;
  end loop;

  if detalle = '' then
    raise notice 'No hay tablas del esquema viejo. Nada que limpiar.';
  else
    raise notice E'Tablas legacy encontradas:\n%', detalle;
  end if;

  if total > 0 then
    raise exception
      E'ABORTADO: hay % filas en el esquema viejo.\n%\nExportá los datos antes de borrar. Ver 09-MIGRACION-DATOS.md.',
      total, detalle;
  end if;
end $$;

-- ───────────────────────────────────────────────────────────────────────────
-- Borrado. Solo se llega acá si la guarda no abortó.
-- ───────────────────────────────────────────────────────────────────────────
do $$
declare
  t      text;
  legacy text[] := array[
    'appointments','clients','transactions','stock','professionals','services','settings'
  ];
begin
  foreach t in array legacy loop
    if exists (
      select 1 from information_schema.columns
      where table_schema = 'public' and table_name = t
        and column_name = 'data' and data_type = 'jsonb'
    ) then
      execute format('drop table public.%I cascade', t);
      raise notice 'Borrada: public.%', t;
    end if;
  end loop;
end $$;

-- La función `set_updated_at()` del esquema viejo se vuelve a crear en
-- 01_plataforma.sql con `create or replace`, así que no hace falta borrarla.

-- ═══════════════════════════════════════════════════════════════════════════
-- Verificación: no debería quedar ninguna tabla con columna `data jsonb`.
-- ═══════════════════════════════════════════════════════════════════════════
select table_name
from information_schema.columns
where table_schema = 'public' and column_name = 'data' and data_type = 'jsonb';
