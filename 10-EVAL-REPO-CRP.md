# 10 · Evaluación de repos externos ("CRP" y otros)

> Quedó pendiente que busques el repositorio que mencionaste. Este documento es la **grilla para
> evaluarlo** cuando lo tengas, más lo que ya se buscó.

---

## 1. La pregunta correcta

No es "¿este repo sirve?". Es: **¿qué pieza concreta me ahorra?**

Solo dos partes de este proyecto justifican adoptar código ajeno:

| Pieza | Por qué vale |
|---|---|
| **Motor de sync offline** | Es la parte más difícil de hacer bien: cursores, tombstones, conflictos, backoff, reentrada tras un crash. Un motor probado ahorra semanas y bugs sutiles |
| **Panel multi-tenant / licencias** | Aburrido de escribir, muchos casos borde (invitaciones, roles, vencimientos, auditoría) |

**La UI se descarta siempre.** La estética tiene que ser fiel al `index.html`. Cualquier design
system ajeno es trabajo que hay que deshacer, no aprovechar.

También se descarta adoptar el modelo de datos ajeno: el nuestro está diseñado alrededor de las
reglas de negocio reales del salón (retoques, cierre de caja, proyección) que ya están inventariadas.

---

## 2. Criterios de descarte rápido

Si falla **uno solo**, no sigas mirando:

- [ ] **Licencia permisiva** (MIT, Apache 2.0, BSD). GPL/AGPL obligaría a abrir el código de un
      producto que vas a revender.
- [ ] Flutter 3.2x+ y **null safety**. Un repo de Flutter 2.x es una migración, no un atajo.
- [ ] **Commits en los últimos 12 meses.** Un motor de sync abandonado es peor que ninguno: los
      bugs los vas a arreglar vos, sin conocer el código.
- [ ] **No atado a Firebase como base de datos.** Si el offline depende de la persistencia de
      Firestore, no se puede reusar con Supabase.
- [ ] **Tiene tests**, sobre todo del motor de sync. Sin tests, no hay forma de confiar en la
      resolución de conflictos.
- [ ] Se puede usar **como paquete o como módulo**, sin tener que adoptar toda su arquitectura de
      app (router, DI, tema).

## 3. Criterios de evaluación real

Si pasó el filtro, mirá esto **en el código**, no en el README:

| Qué mirar | Qué tiene que estar |
|---|---|
| Conflictos | ¿Solo LWW, o soporta deltas/CRDT? Si es solo LWW, el caso del stock hay que resolverlo igual a mano |
| Tombstones | ¿Cómo propaga los borrados? Si hace `DELETE` real, no sirve para offline |
| Cursor | ¿Lo avanza antes o después de aplicar el lote? Antes = pierde datos si la app muere |
| Orden del push | ¿FIFO? Si no, las foreign keys se rompen (clienta creada después que su turno) |
| Reintentos | ¿Backoff? ¿Distingue error de red de error de permiso? |
| Multi-tenant | ¿El cursor es por tabla, o por tabla **y tenant**? Si es solo por tabla, cambiar de tenant rompe |
| Web | ¿Funciona en Flutter web? Muchos motores asumen `sqflite`, que no corre en el navegador |

---

## 4. Lo que ya se buscó (agosto 2026)

Búsquedas hechas en GitHub sobre Flutter + Supabase + salón/CRM/offline:

| Repo | ★ | Veredicto |
|---|---|---|
| `cuddiale/appointment-booking-template` | 0 | Lo único temáticamente cercano: Flutter + Supabase, multi-tenant, para salones y barberías. **0 estrellas**: hay que auditar el código antes de confiar en nada. Puede servir como referencia del esquema, no como base |
| `itsezlife/flutter-instagram-offline-first-clone` | 261 | **Referencia útil del patrón**, no dependencia. Offline-first con PowerSync + Supabase, BLoC. Sirve para ver cómo se estructura, no para copiar |
| `cherrypick-agency/synchronize_cache` | 25 | Sync offline-first para Flutter/Drift con push/pull y resolución de conflictos. Justo la pieza que interesa. **Vale una revisión seria** contra la grilla del §3 |
| `dynos-fit/dynos-sync` | 19 | Motor de sync con delta-pulls. Mismo caso: revisar |
| `locorda/sync-engine` | 8 | CRDT, pero orientado a "bring your own backend" con Drive/Solid. No encaja con Supabase |

**Conclusión: no hay un candidato maduro y obvio.** El motor propio descrito en `05-OFFLINE-SYNC.md`
es unas 400 líneas de Dart bien acotadas; adoptar un repo de 20 estrellas para eso probablemente
cueste más en auditoría y adaptación de lo que ahorra.

---

## 5. La alternativa seria: PowerSync

Vale nombrarla porque es la única que resuelve el problema completo y con soporte:

**PowerSync** es un servicio de sync offline-first con integración oficial de Supabase y SDK de
Flutter. Reemplaza todo `data/sync/`: define reglas de sincronización, mantiene SQLite local en el
dispositivo, resuelve el streaming de cambios y la reconexión.

| A favor | En contra |
|---|---|
| Resuelve el problema difícil, con soporte | **Costo mensual** que crece con los tenants |
| Multi-tenant vía sync rules (encaja bien) | Dependencia de un tercero para algo crítico |
| Menos código propio que mantener | Menos control fino (los deltas de stock hay que ver cómo se expresan) |
| Flutter web soportado | Otra pieza de infraestructura que entender |

**Recomendación:** empezar con el motor propio. Es acotado y ya está diseñado. Si a los 5 o 10
tenants el sync se vuelve una fuente constante de bugs, migrar a PowerSync es un cambio localizado
en `data/sync/` — precisamente porque la arquitectura ya aísla esa capa detrás de los repositorios.

---

## 6. Si el repo "CRP" resulta ser un CRM genérico

Casi seguro **no sirva directamente**. Un CRM genérico está armado alrededor de leads, pipeline y
oportunidades. Este producto está armado alrededor de **turnos y caja de un salón**: la clienta no
es un lead, es alguien que vuelve cada 21 días a un retoque. La forma de los datos no coincide.

Lo que sí puede aportar, y vale mirar:

- El patrón de **multi-tenancy y permisos** (si es más maduro que el nuestro).
- La **pantalla de administración de licencias y facturación**, que es aburrida de escribir.
- Ideas de **reportes** que a este producto le falten.

Pasalo por la grilla del §2 y §3 y decidimos con el código a la vista, no con el README.
