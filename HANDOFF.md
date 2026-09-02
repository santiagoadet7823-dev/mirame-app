# HANDOFF — Mírame App (Flutter)

> **Este es el primer archivo que se lee al abrir una sesión de trabajo.**
> Dice en qué estado está el proyecto, qué se decidió y cuál es el próximo paso.
> Actualizarlo al terminar cada sesión no es opcional.

**Última actualización:** 2026-08-30
**Estado general:** PWA publicada y APK distribuyéndose solo. Repo `mirame-app` vivo.
**Fase actual:** 5 — falta solo Estadísticas. Después: fase 6 (panel) y 7 (notificaciones)

## Links en producción

| Qué | Dónde |
|---|---|
| PWA | https://santiagoadet7823-dev.github.io/mirame-app/ |
| **Tienda de ropa** (el link para las clientas) | https://santiagoadet7823-dev.github.io/mirame-app/tienda.html?t=mirame |
| Landing de descarga (la del QR) | https://santiagoadet7823-dev.github.io/mirame-app/descargar.html |
| Repo | https://github.com/santiagoadet7823-dev/mirame-app |
| Releases | https://github.com/santiagoadet7823-dev/mirame-app/releases |

Publicar una versión nueva:

```bash
bash scripts/bump-version.sh 1.0.3
git commit -am "build: sube a 1.0.3" && git push      # republica la PWA sola
git tag apk-1.0.3 && git push origin apk-1.0.3        # compila, firma y publica el APK
```

⚠️ **`SUPABASE_SERVICE_ROLE_KEY` no está cargado como secret**, así que el workflow avisa con un
`::warning::` y `app_config` hay que actualizarlo a mano después de cada release:

```sql
update public.app_config
set latest_version = 'X.Y.Z',
    apk_url = 'https://github.com/santiagoadet7823-dev/mirame-app/releases/download/apk-X.Y.Z/app-release.apk',
    updated_at = now()
where id = true;
```

`min_version` se sube aparte y **a mano siempre**, recién cuando la versión se comprobó buena: es
el piso que fuerza la actualización, y automatizarlo haría que un release roto trabe a toda la
flota sin arreglo remoto.

---

## 1. Estado por fase

| Fase | Qué | Estado |
|---|---|---|
| 0 | Toolchain | ✅ **completo**. Flutter 3.47 + Dart 3.13 en `C:\src\flutter` (fuera del PATH), Android SDK 36.1, JDK 21 el que trae Android Studio. No hizo falta instalar nada |
| 1 | Backend: esquema SQL + RLS + roles | ✅ **desplegado y verificado** · superadmin 1 sembrado · primer tenant creado · falta el superadmin 2 (revendedor) |
| 2 | Auth + tenancy + roles | ✅ **login end-to-end funcionando** con Google real |
| 3 | Capa de datos local + motor de sync | ✅ Drift + outbox + deltas + cache de acceso offline |
| 4 | Design system en Dart | 🟨 tokens, tipografía, sombras, motion y tema listos · faltan los componentes de negocio |
| 5 | Pantallas de negocio | ✅ **completa**. Shell, inicio, agenda, clientas, caja, stock, stats, cierre de caja, exports CSV y ajustes (servicios, profesionales, exportar backup). Único pendiente: **importar** backup, que necesita `file_picker` — dependencia nueva, sin aprobar todavía |
| 6 | Panel superadmin / revendedor | 🟨 lista de salones + entrar a un salón ✅ · faltan alta de tenant, licencias, usuarios y auditoría |
| 7 | Notificaciones | 🟨 **locales completas** (retoque, turnos de mañana, cierre de caja, stock, cumpleaños) con permiso pedido en contexto · `device_tokens` + `enviar-push` escritos · el push queda inerte hasta cargar `google-services.json` y la service account — ver `06-NOTIFICACIONES.md` §6 |
| 8 | Build PWA + APK, auto-update, distribución | 🟨 **APK 1.0.0 firmado y compilando OK** (62 MB) · falta el auto-updater y el pipeline de GitHub |
| **R** | **Módulo de ropa (consignación)** | 🟨 Fases A–D y F listas: esquema + RLS + vitrina segura, catálogo con talles y fotos, ventas con reparto a tres puntas e impacto en caja, tienda pública con carrito y reservas. liquidaciones con PDF detallado y su egreso en caja. Falta solo **vendedores con cuenta**: el rol `vendedor` y sus policies YA están en el esquema (ve solo su depósito, carga solo sus ventas, no ve el porcentaje del proveedor), falta la invitación y sus pantallas |
| 9 | Migración de los datos reales de la dueña | ✅ **en produccion**: 67 clientas, 96 turnos, 120 servicios de turno, 112 movimientos, 13 servicios, 1 profesional, 2 de stock. Ademas hay **Restaurar backup** en Ajustes, con ids uuid5 deterministas que coinciden con los de la migracion por SQL, asi que reimportar el mismo JSON no duplica nada |

Leyenda: ⬜ pendiente · 🟨 en curso · ✅ hecho · ⛔ bloqueada

---

## 2. Lo que ya está construido

`app_flutter/` — proyecto Dart funcionando. **`flutter analyze` limpio, 147 tests pasando.**

```
lib/core/config/app_config.dart   --dart-define, sin secretos en el repo
lib/core/theme/tokens.dart        paleta, radios, sombras, motion, breakpoints (literales del CSS)
lib/domain/entities/entities.dart 7 entidades de negocio + TimeOfDayValue
lib/domain/entities/access.dart   Profile · Tenant · Membership · License
lib/domain/rules/
  formatting.dart                 formatMoney · initials · avatarIndex · fechas · saludo
  period.dart                     rangos de mes y semana, sin el bug de UTC del legacy
  finance.dart                    resumen, proyección, cierre de caja, gastos por categoría,
                                  barras semanales, donut, top clientas, ticket, comparativa
  stock.dart                      estado, barra, ajuste por delta, alertas, filtros
  reminders.dart                  recordatorios de retoque y cumpleaños
  agenda.dart                     horarios libres, agrupado por hora, SOLAPAMIENTOS (nuevo)
  access.dart                     EL GATE: resolveAccess() + gracia offline + permisos
lib/data/remote/                  cliente Supabase (PKCE) + mappers de acceso
lib/data/repositories/            AccessRepository
lib/core/theme/                   tokens · typography · shadows · motion · app_theme
lib/core/router.dart              go_router + guardas (traduce la decisión, no decide)
lib/features/auth/                SessionController + las 5 pantallas + widgets
lib/main.dart                     bootstrap
assets/icons/                     64 SVG: 14 del original + 46 del diseñador + 4 ilustraciones
assets/fonts/                     Inter y Cormorant variables + Parisienne (OFL incluida)
assets/brand/                     logo-mirame.jpg + el JS fuente de los iconos
test/                             147 tests (137 de dominio + 10 de widget)
```

Comandos (Flutter no está en el PATH todavía):

```bash
cd android/app_flutter
/c/src/flutter/bin/flutter test test/domain
/c/src/flutter/bin/flutter run -d chrome --dart-define-from-file=env.json
```

`env.json` (ignorado por git) tiene `SUPABASE_URL` y `SUPABASE_PUBLISHABLE_KEY`.

Por qué se empezó por acá: es la parte que la documentación marca como "lo que más duele si se
rompe", es Dart puro (no depende del diseñador ni del backend), y es testeable sin emulador.

---

## 3. Próximo paso concreto

**Del diseñador ya llegó y está integrado:** los 46 iconos, las 4 ilustraciones de estado vacío y
las 3 familias tipográficas. Ver §9.

**Lo que del diseñador NO llegó terminado:** el ícono de app y el splash. El entregable es un
**boceto vectorial**, no arte final, y no trae ningún PNG exportado. Detalle y decisiones
pendientes en §9.

**Lo que se puede avanzar sin esperar**, en orden de valor:

1. **Fase 3 — motor de sync.** Ojo: `sqlite3_flutter_libs` resolvió a `0.6.0+eol`, hay que ver
   cuál es el reemplazo vigente. Además el `SessionController` tiene un TODO que lo espera: sin
   red todavía no lee el cache local.
2. **Fase 4 — componentes base** de `shared/widgets/` que no dependen de tipografía definitiva
   (Chip, Pill, Toggle, Sheet, StaggeredEntrance).
3. **Fase 6 — panel de plataforma.** Hoy `/admin` es un `_Placeholder`. Ya hay un tenant real
   para listar.

**Pendiente que necesita tu intervención:** correr `sql/06_seed_superadmins.sql` con los UID reales
tuyo y del revendedor. Requiere que cada uno entre a la app una vez para que exista el usuario.

---

## 4. Índice de planes (`planes/` — NO sube al repo)

| # | Plan | Estado | En una línea |
|---|---|---|---|
| 01 | `01-migracion-flutter-supabase.md` | aprobado | Plan maestro de la migración HTML → Flutter + Supabase multi-tenant |
| 03 | `03-distribucion-pwa-y-apk.md` | implementado | PWA en Pages, releases por tag, invitación por QR y la diferencia real con la OTA de DisT-At |
| 02 | `02-empaquetado-apk.md` | implementado | Rama anticipada de la Fase 8: keystore, firma, iconos y deep link para probar en un teléfono real |
| 04 | `03-tienda-diseno.md` | implementado (fase 0) | Diagnóstico de la vitrina, arreglos de identidad y WhatsApp, y el brief de diseño (`12-BRIEF-TIENDA.md`) |
| 05 | `04-tienda-implementacion.md` | fases 1 y 2 implementadas | La entrega del diseñador portada al HTML plano; cuentas de clienta y mails quedan para las fases 3 y 4 |
| 06 | `05-equipo-y-roles.md` | implementado | Rol `encargado`, permisos más finos, pantalla de Equipo y limpieza de nombres |
| 07 | `06-catalogo-arbell.md` | implementado | Carga masiva del catálogo Arbell desde el PDF, y el procedimiento para actualizar precios con el PDF de cada bimestre |

> El contenido de `planes/` es local. Este índice es lo único que se versiona.
> Al crear un plan nuevo, agregar la fila acá.

---

## 5. Decisiones tomadas (y por qué)

| Decisión | Motivo | Alternativa descartada |
|---|---|---|
| Flutter en vez de seguir con Capacitor | Se pidió desarrollo nativo. Un código para APK y PWA. | Capacitor (lo que usa DisT-At) — conserva el canal OTA, pero no es nativo |
| **Supabase Auth**, no Firebase Auth | Las RLS necesitan `auth.uid()` de Supabase. Dos proveedores de identidad para el mismo usuario es la fuente de bugs número uno en estas migraciones. | Mantener Firebase Auth y mapear UIDs |
| Firebase solo para FCM | Es lo único que Supabase no cubre bien. El proyecto `mirame-lash-studio-41ba9` ya existe. | OneSignal, push propio |
| Multi-tenant desde el día 1 | Es un producto para revender. Agregar `tenant_id` después implica una migración dolorosa con datos en producción. | Single-tenant y migrar luego |
| Local-first con Drift + outbox | La app tiene que funcionar sin señal, no solo leer en cache. | Cache online-first; PowerSync (evaluar más adelante, ver `10-EVAL-REPO-CRP.md`) |
| Esquema relacional, no `data jsonb` | El `supabase/schema.sql` que ya existía usa `jsonb` por fila: no permite RLS por campo, ni índices útiles, ni sync incremental. | Reusar el schema jsonb existente |
| `uuid v7` generado en el cliente | Permite crear registros offline sin esperar al servidor y sin colisiones. | Autoincremental del servidor |
| Plugin Kotlin propio para el auto-update | Ningún paquete de pub implementa la instalación silenciosa de Android 12+. | `ota_update`, `install_plugin` |
| Sin canal OTA | Google prohíbe descargar código Dart ejecutable. Se compensa con la PWA (instantánea) y la instalación silenciosa del APK. | — |

---

## 6. Riesgos abiertos

| Riesgo | Impacto | Mitigación |
|---|---|---|
| **Pérdida del keystore** | Ningún APK futuro se instala como actualización. Los usuarios tendrían que desinstalar, perdiendo los datos locales. | Backup en gestor de contraseñas + 2 lugares privados **antes** del primer release. Secret base64 en GitHub para CI. |
| Free tier de Supabase permite 2 proyectos activos | `la-union-pwa` y `mirame` ocupan los dos; `rindemax` quedó pausado | Si hace falta un tercero, hay que pagar |
| El revendedor lee datos de clientas de terceros | Exposición de datos personales | `audit_log` obligatorio en toda lectura cross-tenant, visible para el tenant |
| Instalación silenciosa no aplica en la primera actualización | Se reporta como bug cuando no lo es | Documentado en `08-AUTOUPDATE-APK.md` §5 |
| Fidelidad estética | Es el requisito más fácil de romper sin darse cuenta | Comparación lado a lado contra el `index.html` original, vista por vista |

---

## 7. Credenciales y recursos (dónde están, NO los valores)

| Recurso | Dónde | Nota |
|---|---|---|
| Proyecto Supabase | ref `hanljsmsgvezuhmehqla`, región `sa-east-1` | **ACTIVO** · esquema + RLS + Google OAuth funcionando |
| Proyecto Firebase (solo FCM) | `mirame-lash-studio-41ba9` | Ya existe, se reutiliza |
| Cuenta GitHub | `santiagoadet7823-dev` | `gh` ya está autenticado en la máquina |
| Repo nuevo | `mirame-app` (a crear) | Público: Pages y Releases gratis |
| Repo legacy | `santiagoadet7823-dev/mirame-lash-studio` | Se conserva como archivo histórico |
| Superadmin 1 | `6e87e720-77c7-44b1-b1c2-68780c13cde5` (santiagoadet7823@gmail.com) | Sembrado el 2026-08-23 |
| Superadmin 2 (revendedor) | **pendiente** | Tiene que entrar una vez a la app primero |
| OAuth client de Google | proyecto `135777850810` | ⚠️ Ese proyecto tiene varios clients; el del Drive legacy ya no se usa |
| Keystore | **a generar en Fase 8** | Nunca en el repo |
| Anon key de Supabase | `--dart-define`, horneada en el build | Es pública por diseño; la seguridad la da RLS |
| Service-role key | Secret de GitHub Actions | **Nunca** en el cliente |

---

## 8. Referencias externas usadas

| Qué | Dónde | Para qué |
|---|---|---|
| App legacy | `../index.html` (3207 líneas) | Fuente de verdad de la estética y de las reglas de negocio |
| Fork Supabase abandonado | `../mirame-lash-studio/` | Solo de referencia histórica; su `schema.sql` se descarta |
| Pipeline APK probado | repo `santiagoadet7823-dev/la-union-app` | Base del auto-updater: `web/src/services/apkUpdate.js`, `ApkUpdaterPlugin.java`, `scripts/apk-release.sh`, `GUIA_ACTUALIZACION_APK.md` |
| Workflow de Pages | `la-union-app/.github/workflows/deploy.yml` | Base del deploy de la PWA |

---

## 9. Entrega del diseñador (2026-08-23)

Origen: `Mirame-entregables-completo.html`, un bundle auto-extraíble de 4,9 MB. Los assets venían
empaquetados en base64 dentro de un `<script type="__bundler/manifest">`; se desempaquetaron y
verificaron uno por uno. La fuente original de los iconos quedó archivada en
`app_flutter/assets/brand/_fuente-iconos-disenador.js`.

### ✅ Completo y ya integrado

| Entregable | Estado |
|---|---|
| **46 iconos de línea** | Grilla 24×24, trazo 1.8, terminaciones redondeadas — cumple la spec del brief. En `assets/icons/` |
| **4 ilustraciones de estado vacío** | 120×120, con el gradiente lavanda→nude de la marca. `empty-*.svg` |
| **Panel de administración** | Diseñado: lista de salones, ficha, alta, auditoría |
| **Fuentes** | Inter y Cormorant Garamond **variables** + Parisienne. Bajadas de Google Fonts (OFL incluida) |

Los 64 SVG se validaron con un parser XML: todos tienen `viewBox` y geometría visible
(215 formas dibujables, 0 problemas).

### ⚠️ Incompleto — el ícono de app

El propio diseñador lo marca: *"Boceto vectorial, no arte final"* y *"para el arte final del
monograma conviene que lo dibuje quien hizo el logo original"*.

Lo que falta para poder compilar el APK:

1. **No hay PNG exportados.** El bundle no trae ni un solo archivo de densidad (mdpi→xxxhdpi, ni
   192/512 para la PWA). Solo especifica los tamaños.
2. **El monograma usa `<text>` con Cormorant Garamond.** Un SVG con `<text>` depende de que la
   fuente esté instalada al rasterizar: hay que convertirlo a trazos antes de exportar.
3. **El logo sigue siendo un JPEG.** El diseñador lo dice explícito: *"para el build hay que
   vectorizarlo"*. Está en `assets/brand/logo-mirame.jpg`.

### 🟡 Decisión pendiente — Parisienne en el wordmark

El diseñador introdujo **Parisienne** (cursiva) para el wordmark "Mírame" del splash y el login.
El `index.html` original usa **Cormorant Garamond** ahí (`splash-name` 28 px w500, `auth-name`
40 px w600).

El brief decía explícitamente que la tipografía no se toca, pero esto entra en el entregable del
splash, así que es discutible. **Requiere decisión del usuario.** La fuente ya está en el proyecto
(61 KB), así que ir por cualquiera de las dos opciones no cuesta trabajo extra.

### Nota técnica — fuentes variables

Google Fonts ya no publica instancias estáticas de Inter ni de Cormorant: solo variables. Eso
implica que **`fontWeight` por sí solo no mueve el eje de peso de forma confiable**; los estilos
de texto deben setear también `fontVariations: [FontVariation('wght', N)]`. Se centraliza en
`core/theme/app_theme.dart` cuando se escriba.

Peso: Inter 876 KB + Cormorant 1,19 MB + Parisienne 61 KB ≈ **2,1 MB**. Se descartaron las
itálicas porque el original las declara en la URL de Google Fonts pero **ningún elemento las usa**
(verificado con grep), lo que ahorra 1,6 MB. Si el peso molesta en la PWA, la optimización es
instanciar subsets estáticos con `fonttools` — no está instalado en la máquina.

---

## 10. Bitácora de sesiones

### 2026-08-22 — Análisis y planificación
- Inventario exhaustivo del `index.html`: design tokens literales, 7 vistas, 10 modales, modelo de
  datos de las 7 stores, reglas de negocio, auth, Drive backup, iconografía.
- Ingeniería inversa del pipeline de distribución de DisT-At / la-union-app.
- Búsqueda en GitHub de repos adaptables: sin candidatos maduros (ver `10-EVAL-REPO-CRP.md`).
- Decisiones de arquitectura tomadas con el usuario (multi-tenant, local-first, alcance del revendedor).
- Escrita la documentación completa de `android/`.
- **Próximo:** Fase 0.

### 2026-08-23 — Capa de dominio
- **Hallazgo:** Flutter 3.47 / Dart 3.13 ya estaban instalados en `C:\src\flutter`, sin PATH.
  La Fase 0 no arrancaba de cero.
- Portada la capa `domain/` completa desde el `index.html`: formato, períodos, finanzas, stock,
  recordatorios y agenda. **97 tests, `flutter analyze` limpio.**
- Agregada detección de solapamiento de turnos, que el legacy no tenía. **Avisa, no bloquea**:
  a veces la dueña sabe lo que hace, y frenar una operación legítima sería peor que el bug.
- Extraídos los 14 SVG del original a `assets/icons/`.
- `tokens.dart` con la paleta, radios, sombras, motion y breakpoints literales del CSS.
- Corregidos los nombres del catálogo semilla en `sql/04_funciones.sql` para que coincidan con el
  `seedDemo()` original ("Extensiones Volumen", "Lifting de Pestañas").
- **Próximo:** ejecutar el SQL (requiere reactivar Supabase) o arrancar el motor de sync.

### 2026-08-23 (tarde) — Backend desplegado
- Reactivado el proyecto Supabase de Mírame.
- **Corrección de un error mío:** el primer `list_tables` devolvió 0 tablas y reporté que el
  esquema de julio nunca se había ejecutado. Era una vista incompleta durante el restore: las 7
  tablas `data jsonb` **sí existían**. Se verificó que estaban vacías (0 filas, 0 usuarios) antes
  de borrarlas.
- Aplicadas las migraciones 00 a 04. **16 tablas, todas con RLS.**
- **Dos bugs de seguridad encontrados probando, no leyendo** (detalle en `03-BACKEND-SUPABASE.md` §4):
  1. `rol_en()` devuelve NULL para no-miembros y `not (NULL)` no dispara → el owner del Salón A
     modificó el stock del Salón B. Arreglado con `coalesce(...,false)` y `is not true`.
  2. `revoke ... from authenticated` no sirve porque PUBLIC tiene EXECUTE por defecto →
     `vencer_licencias()` era invocable sin sesión. Arreglado en `sql/05_permisos.sql`.
- Checklist de RLS corrido completo con 4 roles simulados. Todo pasa. Fixtures borrados.
- `get_advisors`: sin warnings de `anon`. Quedan 11 de `authenticated`, intencionales y documentados.
- **Próximo:** motor de sync (Fase 3), o auth en el cliente (Fase 2).

### 2026-08-23 (noche) — Assets del diseñador
- Desempaquetado el bundle: 46 iconos + 4 ilustraciones + 3 familias tipográficas, todo integrado
  y verificado. `flutter analyze` limpio, 97 tests pasando.
- **El ícono de app NO está terminado** (boceto sin PNG exportados). Sigue bloqueando el build
  del APK. Ver §9.
- **Parisienne** apareció en el wordmark del splash, reemplazando a Cormorant. Pendiente de
  decisión del usuario.
- Bug propio corregido: mi primera extracción de las ilustraciones perdió el atributo `stroke`
  (los colores venían como identificadores, no como strings) y quedaban invisibles.
- **Próximo:** motor de sync (Fase 3), o `app_theme.dart` ahora que están las fuentes.

### 2026-08-23 (cont.) — Lógica de acceso (Fase 2)
- `domain/rules/access.dart`: el árbol completo del gate como **función pura**
  (`resolveAccess`), con **30 tests**. Incluye la gracia offline de 7 días, el manejo de
  superadmin/impersonación y la tabla de permisos que espeja las RLS.
- Decisiones que quedaron codificadas y testeadas:
  · un bloqueo en un salón **no se esquiva** teniendo otro pendiente;
  · si el salón guardado ya no le corresponde al usuario, cae en uno válido en vez de dejarlo afuera;
  · una licencia **ya vencida no se perdona** por estar offline — la gracia cubre no poder
    *validar*, no una licencia que se sabe muerta;
  · sin ninguna validación previa no hay gracia;
  · un superadmin entra a un salón vencido (justamente para poder renovarlo);
  · impersonando, ni el superadmin escribe.
- `data/remote/access_mappers.dart`: enums desconocidos caen al lado seguro (rol → `lectura`,
  estado de tenant → `cancelado`). Con tests.
- `AccessRepository` + `SessionController` (Riverpod) + providers de permisos para la UI.
- Verificado contra la base real que todas las columnas que consulta el repositorio existen.
- `Supabase.initialize` usa `publishableKey`: `anonKey` quedó deprecado. `AppConfig` acepta los
  dos nombres de `--dart-define` para no romper la documentación ya escrita.
- **Próximo:** `app_theme.dart` y las 5 pantallas de gate.

### 2026-08-23 (cont.) — Tema y pantallas de gate
- `core/theme/`: `typography.dart` (helpers que **siempre** setean `fontVariations`),
  `shadows.dart`, `motion.dart` (las 7 animaciones como widgets, todas respetando
  `disableAnimations`) y `app_theme.dart`.
- Detalle del original que se replicó: **no hay ripple de Material**. Los controles responden con
  `scale(0.97)`, como el `:active` del CSS. Está en `PressableScale` y en el `splashFactory` del
  tema.
- Las **5 pantallas** (splash, login, pendiente, bloqueado, vencido) con los textos exactos del
  `index.html`, y el router con guardas.
- El router **traduce** la decisión del `SessionController`, no decide. Si empezara a decidir
  habría dos fuentes de verdad sobre quién está adentro.
- La pantalla de vencido distingue los 3 motivos: mandar a "renovar" a alguien que solo se quedó
  sin señal lo hace llamar por nada.
- **Bug encontrado al renderizar, no al analizar:** mi script de extracción de iconos borraba
  `width`/`height` de *todos* los elementos y no solo del `<svg>` raíz, así que los `<rect>`
  quedaban sin dimensiones — el candado del login se veía como un garabato. Re-extraídos los 14
  originales y verificado que ningún `rect`/`line`/`circle` quede incompleto.
- Verificado en Chrome a 375×812: el login renderiza fiel al original.
- **Segundo bug encontrado, esta vez por un test de widget:** el botón de WhatsApp desbordaba 29 px
  el Row. No se veía en el navegador porque el login no lo tiene — está en pendiente y vencido.
  Con la fuente escalada por accesibilidad habría reventado en un teléfono real. Los tres botones
  ahora usan `Flexible`.
- Borrado el `test/widget_test.dart` de ejemplo que dejó `flutter create` (referenciaba un `MyApp`
  inexistente y rompía la suite completa).
- **Próximo:** motor de sync (Fase 3).

### 2026-08-23 (cont.) — Login funcionando de punta a punta
- Google OAuth configurado y **verificado con un login real** desde Edge. El usuario quedó en
  `auth.users`, el trigger `handle_new_user` le creó el profile con el nombre de Google, y el gate
  lo mandó a "Solicitud enviada" — exactamente lo que dicta la lógica con 0 membresías.
- Cómo se verificó la config **sin credenciales**, antes de probar a mano: siguiendo la cadena de
  redirects con `curl` hasta la pantalla de Google y buscando `redirect_uri_mismatch` /
  `invalid_client`. Está documentado en `04-AUTH-Y-ROLES.md` §7.
- Dos cosas que ese chequeo destapó y que valen para el futuro:
  · el endpoint `/auth/v1/settings` reportaba `external.google: null` **aunque ya estaba
    habilitado** — parece cachear. Le creemos a `/authorize`;
  · el `client_id` que Supabase enviaba no era el que se creía haber configurado. En el proyecto de
    Google conviven varios clients (incluido el del Drive legacy).
- **Bootstrap del primer superadmin:** el trigger `proteger_rol_plataforma` bloquea el `update`
  desde el SQL Editor, porque ahí no hay `auth.uid()`. Se resuelve desactivando el trigger dentro de
  una transacción y verificando después que quedó ACTIVO. Documentado en `sql/06`.
- Confirmado con el usuario: **Google Drive queda fuera** — Supabase es el respaldo remoto. Ya era
  la decisión registrada en `05-OFFLINE-SYNC.md` §10.
- **Próximo:** crear el primer tenant, o arrancar el motor de sync.

### 2026-08-30 — La vitrina: diagnóstico, arreglos y brief

Se abrió la tienda publicada en un teléfono y se miró como la mira una clienta. Lo que
había: el título decía **"Tienda"** —sin nombre ni logo—, un solo producto con media
pantalla vacía debajo, la foto de una remera con la bolsa de plástico puesta, y encima el
cartel rojo de **Agotado** como el elemento más fuerte de la pantalla. Sin ninguna forma de
escribirle a nadie.

**Tres cosas rotas, arregladas (fase 0):**

- **El botón de WhatsApp nunca aparecía.** `tienda.html` declaraba `let WA = null` y nada se
  lo asignaba jamás, así que el bloque condicionado a `WA` no se mostró ni una vez desde que
  existe la tienda.
- **La vitrina no sabía cómo se llamaba el salón.** Vista nueva `tienda_salon`
  (`slug`, `nombre`, `telefono`), con `security_invoker` como las otras tres.
- **El link no tenía preview.** `og:image` + `og:title`/`description` reales, con
  `tienda-preview.jpg` provisorio generado acá y la URL absoluta inyectada por `pwa.yml`.

**Un agujero real que apareció de paso:** `anon` tenía `select` sobre **todas** las columnas
de `tenants`, y desde que existe la policy `tenants_vitrina` eso sí devolvía filas — un
anónimo podía pedir `?select=creado_por,plan` y ver quién dio de alta cada salón y qué plan
paga. Es la misma trampa ya documentada para `productos`: el `grant` por columna no sirve si
no se **revoca** antes. Corregido y verificado con `set role anon`.

**Otras dos de la misma pasada:**

- La primera pintada era una cascada visible: el encabezado decía "1 producto" mientras el
  cuerpo todavía decía "Buscando prendas…". Ahora las dos consultas salen juntas y hay
  esqueletos del tamaño exacto de las tarjetas.
- La tienda no tenía **ningún** bloque `prefers-reduced-motion`, cuando la app lo respeta en
  todas sus animaciones.

**El teléfono se carga desde "Mi tienda"** (`AccessRepository.guardarTelefono`, RLS
`tenants_owner_update`). El normalizador `telefonoWa` tuvo dos bugs que se cazaron probando
formatos reales: no sacaba el **15** —que se marca solo dentro del país y rompe el link— y
no agregaba el **9** de celular, que casi nadie escribe y wa.me necesita. Verificado con
seis formatos argentinos, todos convergen al mismo número.

**El brief está en `12-BRIEF-TIENDA.md`**, publicado además como página compartible. Decide
tres cosas: la tienda es pieza aparte y se rediseña entera; la marca va **por salón**
(`--marca-nombre` / `--marca-acento` / `--marca-logo`, porque hoy el lavanda está quemado y
el segundo salón abriría con los colores de Candela); y el modo oscuro se descarta a
propósito, no por olvido.

**Próximo:** la entrega del diseñador. Lo que queda pendiente del lado técnico es el preview
por salón o por producto, que necesita una Edge Function — las `og:` no se pueden armar desde
el cliente porque el crawler de WhatsApp no ejecuta JavaScript.

### 2026-08-30 (tarde) — La entrega del diseñador, implementada

Llegó el trabajo sobre `12-BRIEF-TIENDA.md`: `tokens.css` con las variables de marca, los 13
íconos a especificación, las once fotos reales convertidas (los hero a 75 KB contra el techo
de 120) y un prototipo navegable en React. **El prototipo no se copia, se porta**: la tienda
es un HTML plano sin build.

**Corrigió una premisa del brief, y tenía razón.** Yo había escrito que las fotos eran
perchas contra una pared — lo saqué del único producto que existía al redactarlo. Las once
que le pasaron son flat-lays sobre una manta crema casi idéntica al `#ede9e2` de la paleta.
Así que la tarjeta no disimula el recorte: lo **continúa**, con un paspartú de ese crema.
También midió el contraste que yo había marcado como dudoso: `#9c9088` sobre `#faf8f5` da
2,93:1 y no pasa AA. Ahora es decorativo, y el texto usa `#6b6259` — medido acá en **5,63:1**.

**Decisiones tomadas con el usuario:** alcance completo (incluidas cuentas y mails, que van
en las fases 3 y 4); se acepta el cambio de tipografía a **Great Vibes + Jost** derivadas del
logo, con el wordmark tipográfico; y la casilla de avisos **queda pre-tildada** — decisión
del usuario con el riesgo de la Ley 25.326 a la vista, a mitigar con el registro de
consentimiento de la fase 4.

**Fase 1 — la vidriera.** Tokens inline, wordmark armado desde `tienda_salon.nombre`, los 13
íconos inline reemplazando **todos** los emojis, paspartú y aspecto 1:1, ritmo de grilla
derivado del índice (si dependiera de los datos bailaría en cada carga), escalera
30·70·110·150·190·220, fotos que entran por opacidad al decodificar, y la hoja pasada de
`@keyframes` a `transform` con arrastre que cierra por 140 px **o por velocidad**. Siete
estados, favoritos en `localStorage`, y la reserva con **fecha concreta** salteando domingos.

Se agregó un estado que el port no tenía y el diseñador sí había diseñado: **una sola
prenda**, presentada grande. Es el estado real de la tienda hoy, y con la prenda agotada el
texto cambia a "Por ahora no queda nada" en vez de mentir con "Recién entró".

**Fase 2 — la base.** `variante_reservada()` y la columna `reservado` en `tienda_variantes`:
`stock_disponible()` ya restaba las reservas, así que una prenda tomada por otra clienta se
leía como agotada. Son dos cosas distintas para quien mira. Y `direccion` / `instagram` en
`tenants`, editables desde "Mi tienda" — quemarlas en el HTML habría hecho que el segundo
salón saliera con la dirección del primero.

**Las fotos ahora suben en WebP** (`fotos.dart`), que es lo que sostiene el techo de un
segundo. El camino de respaldo sigue guardando `.jpg` y el `contentType` sale de la
extensión: subir el jpg original diciendo que es webp lo dejaba roto en la vitrina.

**Un bug que apareció de paso:** el cache de acceso no guardaba el teléfono. Con los campos
nuevos, abrir "Mi tienda" sin señal los habría mostrado vacíos y guardar desde ahí habría
**borrado la dirección real**. Ahora los tres viajan al cache.

**Verificado** con un banco de pruebas local que intercepta `fetch` y siembra 14 productos:
los tres estados de stock, sin foto, sin resultados, tienda vacía, error y una sola prenda;
cero `div` con onclick, cero emojis, ningún área táctil por debajo de 44×44, y el flujo
completo hasta el código de reserva. Contra datos reales la tienda tiene **un producto
agotado**, así que la grilla llena y la última unidad solo se pudieron ver sembrados.

**Próximo:** fase 3 (cuentas de clienta) y fase 4 (avisos por mail). Del diseñador falta la
imagen de preview del link como archivo y el `logo.svg` que `tokens.css` referencia.

### 2026-08-30 (noche) — Tres bugs del uso real

**Las cantidades por talle no se guardaban.** `_depositoId` se resolvía en
`initState` leyendo `depositosProvider`, que es `autoDispose` y que la pantalla
que abre el formulario no mira: en ese momento no había emitido, `.value` daba
null, y el repositorio —sin depósito— se salteaba el stock **en silencio**.
Ahora el depósito se resuelve al guardar y, si el salón no creó ninguno, se crea
uno. Con tests: `test/data/stock_prenda_test.dart`.

**Solo se veía una foto por prenda.** Se guardaban todas —había tres en la
base— pero el formulario leía `portadasProvider`. Y el `orden` se reiniciaba en
0 en cada tanda, así que la portada pasaba a ser cualquiera; en la base había
dos fotos con orden 0, renumeradas.

**El selector de depósito se escondía con menos de dos depósitos**, que es el
caso real.

**La tienda se veía "con zoom al máximo" y sin scroll.** Dos causas: el ancho
clavado en 520 px (en cualquier pantalla más ancha queda como una tirita con
tipografía de teléfono, que se lee como una página achicada), y el botón atrás
de Android, que se llevaba la hoja pero dejaba el `body` bloqueado con
`overflow:hidden` — la página no volvía a scrollear hasta recargar. Ahora la
grilla se llena sola de 2 a 5 columnas y cada hoja empuja una entrada de
historial.

Cargados el WhatsApp (`+54 9 3877545466`) y el Instagram del salón. **Falta la
dirección**, que se carga desde "Mi tienda".

**Publicado:** APK 1.14.1 y la PWA. **Próximo:** fases 3 y 4 del plan de la
tienda (cuentas de clienta y avisos por mail).

### 2026-08-30 (cierre) — Roles, Equipo y nombres

Al sumar `cardixteam@gmail.com` —un segundo teléfono que queda en el estudio— apareció algo
más grande: **la app y el servidor no estaban de acuerdo**. Todo el módulo de la tienda
exigía `administra()` en la RLS, o sea owner o admin, pero la UI se lo ofrecía a un
`profesional`. Un profesional editando un producto guardaba local y **el sync le fallaba en
silencio, trabado en el outbox**.

**Rol `encargado`** y permisos partidos en dos: `escribirAgenda` (turnos y clientas) y
`operarNegocio` (caja, tienda, insumos). Matriz verificada simulando cada rol con
`set request.jwt.claims`:

| rol | atiende | opera | administra |
|---|:--:|:--:|:--:|
| owner · admin | sí | sí | sí |
| **encargado** | sí | sí | **no** |
| profesional | sí | **no** | no |
| lectura | no | no | no |

Del lado del servidor, la tienda pasó de `administra()` a la nueva `opera()`; caja e insumos
también; y servicios, profesionales y ajustes subieron a `administra()` porque son
configuración, no operación. `verReportes` deja de ser para todos: un profesional que no
toca la caja tampoco ve la facturación.

**Pantalla de Equipo** (`features/settings/equipo_view.dart`): pendientes arriba, aprobar
eligiendo rol, cambiar rol, bloquear, y el botón de invitar. Antes aprobar a alguien había
que hacerlo por SQL. Nadie se puede degradar ni bloquear a sí mismo. La ruta `/admin/invitar`
cuelga del área de plataforma y una dueña no llega, así que la pantalla se empuja directo.

**`cardixteam@gmail.com` quedó como `encargado` aprobado** en el salón de Candela.

**Nombres:** el nav dice **Insumos** (era Stock, y tiene dos insumos reales que ella gasta
trabajando — no era redundante con la tienda, era choque de nombres); el módulo dice
**Tienda** con ícono de local; el acceso al link dice **Compartir**; y el rubro de la vitrina
dice **Estética**, solo la etiqueta — el valor guardado sigue siendo `insumos`.

**El ícono del carrito** pasó a una bolsa con pliegue. Se probaron tres variantes a 24 px: el
fuelle se ensucia y la curva inferior se lee como una carita.

**Próximo:** fases 3 y 4 del plan de la tienda (cuentas de clienta y avisos por mail).

### 2026-08-30 (noche) — El catálogo Arbell cargado, y el procedimiento para el próximo

La tienda declaraba el rubro **Arbell** desde el primer día (`tienda.html:484`,
`producto_form.dart:324`) y no tenía un solo producto adentro. Se cargó el catálogo
`cat-4-2026` (vigencia 08/05 al 09/07): **274 productos, 372 códigos, todos despublicados**.

**Lo primero que hubo que aclarar:** «el salón de Candela» **es** el tenant `mirame`. Candela
Gil figura como `owner` de Mírame Lash Studio y no existe un segundo tenant. El proveedor
`arbell` ya estaba creado.

**Las herramientas viven en `scripts/arbell/`** y no tocan la app Flutter:

| | |
|---|---|
| `extraer.py` | PDF → `catalogo.json` + `revision.csv` + recortes + hoja de contactos |
| `cargar.py` | Emite un SQL autocontenido e idempotente; se pega en el SQL Editor |
| `subir_fotos.py` | Sube a Storage los recortes aprobados, en WebP |
| `README.md` | **El procedimiento completo para el catálogo siguiente** |
| `secciones.json` | Rangos de página → categoría. Se revisa con cada PDF |
| `catalogos/2026-04.json` | El catálogo congelado, para diffear precios |

**La clave de actualización es `producto_variantes.sku`**, con el código de Arbell crudo
(`3154`, `C905`, `AC3027`, `VO70`). Es lo único estable entre catálogos: los nombres cambian
de redacción y los precios cambian por definición. Se agregó el índice único
`variantes_tenant_sku_idx` sobre `(tenant_id, sku)` — sin él cada corrida duplicaría todo.

**Cargar no pisa lo que ella escribió.** El upsert actualiza **solo el precio**; `nombre` y
`categoria` quedan como estén, porque si Candela corrigió un nombre a mano el catálogo
siguiente no puede deshacérselo (`--actualizar-nombres` lo fuerza). Y **nunca borra**: un
código que desaparece se despublica y sale en el informe.

Verificado contra la base: idempotencia (correr dos veces da 0 altas, 0 variantes, 0 cambios),
la ruta de actualización de precios (9900 → 10900 sin tocar el nombre), y que con `role anon`
la vitrina ve **0** productos Arbell mientras estén en borrador.

**Dos cosas que el parser no puede resolver solo.** El catálogo es una pieza editorial, no una
lista: 90 de 274 productos salen con el precio en el mismo bloque que el código; el resto toma
el precio de la página y **queda marcado para revisar** en `revision.csv`. Y los recortes de
foto aciertan en las páginas de fondo claro (la 40, la 6) y fallan en las de panel oscuro a
sangre (la 30) — por eso el script propone el candidato y la hoja de contactos decide.

**⚠️ Todo entró con stock 0.** Cualquier producto Arbell que se publique con stock 0 se va a
leer **«Agotado»** en la vitrina (`tienda.html:582`). El orden es: cargar la cantidad de lo
que ella pidió, y recién ahí publicar. Si alguna vez se quiere publicar el catálogo entero
como «por pedido», hay que hacer que `rubro === 'arbell'` no muestre estado de stock — la
vitrina ya declara `sub: 'Por pedido'` para ese rubro, pero el estado todavía no lo respeta.

**Próximo:** que Candela revise `revision.csv`, apruebe fotos y publique lo que tenga stock.
Sigue pendiente lo de antes: fases 3 y 4 del plan de la tienda.

### 2026-09-01 — El sync roto (1299), las fotos, y el codegen de Drift caído

**El sync fallaba en cada ciclo y la causa no era el catálogo.** El detalle en pantalla decía
`NOT NULL constraint failed: appointment_services.id`. Es deriva de esquema entre el código y
la base del teléfono: en `c5a2077` la tabla nació con el mixin `_Sincronizable` (`id` y
`tenant_id` NOT NULL) y en `e9a5e1f` se le sacó el mixin **sin subir `schemaVersion`**. Drift
no recrea una tabla si la versión no cambia, así que todo teléfono que ya la tenía se quedó con
la vieja, y el insert de hoy —que manda tres columnas— dejaba `id` en NULL.

Reventaba fuerte porque `_traerServiciosDeTurnos` era **el único pull sin try/catch por fila**.
La excepción subía, `traer()` la relanzaba, y el ciclo nunca reportaba éxito: barra roja fija y
"Última vez: Todavía no", aunque las demás tablas sí bajaran.

**Arreglos** (`schemaVersion` 3 → 4):

| Dónde | Qué |
|---|---|
| `database.dart` | v4 **recrea** `appointment_services` (`deleteTable` + `createTable` + su índice). Recrear y no parchear `id`: la tabla vieja también tiene `tenant_id` NOT NULL |
| `sync_engine.dart` | `_traerServiciosDeTurnos` aísla la fila, como ya hacía `_traerTabla` |
| `sync_engine.dart` | `_aplicar` **descarta las columnas que la tabla local no conoce** |

Lo último tapa un agujero que venía de fábrica: `proveedores.tenant_proveedor_id` y
`professionals.activo` existen en Postgres y no en Drift, así que **esas dos tablas no
sincronizaban ni una fila** desde que existen, en silencio. Ahora la fila entra con lo que la
app sí entiende, y el backend puede agregar columnas sin romper APKs viejos.

**Las fotos eran un problema aparte.** Las policies de Storage usaban `administra()`
(owner|admin) mientras las de `productos`/`producto_fotos` usaban `opera()`
(owner|admin|**encargado**). `cardixteam@gmail.com` es `encargado`: podía crear y publicar el
producto pero **no subir el archivo**. Migración `storage_fotos_permite_encargado` aplicada;
verificado que `opera()` pasó de `false` a `true` para ese usuario.

Y no se arreglaba solo: `subirFoto` se comía el rechazo con un `debugPrint`, y
`fotosPendientes()` **no lo llamaba nadie** — una foto que fallaba una vez no se reintentaba
nunca. Ahora `subirFoto` devuelve el motivo (distingue RLS de falta de señal), el formulario lo
dice en un SnackBar en vez de cerrar como si nada, y hay un botón **«Reintentar»** cuando
quedan fotos pendientes.

**⚠️ El codegen de Drift está caído en este entorno.** `dart run build_runner build` corre sin
error, escribe 185 artefactos de análisis, **no emite el `.drift.g.part`** y de paso **borra
`lib/data/local/database.g.dart`** (build_runner lo considera output suyo y lo limpia por
obsoleto). `drift_dev` 2.34.5 ya es la última y `pubspec.lock` no cambió, así que apunta a
`build` 4.x / `source_gen` 4.x o al analyzer del SDK.

**Si vas a correr build_runner: hacé `git checkout` de `database.g.dart` después.** Este cambio
se hizo *sin* codegen a propósito — por eso `professionals.activo` no se agregó como columna:
el filtro de `_aplicar` resuelve el pull sin tocar el esquema. Arreglar el generador es su
propia tarea.

**Fuera de alcance, anotado:** `appointments.hora` es nullable en Postgres y NOT NULL en Drift.
Hoy no explota (los 96 turnos tienen hora), pero el primer turno sin hora rompe el pull de la
agenda con el mismo 1299. Son 27 usos de `.hora`; merece su propio cambio.

`flutter analyze` limpio, **294 tests pasando**.

**Próximo:** publicar el APK con la v4. Mientras tanto, el teléfono de Candela se desbloquea
borrando los datos de la app (el outbox está vacío, así que no se pierde nada) y volviendo a
cargar las fotos.
