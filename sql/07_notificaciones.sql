-- 07 · Notificaciones push
--
-- Solo la plomería: dónde viven los tokens de FCM y quién puede tocarlos.
-- El envío es la Edge Function `enviar-push`, que necesita la service account
-- de Firebase y por eso NO puede vivir en el cliente.

create table if not exists public.device_tokens (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null references auth.users(id) on delete cascade,
  -- El salón activo cuando se registró. Permite mandarle a "todo el salón"
  -- sin resolver membresías en cada envío.
  tenant_id   uuid references public.tenants(id) on delete cascade,
  token       text not null,
  plataforma  text not null default 'android',
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now(),

  -- Un token identifica un DISPOSITIVO, no una persona. Si el teléfono cambia
  -- de dueña, la fila se reasigna en vez de duplicarse — si no, la usuaria
  -- anterior seguiría recibiendo los avisos de un salón que ya no es suyo.
  unique (token)
);

create index if not exists device_tokens_user_idx on public.device_tokens(user_id);
create index if not exists device_tokens_tenant_idx on public.device_tokens(tenant_id);

alter table public.device_tokens enable row level security;

-- Cada quien administra los tokens de sus propios dispositivos. El fan-out lo
-- hace la Edge Function con la service role, que saltea RLS.
drop policy if exists device_tokens_propios on public.device_tokens;
create policy device_tokens_propios on public.device_tokens
  for all to authenticated
  using (user_id = auth.uid() or public.es_superadmin())
  with check (user_id = auth.uid());

-- Alta/actualización desde el cliente en una sola llamada.
create or replace function public.registrar_token_push(
  p_token text,
  p_tenant uuid default null,
  p_plataforma text default 'android'
) returns void
language plpgsql security definer set search_path = public as $$
begin
  insert into public.device_tokens (user_id, tenant_id, token, plataforma)
  values (auth.uid(), p_tenant, p_token, p_plataforma)
  on conflict (token) do update
    set user_id    = auth.uid(),
        tenant_id  = p_tenant,
        plataforma = p_plataforma,
        updated_at = now();
end;
$$;

-- Al cerrar sesión. Borra por token y no por usuario: cerrar sesión en el
-- teléfono no tiene que dejar sin avisos a la tablet del salón.
create or replace function public.borrar_token_push(p_token text)
returns void
language plpgsql security definer set search_path = public as $$
begin
  delete from public.device_tokens where token = p_token and user_id = auth.uid();
end;
$$;

grant execute on function public.registrar_token_push(text, uuid, text) to authenticated;
grant execute on function public.borrar_token_push(text) to authenticated;
