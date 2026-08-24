# 05 · Offline local-first y motor de sync

> La app tiene que **funcionar** sin internet, no solo mostrar cache. Crear un turno en modo avión
> tiene que ser tan instantáneo como con señal.

---

## 1. Arquitectura

```
UI ──watch()──> Drift (SQLite)          ← fuente de verdad de la UI
                  ▲              │
       aplica pull│              │write: fila real + fila en `outbox`
                  │              ▼
              SyncEngine ◄── OutboxQueue
                  │
        push ▲    ▼ pull (updated_at > cursor)
              Supabase
```

Nadie en `features/` conoce Supabase. Todo va por repositorio → Drift.

---

## 2. Tablas locales

Espejo de las 7 de negocio, más dos propias del motor:

```dart
// outbox — operaciones pendientes de subir
class Outbox extends Table {
  IntColumn    get id        => integer().autoIncrement()();
  TextColumn   get tabla     => text()();                 // 'appointments' | 'clients' | ...
  TextColumn   get op        => text()();                 // 'insert' | 'update' | 'delete' | 'rpc'
  TextColumn   get rowId     => text()();
  TextColumn   get payload   => text()();                 // JSON
  IntColumn    get intentos  => integer().withDefault(const Constant(0))();
  DateTimeColumn get creadaEn  => dateTime()();
  DateTimeColumn get proximoEn => dateTime().nullable()(); // backoff
  TextColumn   get ultimoError => text().nullable()();
}

// sync_state — cursor del pull, uno por tabla y tenant
class SyncState extends Table {
  TextColumn     get tabla    => text()();
  TextColumn     get tenantId => text()();
  DateTimeColumn get lastPull => dateTime().nullable()();
  @override Set<Column> get primaryKey => {tabla, tenantId};
}
```

Cada tabla espejo agrega dos columnas que no existen en el servidor:

| Columna local | Para qué |
|---|---|
| `pendiente` (bool) | La fila tiene cambios sin subir. La UI puede mostrar un puntito discreto |
| `syncedAt` | Última vez que se confirmó contra el servidor |

---

## 3. IDs generados en el cliente

`uuid v7` — ordenable por tiempo, sin colisiones, generado localmente.

Esto es lo que permite crear un turno sin señal: no hay que esperar a que el servidor asigne un id,
y las relaciones (turno → servicios) se pueden armar de una, offline.

Se abandona el `autoIncrement` de IndexedDB. Al migrar los datos viejos (Fase 9) se genera un uuid
por cada registro y se guarda el id legacy en una columna `legacy_id` para poder auditar la
migración.

---

## 4. Escritura

```dart
Future<void> save(Appointment a) async {
  await db.transaction(() async {
    await dao.upsert(a.copyWith(updatedAt: DateTime.now(), pendiente: true));
    await outbox.encolar(tabla: 'appointments', op: 'upsert', rowId: a.id, payload: a.toJson());
  });
  syncEngine.nudge();   // intenta ya; si no hay red, no pasa nada
}
```

La fila local y la del outbox se escriben en **la misma transacción**. Si se rompen en dos, un
crash entre medio deja un cambio local que nunca sube — el bug más difícil de encontrar de este
tipo de motores.

**Borrar** es marcar `deleted_at`, nunca un `DELETE`. Un borrado real no se le puede propagar a un
cliente que estaba offline.

---

## 5. Push (drenar el outbox)

- Se dispara con: arranque de la app, cambio de `connectivity_plus` a conectado, `nudge()` tras
  una escritura, y un timer de respaldo cada 5 minutos.
- Orden **FIFO estricto** por `creadaEn`. Importa: si se crea una clienta y después un turno que
  la referencia, invertir el orden rompe la foreign key.
- Backoff exponencial por fila: 2s, 4s, 8s… hasta 5 minutos. Se guarda en `proximoEn`.
- Después de N intentos fallidos con un error **no** de red (por ejemplo, una violación de RLS),
  la fila se marca como conflictiva y se muestra en Ajustes → "Cambios que no se pudieron
  sincronizar", con la opción de reintentar o descartar. Nunca se descarta sola en silencio.
- Un error de red **no cuenta** como intento fallido: no tiene sentido penalizar quedarse sin señal.

---

## 6. Pull (traer lo del servidor)

Por tabla y por tenant activo:

```sql
select * from appointments
where tenant_id = :t and updated_at > :cursor
order by updated_at
limit 500;
```

- Se pagina hasta agotar, y recién ahí se avanza el cursor a la `updated_at` más alta recibida.
- Las filas con `deleted_at` no nulo se aplican como borrado local (tombstone).
- El cursor se guarda **después** de aplicar el lote, no antes: si la app muere a mitad, el próximo
  arranque repite el lote (idempotente) en vez de saltearlo.
- Primera sincronización de un dispositivo: cursor nulo, trae todo.

---

## 7. Conflictos

### 7.1 Regla general: last-write-wins por `updated_at`

Si el servidor tiene una versión más nueva que la local y la local **no** está pendiente, gana el
servidor. Si la local está pendiente, gana el push (el usuario acaba de escribir).

Es suficiente para este dominio: hay una o dos personas por salón, y los choques reales sobre el
mismo registro son rarísimos.

### 7.2 Excepción: `stock_items.cantidad` usa deltas

Este es el caso donde LWW pierde datos de verdad:

> Dos profesionales, ambas sin señal, descuentan una unidad del mismo adhesivo. Ambas pasan de 10
> a 9 localmente. Al reconectar, LWW escribe 9 y después 9. **Quedan 9 en vez de 8**: se perdió un
> descuento, y el stock queda mintiendo.

Solución: el botón +/- **no** encola un valor absoluto. Encola `op: 'rpc'` con
`ajustar_stock(item, delta)`, y el servidor hace `greatest(0, cantidad + delta)`. Los dos
descuentos se aplican.

El `greatest(0, …)` replica el comportamiento de `adjQ()` del legacy, que nunca dejaba bajar de cero.

Cualquier campo futuro que sea un contador acumulable se trata igual.

---

## 8. Realtime (opcional, Fase 3 tardía)

Suscripción de Supabase a los cambios del tenant activo, para que dos dispositivos del mismo salón
se vean en vivo. Es un **acelerador del pull**, no un reemplazo: si la suscripción se cae, el pull
periódico igual converge. Nada del motor puede depender de que Realtime esté vivo.

Vale la pena recién cuando un salón tenga dos profesionales trabajando a la vez.

---

## 9. Indicadores en la UI

El legacy tiene una barra de backup en el dashboard ("Backup local · hora" + chip de Drive). Se
reemplaza por el estado de sync, con el mismo lugar y peso visual:

| Estado | Qué se muestra |
|---|---|
| Todo sincronizado | "Sincronizado · 14:32" con un punto verde |
| Con pendientes | "3 cambios sin subir" con un punto ámbar |
| Sin conexión | "Sin conexión · los cambios se guardan" con un punto gris |
| Con conflictos | "1 cambio no se pudo sincronizar" con un punto rojo, tocable |

Nunca un diálogo de error por quedarse sin señal. En una app local-first eso es un estado normal,
no una falla.

---

## 10. Export / import JSON

Se conserva del legacy como red de seguridad y portabilidad, con el mismo formato:

```json
{ "ver": "…", "at": "ISO", "studio": "…", "a": [], "c": [], "tx": [], "s": [], "p": [], "sv": [] }
```

Sirve para: migrar los datos de la dueña (Fase 9), darle a un salón una copia de sus propios datos
si se va del producto, y depurar.

El backup a Google Drive del legacy **no se porta**: Supabase ya es el respaldo remoto, y mantener
un OAuth de Drive más el appDataFolder es superficie de mantenimiento sin contrapartida.

---

## 11. Cómo agregar una entidad al motor de sync

1. Tabla en Postgres con el patrón completo (`03-BACKEND-SUPABASE.md` §3).
2. Tabla espejo en Drift, con `pendiente` y `syncedAt`.
3. DAO con `watch…()` y `upsert()`.
4. Mapper en `data/remote/mappers/`.
5. Agregar el nombre a la lista de tablas del `SyncEngine`.
6. Repositorio que escribe en Drift + outbox **en la misma transacción**.
7. Test de integración: escribir offline, verificar que aparece en la UI y que sube al reconectar.
8. Commit `feat(sync): agrega <entidad> al motor de sincronizacion`.

---

## 12. Verificación de la Fase 3

- [ ] Crear un turno en modo avión → aparece en la lista **al instante**, con indicador de pendiente.
- [ ] Reconectar → sube solo, el indicador desaparece, la fila está en Postgres.
- [ ] Editar la misma clienta en dos dispositivos → gana el más reciente, sin pérdida silenciosa.
- [ ] **Ajustar stock `-1` en dos dispositivos offline → el resultado final es `-2`, no `-1`.**
- [ ] Borrar un turno en el dispositivo A → desaparece del B tras sincronizar.
- [ ] Matar la app a mitad de un pull → al reabrir, converge sin filas duplicadas ni faltantes.
- [ ] Forzar un error de RLS en el outbox → aparece en la lista de conflictos, no se descarta solo.
- [ ] Cambiar de tenant activo → ninguna lista queda mostrando datos del anterior.
