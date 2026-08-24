# Mírame App — CLAUDE.md
> Constitución técnica del proyecto Flutter. **Leer SIEMPRE antes de tocar código.**
> Reemplaza al `CLAUDE.md` de la raíz, que documenta la app HTML legacy (`../index.html`).

---

## Qué es este proyecto

Producto SaaS de gestión para salones de belleza: turnos, CRM, caja, stock y estadísticas.
Nace de una PWA de un solo archivo (`../index.html`, vanilla JS + IndexedDB + Firebase) que
funcionaba para **una sola dueña en su propio dispositivo**. Se convierte en un producto
**multi-tenant revendible**, con app nativa Android (APK) y PWA desde el mismo código Flutter.

| Aspecto | Decisión |
|---|---|
| Framework | **Flutter** (Dart) — un código, dos targets: APK Android + PWA web |
| State | **Riverpod** |
| Router | **go_router** (la PWA necesita URLs reales) |
| Base local | **Drift** (SQLite) — fuente de verdad de la UI |
| Backend | **Supabase** (Postgres + Auth + Realtime + Edge Functions) |
| Auth | **Supabase Auth** con Google OAuth |
| Push | **Firebase Cloud Messaging** — Firebase se usa SOLO para esto |
| Offline | **Local-first**: escritura local + cola `outbox` + sync bidireccional |
| Hosting PWA | **GitHub Pages** |
| Distribución APK | **GitHub Releases** + auto-updater in-app |
| Plano de versiones | tabla `app_config` en Supabase |

---

## Restricciones NO NEGOCIABLES

### NUNCA hacer

- **Cambiar la estética.** La UI debe ser 100% fiel al `../index.html`. Los tokens están en
  `02-DESIGN-SYSTEM.md` con valores literales. No inventar colores, radios ni tipografías.
- Consultar Supabase directamente desde un widget. **Todo pasa por un repositorio hacia Drift.**
- Escribir en el servidor sin pasar por la cola `outbox` (rompe el modo offline).
- Agregar una tabla de negocio sin `tenant_id`, sin RLS y sin `deleted_at`.
- Auto-promover a `superadmin` desde la UI. Los dos superadmins se siembran por SQL, y punto.
- Commitear el keystore, `keystore.properties`, `.env`, service-role keys o `planes/`.
- Bajar el `versionCode`. Android rechaza el downgrade y deja la flota trabada.
- Usar `google_fonts` por CDN — la app tiene que abrir sin red. Fuentes locales en `assets/fonts/`.
- Meter librerías pesadas de charts (fl_chart, syncfusion). El donut y las barras son `CustomPainter`.

### SÍ hacer

- Corregir la deuda técnica que el legacy arrastra (ver abajo).
- Escribir tests de la lógica de negocio pura (`lib/domain/`) — es la parte que más duele si se rompe.
- Consultar las skills de `skills/` antes de reinventar un patrón del proyecto.
- Preguntar antes de agregar una dependencia nueva.

---

## Deuda heredada del legacy que YA se corrigió (no reintroducir)

| Legacy (`index.html`) | Ahora |
|---|---|
| `price` / `amount` / `qty` / `min` guardados como **string** (venían de `input.value`) | `numeric` / `int` |
| `td()` usaba `toISOString()`, así que el día cambiaba a las 21:00 (UTC-3) | fechas locales, TZ `America/Argentina/Salta` |
| El recordatorio de retoque matcheaba `service.name == appointment.service` | vínculo por **id** (`appointment_services`) |
| `transactions.clientId` se leía pero **nunca se escribía** (el CRM siempre mostraba $0) | se escribe |
| `vip` era el string `'true'` / `'false'` | `boolean` |
| `id` autoincremental de IndexedDB | `uuid v7` generado en el cliente |
| Sin detección de solapamiento de turnos ni uso de `service.duration` | validación en `domain/` |
| Todo en memoria, sin paginación | queries paginadas en Drift |

---

## Estructura

```
lib/
├── main.dart              bootstrap, DI, guardas de arranque
├── core/
│   ├── config/            AppConfig vía --dart-define
│   ├── theme/             tokens · app_theme · shadows · motion
│   ├── result.dart        Result<T>
│   └── audit.dart         registro de acceso cross-tenant
├── data/
│   ├── local/             Drift: tablas, DAOs, migraciones
│   ├── remote/            cliente Supabase, mappers
│   ├── sync/              SyncEngine, OutboxQueue, ConflictResolver
│   └── repositories/      un repo por entidad
├── domain/                entidades puras + reglas de negocio (testeable, sin Flutter)
├── features/              auth · shell · dashboard · agenda · crm · caja · stock · stats · settings · admin
└── shared/widgets/        KpiCard · Chip · Pill · Sheet · Toggle · EmptyState · Fab …

android/app/src/main/kotlin/…/MirameUpdaterPlugin.kt   ← auto-update del APK
```

Documentación: `01-ARQUITECTURA.md` … `11-BRIEF-DISENADOR.md`. Empezar siempre por `HANDOFF.md`.

---

## Flujo de datos (memorizar)

```
Widget ─watch()→ Repositorio ─watch()→ Drift (SQLite)   ← única fuente de verdad de la UI
                      │
                      └─write()→ Drift + fila en `outbox`
                                        │
                                   SyncEngine ─push→ Supabase
                                        └───── pull ──┘   (por updated_at / deleted_at)
```

Corolario: **la UI nunca espera a la red.** Si una pantalla muestra un spinner esperando a
Supabase, está mal escrita.

---

## Roles

| Rol | Alcance | Puede |
|---|---|---|
| `superadmin` | plataforma | todo: tenants, licencias, usuarios, config global, publicar versiones |
| `owner` | su tenant | todo dentro del salón, incl. aprobar usuarios |
| `admin` | su tenant | igual que owner, sin borrar el tenant |
| `profesional` | su tenant | agenda, clientas, caja |
| `lectura` | su tenant | solo ver |

El **revendedor** es un `superadmin`. Puede leer datos de negocio de sus tenants, pero **toda
lectura cross-tenant queda en `audit_log`** y el tenant puede verla. No es opcional.

---

## Convención de commits

```
<tipo>(<alcance>): <descripción en minúscula, imperativo, sin punto final>
```

| Tipo | Cuándo |
|---|---|
| `feat` | nueva funcionalidad |
| `fix` | corregir un bug |
| `docs` | cambios en la documentación |
| `style` | cambios de formato (`dart format`, espaciado) — sin tocar lógica |
| `refactor` | cambios de código que no agregan función ni corrigen bug |
| `perf` | mejoras de rendimiento |
| `test` | agregar o corregir tests |
| `build` | toolchain, `pubspec.yaml`, Gradle, dependencias |
| `ci` | workflows de GitHub Actions, scripts de release |
| `chore` | tareas varias |

**Alcance**: `auth` · `agenda` · `crm` · `caja` · `stock` · `stats` · `sync` · `theme` · `admin` · `updater` · `sql`

Reglas:
- Español, imperativo presente ("agrega", no "agregado"), minúscula inicial, sin punto final, 72 caracteres como máximo.
- Cuerpo opcional tras línea en blanco: explica el **por qué**, no el qué. Envuelto a 72 columnas.
- Breaking change: `!` tras el alcance más un pie `BREAKING CHANGE: …`. **Obligatorio** en cualquier
  cambio de esquema que rompa APKs viejos que ya están en la calle.
- Un commit es un cambio coherente. Nada de "varios arreglos".

```
feat(agenda): agrega deteccion de solapamiento de turnos
fix(sync): evita perder ajustes de stock concurrentes usando deltas
ci(release): compila el apk firmado en github actions
```

**Ramas**: `main` protegida y siempre desplegable. Trabajo en `feat/<alcance>-<breve>` o
`fix/<alcance>-<breve>`. Merge por PR con squash. Tags: `apk-<version>`, `pwa-<version>`.

---

## Bitácora de planificación — `planes/`

Cada planificación del proyecto se guarda como **archivo separado** en `planes/`, con su nombre
respectivo. No se sobrescriben ni se acumulan en un solo archivo.

- Nombre: `NN-nombre-del-plan.md`, numerado cronológicamente.
- Encabezado: fecha · objetivo · decisiones tomadas (y las descartadas, con motivo) · estado
  (`propuesto` / `aprobado` / `implementado` / `descartado`).
- **`planes/` está en `.gitignore` y NO sube al repo.** Verificar con `git check-ignore` antes del push.
- `HANDOFF.md` lleva el índice (título, estado y una línea). El índice sí sube; el contenido no.

Arranque de cualquier sesión: `CLAUDE.md` → `HANDOFF.md` → el plan relevante en `planes/`.

---

## Reglas para futuras sesiones de Claude Code

1. Leer `HANDOFF.md` antes de proponer nada. Dice en qué fase está el proyecto.
2. Cambios mínimos. No refactorizar lo que funciona.
3. Antes de escribir un widget, leer `02-DESIGN-SYSTEM.md`. Los valores no se estiman a ojo.
4. Antes de tocar el esquema, leer `03-BACKEND-SUPABASE.md`. Toda tabla nueva replica el patrón.
5. Antes de agregar una entidad al sync, leer `05-OFFLINE-SYNC.md`.
6. No agregar dependencias sin preguntar.
7. Probar en móvil primero — es el dispositivo primario de la dueña.
8. Al terminar, actualizar `HANDOFF.md` con lo hecho y el próximo paso.
