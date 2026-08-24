---
name: mirame-offline-sync
description: Motor de sincronización offline-first de Mírame (Drift + outbox + Supabase). Usar al agregar una entidad al sync, al tocar repositorios, la cola de escrituras, la resolución de conflictos o el cursor de pull, y al depurar datos que no suben o no bajan.
---

# Motor de sync de Mírame

Documento completo: `android/05-OFFLINE-SYNC.md`.

## Regla número uno

**La UI nunca espera a la red.** Lee de Drift, que responde en microsegundos y funciona en modo
avión. Si una pantalla muestra un spinner esperando a Supabase, está mal escrita.

Ningún widget importa `supabase_flutter`. Si aparece ese import fuera de `data/remote/` y
`features/auth/`, es un bug.

```
Widget ─watch()→ Repositorio ─watch()→ Drift
                      └─write()→ Drift + outbox  (misma transacción)
                                    │
                               SyncEngine ⇄ Supabase
```

## Escribir

```dart
await db.transaction(() async {
  await dao.upsert(entidad.copyWith(updatedAt: DateTime.now(), pendiente: true));
  await outbox.encolar(tabla: '…', op: 'upsert', rowId: id, payload: json);
});
syncEngine.nudge();
```

La fila real y la del outbox van en **la misma transacción**. Separarlas deja cambios que nunca
suben si la app muere entre medio — el bug más difícil de encontrar de este tipo de motores.

**Borrar es marcar `deleted_at`**, nunca un `DELETE`.

## La excepción del stock

`stock_items.cantidad` **no** usa last-write-wins. Usa deltas.

> Dos profesionales offline descuentan una unidad cada una. Ambas pasan de 10 a 9 localmente. Con
> LWW se escribe 9 y después 9: quedan 9 en vez de 8, y el stock miente.

El botón +/- encola `op: 'rpc'` con `ajustar_stock(item, delta)`. El servidor hace
`greatest(0, cantidad + delta)`.

Cualquier campo futuro que sea un contador acumulable se trata igual.

## Invariantes del motor

| Regla | Por qué |
|---|---|
| Push en **FIFO estricto** por `creadaEn` | Una clienta creada después que su turno rompe la foreign key |
| Cursor se avanza **después** de aplicar el lote | Si se avanza antes y la app muere, se saltea el lote |
| Error de red **no** cuenta como intento fallido | Quedarse sin señal no es un fallo que haya que penalizar |
| Cursor por tabla **y tenant** | Con cursor solo por tabla, cambiar de tenant rompe la sincronización |
| Realtime es un acelerador, no un reemplazo | Si la suscripción se cae, el pull periódico igual converge |
| Nada se descarta en silencio | Los conflictos van a una lista visible en Ajustes, con reintentar o descartar |

## Agregar una entidad

1. Tabla en Postgres con el patrón completo (ver skill `mirame-supabase`).
2. Tabla espejo en Drift, con `pendiente` y `syncedAt`.
3. DAO con `watch…()` y `upsert()`.
4. Mapper en `data/remote/mappers/`.
5. Agregar el nombre a la lista de tablas del `SyncEngine`.
6. Repositorio que escribe en Drift + outbox en la misma transacción.
7. Test: escribir offline, verificar que aparece en la UI y que sube al reconectar.
8. `feat(sync): agrega <entidad> al motor de sincronizacion`

## Depurar

| Síntoma | Mirar primero |
|---|---|
| Un cambio no sube | La tabla `outbox`: ¿está la fila? ¿qué dice `ultimoError`? ¿`proximoEn` en el futuro? |
| Un cambio del servidor no baja | `sync_state`: ¿el cursor quedó adelantado? Ponerlo en null fuerza un pull completo |
| Filas duplicadas | El upsert no está usando el `id` como clave de conflicto |
| Datos de otro salón visibles | El cursor o el provider no se invalidaron al cambiar de tenant |
| El stock queda corto | Alguien reemplazó el delta por un valor absoluto |

## Sin conexión no es un error

En una app local-first quedarse sin señal es un estado normal. Se muestra como indicador de
"pendiente de sincronizar", nunca como un diálogo de error.
