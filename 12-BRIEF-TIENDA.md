# Brief de diseño — Tienda pública

> Para pasarle al diseñador tal como está.
> Complementa a `11-BRIEF-DISENADOR.md`, que cubre la **app de gestión**. Este cubre la
> **vidriera que ven las clientas**, que es otra pieza y tiene otro trabajo que hacer.

---

## 1. Contexto en 30 segundos

Mírame Lash Studio es un estudio de extensión de pestañas en Salta. Además de los
servicios, la dueña vende **ropa a consignación**, productos de **Arbell** e **insumos de
estética**. Alguien le entrega la mercadería, ella la vende y le devuelve una parte.

Para venderla armamos una **tienda web**: una página que ella manda por WhatsApp a sus
clientas para que vean lo que hay, elijan talle y color, y reserven. La reserva les guarda
la prenda 48 horas y le avisa a ella.

La página existe y funciona. **Nunca la diseñó nadie** — se construyó resolviendo el
problema técnico (que abra rápido, que no filtre datos del negocio) y la parte que ve la
clienta quedó armada con lo mínimo. Eso es lo que venimos a resolver.

### Quién la usa

Una mujer que recibe un link por WhatsApp. Lo abre con datos móviles, en un Android de
gama media, casi siempre de noche y con una mano. **No conoce el negocio** y no va a
instalar nada. Muchas veces es la primera vez que ve una foto de esa ropa.

**El éxito es uno solo: que reserve, o que escriba.** Todo lo demás es decoración.

### Cuánto tráfico entra por dónde

**El 100 % entra por un link de WhatsApp.** No hay Google, no hay Instagram con link en
bio, no hay tráfico directo. Esto tiene dos consecuencias que atraviesan todo el brief:

1. **La previsualización del link es la primera impresión**, y hoy es un rectángulo gris
   que dice "Tienda". Se ve antes que la página. Es lo primero de la lista de entregables.
2. **El diseño de escritorio no importa.** Se entrega, pero como cortesía.

---

## 2. Lo que hay que ver antes de empezar

**Abrir la tienda en un teléfono, no en el navegador de la compu.**
`https://santiagoadet7823-dev.github.io/mirame-app/tienda.html?t=mirame`

Y quedarse con esto, que es lo que se ve hoy:

- El título dice **"Tienda"**. Sin nombre, sin logo. Nada dice de quién es.
- Hay un producto solo, arriba a la izquierda, con **media pantalla vacía debajo**.
- La foto es de celular: una remera colgada de una percha contra una pared, **con la bolsa
  de plástico todavía puesta**.
- Encima de la foto, lo más fuerte de toda la pantalla, un velo blanco y un cartel rojo:
  **Agotado**.
- **No hay forma de escribirle a nadie.**

Eso es la vidriera del negocio.

---

## 3. Lo que no se toca

**La app de gestión queda fuera de alcance.** Es la herramienta con la que trabaja la dueña
— agenda, clientas, caja, stock — y su estética está congelada por decisión del proyecto.
No se rediseña, no se "armoniza", no se le sugieren cambios.

**La tienda sí se rediseña entera.** Es pieza aparte: nació después, la ven clientas y no
la dueña, y su trabajo es vender. La paleta y las tipografías de la marca son el punto de
partida, no una jaula.

### Dos restricciones técnicas que condicionan el diseño

Estas no son preferencias. Una propuesta que no las cumpla queda fuera de alcance aunque se
vea mejor.

| | |
|---|---|
| **Un solo archivo HTML** | Sin build, sin framework, sin librerías. Todo el CSS y el JS van adentro del mismo archivo. No hay React, no hay Tailwind, no hay componentes. |
| **La primera foto en ~1 segundo con datos móviles** | Es la razón por la que la tienda no está hecha en Flutter como el resto del producto. Presupuesto: **hero ≤ 120 KB**, formato WebP o AVIF, el resto de las fotos en `lazy`. Fuentes: las dos que ya se usan, nada más. |

---

## 4. Referencia estética

Se adjunta la referencia **"Luxora Fashion"** que eligió el cliente. Define la dirección:
e-commerce de moda en neutros cálidos, serif grande, mucho aire, micro-etiquetas en
mayúscula espaciada.

### Lo que hay que tomar

- **La paleta ya la tenemos.** Los cremas y taupes de la referencia son casi exactamente
  los fondos y los nude que ya están en el sistema (§5). Lo que cambia es el **rol**: hoy
  el lavanda es el color de la tienda; ahí el neutro cálido es el mundo y el color aparece
  **solo en lo que se toca**.
- **La serif carga la página.** Hoy Cormorant aparece únicamente en el título y en los
  precios; todo lo demás es Inter plano y la página se lee sin voz.
- **Piezas concretas**: hero · categorías como mosaico con foto en vez de píldoras de texto
  · corazón de favorito en la tarjeta · selector de cantidad en la ficha · barra de datos
  al pie.

### Lo que NO se puede copiar

Esto es lo más importante del brief. Si algo se pasa por alto, que no sean estos cinco
puntos.

1. **El hero de la referencia es una foto editorial de modelo. Acá no hay eso ni va a
   haber.** El material real es una percha contra una pared. Un hero es el elemento más
   expuesto de la página: copiado tal cual, va a verse **peor que no tener hero**.
   Necesitamos un hero que funcione con lo que hay — resuelto con tipografía y color, o con
   un **recorte de detalle** (textura de tela, un perchero, un rincón del estudio), que es
   muchísimo más fácil de fotografiar bien con un celular que un look completo.

2. **"FREE SHIPPING · 30-DAY RETURNS · SECURE PAYMENT" sería mentira.** La tienda no envía,
   no cobra online, y la mercadería a consignación no se devuelve. El **lugar** de esa barra
   sirve; el contenido tiene que ser lo que es cierto: *se lo guardamos 48 h · se puede
   probar · lo retirás en el estudio · pagás cuando lo ves*.

3. **La referencia es desktop-first y nuestro tráfico es 100 % teléfono.** Las cuatro
   pantallas chicas de abajo de esa imagen son las únicas que importan.

4. **Ese look implica imágenes grandes** y el techo de 1 segundo sigue en pie.

5. **La referencia no tiene ni un estado feo**: ni agotado, ni sin foto, ni un solo
   producto, ni error de carga. Un comp de plantilla nunca los muestra. **La tienda vive
   justamente ahí** — hoy tiene un producto y está agotado. Los estados son entregable
   obligatorio (§6.3).

---

## 5. Sistema visual de partida

### 5.1 Todo se entrega como variables de marca

La página **ya es multi-salón**: la misma URL sirve a cualquier salón según el parámetro
`?t=`. Hoy el lavanda de Mírame está quemado en el CSS, así que el segundo salón abriría su
vidriera con los colores de Candela.

El entregable es **un sistema con tres variables**:

```
--marca-nombre     el nombre del salón
--marca-acento     su color
--marca-logo       su logo
```

**Mírame es la primera instancia, no el molde.** El diseño tiene que verse bien con el
lavanda y también con un verde o un bordó. Conviene mostrarlo con dos acentos distintos
para probar que el sistema aguanta.

El chasis neutro cálido es de la plataforma y no cambia entre salones.

### 5.2 Color

**Fondos:** `#faf8f5` (base, blanco cálido) · `#f4f1ec` · `#ede9e2` · `#ffffff`

**Texto:** `#1a1612` (principal) · `#5c5248` (secundario) · `#9c9088` (apagado) ·
`#c4bdb5` (claro)

**Nude / durazno:** `#fdf0ec` `#f8ddd4` `#f0c4b8` `#e4a898` `#d4897a`
**Rosa suave:** `#f9e8e8` · `#e8b4b4`

**Acento de Mírame (lavanda), escala completa:**
`#f5f3ff` `#ede9fd` `#ddd6fb` `#c4b8f8` `#a898f3` **`#8b77ec`** `#7459d9` `#5f45be`
`#4e389a` `#3d2c7a`

**Semánticos:** éxito `#166534` sobre `#f0fdf4` · alerta `#9f1239` sobre `#fff1f2`

### 5.3 Tipografía

- **Cormorant Garamond** (serif) — títulos, precios, cifras. Pesos 500/600.
  **Se promueve a voz de la página**, no solo al título.
- **Inter** (sans) — interfaz, etiquetas, textos corridos. Pesos 400 a 700.

Las dos ya están en el proyecto y vienen de Google Fonts. **No sumar una tercera**: cada
familia nueva es peso en la carga y la página tiene un techo de 1 segundo.

Los precios llevan **`tabular-nums`** siempre. Hoy no lo hacen y los números bailan de una
tarjeta a otra.

### 5.4 Forma

**Radios:** 10 · 14 · 20 · 26 · 36 px, y píldoras completas.
**Sombras:** muy suaves y difusas, nunca duras. Referencia: `0 4px 16px rgba(0,0,0,.08)`.
**Bordes:** hairlines a muy baja opacidad — `rgba(0,0,0,.07)` y `rgba(0,0,0,.11)`.

**Sensación general:** claro, aireado, con mucho espacio en blanco. Nada de bordes marcados
ni de sombras dramáticas.

---

## 6. Entregables

En este orden. Los primeros tres son los que mueven la aguja.

### 6.1 Identidad de la vidriera — **prioridad crítica**

**a) La imagen de previsualización del link (1200×630).**
Es lo primero que ve todo el mundo y hoy no existe. Hay una provisoria armada por nosotros
—crema, serif, "Mirá lo que hay disponible"— que sirve de piso, no de meta.

Restricción importante: **es un archivo estático y no puede llevar el nombre del salón**.
El crawler de WhatsApp no ejecuta JavaScript, así que la imagen no se puede personalizar
desde la página. Tiene que funcionar para cualquier salón. *(El preview por salón o por
producto requiere trabajo de backend que está fuera de este brief.)*

**b) La cabecera de la página**: nombre del salón, logo, y la línea que dice qué es esto.
Hoy es la palabra "Tienda" centrada y nada más.

### 6.2 La tarjeta de producto — **prioridad crítica**

Es el 90 % de la página.

**El problema real, y no es un caso borde: las fotos son de celular y van a serlo siempre.**
Sacadas en una habitación, con luz despareja, la prenda colgada de una percha, a veces con
la bolsa puesta. Hoy la tarjeta las recorta a 3:4 con `object-fit: cover` y las tira sobre
blanco, sin marco ni respiro, así que cada imperfección queda a la vista.

**Un diseño que solo se ve bien con fotos de estudio va a verse mal para siempre.** Lo que
pedimos es una tarjeta que **dignifique una foto mediocre**: un fondo cálido detrás de la
imagen en vez de blanco puro, un borde interior que haga leer el corte como intencional,
una relación de aspecto decidida a conciencia (¿3:4? ¿1:1? ¿es mejor un poco de aire
alrededor que un recorte a sangre?).

La tarjeta incluye: foto · nombre · precio · talles disponibles · **favorito (corazón)** ·
y la marca de estado cuando corresponde.

**Detalle a resolver:** hoy los nombres de una y de dos líneas dan tarjetas de distinta
altura y la grilla queda dentada abajo.

### 6.3 Estados — **prioridad crítica**

Son donde la tienda vive hoy y donde ninguna referencia ayuda.

| Estado | Qué pasa hoy |
|---|---|
| **Agotado** | Velo blanco al 60 % sobre toda la foto más un cartel rojo. **Lo que no se puede comprar grita más que lo que sí.** Y la tarjeta sigue siendo tocable: se abre la ficha, todas las opciones salen tachadas y el botón queda para siempre en "Elegí una opción". Callejón sin salida. **Pedimos: bajarle el volumen (foto desaturada, etiqueta chica y quieta) y darle una salida — "Avisame cuando vuelva".** |
| **Última unidad** | No existe. El dato ya está en la base y no se usa. |
| **Reservado por otra** | No existe. |
| **Sin foto** | Un emoji gigante al 25 % de opacidad. |
| **Un solo producto** | Una tarjeta chica arriba a la izquierda y media pantalla vacía. Parece abandonada, no nueva. **La grilla tiene que verse bien con 1, con 3, con 12 y con 60.** |
| **Tienda vacía** | Emoji y una línea de texto. |
| **Error de carga** | Emoji y una línea de texto. Pasa de verdad, con mala señal. |

### 6.4 Ficha del producto

Se abre como hoja desde abajo. Lleva: carrusel de fotos · código · nombre · precio ·
descripción · selección de talle y color · **cantidad** · y el botón de agregar.

Hay que resolver **qué muestra cuando no hay stock**, que es el callejón sin salida de
arriba, y **cómo se ve la selección de variante** cuando hay una sola opción (hoy se elige
sola, y está bien, pero el diseño tiene que contemplarlo).

### 6.5 Carrito y reserva

El pedido, los datos de la clienta (nombre y WhatsApp), y la pantalla de confirmación con
el código.

**Lo que falla hoy es el final:** aparece un código, dice "48 horas", y ahí termina. Sin
fecha concreta, sin dirección, sin forma de guardarlo, sin saber qué pasa después.
**Pedimos un cierre que diga qué hacer ahora**, con **fecha y hora concretas** en vez de
"48 horas" — *"te lo guardamos hasta el jueves a las 14"* se cumple; *"48 horas"* se
olvida.

### 6.6 Portada: hero, categorías y barra de datos

Las tres piezas que trae la referencia y que hoy no existen.

- **Hero** que funcione sin foto editorial (ver §4, punto 1). Es el entregable de más
  riesgo del brief.
- **Categorías / rubros.** Hoy son tres solapas con emoji: 👗 Ropa · 💄 Arbell · 🧴
  Insumos. La referencia las muestra como mosaico con foto. Hay que decidir si eso es
  posible con el material que hay, o si conviene una solución tipográfica.
- **Barra de datos ciertos** al pie (ver §4, punto 2).

### 6.7 Especificación de movimiento

Sección aparte, en §7. Define el nivel de terminación de todo lo anterior.

### 6.8 Íconos de línea — **reemplazan los emojis**

Hoy la tienda usa **emojis del sistema** para los rubros, para el placeholder de foto y
para los estados vacíos. El brief de la app ya los había rechazado, por este motivo
exacto: *"se ven distinto en cada teléfono Android y rompen la elegancia del resto"*. La
tienda los reintrodujo y hay que sacarlos.

Especificación, idéntica a la del set de la app para que sean el mismo idioma:
**grilla 24×24 · trazo 1.8 px · sin relleno · esquinas y terminaciones redondeadas · un
solo color** (se pinta por código) · SVG individuales optimizados.

Lista: ropa · cosmética · insumos · producto sin foto · tienda vacía · búsqueda sin
resultados · error de carga · favorito (contorno y relleno) · carrito · WhatsApp ·
compartir · cerrar · flecha.

**Total: 13 íconos.**

### 6.9 Guía de foto para la dueña

**Este entregable es el que sostiene 6.2 y 6.6.** El diseño no puede arreglar una foto que
no existe, pero una tarjeta de ayuda dentro de la app, en el momento en que ella carga el
producto, sí.

Una lámina simple y sin vocabulario técnico: **fondo · luz · encuadre · distancia**, con
**un ejemplo bien y uno mal** hechos con el mismo teléfono y en la misma habitación. Nada
de trípodes ni de aros de luz: tiene que ser ejecutable un martes a las 9 de la noche.

---

## 7. Movimiento

Hoy la tienda tiene **una sola animación** (la hoja que sube) y un `transition: all .18s`
repetido en tarjetas, píldoras, solapas y opciones. No hay más nada.

Lo que pedimos, como especificación y no como sugerencia:

**Solo `transform` y `opacity`.** Nunca `transition: all` —anima propiedades que nadie
eligió animar—, nunca propiedades de layout.

**La duración sale de la distancia y del tamaño.** Una píldora y una hoja a pantalla
completa no pueden compartir la misma duración, que es lo que pasa hoy. Punto de partida:

| Token | Duración | Para qué |
|---|---|---|
| `--dur-1` | 120 ms | press, píldoras, chips |
| `--dur-2` | 200 ms | tarjetas, fades, cambios de estado |
| `--dur-3` | 320 ms | la hoja inferior |

**Entrada `ease-out`, salida `ease-in`.** Lo que llega desacelera; lo que se va acelera.

**La hoja tiene que ser interrumpible y reversible.** Hoy está hecha con un `@keyframes`,
así que no se puede parar ni revertir a mitad de camino: abrir y cerrar rápido se ve roto.
Tiene que manejarse por `transform`, con arrastre para cerrar y respuesta a la velocidad
del gesto. Y salir **del lugar donde se tocó**, no de la nada.

**La grilla entra escalonada**, reusando la escalera exacta que ya usa la app:
**30 · 70 · 110 · 150 · 190 · 220 ms**. Así la tienda hereda el ritmo del producto en vez
de inventar uno.

**Las fotos entran con opacidad** cuando terminan de decodificar, sobre el fondo cálido de
la tarjeta. Hoy aparecen de golpe.

**Se anima en el cambio de estado, no en cada render.**

**`prefers-reduced-motion: reduce` anula todo**, dejando solo la opacidad. La app respeta
esta preferencia en todas sus animaciones; la vitrina no puede ser la excepción.

---

## 8. Accesibilidad

Requisito, no nota al pie.

- **Todo lo que se toca es un `<button>` o un `<a>`.** Hoy las tarjetas, las píldoras y las
  solapas son `div` con `onclick`: no se llegan con teclado y un lector de pantalla no las
  anuncia como algo que se pueda tocar.
- **`:focus-visible` visible y diseñado.** Hoy no hay ninguno en toda la hoja de estilos.
- **Contraste AA verificado, no supuesto.** El gris apagado `#9c9088` sobre el fondo
  `#faf8f5` está al límite y se usa para los talles y las ayudas. Hay que medirlo y
  corregirlo si no da.
- **Área táctil mínima de 44×44** en todo lo que se toca, incluido el corazón de favorito.

---

## 9. Modo oscuro: decisión tomada

**La tienda se queda en claro, y lo decimos a propósito.** Es una vidriera cálida y clara
por identidad, y un claro bien resuelto lee mejor que un oscuro apurado.

Lo que no puede pasar es que sea un olvido. Si el diseñador cree que vale la pena, que lo
proponga como fase posterior con el mapeo completo de colores — nunca como inversión
automática.

---

## 10. Funciones que proponemos para la parte de la clienta

El diseñador las evalúa y diseña las que entren. Están ordenadas por lo que creemos que
más mueve la aguja.

| Función | Por qué |
|---|---|
| **Compartir un producto solo** | Ella manda *una* prenda a *una* clienta. Hoy solo puede mandar la tienda entera y decir "fijate la remera gris". Es el pedido que va a aparecer solo a la semana de usarla. |
| **"Avisame cuando vuelva"** en los agotados | Convierte el callejón sin salida en una lista de gente que ya dijo que sí |
| **Filtro por talle** | La primera pregunta de cualquiera es "¿tenés el mío?" |
| **Favoritos en el teléfono**, sin cuenta | Mirar hoy y decidir mañana es el comportamiento real. Es el corazón de la referencia. |
| **"Novedades"** — lo que entró esta semana | Da un motivo para volver a abrir el mismo link |
| **Últimas unidades** cuando queda 1 o 2 | El dato ya está y no se usa |
| **Fecha concreta en la reserva** | Ver §6.5 |
| **Cómo comprar · dónde se retira · se puede probar** | Es lo que separa a una desconocida de reservar |

---

## 11. Material que se entrega

- **El link de la tienda**, con productos reales cargados.
- **La referencia de Luxora**, junto con la lista de §4 de qué tomar y qué no.
- **Fotos reales de la dueña, sin retocar.** Son el material de verdad y la vara contra la
  que hay que probar cada tarjeta. Si una propuesta solo se ve bien con las fotos del comp,
  no sirve.
- Capturas de los estados que hoy no se pueden ver en vivo porque hay un solo producto.
- Este documento, con la paleta y las tipografías.
- Los íconos SVG que ya existen en la app, como referencia de estilo del set nuevo.
- El logo en la mejor resolución disponible.

---

## 12. Cómo se entrega

- **Figma**, con el ancho de teléfono (390) como principal y escritorio (1280) como
  secundario.
- **Los tokens como CSS custom properties**, no como estilos de Figma solamente: quien
  implementa es un archivo HTML plano y los va a copiar tal cual.
- **Assets exportados**: SVG para íconos y logo; JPG/WebP optimizados para la imagen de
  preview.
- **La especificación de movimiento escrita** (duraciones, curvas, secuencias), no un
  prototipo. Un prototipo de Figma no se puede traducir a CSS sin los números.

---

## 13. Orden sugerido

| | Entregable | Bloquea |
|---|---|---|
| 1 | Imagen de preview del link + cabecera (§6.1) | Es lo primero que ve todo el mundo |
| 2 | Tarjeta de producto (§6.2) y estados (§6.3) | Es el 90 % de la página |
| 3 | Guía de foto (§6.9) | Sostiene a los dos anteriores — cuanto antes empiece ella a sacar mejores fotos, mejor |
| 4 | Ficha, carrito y reserva (§6.4, §6.5) | El camino a la venta |
| 5 | Portada: hero, categorías, barra (§6.6) | Lo de más riesgo; conviene con el resto ya resuelto |
| 6 | Íconos (§6.8) y movimiento (§7) | Pulido final |

Los puntos 1 y 2 son los únicos que bloquean. El resto puede llegar después sin frenar
nada.
