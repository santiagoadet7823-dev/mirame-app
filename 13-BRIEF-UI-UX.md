# Brief UI/UX — Mírame, segunda vuelta (APK + PWA + widget)

**Para:** diseñador/a UI/UX · **De:** Santiago (Mírame) · **Fecha:** 22 de septiembre de 2026
**Prototipo interactivo (hoy vs. propuesta):** https://claude.ai/artifact/6uNgRP7uEWK3iGrXwe2arH
*(es privado: pedile acceso a Santiago si el link no abre)*
**App en vivo (PWA):** https://santiagoadet7823-dev.github.io/mirame-app/ · **Design system:** `02-DESIGN-SYSTEM.md`
**Brief anterior (íconos, splash, admin):** `11-BRIEF-DISENADOR.md` — sigue vigente; este lo complementa.

---

## 0. Contexto en 30 segundos

Mírame es la app de gestión de un estudio de pestañas: turnos, clientas, caja, insumos, stats y una
tienda de ropa/productos. La usan la dueña y su equipo, **no las clientas** (las clientas solo ven
la vitrina web `tienda.html`, que ya tiene su propio brief). Corre como **APK Android** en el
celular y como **PWA** en la compu del salón, con la misma base y las mismas funciones.

Hoy funciona completa y el modo escritorio se acaba de hacer (tablas, panel lateral, diálogos).
Lo que queremos ahora es que **se vea y se sienta como una app premium de belleza**, tomando ideas
de tres referencias, **sin cambiar la paleta, el logo ni ninguna función**. El brief anterior decía
"no hay rediseño"; eso cambia acá: **sí hay rediseño de composición y componentes**, no de
identidad.

## 1. Lo que NO se toca

- **Paleta**: los tokens de `02-DESIGN-SYSTEM.md` §1 — fondos crema (`#faf8f5` / `#f4f1ec`),
  lavanda `lav50…lav900` (brand `#8b77ec`), nude/rosa (`#fdf0ec`, `#f0c4b8`, `#d4897a`), textos
  `#1a1612 / #5c5248 / #9c9088`, semánticos success/warning/danger. Si necesitás un tono nuevo
  (p. ej. para el widget pastel), proponelo con nombre y hex y justificalo; no lo uses sin avisar.
- **Tipografías**: Cormorant Garamond para títulos y números grandes, Inter para UI, Parisienne
  solo en el wordmark "Mírame".
- **Logo y wordmark**: el redondo actual (`assets/brand/logo-mirame.jpg`) y "Mírame / LASH STUDIO".
- **Radios** 10/14/20/26/36 + píldora, sombras suaves, motion del design system §5.
- **Las 5 pestañas** del celular: Inicio · Agenda · Clientas · Caja · Insumos (Stats, Ajustes y
  Tienda se llegan desde Inicio y desde el engranaje). En escritorio el sidebar tiene las 8.
- **Todas las funciones**: nada se saca. Si una pantalla propuesta no muestra algo que hoy existe,
  es un olvido nuestro: preguntá.
- **Solo modo claro.** El dark mode sigue siendo opcional y posterior (brief anterior 4.6).

## 2. Referencias: qué tomamos de cada una

Están en la primera fila del prototipo, con su nota.

| Referencia | Tomamos | No tomamos |
|---|---|---|
| **App de barbería/salón** (Behance, booking para clientes) | Fila de **íconos circulares tintados** para acciones; **barra de acciones circulares** en el detalle (Website·Message·Call·Direction·Share → WhatsApp·Llamar·Nuevo turno·Fotos·Compartir); **tabs** con subrayado; filas con chevron; **CTA fijo abajo** con píldora; tarjetas con foto grande y esquina 14; jerarquía título grande + "Ver todo" a la derecha (ya la tenemos). | Buscador de salones, banner de descuento, rating con estrellas (no hay clientas calificando), login con contraseña (entramos con Google). El rojo coral se reemplaza por lavanda/nude. |
| **Booking pastel "Book Your Glow"** (Pinterest) | Es la inspiración directa del **widget**: calendario del mes + lista de horarios del día. También la **grilla de estilistas** con foto → nuestra pantalla Equipo, y las tarjetas de servicio con precio → chips de servicio en el formulario. Suavidad general (bordes claros, sombras muy difusas). | El sidebar rosado en el celular, los testimonios ("Client Love"), el efecto neumórfico fuerte. |
| **Dashboard pastel** (Pinterest, tablet) | El **gráfico de área en pastel** (crema / rosa / durazno superpuestos) para el Inicio de escritorio; aire y título grande. | Nada más: es una imagen de estilo, no de estructura. |

## 3. Pantalla por pantalla

Cada pantalla tiene en el prototipo un marco **HOY** (lo que existe, reconstruido o captura real) y
uno **PROPUESTA**. Lo que sigue es el detalle de cada propuesta y lo que te pedimos.

### 3.1 Inicio (celular)

**Hoy:** saludo, tarjeta KPI con gradiente (turnos de hoy, semana, 3 mini), "Agenda de hoy" con
filas de hora + "Turno" + precio, acciones rápidas en 3 filas de 2 tarjetas con emoji, alertas de
stock y retoques abajo de todo.

**Propuesta:**
1. Saludo con el nombre de quien está logueada y un **buscador global** compacto a la derecha
   (busca clientas, turnos, productos).
2. La KPI hero se queda igual (es lo más reconocible de la app) y suma "próximo a las 10:00" y la
   variación semanal (▲ 12 %) en success.
3. **Acciones rápidas como fila de 5 íconos circulares** (Turno · Clienta · Pago · Venta · Stats),
   56 px, fondo tintado por acción (lav50 / nude100 / successBg / warningBg / skyBg), ícono de
   línea del set del brief anterior, etiqueta de 11 px debajo. Reemplaza las 6 tarjetas con emoji.
4. "Agenda de hoy" con **tarjetas completas**: avatar con gradiente, nombre, servicio, con quién,
   chip de hora, precio y píldora de estado.
5. **Carrusel "Próximos retoques"** (hoy está abajo de todo y nadie llega): tarjetas verticales
   con avatar, nombre y píldora "Retoque: 3 días".
6. Alertas de stock siguen debajo (no entraron en el marco, mismo diseño de hoy).

**Te pedimos:** el frame 390 completo, la fila de íconos en sus 5 variantes de color, la tarjeta
de turno (normal, pendiente, hecho, cancelado) y la tarjeta de retoque.

### 3.2 Agenda (celular)

**Hoy:** calendario del mes completo arriba (ocupa media pantalla), chips de filtro, línea de
tiempo por hora con tarjetas de borde izquierdo, FAB.

**Propuesta:**
1. **Tira semanal** por defecto (7 días, el elegido en brand con número en Cormorant, punto en los
   días con turnos); toggle "Semana / Mes" que despliega el calendario completo actual.
2. **Resumen del día**: "Martes 22 · 4 turnos · $53.000" y los avatares de quiénes trabajan.
3. Línea de tiempo con las **mismas tarjetas de turno del Inicio** (avatar, servicio, profesional).
4. Búsqueda de turno por clienta (lupa).
5. FAB igual.

**Te pedimos:** tira semanal (estados: normal, hoy, elegido, con turnos), el toggle, y el estado
vacío del día ("Sin turnos" — hoy es un emoji de calendario, va con ilustración del brief 4.4).

### 3.3 Ficha de clienta (celular; en escritorio va en el panel lateral)

**Hoy:** sheet desde abajo con avatar centrado, nombre, VIP, tres números, tarjeta de WhatsApp,
observaciones, historial (5) y botón "Editar datos".

**Propuesta:** pantalla completa, inspirada en el detalle de la referencia de barbería.
1. **Banda superior** con gradiente lav50→nude100 (200 px), botones flotantes Volver / Editar /
   Favorita (corazón = VIP), **avatar grande (84) superpuesto** al borde de la banda.
2. Nombre en Cormorant 24 + **píldoras**: VIP, "Clienta desde ago 2026", "Retoque en 6 días".
3. Los tres números como hoy (Turnos · Total · Promedio).
4. **Barra de 5 acciones circulares** (52 px): WhatsApp (success) · Llamar (lav) · Nuevo turno
   (nude) · Fotos (warning) · Compartir (sky). Etiqueta debajo.
5. **Tabs**: Historial · Notas · Fotos · Pagos, subrayado brand de 2 px.
6. Lista del historial (fecha en chip lavanda, servicio · precio, estado).
7. **CTA fijo** "Agendar turno" (píldora brand 48 px, sombra brand) sobre un degradé al fondo,
   respetando safe-area.

**Te pedimos:** el frame, la barra de acciones con sus 5 colores, las 4 tabs con su contenido
(Notas = texto libre editable; Fotos = grilla 3 col de antes/después; Pagos = lista de
movimientos de esa clienta), y la versión **panel lateral de 400 px** para escritorio (misma
ficha sin la banda de 200: banda de 120).

### 3.4 Tienda (celular)

**Hoy:** título "Productos", links Mi tienda/Liquidar/Proveedores, buscador, dos filas de chips,
grilla 2 col con foto vertical, precio y "1 en stock", FAB con menú Vender / Nueva prenda.

**Propuesta:**
1. Título "Tienda" + los tres links como hoy (funcionan, se quedan).
2. **Buscador píldora + botón de filtros** (cuadrado brand con ícono), una sola fila de chips
   (rubro y estado combinados, scroll horizontal).
3. **Tarjetas con foto** de esquina 14, precio en Cormorant 17, píldora de stock (success /
   warning), corazón arriba a la derecha = **publicada en la vitrina** (nude cuando sí), ícono de
   bolsa = vender esta prenda.
4. FAB igual.

**Te pedimos:** tarjeta (con foto, sin foto, agotada, sin publicar), botón de filtros y el sheet
de filtros (rubro, estado, proveedor, orden).

### 3.5 Equipo (Ajustes → Equipo, celular)

**Hoy:** lista simple de miembros con inicial, rol y estado.

**Propuesta** (de la grilla de estilistas de la referencia pastel): tres KPI arriba
(Profesionales · Turnos hoy · $ hoy), **grilla 2 col de tarjetas de profesional**: avatar/foto 64,
nombre, rol, píldora de carga de hoy ("4 turnos hoy" / "Libre hoy"), botón "Ver agenda"; tarjeta
punteada "Invitar". Debajo, "Roles y permisos" como fila con chevron.

**Te pedimos:** tarjeta de profesional (con foto y sin foto, bloqueada), tarjeta "Invitar", y la
foto de perfil en el formulario de miembro.

### 3.6 Formularios (Nuevo turno como ejemplo; aplica a clienta, movimiento, producto)

**Hoy:** sheet con campos apilados, "Guardar" al final del scroll.

**Propuesta:**
1. Cabecera con título Cormorant 22 y cerrar (×).
2. **Servicio en chips** seleccionables (multi), **profesional en avatares** seleccionables (anillo
   lav300 al elegido), fecha y hora en dos campos con ícono, precio y estado en dos columnas,
   notas al final.
3. **CTA fijo** "Guardar turno" al pie con borde superior; "Cancelar" como texto debajo.
4. En escritorio el mismo formulario va en diálogo centrado de 560 px (ya existe).

**Te pedimos:** los campos (normal, foco, error, deshabilitado), chip seleccionado/no, avatar
seleccionado/no, y el pie con CTA en celular y en diálogo.

### 3.7 Escritorio — Inicio (PWA, 1280)

**Hoy:** captura real en el prototipo (sidebar, KPI hero estirada, agenda vacía, acciones rápidas
en 4 columnas).

**Propuesta:**
1. Header con **buscador global** (atajo "/"), botón "Nuevo turno" como acción primaria, campana y
   engranaje.
2. Fila de **4 KPI** (Turnos hoy · Esta semana · Este mes · Pendientes) con la variación en
   texto chico coloreado.
3. **Gráfico de área pastel** "Ingresos por semana" (servicios en lavanda, tienda en nude, rellenos
   translúcidos superpuestos como la referencia de dashboard) — 3/5 del ancho.
4. "Agenda de hoy" como lista compacta a la derecha (2/5).
5. Sidebar con la persona logueada al pie (avatar, nombre, rol).

Las otras vistas de escritorio (Agenda en dos paneles, Clientas/Caja/Insumos con tabla y panel
lateral, Tienda en grilla fluida) están en capturas reales en el prototipo: ahí solo pedimos
que **revises consistencia** con lo nuevo (mismas tarjetas de turno, mismos íconos), no un
rediseño.

**Te pedimos:** el frame 1280 del Inicio, el gráfico (con y sin datos), la tarjeta KPI (4
variantes de color de la variación) y el bloque de usuario del sidebar.

### 3.8 Widget de Android (pantalla de inicio del celular)

Solo Android (el APK). **La PWA no puede tener widgets** — no existe en la web.

Dos tamaños, en **paleta pastel sobre tarjeta blanca al 82 %** con blur del fondo, pensada para
convivir con cualquier fondo de pantalla:

- **4×4 (toda una pantalla)**: cabecera "Septiembre 2026" con flechas; grilla del mes con
  **puntos en los días con turnos** y fondo lav50 en esos días; **día tocado** en brand con número
  blanco; separador; "Martes 22 · 4 turnos · $53.000" + botón "＋" (abre el formulario de turno
  en la app); lista del día con hora · avatar · clienta · servicio · estado (hasta 3 filas, luego
  "+1 turno más · abrir agenda"). Tocar un día cambia la lista **sin abrir la app**.
- **4×2**: "Hoy, martes 22 · 4 turnos" + 3 filas compactas + "＋".

**Restricciones técnicas** (es un AppWidget nativo, RemoteViews/Glance): sin animaciones, sin
scroll interno, sin fuentes propias garantizadas (Cormorant puede no cargar → diseñar la
alternativa con la fuente del sistema), cada celda del mes es un botón (mínimo 40 px), el
contenido se refresca cuando cambia algo en la app o cada 30 min.

**Estados a diseñar:** con turnos, sin turnos ese día, **sin sesión** ("Abrí Mírame para entrar"),
cargando, y el **preview** que muestra el selector de widgets de Android.

**Te pedimos:** los dos tamaños en sus estados, a 1x en 390 de ancho, y los assets exportables
(fondo redondeado 26 como shape/9-patch, íconos del widget).

## 4. Componentes nuevos (resumen para la librería)

| Componente | Dónde se usa | Especificación base |
|---|---|---|
| Chip-ícono circular | Inicio, acciones de ficha, escritorio | 56/52/44 px, fondo tintado (lav50, nude100, successBg, warningBg, skyBg), ícono 20-22 px del set, etiqueta 11 px/500 debajo |
| Barra de acciones | Ficha de clienta, panel lateral, ficha de producto | 5 chips-ícono repartidos, gap 6 |
| Tabs | Ficha, producto, ajustes | Inter 13/500, activo 600 en lav700, subrayado 2 px brand, separador inferior `border` |
| Tarjeta de turno | Inicio, Agenda, widget, escritorio | avatar 42, nombre 14/600 + píldora de estado, línea 12 "servicio · con X", chip de hora lav50 + precio |
| Tira semanal | Agenda | 7 celdas, día elegido fondo brand radio 14, número Cormorant 20 |
| Tarjeta con foto | Tienda, Equipo | radio 14, foto 150 alto, corazón/estado flotante |
| Banda de ficha | Ficha de clienta y de producto | 200 px (120 en panel), gradiente lav50→nude100, avatar superpuesto −36 px |
| CTA fijo | Formularios, ficha | píldora brand 48 px, sombra brand, degradé al fondo, safe-area |
| Píldora | En todas | 10/600, fondo+borde+texto por semántica |
| Gráfico de área pastel | Inicio escritorio, Stats | 2 series, rellenos 70 % → 0, línea 2 px |
| Widget | Android | ver §3.8 |

## 5. Entregables y formatos

1. **Frames Figma** por pantalla de §3 a **390** (celular) y **1280** (escritorio) donde aplique,
   con los estados pedidos. Nombrá los frames como los artboards del prototipo.
2. **Componentes** de §4 como componentes Figma con variantes, usando los tokens del design system
   (podés importar `02-DESIGN-SYSTEM.md` §1 y §2 como estilos).
3. **Íconos** nuevos que aparezcan (bolsa, cámara, lifting, cejas, etc.): mismo set del brief
   anterior, SVG 24 px, trazo 1.8, puntas redondas, un solo color.
4. **Widget**: los dos tamaños, estados, preview y assets exportados (PNG @2x y @3x + SVG).
5. **Tokens nuevos**, si los hay, en una tabla nombre → hex → uso.
6. Un **PDF corto** (opcional) con las decisiones que tomaste distinto de este brief y por qué.

**Orden sugerido:** tarjeta de turno + chip-ícono (afectan todo) → Inicio celular → Ficha →
Agenda → Formulario → Escritorio Inicio → Tienda/Equipo → Widget.

## 6. Lo que recibís

- El prototipo (link arriba), con referencias, HOY, PROPUESTA y notas.
- Capturas reales de escritorio (en el prototipo) y la PWA en vivo para tocar (pedile acceso a
  Santiago).
- `02-DESIGN-SYSTEM.md`, `11-BRIEF-DISENADOR.md`, `12-BRIEF-TIENDA.md`.
- El logo actual y las fuentes (`app_flutter/assets/`).

## 7. Cómo se aprueba

Santiago revisa cada frame contra tres preguntas: ¿respeta paleta/logo/tipografías? ¿están todas
las funciones de hoy? ¿se entiende sin explicación? Lo aprobado se implementa en Flutter en el
orden de §5; el widget va aparte porque es código nativo.
