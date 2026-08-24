# 00 · Plan maestro y checklist de fases

El plan narrativo completo está en `planes/01-migracion-flutter-supabase.md` (local, no versionado).
Este archivo es la **checklist ejecutable**: se marca a medida que se avanza y se refleja en `HANDOFF.md`.

---

## Fase 0 — Toolchain

- [x] Flutter 3.47 + Dart 3.13 en `C:\src\flutter` (falta agregarlo al PATH)
- [ ] JDK 17 o 21 instalado (el activo hoy es **25**, incompatible con Gradle/AGP)
- [ ] Android SDK + platform-tools
- [ ] `flutter doctor -v` limpio para Android y Web
- [x] `flutter create` — plataformas android y web generadas
- [x] `.gitignore` en `app_flutter/` (env.json verificado como ignorado)
- [ ] `git init` + primer commit `chore: inicializa proyecto flutter`
- [ ] Verificar `git check-ignore android/planes` antes del primer push

## Fase 1 — Backend (desbloquea todo)

- [x] Reactivar el proyecto Supabase `hanljsmsgvezuhmehqla`
- [x] Ejecutar `sql/00_limpieza.sql` (borró las 7 tablas `data jsonb`, verificadas vacías)
- [x] Ejecutar `sql/01_plataforma.sql` (tenants, profiles, tenant_members, licencias, audit_log, app_config)
- [x] Ejecutar `sql/02_negocio.sql` (7 tablas de negocio + appointment_services)
- [x] Ejecutar `sql/03_rls.sql` (helpers + policies)
- [x] Ejecutar `sql/04_funciones.sql` (RPC de deltas de stock, seed de tenant)
- [x] Ejecutar `sql/05_permisos.sql` (grants finos)
- [x] Superadmin 1 sembrado · [ ] falta el revendedor (tiene que entrar una vez)
- [x] Activar Google como provider en Authentication → Providers
- [x] Cargar las URLs en los **tres** lugares (ver `04-AUTH-Y-ROLES.md` §7):
      Google *JavaScript origins* (puerto exacto) · Google *redirect URIs* (callback de Supabase) ·
      Supabase *Redirect URLs* (acepta wildcards)
- [x] Probar las RLS con los 5 roles — corrido, 2 bugs encontrados y arreglados
- [x] `get_advisors` security limpio (salvo 11 warnings intencionales)

## Fase 2 — Auth + tenancy

- [x] `AppConfig` por `--dart-define` (URL + publishable key)
- [x] Cliente Supabase inicializado con PKCE y deep link
- [x] Login con Google en **web** verificado end-to-end · falta probar en el APK
- [x] `SessionController` (Riverpod): sesión → profile → membresías → tenant activo
- [x] Las 5 pantallas de gate: splash, login, pending, blocked, expired
- [x] Guardas de `go_router` según rol
- [x] Camino offline: gracia de 7 días — **lógica lista y testeada**; falta leer el cache de Drift (Fase 3)
- [x] Selector de tenant para superadmin — lógica lista, falta la UI

## Fase 3 — Datos locales + sync

- [ ] Tablas Drift espejo de las 7 de negocio + `outbox` + `sync_state`
- [ ] DAOs y repositorios (uno por entidad)
- [ ] `uuid v7` en el cliente
- [ ] `OutboxQueue` con reintento exponencial
- [ ] `SyncEngine`: pull por `updated_at`, tombstones por `deleted_at`
- [ ] Conflictos: LWW general, **deltas** para `stock_items.cantidad`
- [ ] Reacción a `connectivity_plus`
- [ ] Import/export JSON compatible con el formato legacy

## Fase 4 — Design system

- [x] `core/theme/tokens.dart` con los valores literales de `02-DESIGN-SYSTEM.md`
- [x] Fuentes Cormorant Garamond + Inter + Parisienne en `assets/fonts/` (variables, OFL)
- [x] `app_theme.dart` + `shadows.dart` + `motion.dart` + `typography.dart` (con `fontVariations`)
- [x] Curvas exactas `Cubic(.4,0,.2,1)` y `Cubic(0,0,.2,1)`
- [x] Widgets de las animaciones + `StaggeredEntrance` + `PressableScale`
- [ ] Componentes base: Chip, Pill, Sheet, Toggle, EmptyState, Fab, KpiCard, Card
- [ ] `AppShell` responsive: BottomNav (móvil) ↔ NavigationRail (>=900px)
- [x] Los 64 iconos SVG (14 del original + 46 del diseñador + 4 ilustraciones)
- [x] `avc(name)` replicado (hash `h = (h*31 + c) % 6`)

## Fase 5 — Pantallas de negocio

- [ ] Dashboard (saludo por hora, KPI hero, proyección, agenda de hoy, quick actions, stock, recordatorios)
- [ ] Agenda (calendario, filtros de pro y estado, timeline por hora)
- [ ] CRM (búsqueda, filtros, ficha de clienta, mensajes rápidos)
- [ ] Caja (navegador de mes, balance, filtros, cierre de caja)
- [ ] Stock (búsqueda, filtros, ajuste +/-)
- [ ] Stats (4 KPIs, resultado financiero, gastos por categoría, barras 8 semanas, donut, top clientas, comparativa, export CSV)
- [ ] Ajustes (perfil, estudio, profesionales, servicios, backup, app)
- [ ] Los 10 modales
- [ ] Panel de notificaciones

## Fase 6 — Panel superadmin / revendedor

- [ ] Lista de tenants con estado y licencia
- [ ] Alta de tenant (Edge Function `crear-tenant`)
- [ ] Suspender / reactivar tenant
- [ ] Gestión de usuarios por tenant (aprobar, bloquear, rol)
- [ ] Licencias: renovar, ver historial de pagos, alertas de vencimiento
- [ ] "Entrar como" un tenant, con banner visible y registro en `audit_log`
- [ ] Vista de auditoría (el tenant ve quién miró sus datos)
- [ ] Acceso oculto conservado: triple-tap en el logo (600 ms) + `Ctrl+Shift+A`

## Fase 7 — Notificaciones

- [ ] `firebase_core` + `firebase_messaging`, tabla `device_tokens`
- [ ] `flutter_local_notifications` para recordatorios sin servidor
- [ ] Edge Function `enviar-push`
- [ ] Cron: recordatorio de retoque, turno de mañana, licencia por vencer, stock bajo

## Fase 8 — Build y distribución

- [ ] Ícono de app en PNG por densidad ← **falta del diseñador, bloquea el APK**
- [ ] Generar el keystore y **respaldarlo** (gestor de contraseñas + 2 lugares privados)
- [ ] Secrets de GitHub: keystore base64, passwords, service-role key
- [ ] Workflow `pwa.yml` → GitHub Pages
- [ ] Workflow `apk.yml` → compila firmado, publica el release, actualiza `app_config`
- [ ] Plugin Kotlin `MirameUpdater` (PackageInstaller silencioso + FileProvider de reserva)
- [ ] Sheet de actualización en Dart
- [ ] `scripts/bump-version.sh` y `scripts/apk-release.sh`
- [ ] Prueba end-to-end de actualización en un teléfono real

## Fase 9 — Migración de datos reales

- [ ] Exportar el JSON de la app legacy (Ajustes → Exportar datos)
- [ ] Script de importación con las correcciones de modelo aplicadas
- [ ] Verificación de totales (turnos, clientas, caja del mes) contra la app vieja
- [ ] Período de convivencia con la app legacy antes de apagarla
