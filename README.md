# Mírame App — documentación de la migración a Flutter

Migración de la PWA de un solo archivo (`../index.html`) a un producto multi-tenant con app nativa
Android (APK) y PWA, backend Supabase y funcionamiento offline.

## Por dónde empezar

1. **`HANDOFF.md`** — estado actual, próximo paso, decisiones tomadas y riesgos abiertos.
2. **`CLAUDE.md`** — constitución técnica: restricciones, convenciones, flujo de datos.
3. **`00-PLAN-MAESTRO.md`** — checklist ejecutable de las 10 fases.

## Documentos

| Archivo | Qué contiene |
|---|---|
| `CLAUDE.md` | Constitución técnica. Restricciones no negociables, convención de commits |
| `HANDOFF.md` | Estado, decisiones, riesgos, índice de planes, bitácora |
| `00-PLAN-MAESTRO.md` | Checklist de las fases 0 a 9 |
| `01-ARQUITECTURA.md` | Capas, stack, rutas, configuración, errores, tests |
| `02-DESIGN-SYSTEM.md` | **Tokens literales del CSS original.** Colores, tipografía, sombras, motion |
| `03-BACKEND-SUPABASE.md` | Esquema, RLS, funciones, auditoría, verificación |
| `04-AUTH-Y-ROLES.md` | Login, gate de acceso, roles, tenancy, impersonación |
| `05-OFFLINE-SYNC.md` | Drift, outbox, pull incremental, conflictos, deltas de stock |
| `06-NOTIFICACIONES.md` | FCM y notificaciones locales |
| `07-PWA-Y-APK.md` | Toolchain, builds, workflows de CI, secrets, repo |
| `08-AUTOUPDATE-APK.md` | Auto-actualización: plugin nativo, `app_config`, rollback, keystore |
| `09-MIGRACION-DATOS.md` | Traer los datos reales de la app vieja |
| `10-EVAL-REPO-CRP.md` | Grilla para evaluar repos externos + lo ya buscado |
| `11-BRIEF-DISENADOR.md` | Brief listo para pasarle al diseñador |

## Carpetas

| | |
|---|---|
| `sql/` | Migraciones numeradas, ejecutables en el SQL Editor de Supabase |
| `scripts/` | `bump-version.sh`, `apk-release.sh` |
| `skills/` | 4 skills de proyecto para futuras sesiones de Claude Code |
| `planes/` | **Bitácora de planificación. NO sube al repo** (ver `.gitignore`) |
| `app_flutter/` | El código Flutter (se crea en la Fase 0) |

## Estado

Documentación completa. Código sin iniciar. **Fase 0: toolchain.**
