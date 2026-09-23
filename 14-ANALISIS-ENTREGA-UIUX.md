# Entrega del diseñador — análisis, qué cambia y qué falta

**Fecha:** 22 de septiembre de 2026 · **Entrega analizada:** `Mobile app UIUX design/entrega-uiux/`
**Insumo del diseñador:** `13-BRIEF-UI-UX.md` · **Estado del código:** commit `614cc13`, APK 1.17.3

Este documento es para vos, no para el diseñador. Dice qué entregó, qué de eso **ya está
construido**, qué cambia de verdad, qué necesita datos que hoy no existen, y qué comportamientos
faltó definir (lo que me pediste que proponga: scroll, zonas fijas, zonas que cambian al
scrollear).

---

## 1. Qué entregó

Ocho artboards HTML, más un `LEEME.md` y el bundle `Mirame-entregables-completo.html` (el que
conviene abrir para mirar todo junto).

| Archivo | Qué es | Medida | Plataforma |
|---|---|---|---|
| `Mirame - UI UX entregables` | Portada: índice, tokens nuevos, decisiones tomadas distinto al brief | — | — |
| `UIUX - Componentes` | Librería: 8 bloques con medidas para construir en Flutter | — | las tres |
| `UIUX - Celular Inicio y Agenda` | Inicio, Agenda semana, Agenda mes + día vacío | 390×844 | APK celular |
| `UIUX - Celular Ficha y formularios` | Ficha + 4 tabs, panel lateral, Nuevo turno, estados de campo | 390×844 y panel 400 | APK + PWA |
| `UIUX - Celular Tienda y Equipo` | Tienda, sheet de filtros, Equipo, variantes de profesional | 390×844 | APK celular |
| `UIUX - Escritorio Inicio` | Inicio de escritorio, gráfico sin datos, KPI en 4 variantes | 1280×800 | PWA |
| `UIUX - Tablet horizontal` | Inicio, Agenda, Clientas, Tienda + diálogo, y las reglas de adaptación | 1280×800 | **APK tablet** |
| `UIUX - Widget Android` | 4×4 con y sin turnos, 4×2 en 3 estados, preview, alternativa de fuente | 4×4 y 4×2 | solo APK |

**Lo mejor de la entrega:** está pensada para construir, no para mirar. Cada bloque lleva la
medida en píxeles, los cuatro estados de cada componente, y notas del tipo "el punto de 5 px vive
siempre en la misma línea base para que la tira no salte". La vista de tablet, además, no es una
copia del escritorio: distingue **dedo** (toques de 44, sin hover, sin atajos de teclado) de
**puntero** (hover, atajo `/`, tablas densas), que es exactamente la diferencia que importa.

---

## 2. Qué ya está construido (no hay que rehacerlo)

De la sesión anterior ya está en el código y coincide con lo que pide la entrega:

| Lo que pide la entrega | Ya existe en |
|---|---|
| Sheet en celular ↔ diálogo centrado de 560 en pantalla grande | `showAppSheet()` — `features/shell/vistas_comunes.dart` |
| Barra de vista con buscador, filtros y acción primaria a la derecha | `BarraVista`, `BotonPrimario` — mismo archivo |
| FAB solo en celular | `fabVista()` — `features/shell/app_shell.dart` |
| Tabla con cabecera ordenable, hover y columnas que se esconden | `TablaMirame` — `shared/widgets/tabla_mirame.dart` |
| Lista + ficha al costado sin taparse, panel de 400 | `MaestroDetalle` / `PanelLateral` — `shared/widgets/panel_lateral.dart` |
| Agenda de escritorio en dos paneles (mes fijo izquierda, día derecha) | `features/agenda/agenda_view.dart` |
| Contenido con tope (1040 lectura / 1360 tabla) y grillas por ancho de celda | `core/layout/layout.dart` |
| Píldoras de estado con fondo + borde + texto por semántica | `Pildora` / `BadgeEstado` — `vistas_comunes.dart` |
| Sidebar que se pliega a riel | `app_shell.dart` |

O sea: **la estructura de escritorio de la entrega ya está**. Lo que falta ahí es casi todo
cosmético (el Inicio) y el eje táctil.

---

## 3. Qué cambia de verdad

Ordenado por cuánto trabajo es, con el archivo que se toca.

### 3.1 Cambios grandes

**Ficha de clienta — de sheet a pantalla completa** (`features/crm/client_detail.dart`)
Hoy: sheet que sube desde abajo (`DraggableScrollableSheet` al 85 %), avatar centrado, tres
números, tarjeta de WhatsApp, observaciones, historial de 5 y "Editar datos" al final.
Entrega: pantalla completa con banda de 200 px en gradiente, avatar de 84 superpuesto, tres
botones flotantes (volver, editar, corazón), píldoras de estado, barra de **5 acciones**
(WhatsApp · Llamar · Turno · Fotos · Compartir) y **4 tabs** (Historial · Notas · Fotos · Pagos),
con CTA fijo "Agendar turno".
Es el cambio más grande de la entrega y el que más gana: hoy la ficha es un cajón, ahí pasa a ser
la pantalla donde vive la relación con la clienta.

**Agenda — tira semanal en vez del mes siempre abierto** (`features/agenda/agenda_view.dart`,
`calendario.dart`)
Hoy: el calendario del mes ocupa media pantalla y abajo la línea de tiempo.
Entrega: tira de 7 días por defecto + toggle **Semana / Mes** que despliega el mes dentro de la
misma cabecera blanca; tarjeta de resumen del día ("Martes 22 · 4 turnos · $53.000") con la pila
de avatares de quiénes trabajan; la línea de tiempo con la hora afuera y un punto de color sobre
el riel. La hora del **próximo turno** va en lavanda y el resto en gris.

**Escritorio Inicio — la KPI hero se parte** (`features/dashboard/dashboard_view.dart`)
Hoy: la misma tarjeta hero del celular, estirada a 1000 px, y la agenda vacía ocupando el ancho.
Entrega: 4 tarjetas KPI (Turnos hoy · Esta semana · Este mes · Pendientes) con la variación en
texto (▲ 12 %), gráfico de área pastel de dos series (servicios / tienda) ocupando 3/5, y la
agenda del día compacta en 2/5 con el próximo turno resaltado. Sidebar de **232** (hoy 248) con
el bloque de usuario al pie y badge de alerta en Insumos.

**Vista de tablet horizontal — no existe hoy** (`core/layout/layout.dart`, `app_shell.dart`)
Ver §5: es lo que pediste y necesita dos cambios de base antes que nada.

### 3.2 Cambios medianos

**Inicio del celular** (`dashboard_view.dart`)
- Las **6 tarjetas con emoji** de acciones rápidas pasan a una **fila de 5 chips-ícono
  circulares** de 56 px (Turno · Clienta · Pago · Venta · Stats), con ícono de línea, no emoji.
- El **carrusel de retoques sube** arriba de las alertas de stock (hoy es la sección 6, la
  última). ✅ Ya lo aprobaste.
- El buscador entra como **chip de 40 px** que se expande al tocarlo (decisión del diseñador: un
  campo de ancho completo empujaba la hero fuera de la primera pantalla).
- ⚠️ **La KPI hero cambia de color.** Hoy es gradiente **claro** (`lav50 → nude100`) con texto
  oscuro. La entrega la pasa a **gradiente brand sólido** (`#8b77ec → #7459d9`) con texto blanco y
  el número en Cormorant 52. Es lindo, pero es el elemento más reconocible de la app y mi brief
  decía "se queda igual". **Es una decisión tuya**, no la doy por aprobada.

**Tienda** (`features/ropa/ropa_view.dart`)
Hoy: dos filas de chips (rubro y estado). Entrega: **una sola fila** con scroll + **botón de
filtros de 44×44** con contador de filtros activos, que abre un **sheet de filtros** (Rubro,
Estado, Proveedor, Orden) con "Limpiar" y un CTA **"Ver 12 artículos"** que cuenta el resultado.
El corazón = publicada en la vitrina ✅ (ya aprobado); la bolsa = vender esa prenda.

**Equipo** (`features/settings/equipo_view.dart`)
Hoy: lista simple. Entrega: 3 KPI arriba, **grilla de 2 columnas** de tarjetas de profesional
(foto 64, rol, píldora de carga del día, botón "Ver agenda"), tarjeta punteada "Invitar", y dos
filas de ajustes (Roles y permisos · Horarios de atención).

### 3.3 Cambios chicos pero que tocan todo

**Una sola tarjeta de turno.** Hoy hay tres versiones distintas (una en Inicio, otra en la línea
de tiempo de Agenda, otra en la tabla). La entrega define **una** con dos tamaños: completa
(68 px, avatar 42, píldora de estado) y compacta (46 px, avatar 28, punto de 7 px), más el estado
cancelado (opacidad 60 %, nombre tachado, avatar sin gradiente). Conviene hacerla primero: la usan
Inicio, Agenda, escritorio y el widget.

**Tokens nuevos** ✅ aprobados: `skyBg #eff6ff`, `sky300 #bfdbfe`, `sky700 #1d4ed8` (la quinta
acción no puede repetir el lavanda del turno), `nude700 #b8654f` (el `#d4897a` actual **no llega a
4,5:1** de contraste sobre nude50 — esto es una corrección de accesibilidad, no un capricho) y
`widgetSurface` (blanco al 82 %).

**Estados de campo** (foco con halo de 3 px, error con borde `#ef4444` y mensaje abajo,
deshabilitado) — hoy los campos solo tienen normal y foco.

---

## 4. Lo que necesita datos que hoy no existen

Esto es lo que no se ve en un mockup y frena la implementación si no se decide antes:

| Lo que pide | ¿Se puede hoy? |
|---|---|
| Tab **Pagos** de la clienta | **Sí.** `Transactions.clientId` ya existe en la base; es solo una consulta nueva. |
| Tab **Fotos** (antes/después por turno) | **No.** No hay tabla de fotos de clienta. Se puede calcar la de productos (`ProductoFotos` con `rutaLocal` y `pendienteDeSubir`) y ya tenemos `image_picker` y compresión, pero es tabla nueva + migración + bucket en Supabase + permisos. **Es un proyecto aparte, no parte del rediseño.** |
| **Etiquetas** en la tab Notas ("Adhesivo sensitive", "Efecto natural") | No. Campo nuevo. |
| **Foto de perfil** del profesional | No. `Professionals` tiene nombre y teléfono nada más. |
| **Horarios de atención** por profesional y día | No. Tabla nueva. |
| **"Ver agenda"** filtrada por profesional | La Agenda no filtra por profesional. Es un filtro nuevo (fácil). |
| Píldora de **carga del día** ("2 turnos hoy") | Sí, se cuenta de los turnos. |
| **Contador de filtros activos** en Tienda | Sí, es estado de la vista. |
| **Widget** | No hay `home_widget` ni `workmanager` en `pubspec.yaml`. Es código Kotlin + puente por `SharedPreferences`. Proyecto aparte. |

**Recomendación:** construir la ficha con **3 tabs** (Historial · Notas · Pagos) y dejar Fotos
visible pero deshabilitada con un "Próximamente", o directamente afuera hasta que decidas si
querés fotos de clientas (implica guardar fotos de personas: hay que pensar consentimiento y
borrado).

---

## 5. La tablet: qué falta antes de poder dibujar nada

Dos cosas de base, y ninguna la podía ver el diseñador:

**1. Hoy la app no gira.** `lib/main.dart:21` fuerza vertical:

```dart
await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
```

Mientras esté esa línea, la tablet se queda en vertical aunque la acuestes. El manifest ya está
bien (declara `configChanges` con `orientation|screenSize`), así que alcanza con sacarla. ✅ Pediste
giro libre en todos los dispositivos.

**2. Hoy "pantalla grande" y "escritorio" son lo mismo.** `core/layout/layout.dart` decide solo por
ancho: `>= 900` es escritorio. Una tablet en horizontal mide 1280 y **hoy caería en el layout de
escritorio**: sidebar de 248, tablas de filas de 52 px, hover y atajo de teclado `/`. Es
exactamente lo que el diseñador dice que no hay que hacer ("Escritorio y tablet no son lo mismo").

Falta un segundo eje: **dedo o puntero**. En Flutter se resuelve con la plataforma
(`!kIsWeb && (Android || iOS)` = dedo), y con eso el mismo ancho de 1280 da dos layouts:

| | PWA en la compu (puntero) | APK en tablet (dedo) |
|---|---|---|
| Navegación | sidebar 232/248 con las 8 | **riel de 92** con 5 + separador + 3 |
| Filas de tabla | 52 px, hover | **64 px, sin hover** |
| Buscador | con atajo `/` | sin atajo |
| Tarjeta de turno | compacta 46 | **completa 76** |
| Chips-ícono | 44 | **58** |

Y al girar la tablet a vertical (menos de 900 px de ancho) vuelve sola al layout de celular con la
barra de abajo — que es lo que ya hace hoy, sin diseño aparte. ✅ Coincide con la entrega.

**Construido en la 1.21.0.** Las cinco filas de la tabla de arriba están: riel de 92, filas de 64
(las decide `TablaMirame`, no cada vista), tarjeta de turno de 76 con avatar de 46 y chips de 58.
Además, adentro de cada vista: Clientas en tarjetas + ficha al lado, Tienda con la columna de
filtros fija y grilla de 4, Agenda con "Quiénes trabajan" y los huecos tocables, Inicio con
retoques y alertas. Lo que NO entró son los filtros de proveedor y orden de la columna de Tienda:
no existen en la app, ni en el sheet del teléfono ni en la base.

**Caja en tablet abre en "cobrar el turno de ahora"** ✅ aprobado y construido en la 1.21.0. La
lista del mes sigue debajo: arriba aparece el turno de hoy más cercano a esta hora, con el monto y
el nombre de la clienta ya cargados. Reemplazar la vista entera era peor — el cierre de caja y los
gastos del día también se hacen desde ahí.

---

## 6. Inconsistencias a resolver con el diseñador

Ocho cosas que no cierran entre el catálogo de componentes y las pantallas. Ninguna es grave, pero
hay que decidirlas antes de construir:

1. **Tarjeta de retoque**: el catálogo la define de 150 px con la píldora "Retoque: 3 días"; el
   Inicio la dibuja de 114 px y solo "3 días". → Propongo 150 y el texto largo: en el carrusel se
   ve un tercio de la tercera tarjeta y eso invita a deslizar.
2. **Píldora de stock en Tienda**: "3 en stock" en el catálogo, "3" pelado en la grilla. → "3" en
   la grilla (la tarjeta ya es angosta) y el texto largo en la ficha del producto.
3. **"Retoque en 6 días"**: nude en el catálogo, lavanda en la ficha. → Nude: es información de
   la clienta, no un estado de turno.
4. **Alto de la banda de la ficha**: la spec dice 200 (120 en panel), los mocks dibujan 150/90
   porque están a escala. → Vale la spec.
5. **Celda del mes en el widget**: el texto dice 44 px, el dibujo tiene 38, y el mínimo que pedía
   el brief era 40. → 44, aunque haya que bajar a 2 turnos en el 4×4.
6. **El catálogo dice "once componentes" y trae 8**: no falta nada, el gráfico está en el archivo
   de escritorio y el widget en el suyo. Solo hay que saberlo.
7. **Tienda no dibuja la barra de abajo**: se llega desde Inicio y el engranaje, como hoy. OK,
   pero conviene que la pantalla tenga "volver" visible.
8. **Escritorio tiene 3 acciones rápidas (Clienta · Pago · Venta) y el celular 5**: es a propósito
   (Turno está en la barra de arriba y Stats en el sidebar), pero hay que escribirlo o alguien lo
   va a "arreglar".

---

## 7. Lo que faltó definir: comportamiento

Los mockups son fotos. Esto es lo que se mueve, y es donde una app se siente cara o barata. Nada
de esto está en la entrega. **Lo marcado ✅ ya está construido** (commits `321f1c9`, `97cef21`,
`11db88f`); lo demás espera a que existan los componentes de la Tanda C.

### 7.1 Zonas que quedan fijas al scrollear

- ✅ **La barra de arriba ya era fija**, pero se confundía con la lista: ahora **gana una sombra
  solo cuando hay contenido scrolleado por encima**. La sombra es lo único que avisa que hay algo
  arriba.
- ✅ **Cabecera de tabla** pegada con la misma sombra. Con 184 clientas, scrolleabas y no sabías
  qué columna era cuál.
- **Ficha de clienta**: la barra de tabs pegada y la banda colapsando a 56 px con el avatar chico
  (`SliverAppBar`). Espera a que la ficha deje de ser un sheet (Tanda C).
- **CTA fijo que se esconde al scrollear hacia abajo y vuelve al subir**, para que no tape la
  última fila. Espera al CTA fijo (Tanda C).
- **Agenda**: cuando exista la tira semanal, la tira y el resumen del día quedan fijos. Hoy el
  calendario ya está fuera del scroll.

### 7.2 Zonas que cambian al scrollear

- ✅ **Sombra de contexto** en header y cabecera de tabla, solo con contenido arriba.
- ✅ **FAB que se encoge** de 54 a 44 px al bajar por la lista, y vuelve al subir.
- ✅ **Degradé de corte** en las filas de filtros: avisa que la fila sigue a la derecha (y a la
  izquierda cuando ya se deslizó).
- ✅ **Franja horaria en curso** marcada en brand en la Agenda: la línea vertical se engrosa y la
  hora va en lavanda.
- El degradé del carrusel de retoques espera al carrusel (Tanda C).

### 7.3 Scroll

- ✅ **La Agenda arranca en el próximo turno**, no a las 00:00. Abrirla a las 17:00 y ver las
  09:00 era empezar mirando lo que ya pasó.
- ✅ **Botón "Hoy"** flotante cuando el día elegido no es hoy (y la tecla `T` en escritorio).
- ✅ **Cierre de lista**: "No hay más turnos este día".
- ✅ En escritorio, mes y lista del día ya son dos scrolls independientes.
- La fila de 5 chips-ícono no scrollea (entran los 5 en 390): queda así por diseño.

### 7.4 Estados

- ✅ **Esqueletos de carga** en Inicio, Agenda, Clientas, Caja, Insumos y Tienda. Mientras la base
  abría, las vistas decían "Sin clientas" / "Sin turnos": era mentira y asustaba.
- ✅ **Vacío por filtro ≠ vacío de verdad**: textos distintos y un botón de salida ("Ver todos",
  "Limpiar búsqueda"). Antes los dos casos decían casi lo mismo y ninguno ofrecía salida.
- ✅ **Fin de lista**.
- **Sin conexión**: la franja ya existe en el shell; falta que el diseñador la dibuje con el
  estilo nuevo.
- **Guardando**: `SheetFormulario` ya muestra el progreso ("Subiendo 2 de 5"); no está en los
  mockups.

### 7.5 Gestos

- ✅ **Deslizar una tarjeta de turno**: derecha = Hecho, izquierda = Cancelar, y otra vez deshace.
  Eran las dos cosas más frecuentes del día y pedían abrir el formulario, elegir en un desplegable
  y guardar.
- ✅ **Tirar para refrescar** en Agenda: fuerza el sync en vez de esperar los 3 minutos del ciclo.
- ✅ **Toque largo sobre una clienta**: WhatsApp, agendar o editar, sin abrir la ficha.
- ✅ **Teclado**: `Esc` cierra la ficha de clienta, `←` `→` corren el día en Agenda, `T` vuelve a
  hoy.
- **Al girar con el panel abierto** se mantiene la clienta elegida y el scroll: queda para la
  Tanda A, porque hoy la app no gira.

### 7.6 Accesibilidad y tamaños

- ✅ **Filas de tabla con alto mínimo en vez de fijo**: con el texto del sistema al 130 % una fila
  de 52 px recortaba el nombre en vez de crecer.
- ✅ Los esqueletos no laten con "reducir movimiento" activado.
- Toques de 48 en celular y 44 en tablet: la parte de tablet va con la Tanda A.
- Contraste: el `nude700` del diseñador corrige un problema real; falta revisar el gris `#9c9088`
  sobre crema en textos de 11 px.

Todo lo nuevo vive en `app_flutter/lib/shared/widgets/comportamiento.dart` y está cubierto por
`test/core/comportamiento_test.dart`.

## 8. Plan sugerido

| Tanda | Qué | Depende de |
|---|---|---|
| **A** | Giro libre + modo táctil (riel 92, escalas de dedo). La tablet empieza a funcionar. | Nada |
| **B** | Componentes compartidos: tarjeta de turno, chip-ícono, tira semanal, banda + tabs, tokens nuevos. | A |
| **C** | Pantallas: Inicio, Agenda, Ficha (3 tabs), Tienda, Equipo, Inicio de escritorio. | B |
| **D** | Comportamiento: zonas fijas, colapso, esqueletos, gestos (§7). | C |
| **E** | Proyectos aparte: widget Android (Kotlin) y fotos de clienta (tabla + storage). | — |

Antes de la B hay que cerrar: **si la KPI hero pasa a brand sólido** (§3.2) y **si la ficha lleva
Fotos** (§4).

---

## 9. Respuesta al diseñador

Para copiar y pegar:

> Aprobado tal como lo proponés: los cinco tokens nuevos (los tres *sky*, `nude700` y
> `widgetSurface`), el carrusel de retoques **antes** de las alertas de stock, el corazón de
> Tienda como **publicada en la vitrina**, y en la tablet del mostrador **Caja abre en el cobro
> del turno en curso**.
>
> Tres cosas para cerrar: (1) la KPI hero del celular pasó de gradiente claro a brand sólido con
> texto blanco — lo estamos decidiendo, si queda en claro avisamos; (2) unificá la tarjeta de
> retoque en 150 px con "Retoque: 3 días", la píldora de stock en "3" en la grilla, "Retoque en N
> días" en nude y la celda del widget en 44 px; (3) falta la capa de comportamiento: qué queda
> fijo al scrollear, qué cambia, esqueletos de carga, vacío-por-filtro vs vacío-real, y los gestos
> de deslizar. Te paso el detalle en el punto 7 de nuestro análisis.
>
> La tab **Fotos** de la clienta no tiene dónde guardarse todavía: arrancamos con Historial,
> Notas y Pagos, y Fotos queda para una segunda etapa.
