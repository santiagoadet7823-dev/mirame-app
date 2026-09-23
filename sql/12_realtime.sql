-- 12 · Realtime: el servidor avisa, la app no pregunta
--
-- Aplicado el 2026-09-23 (migracion `realtime_publicar_tablas_de_sync`).
--
-- Por que: la app sincronizaba con un timer. Cargabas algo en la compu y en el
-- celular tardaba en aparecer sin ninguna razon visible. Con la publicacion,
-- Supabase empuja un aviso y la app corre un ciclo en el momento.
--
-- La app **no aplica el payload del evento**: lo usa solo como aviso y despues
-- hace el pull normal, que ya sabe de cursores, tombstones y columnas que esa
-- version del APK todavia no conoce. Aplicar el evento por su cuenta seria una
-- segunda implementacion de lo mismo, con sus propios bugs.
--
-- No hace falta `REPLICA IDENTITY FULL`: solo importaria si el filtro por
-- tenant tuviera que leer la fila vieja de un DELETE, y aca los borrados son
-- logicos (se escribe `deleted_at`, o sea un UPDATE). La fila nueva siempre
-- trae su `tenant_id`.
--
-- Revertirlo NO rompe la app: sin eventos, el ciclo periodico converge igual.
-- Nada del motor depende de que la suscripcion este viva.
--
--   alter publication supabase_realtime drop table public.appointments;  -- etc.

alter publication supabase_realtime add table
  public.professionals,
  public.services,
  public.clients,
  public.appointments,
  public.appointment_services,
  public.transactions,
  public.stock_items,
  public.proveedores,
  public.depositos,
  public.productos,
  public.producto_variantes,
  public.stock_variantes,
  public.producto_fotos,
  public.ventas,
  public.venta_items,
  public.reservas,
  public.reserva_items,
  public.liquidaciones,
  public.movimientos_stock;

-- Verificacion:
--   select count(*) from pg_publication_tables where pubname='supabase_realtime';
--   -- 19
