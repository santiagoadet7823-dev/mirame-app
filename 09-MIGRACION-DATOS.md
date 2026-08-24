# 09 · Migración de los datos reales

> Fase 9. Se hace **al final**, cuando la app nueva ya funciona. Son los datos reales de un negocio
> en marcha: turnos agendados, caja del mes, historial de clientas.

---

## 1. Origen

La app legacy exporta un JSON desde Ajustes → Exportar datos:

```json
{
  "ver": "5.0",
  "at": "2026-08-22T…",
  "studioName": "Mírame Lash Studio",
  "a":  [ /* appointments */ ],
  "c":  [ /* clients */ ],
  "tx": [ /* transactions */ ],
  "s":  [ /* stock */ ],
  "p":  [ /* professionals */ ],
  "sv": [ /* services */ ]
}
```

> El legacy tiene una inconsistencia menor: `backup()` genera `{ver: '5.1', studio: …}` y
> `exportData()` genera `{ver: '5.0', studioName: …}`. El importador debe tolerar **ambas** claves.
> También hay backups viejos con las claves largas (`appointments` en vez de `a`).

Hay además un backup en Google Drive (`mirame_backup.json` en `appDataFolder`) y otro en
`localStorage['mirame_bk']`. **Usar el export manual**, que es el más fresco y no depende de que el
token de Drive siga vivo.

---

## 2. Transformaciones obligatorias

El modelo legacy tiene deuda que **no se replica**. Cada fila de esta tabla es una conversión que
el script tiene que hacer:

| Campo legacy | Tipo legacy | Destino | Conversión |
|---|---|---|---|
| `id` | int autoincremental | `uuid` v7 | Generar nuevo, guardar el original en `legacy_id` |
| `price`, `amount`, `qty`, `min` | **string** | `numeric` / `int` | `num.tryParse(x) ?? 0` |
| `date` | string `'YYYY-MM-DD'` | `date` | Parsear como fecha **local**, no UTC (§3) |
| `time` | string `'HH:mm'` | `time` | Directo |
| `vip` | string `'true'` / `'false'` | `boolean` | `x == 'true' \|\| x == true` |
| `services` | `string[]` de nombres | `appointment_services` | Resolver nombre → `service_id` (§4) |
| `service` | string (legacy, = `services[0]`) | — | Se descarta tras resolver `services` |
| `clientId`, `proId` | string con el id numérico | `uuid` | Vía el mapa de ids viejo → nuevo |
| `status` | `'confirmed'\|'pending'\|'done'\|'cancelled'` | enum | Directo |
| `payment` | `'efectivo'\|'transferencia'\|'tarjeta'` | enum | Directo |
| — | — | `tenant_id` | El uuid del tenant de Mírame, en todas las filas |
| — | — | `deleted_at` | `null` |

---

## 3. La trampa de las fechas

`td()` del legacy hace `new Date().toISOString().slice(0,10)`, que devuelve el día **en UTC**. En
Argentina (UTC−3), **después de las 21:00 el "hoy" del legacy es el día siguiente**.

Consecuencia real: hay turnos y movimientos de caja guardados con la fecha corrida un día, si se
cargaron de noche.

Qué hacer:

- Los strings `'YYYY-MM-DD'` guardados **ya son el valor que la dueña vio en pantalla**. Se importan
  tal cual, como fecha local. No se les aplica ninguna corrección de zona horaria: "corregirlos"
  movería un día registros que hoy están donde ella espera.
- Lo que se corrige es de acá en adelante: la app nueva usa fechas locales con TZ
  `America/Argentina/Salta`, así que el problema no se reproduce.
- Vale la pena avisarle y revisar juntos si algún movimiento nocturno quedó en el día equivocado.

---

## 4. Servicios: de nombre a id

El legacy vincula turnos con servicios **por nombre** (`sv.name === appt.service`). El importador:

1. Importa primero los servicios y arma un mapa `nombre → uuid`.
2. Para cada turno, resuelve cada nombre de `services[]` contra ese mapa.
3. **Si un nombre no matchea** (porque el servicio se renombró o se borró después de crear el
   turno), crea un servicio "archivado" con ese nombre, `deleted_at` seteado y precio 0, y lo
   vincula. Así el turno conserva su información y el catálogo activo no se ensucia.
4. Registra cada caso en el reporte de migración.

Este paso es exactamente la razón por la que el modelo nuevo vincula por id: en el legacy,
renombrar un servicio rompía silenciosamente los recordatorios de retoque de todas las clientas
que lo tenían.

---

## 5. Orden de importación

Las foreign keys mandan:

```
1. professionals
2. services
3. clients
4. appointments          (necesita clients + professionals)
5. appointment_services  (necesita appointments + services)
6. transactions          (necesita clients, opcional)
7. stock_items
8. settings
```

Todo dentro de **una transacción**. Si algo falla, no queda una migración a medias.

---

## 6. `transactions.client_id`

El legacy **nunca escribía** este campo, aunque el CRM lo leía (por eso "gastado por clienta"
siempre daba $0).

En la migración no se puede inventar: no hay dato. Se importa en `null`.

Opcionalmente, se puede intentar una reconstrucción heurística cruzando ingresos con turnos del
mismo día y monto. **No se recomienda**: adivinar mal a qué clienta corresponde una plata es peor
que no saberlo. Mejor que el dato empiece a acumularse limpio desde la app nueva.

---

## 7. Reporte de migración

El script termina imprimiendo, y guardando en un archivo:

```
Profesionales:  2 importadas
Servicios:      7 importados  (+1 archivado: "Volumen Ruso" venía de un turno viejo)
Clientas:      48 importadas
Turnos:       312 importados  ·  4 sin clienta resuelta  ·  2 con servicio archivado
Movimientos:  520 importados  ·  520 con client_id nulo (esperado)
Stock:         14 importados
```

Cada incidencia se lista con el registro concreto. Nada se descarta en silencio.

---

## 8. Verificación (comparar contra la app vieja, número por número)

Con las dos apps abiertas al lado:

- [ ] Cantidad total de clientas.
- [ ] Cantidad total de turnos.
- [ ] **Ingresos del mes en curso** — tiene que dar exactamente igual.
- [ ] **Egresos del mes en curso.**
- [ ] Balance neto y margen %.
- [ ] Turnos de hoy y de mañana: mismos, misma hora, misma clienta.
- [ ] Top 5 clientas: mismo orden y mismos montos.
- [ ] Ticket promedio del mes.
- [ ] Cantidad de productos en stock y sus cantidades.
- [ ] Recordatorios de retoque: mismas clientas listadas.

Si un número no coincide, **no se migra**. Se encuentra por qué primero.

---

## 9. Convivencia

No se apaga la app vieja el mismo día.

1. Migrar los datos a la app nueva.
2. **Una o dos semanas de uso en paralelo**: la dueña carga en la nueva, y la vieja queda accesible
   de solo lectura como referencia.
3. Cuando confíe, se apaga la vieja (se deja el Netlify arriba un tiempo más, sin escritura).
4. Guardar el JSON de export final en dos lugares, para siempre.

Migrar los datos de un negocio en marcha es la parte donde un error se paga en confianza, no en
tiempo de desarrollo. El paralelo no es exceso de cuidado: es lo mínimo.
