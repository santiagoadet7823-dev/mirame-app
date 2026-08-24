# Brief de diseño — Mírame App

> Para pasarle al diseñador tal como está.

---

## 1. Contexto en 30 segundos

Mírame Lash Studio es una app de gestión para un estudio de extensión de pestañas: turnos,
clientas, caja, stock y estadísticas. Hoy existe y funciona como una web app instalable; la estamos
convirtiendo en app nativa Android y en versión web, para venderla también a otros salones.

**La estética ya está definida y funciona. No hay rediseño.** Es una paleta lavanda y nude, con
tipografía serif elegante para los números y sans para la interfaz. El público son dueñas de
salones de belleza: la app tiene que verse cuidada, no corporativa.

Necesitamos piezas puntuales que hoy no existen o están resueltas de forma provisoria.

---

## 2. Lo que NO hay que tocar

- El layout de las pantallas existentes.
- La paleta, la tipografía, los radios, las sombras.
- La navegación (5 pestañas abajo).

Cualquier propuesta de "mejorar" la interfaz existente queda fuera de alcance. La fidelidad al
diseño actual es un requisito técnico del proyecto.

---

## 3. Sistema visual (para que lo nuevo encaje)

**Color de marca:** lavanda `#8b77ec`. Escala completa: `#f5f3ff` `#ede9fd` `#ddd6fb` `#c4b8f8`
`#a898f3` `#8b77ec` `#7459d9` `#5f45be` `#4e389a` `#3d2c7a`

**Color secundario (nude/durazno):** `#fdf0ec` `#f8ddd4` `#f0c4b8` `#e4a898` `#d4897a`
**Rosa suave:** `#f9e8e8` · `#e8b4b4`

**Fondos:** `#faf8f5` (base, un blanco cálido) · `#f4f1ec` · `#ede9e2` · `#ffffff` (superficies)

**Texto:** `#1a1612` (principal) · `#5c5248` (secundario) · `#9c9088` (apagado) · `#c4bdb5` (claro)

**Tipografías:**
- **Cormorant Garamond** (serif) — títulos y cifras grandes. Pesos 400/500/600.
- **Inter** (sans) — toda la interfaz. Pesos 300 a 700.

**Radios:** 10, 14, 20, 26, 36 px, y píldoras completas.
**Sombras:** muy suaves, difusas, nunca duras. Ej: `0 4px 16px rgba(0,0,0,.08)`.

**Sensación general:** claro, aireado, con mucho espacio en blanco. Gradientes suavísimos
(lavanda → nude). Nada de bordes marcados ni de sombras dramáticas.

---

## 4. Entregables

### 4.1 Ícono de app y splash — **prioridad alta**

Hoy solo existe una foto del logo en JPEG. Hace falta el set completo:

- **Ícono adaptativo de Android**: capa de fondo y capa de frente **separadas** (Android las anima
  y recorta con distintas formas según el fabricante).
- **Versión monocromática** para el tema dinámico de Android 13+.
- Densidades: mdpi, hdpi, xhdpi, xxhdpi, xxxhdpi.
- **Favicon y íconos de PWA**: 192×192 y 512×512 PNG, más una versión `maskable`.
- **Splash screen nativo**: logo centrado sobre fondo `#faf8f5`. Simple; se ve menos de un segundo.

Formato de entrega: SVG vectorial del logo + los PNG exportados.

### 4.2 Set de íconos propio — **prioridad alta**

Hoy la app mezcla dos sistemas: unos 12 íconos SVG de línea (estilo Feather: trazo de 1.8 px,
esquinas redondeadas, sin relleno) y unos **60 emojis del sistema**.

Los emojis se ven distinto en cada teléfono Android y rompen la elegancia del resto. Queremos
reemplazarlos por íconos de línea propios, **coherentes con los 12 que ya existen**.

Especificación:
- Grilla de 24×24, trazo **1.8 px**, sin relleno, esquinas y terminaciones redondeadas.
- Un solo color (se pinta por código).
- Entrega: SVG individuales optimizados.

Lista (agrupada por dónde aparecen):

**Acciones rápidas (4):** nuevo turno · nueva clienta · registrar pago · estadísticas
**Estados vacíos (4):** sin turnos · sin clientas · sin productos · sin movimientos
**Categorías de stock (7):** adhesivos · pestañas · removedores · primers · herramientas · limpieza · otros
**Categorías de caja (9):** servicio · productos · insumos · alquiler · sueldos · marketing · impuestos · mantenimiento · otros
**Estados de turno (4):** confirmado · pendiente · completado · cancelado
**Métodos de pago (3):** efectivo · transferencia · tarjeta
**Ajustes (9):** cerrar sesión · nombre del estudio · profesionales · servicios · exportar · importar · auto-backup · instalar app · versión
**Varios (6):** recordatorio de retoque · sincronización · alerta · éxito · error · información

Total aproximado: **46 íconos**.

### 4.3 Pantallas nuevas — **prioridad media**

No existen y no tienen diseño previo. Son para el panel de administración del producto (lo usamos
nosotros y el revendedor, no las dueñas de salón). Mismo sistema visual, pero puede ser más denso:
se usa mayormente en escritorio.

1. **Lista de salones**: tarjetas o tabla con nombre, estado (prueba / activo / suspendido /
   vencido), días restantes de licencia y cantidad de usuarios.
2. **Ficha de un salón**: datos, licencia con historial de pagos, usuarios y sus roles, botón de
   suspender, y acceso a "ver como el salón".
3. **Alta de un salón nuevo**: formulario de 4 o 5 campos.
4. **Registro de auditoría**: lista de quién accedió a los datos de qué salón y cuándo.
5. **Estados de error y vacío** de estas pantallas.

Entregar en dos anchos: escritorio (1280) y móvil (390).

### 4.4 Ilustraciones de estado vacío — **prioridad baja**

Hoy son emojis gigantes dentro de un círculo con gradiente. Funcionan, pero una ilustración
sencilla y propia elevaría bastante la percepción de la app.

Cuatro escenas, en el estilo de la marca (línea fina, paleta lavanda/nude, mucho aire):
agenda vacía · sin clientas · sin productos · sin movimientos.

Tamaño de referencia: 120×120. SVG.

### 4.5 Piezas para distribuir la app — **prioridad baja**

- Una página simple de descarga (para mandar el link a un salón nuevo): logo, 3 capturas, botón de
  descargar el APK, botón de abrir la versión web.
- 3 o 4 capturas de pantalla con marco de teléfono, para esa página y para mandar por WhatsApp.

### 4.6 Modo oscuro — **opcional, fase posterior**

La app hoy es solo modo claro. Si se quiere modo oscuro, hace falta el mapeo completo de unos 40
colores, no una inversión automática. **Decidir si entra recién después de la primera versión**:
no es lo que más valor agrega ahora.

---

## 5. Material que se le entrega al diseñador

- La app actual funcionando (link o el archivo HTML), para verla en el teléfono.
- Capturas de las 7 pantallas en los 3 tamaños.
- Este documento con la paleta y la tipografía.
- Los 12 íconos SVG que ya existen, como referencia de estilo del set nuevo.
- El logo actual en la mejor resolución disponible.

---

## 6. Orden sugerido de entrega

1. Ícono de app, adaptativo y splash (bloquea el primer build del APK).
2. Set de íconos (bloquea el pulido visual de las pantallas).
3. Pantallas de administración.
4. Ilustraciones de estado vacío.
5. Piezas de distribución.
6. Modo oscuro, si se decide hacerlo.

Los puntos 1 y 2 son los que bloquean desarrollo. El resto puede llegar después sin frenar nada.
