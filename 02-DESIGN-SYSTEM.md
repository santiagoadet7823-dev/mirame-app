# 02 · Design system — del CSS al Dart

> **Fuente de verdad de la estética.** Todos los valores de este archivo están extraídos
> literalmente de `../index.html` (líneas 20–1258). **No se aproximan, no se "mejoran", no se
> redondean.** Si un valor no está acá, se lee del CSS original antes de inventarlo.

Destino: `lib/core/theme/tokens.dart` · `app_theme.dart` · `shadows.dart` · `motion.dart`

---

## 1. Paleta

### 1.1 Fondos y superficies

| Token | Hex |
|---|---|
| `bg` | `#faf8f5` |
| `bg2` | `#f4f1ec` |
| `bg3` | `#ede9e2` |
| `surface` | `#ffffff` |
| `surface2` | `#fdfcfb` |

### 1.2 Lavender (marca)

| Token | Hex | | Token | Hex |
|---|---|---|---|---|
| `lav50` | `#f5f3ff` | | `lav500` | `#8b77ec` |
| `lav100` | `#ede9fd` | | `lav600` | `#7459d9` |
| `lav200` | `#ddd6fb` | | `lav700` | `#5f45be` |
| `lav300` | `#c4b8f8` | | `lav800` | `#4e389a` |
| `lav400` | `#a898f3` | | `lav900` | `#3d2c7a` |

Alias: `brand = lav500` · `brandDark = lav700` · `brandLight = lav100` · `brandBg = lav50`

### 1.3 Nude y rose

| Token | Hex |
|---|---|
| `nude100` | `#fdf0ec` |
| `nude200` | `#f8ddd4` |
| `nude300` | `#f0c4b8` |
| `nude400` | `#e4a898` |
| `nude500` | `#d4897a` |
| `roseSoft` | `#f9e8e8` |
| `roseMid` | `#e8b4b4` |

### 1.4 Texto y bordes

| Token | Valor |
|---|---|
| `tPrimary` | `#1a1612` |
| `tSecondary` | `#5c5248` |
| `tMuted` | `#9c9088` |
| `tLight` | `#c4bdb5` |
| `tWhite` | `#ffffff` |
| `border` | `rgba(0,0,0,0.07)` → `Color(0x12000000)` |
| `borderMd` | `rgba(0,0,0,0.11)` → `Color(0x1C000000)` |
| `borderLav` | `rgba(139,119,236,0.18)` → `Color(0x2E8B77EC)` |

### 1.5 Semánticos (hardcodeados en el CSS, no eran tokens)

| Uso | Fondo | Borde | Texto |
|---|---|---|---|
| success / done / WhatsApp | `#f0fdf4` | `#bbf7d0` | `#166534` |
| warning / pending / stock bajo | `#fffbeb` | `#fde68a` | `#92400e` |
| danger / cancelled / sin stock | `#fff1f2` | `#fecdd3` | `#9f1239` |
| danger (estado activo) | `#ffe4e6` | — | — |
| confirmed | `lav50` | `lav200` | `lav700` |
| sky (quick action de stats) | `#f0f9ff` | `#bae6fd` | — |

Otros literales: ingresos `#1a7a4a` · egresos `#a83232` · barra stock ok `#34d399` / low `#f59e0b`
/ out `#f87171` · dot de backup `#34d399` · WhatsApp `#25D366` · chip de servicio en el modal de
turno `#fdf4f9`.

Logo de Google (4 paths): `#4285F4` `#34A853` `#FBBC05` `#EA4335`.

### 1.6 Series de datos

```dart
const svcColors = [
  Color(0xFFA898F3), Color(0xFFD4896E), Color(0xFF7BB8A4), Color(0xFFD4A0C8),
  Color(0xFF8FB4E0), Color(0xFFC8A87A), Color(0xFFA0C878), Color(0xFFE0A0A0),
];
const expColors = [
  Color(0xFFE11D48), Color(0xFF9F1239), Color(0xFFC026D3), Color(0xFF7C3AED),
  Color(0xFF2563EB), Color(0xFF0891B2), Color(0xFF059669),
];
```

### 1.7 Gradientes de avatar (`av-a` … `av-f`)

Todos `linear-gradient(135deg, …)` → `LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight)`.

| Clase | Colores |
|---|---|
| `av-a` | `#a898f3` → `#8b77ec` |
| `av-b` | `#d4896e` → `#e4a898` |
| `av-c` | `#7bb8a4` → `#5da090` |
| `av-d` | `#d4a0c8` → `#c084b4` |
| `av-e` | `#8fb4e0` → `#6594c8` |
| `av-f` | `#c8a87a` → `#b8906a` |

**La asignación es determinista** y hay que replicarla exacta, o cada clienta cambia de color:

```dart
/// Puerto literal de `avc(name)` del index.html.
int avatarIndex(String name) {
  var h = 0;
  for (final c in name.codeUnits) {
    h = (h * 31 + c) % 6;
  }
  return h;
}
```

> Nota: el original acumula el módulo en cada iteración (no al final). Reproducir ese detalle
> exactamente, o los colores no coinciden con los que la dueña ya conoce.

### 1.8 Otros gradientes

| Elemento | Gradiente |
|---|---|
| `balance-card` | `linear-gradient(140deg, lav50 0%, nude100 100%)` |
| `profile-hero` | `linear-gradient(145deg, lav50, nude100)` |
| `kpi-hero` | `linear-gradient(135deg, lav50 0%, nude100 100%)` |
| `kpi-hero::before` | `radial-gradient(circle, rgba(139,119,236,.10) 0%, transparent 70%)`, 130×130, `top:-40 right:-40` |
| `gdrive-card` | `linear-gradient(135deg, lav50 0%, #fff 100%)` |
| `auth-emblem` | `linear-gradient(150deg, lav100 0%, nude100 100%)` |
| `auth-screen::before` | `radial-gradient(circle, rgba(139,119,236,.16) 0%, transparent 70%)`, 340 px, `top:-130 left:-120`, `blur(8px)` |
| `auth-screen::after` | `radial-gradient(circle, rgba(212,137,122,.15) 0%, transparent 70%)`, 380 px, `bottom:-150 right:-130` |
| `empty-ic` | `linear-gradient(145deg, lav50, nude100)` |
| barra de margen (stats) | `linear-gradient(90deg, lav400, lav600)` |
| sidebar desktop | `linear-gradient(180deg, surface, bg2)` |

---

## 2. Tipografía

Dos familias. **Se empaquetan como archivos locales en `assets/fonts/`** — nunca `google_fonts`
por CDN, porque la app debe abrir sin red.

- **Cormorant Garamond** — pesos 400, 500, 600 + itálicas 400, 500. Uso: display y números grandes.
- **Inter** — pesos 300, 400, 500, 600, 700. Uso: toda la UI. Tamaño base **14 px**.

### 2.1 Escala de display (Cormorant Garamond)

| Uso | px | peso | tracking |
|---|---|---|---|
| `bal-amount` (balance del mes) | 46 | 600 | −2 |
| `cierre` neto | 48 | 500 | −2 |
| `auth-mono` (monograma) | 46 | 600 | — |
| `kpi-hero-val` | 42 | 600 | −1 |
| `auth-name` | 40 | 600 | — |
| `splash-name`, `kpi-v`, `stat-v` | 28 | 500 / 600 | −0.5 (kpi) |
| `hdr-title` (desktop), `auth-title` | 26 | 600 | — |
| `dash-greet` | 24 | 500 | — |
| `side-mono` | 24 | 600 | — |
| `cf-v` | 22 | 600 | −0.3 |
| `cli-detail` nombre, `prf-name` | 22 | 500 / 600 | — |
| `m-title` / `modal-ttl`, `det-v`, `kpi-mini-v`, `side-name` | 20 | 600 | — |
| `hdr-name` | 18 | 600 | — |
| `cal-month-lbl`, `svc-prc` | 17 | 600 | — |
| notificación (título) | 16 | 600 | — |

### 2.2 Inter

Tamaños en uso: 8, 9, 9.5, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 24, 34, 40, 50 px.
Peso 700 en: `t-hm`, `a-av`, `cli-av`, `qty-n`, `tx-amt`, `nav-badge`, `vip-tag`, `rank-n`,
`au-badge`, `legend-val`.

### 2.3 Letter-spacing de labels en mayúscula

| Clase | tracking |
|---|---|
| `sec-label` | 1.2 |
| `fl` (label de campo) | 1.0 |
| `kpi-l`, `stat-l`, `cf-l`, `det-l` | 0.8 |
| `bal-lbl`, `hdr-tagline` | 1.5 |
| `splash-sub`, `auth-tag` | 2.5 |
| `side-tag` | 1.8 |

### 2.4 Line-height

`1` en los valores de display · `1.5` en `auth-foot` y el textarea de mensajes ·
`1.6` en `empty-d`, `auth-sub` y las notas de clienta.

### 2.5 Cifras tabulares

Todos los valores monetarios y numéricos grandes usan `font-variant-numeric: tabular-nums`.
En Dart: `fontFeatures: [FontFeature.tabularFigures()]`.
Aplica a: `kpi-hero-val`, `bal-amount`, `cf-v`, `stat-v`, `det-v`, `a-price`, `svc-prc`, `kpi-v`,
`kpi-mini-v`, `tx-amt`, `qty-n`.

---

## 3. Radios

| Token | px | Dart |
|---|---|---|
| `rSm` | 10 | `BorderRadius.circular(10)` |
| `rMd` | 14 | |
| `rLg` | 20 | |
| `rXl` | 26 | |
| `r2x` | 36 | |
| `rFu` | 999 | `StadiumBorder()` |

---

## 4. Sombras

### 4.1 Tokenizadas

| Token | CSS | Dart |
|---|---|---|
| `shXs` | `0 1px 3px rgba(0,0,0,.06)` | `BoxShadow(color: Color(0x0F000000), offset: Offset(0,1), blurRadius: 3)` |
| `shSm` | `0 2px 8px rgba(0,0,0,.07)` | `offset (0,2)`, `blur 8`, `0x12000000` |
| `shMd` | `0 4px 16px rgba(0,0,0,.08)` | `offset (0,4)`, `blur 16`, `0x14000000` |
| `shLg` | `0 8px 28px rgba(0,0,0,.09)` | `offset (0,8)`, `blur 28`, `0x17000000` |
| `shBrand` | `0 4px 14px rgba(139,119,236,.22)` | `offset (0,4)`, `blur 14`, `0x388B77EC` |

> Recordatorio: CSS `blur-radius` y Flutter `blurRadius` **no son la misma unidad**. CSS usa una
> desviación estándar de `blur/2`. Si al comparar lado a lado la sombra se ve más dura en Flutter,
> el ajuste correcto es `blurRadius: cssBlur` con `spreadRadius: 0` y verificar visualmente, no
> cambiar el color.

### 4.2 Hardcodeadas (también hay que portarlas)

| Elemento | Sombra |
|---|---|
| `modal-sh` (móvil) | `0 -8px 40px rgba(0,0,0,.12)` |
| `modal-sh` (desktop) | `0 24px 60px rgba(10,8,6,.28)` |
| `toggle::after` (knob) | `0 1px 4px rgba(0,0,0,.2)` |
| `auth-emblem` | `shLg` + `0 12px 30px rgba(139,119,236,.16)` + `inset 0 1px 2px rgba(255,255,255,.9)` |
| `auth-wa` | `0 6px 16px rgba(37,211,102,.32)`; activo `0 3px 10px rgba(37,211,102,.26)` |
| `empty-ic` | `inset 0 1px 3px rgba(255,255,255,.7)` |
| `pill.on` | `0 1px 6px rgba(139,119,236,.14)` |
| `auth-big` | `filter: drop-shadow(0 6px 14px rgba(0,0,0,.08))` |
| overlay de modal | fondo `rgba(10,8,6,0.5)` |

Las `inset` no existen en `BoxShadow`: se resuelven con un `Container` interno con borde
degradado, o se omiten si al comparar no se notan (decidir mirando, no por regla).

---

## 5. Movimiento

### 5.1 Curvas y duraciones

```dart
const easeStd = Cubic(0.4, 0.0, 0.2, 1.0);   // --ease
const easeOut = Cubic(0.0, 0.0, 0.2, 1.0);   // --ease-out

const t1 = Duration(milliseconds: 120);   // --t1: 0.12s
const t2 = Duration(milliseconds: 220);   // --t2: 0.22s
const t3 = Duration(milliseconds: 350);   // --t3: 0.35s
```

`Curves.easeInOut` **no** equivale a `--ease`. Usar los `Cubic` exactos.

### 5.2 Las 7 animaciones

| Nombre | Definición | Dónde |
|---|---|---|
| `splashIn` | `opacity 0→1`, `translateY 10→0` | splash (600 ms, `easeOut`); nombre delay 150 ms, subtítulo 250 ms |
| `fadeUp` | `opacity 0→1`, `translateY −8→0` | panel de notificaciones (200 ms, `easeOut`) |
| `gdPulse` | `opacity 1 → .3 → 1` | dot de sync de Drive (1 s, infinito) |
| `authFloat` | `translateY 0 → −6 → 0` | emblema de login (5.5 s, `easeStd`, infinito) |
| `vRise` | `opacity 0→1`, `translateY 12→0` | entrada de vista (420 ms, `easeOut`) |
| `fabPop` | `opacity 0→1`, `scale .6→1` | FAB (340 ms, `easeOut`, delay 200 ms) |
| `itemIn` | `opacity 0→1`, `translateY 6→0` | ítems de lista (400 ms, `easeOut`) |

### 5.3 Stagger

**Entrada de vista** — los hijos directos de la vista activa entran con `vRise` y estos delays:

| hijo | delay |
|---|---|
| 1º | 30 ms |
| 2º | 70 ms |
| 3º | 110 ms |
| 4º | 150 ms |
| 5º | 190 ms |
| 6º en adelante | 220 ms |

**Listas** — `agenda-list`, `clients-list`, `tx-list`, `stock-list`, `dash-appts` usan `itemIn`
con el mismo escalonado.

Implementación: un widget `StaggeredEntrance` que envuelve una lista de hijos y les aplica el
delay por índice. Un solo lugar, no repetido por pantalla.

### 5.4 Transiciones de barras (importante para que los gráficos no aparezcan de golpe)

| Elemento | Duración |
|---|---|
| `stk-bar` (ancho) | 500 ms |
| `bar-el` (alto) | 600 ms |
| `rank-bar-f` (ancho) | 700 ms |
| barra de margen y de gasto por categoría | 800 ms |
| `proj-bar` | 1000 ms |

### 5.5 Modales

Sheet: `transform` 320 ms con `easeOut`. Overlay: `opacity` en `t2` (220 ms).

### 5.6 Reduced motion

El CSS anula todo con `prefers-reduced-motion: reduce`. En Flutter el equivalente es
`MediaQuery.of(context).disableAnimations`. Toda animación del proyecto debe consultarlo y
saltar a su estado final. Se centraliza en `motion.dart`.

---

## 6. Geometría y espaciado

| Elemento | Valores |
|---|---|
| `.view` padding | `16 16 96` (móvil) · lateral 18 en ≥600 px · `30 32 40` en desktop |
| `#hdr` padding | `12 18 10` · desktop `16 32` |
| `#nav` padding | `0 8 (8 + safeBottom)`; ítem `10 4 6`, gap 3 |
| `.nav-ic` | 32×32, radio 10 (desktop 34×34); SVG 18×18, stroke 1.8 |
| `.hdr-btn` | 36×36 círculo; SVG 17×17, stroke 1.8 |
| `.hdr-logo` | 40×40 círculo, borde `1.5px borderMd` |
| FAB | 54×54 círculo, `bottom: 80 + safeBottom`, `right: 18`, fuente 24. En ≥600 px `right: 50% − 215 + 18`. En desktop `bottom: 34, right: 34` |
| Avatares | `a-av` 42 · `cli-av` 46 · `au-av` 40 · `prf-av-wrap` 86 · splash 100 · `auth-emblem` 96 · detalle de clienta 72 |
| `.t-pill` | min-width 46, padding `7 9`, radio `rSm` |
| `.fi` (input) | padding `13 14`, radio `rMd`, fondo `bg2`; foco: borde `lav300`, fondo `lav50`; textarea min-height 76 |
| Botones | primary padding 15 · secondary 14 · danger y WhatsApp 13 · `btn-row` grid `1fr 1fr` gap 10 |
| `.chip` | `8 15`, radio `rFu` |
| `.pill` | `7 15`, radio `rFu` |
| `.toggle` | 44×25, radio 13; knob 19×19; recorrido `translateX(19)` |
| `.modal-sh` | `max-width 560`, `max-height 91vh` (desktop 88vh), radio `rXl` arriba; handle 34×3 radio 2 |
| Calendario | 7 columnas gap 2; día `aspect-ratio 1` circular; punto de "tiene turnos" 4×4 abajo 4, opacidad .6 |
| Timeline | fila min-height 52; línea vertical en `left: 38` de 1 px color `bg3`; `tl-time` ancho 38 alineado a la derecha; evento con borde izquierdo `3px solid brand` |
| Barras (stats) | contenedor alto 90, gap 6; barra radio `5 5 0 0`, alto mínimo 3, color `lav300` |
| Donut | SVG 110×110, centro (55,55), radio 38, agujero radio 20 relleno `bg`, opacidad 0.85 por porción |

### 6.1 Safe areas

`--safe-top` y `--safe-bottom` vienen de `env(safe-area-inset-*)`. En Flutter: `SafeArea` y
`MediaQuery.viewPadding`. El bottom nav y el FAB dependen de esto — si se ignora, quedan tapados
por la barra de gestos.

---

## 7. Layout responsive

Tres modos, ya definidos en el CSS:

| Ancho | Comportamiento |
|---|---|
| `< 600 px` | móvil puro, bottom nav |
| `>= 600 px` | contenido con `max-width: 430px` centrado; FAB reposicionado a `50% − 215 + 18` |
| `>= 900 px` (modo desktop) | grid `248px 1fr`, áreas `"nav hdr" / "nav content"`; sidebar vertical con gradiente; header con título; contenido `max-width: 1040px` centrado; `qa-grid` y `stat-grid` a 4 columnas; **modales como diálogos centrados**, no sheets |

Bajo 900 px el botón de modo desktop se oculta. El modo se persiste en `localStorage['uiMode']`
(en Flutter: `SharedPreferences`), con default `desktop` si el ancho es ≥ 1024.

Implementación: `LayoutBuilder` + un `AppShell` que conmuta `BottomNavigationBar` ↔ `NavigationRail`,
y un helper `showAppSheet()` que decide entre `showModalBottomSheet` y `showDialog` según el ancho.

---

## 8. Navegación

**El bottom nav tiene 5 ítems, no 7.** Stats se abre desde la quick action "Estadísticas" del
dashboard, y Ajustes desde el engranaje del header. Respetar esto: son 7 vistas, 5 pestañas.

| # | Vista | Label | Icono (Feather, `viewBox 0 0 24 24`, `fill: none`, `stroke-width: 1.8`) |
|---|---|---|---|
| 1 | dashboard | Inicio | casa: `M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z` + `polyline 9 22 9 12 15 12 15 22` |
| 2 | agenda | Agenda | calendario: `rect x=3 y=4 w=18 h=18 rx=2` + dos líneas verticales + `line 3,10 → 21,10`. Lleva badge |
| 3 | crm | Clientas | usuarios: `M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2` + `circle 9,7 r4` + `M23 21v-2a4 4 0 0 0-3-3.87` + `M16 3.13a4 4 0 0 1 0 7.75` |
| 4 | caja | Caja | símbolo de peso: `line 12,1 → 12,23` + `M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6` |
| 5 | stock | Stock | caja 3D: `M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z` |

**Estado activo:** fondo del icono `brandBg`, stroke `brand`, label `brand` peso 600, y una barra
superior de 22×3 px con radio `0 0 3 3` que anima `scaleX 0 → 1` en `t2`.
**Al presionar:** el icono escala a `0.9`.
**Badge:** círculo 16×16 color `brand`, texto 9 px peso 700 blanco, posición `top: 8, right: 50% − 22`.

Cada cambio de pestaña dispara `HapticFeedback` (el original hace `navigator.vibrate(6)`).

---

## 9. Iconografía

### 9.1 Hoy

- **~12 SVG inline** estilo Feather/Lucide: los 5 del nav, engranaje, campana, monitor, teléfono,
  lupa (×2), candado, logo de Google (4 paths de color), logo de WhatsApp (`fill: currentColor`),
  avatar genérico de Drive (`fill: #9c9088`).
- **~60 emojis** para todo lo demás: quick actions, empty states, categorías de stock y de caja,
  chips de estado, toasts, plantillas de mensajes.
- **Logo** en JPEG base64 (splash 100 px, header 40 px, perfil 86 px).

### 9.2 En Flutter

- Los SVG se guardan en `assets/icons/` y se pintan con `flutter_svg`. Los paths ya están arriba.
- Los emojis **se mantienen por ahora**, pero empaquetando **Noto Color Emoji** en `assets/fonts/`:
  sin eso, cada fabricante de Android los dibuja distinto y la app se ve inconsistente.
- **Mejor a mediano plazo:** reemplazarlos por un set de iconos de línea propio, coherente con los
  Feather (`stroke-width 1.8`). Está pedido en `11-BRIEF-DISENADOR.md` punto 2.
- El donut, las barras y el gráfico de rank se dibujan con `CustomPainter`. Nada de librerías de
  charts: el original los hace con SVG y CSS a mano, y pesan cero.

---

## 10. Skills de diseño a consultar

Estas skills están instaladas en la máquina y aplican a las fases 4 y 5:

| Skill | Para qué, concretamente |
|---|---|
| `ui-ux-pro-max` | Tiene stack **Flutter**: patrones de componentes, presets de motion, entradas de iconografía. Útil al construir `shared/widgets/`. |
| `apple-design` | Calidad de gestos y sheets: springs, interrupción de animaciones, momentum, materiales. El bottom sheet y el swipe del calendario se benefician. |
| `emil-design-eng` | Los detalles invisibles: cuándo animar y cuándo no, estados de foco, jerarquía. Útil como criterio de revisión. |
| `find-animation-opportunities` | Correr **después** de tener la UI montada, para detectar dónde falta movimiento. No antes. |
| `improve-animations` | Auditoría de motion cuando ya haya varias pantallas. |

Regla: estas skills **informan el cómo, no el qué**. Ningún valor visual del original se cambia
porque una skill sugiera otra cosa. La fidelidad manda.

---

## 11. Verificación de fidelidad

No se aprueba "a ojo". El procedimiento es:

1. Abrir `../index.html` en el navegador con el ancho del dispositivo de prueba.
2. Abrir la pantalla equivalente en Flutter al mismo ancho.
3. Comparar lado a lado: colores con cuentagotas, tamaños con la regla del inspector.
4. Verificar los valores contra las tablas de este documento, no contra la impresión visual.
5. Revisar los tres breakpoints (móvil, 600, 900) por cada pantalla.
6. Revisar con reduced motion activado.

Cualquier desvío se documenta acá con el motivo, o se corrige. No se deja sin registrar.
