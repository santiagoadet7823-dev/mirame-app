# Catálogo Arbell → tienda

Cómo cargar el catálogo de Arbell en la tienda, y cómo **actualizar los precios**
cuando llega el PDF del bimestre siguiente.

El catálogo cambia cada dos meses y trae ~370 códigos. A mano son varias tardes;
así son unos veinte minutos, de los cuales quince son de revisión humana.

---

## Lo único que hay que recordar

**La clave de todo es `producto_variantes.sku`**, que guarda el código de Arbell tal
cual sale del catálogo: `3154`, `C905`, `AC3027`, `VO70`.

Es lo único estable entre catálogos. Los nombres cambian de redacción, los precios
cambian por definición, y las secciones se reordenan. El código no. Por eso la
actualización busca por sku y no por nombre.

---

## El procedimiento, de arriba a abajo

### 0. Antes de empezar

```bash
pip install pymupdf pillow
```

Nada más. No hay build, no hay dependencias del proyecto Flutter.

### 1. Revisar el mapa de secciones

`secciones.json` dice qué páginas son de qué categoría. **Arbell reordena las
secciones en cada catálogo**, así que esto hay que mirarlo siempre:

```bash
python extraer.py ~/Downloads/cat-5-2026.pdf --solo-secciones
```

Imprime página por página la categoría que le tocaría. Se compara contra el PDF
abierto al lado y se corrigen los rangos en `secciones.json`. Las páginas fuera de
todo rango se ignoran: ahí van portadas, índices y separadores.

### 2. Extraer

```bash
python extraer.py ~/Downloads/cat-5-2026.pdf
```

Tarda unos minutos: renderiza las 149 páginas. Deja todo en `salida/`:

| Archivo | Para qué |
|---|---|
| `revision.csv` | **Una fila por código. Es el archivo que se corrige.** Abre en Excel |
| `revision.html` | Hoja de contactos: el recorte de foto de cada producto, con su tilde |
| `catalogo.json` | Lo que consume `cargar.py` |
| `paginas/NNN.png` | Cada página del PDF, para verificar contra el original |
| `recortes/ARB-*.png` | La foto candidata de cada producto |

Para iterar sin esperar los renders: `--sin-imagenes`.

### 3. Revisar — este paso no se saltea

El catálogo es una pieza editorial, no una lista de precios. El parser trabaja en
dos pasadas y **solo la primera es confiable**:

- **`confianza: alta`** — el código y el precio estaban en el mismo bloque de texto.
  Es el caso de la página 40: `3154 | AGUA MICELAR | 125 ml. | P.REG.: $11990 | $9900`.
  Fueron 90 de 274 en el catálogo 2026-04.
- **`confianza: media`** — el precio se tomó de otro lado de la página. Es el caso de
  la página 80, donde siete ampollas comparten un `$3500 CADA UNA` suelto al pie.
  **Todo esto hay que mirarlo.** La columna `motivo` dice por qué quedó marcado.

En `revision.html` las tarjetas con borde ámbar son las de confianza media.

Lo que más falla, en orden:
1. **Combos y regalos** (`CÓDIGO 0038`, `2x1`, `llevá el sérum gratis`). El precio
   grande de esas páginas es el del combo, no el del producto suelto.
2. **Nombres con el párrafo pegado**, sobre todo en joyería. El parser corta a los 60
   caracteres y manda el resto a `descripcion`, pero el corte no siempre cae bien.
3. **Tonos mal apareados.** En las grillas de esmaltes el código y el color son
   bloques separados del PDF; se emparejan por cercanía y en las grillas apretadas
   puede cruzarse alguno.

Corregir directo en `catalogo.json` (o corregir el CSV y volcar los cambios). Los
recortes que no sirvan, simplemente no se tildan.

### 4. Cargar

```bash
python cargar.py --dry-run     # deja salida/carga.sql terminando en ROLLBACK
python cargar.py               # deja salida/carga.sql terminando en COMMIT
```

El script **no se conecta a la base**: escribe un SQL autocontenido. Se pega en el
**SQL Editor de Supabase** (Dashboard → SQL Editor) y se corre. Todo va en una sola
transacción: si algo falla, no queda nada a medias.

El SQL imprime un informe al final:

```
altas de producto                          | 274
productos ya cargados                      |   0
cambios de precio                          |   0
variantes nuevas                           | 372
despublicar (ya no estan en el catalogo)   |   0
```

En una actualización normal de precios se espera ver **pocas altas y muchos cambios
de precio**. Si ves 274 altas otra vez, algo anda mal: probablemente cambió el
formato de los códigos y no está matcheando por sku.

**Es idempotente.** Correr el mismo SQL dos veces da 0 altas, 0 variantes nuevas y
0 cambios de precio. Está garantizado por el índice único
`variantes_tenant_sku_idx` sobre `(tenant_id, sku)`.

#### Lo que hace y lo que no

| Situación | Qué pasa |
|---|---|
| El sku ya existe | Se actualiza **el precio** de su producto padre |
| El sku es nuevo pero el producto existe | Se agrega la variante a ese producto |
| No matchea nada | Alta de producto + variantes + stock en 0 |
| El sku estaba y **ya no está en el catálogo** | `publicado = false` y sale en el informe |

**Nunca borra.** Un código discontinuado puede ser algo que ella ya vendió; borrarlo
rompería la venta vieja.

**Nunca pisa `nombre` ni `categoria`.** Si Candela corrigió un nombre a mano, el
catálogo siguiente no se lo deshace. Para forzarlo: `python cargar.py --actualizar-nombres`.

**Entra todo despublicado** (`publicado = false`). Ella revisa desde el módulo Tienda
y publica lo que quiera.

### 5. Fotos

```bash
# tras tildar en revision.html y pegar la lista en salida/fotos-aprobadas.txt
SUPABASE_SERVICE_KEY=... python subir_fotos.py --dry-run
SUPABASE_SERVICE_KEY=... python subir_fotos.py
```

Convierte el recorte a WebP de 1200 px y lo sube a `{tenant}/{producto_id}/`, que es
la convención de `features/ropa/fotos.dart`. **No pisa un producto que ya tiene foto**:
la foto propia siempre vale más que un recorte del catálogo.

Necesita la service key (Dashboard → Settings → API) porque la RLS no le deja
escribir a `anon` y el MCP de Supabase no expone Storage. Va por variable de entorno;
no la guardes en un archivo dentro del repo.

### 6. Congelar y anotar

```bash
cp salida/catalogo.json catalogos/2026-05.json
```

`catalogos/` **sí sube al repo**; `salida/` no (son 280 MB de renders). Tener el JSON
de cada bimestre permite diffear precios entre catálogos sin volver a abrir los PDF.

Después, la fila en `HANDOFF.md`.

---

## Sobre las fotos, con honestidad

**Los recortes automáticos aciertan a veces y a veces no, y no hay forma de que sea
de otro modo.** El catálogo es editorial: los frascos se solapan, hay páginas a sangre
sobre fondo negro y hay composiciones donde el producto está fundido con el fondo.

- Donde sale bien: páginas de fondo claro con los productos en fila (la 40, la 6).
- Donde sale mal: páginas con panel oscuro y foto a sangre (la 30).

Por eso el script genera el **candidato** y la hoja de contactos decide. Lo que no
pase la revisión queda sin foto, y la vitrina ya tiene un estado «sin foto» que se ve
bien. Es preferible eso a publicar un recorte con media etiqueta de otro producto.

Las imágenes son material de campaña de Arbell. Que una consultora las use para
revender es la práctica normal del canal, pero la marca es la dueña.

---

## Referencia rápida

| Dato | Valor |
|---|---|
| Proyecto Supabase | `hanljsmsgvezuhmehqla` |
| Tenant (el salón de Candela **es** `mirame`) | `f287a618-934d-4877-be79-8f7d2e89d734` |
| Proveedor `arbell` | `01a05093-bf4e-7d33-9453-a3121be96945` |
| Bucket | `productos` (público, 3 MB, jpeg/png/webp) |
| Rubro en la tienda | `productos.rubro = 'arbell'` |
| Código de producto | `ARB-3154` (uno solo) · `ARB-F-ESMALTES` (familia con tonos) |
| Código de Arbell | `producto_variantes.sku` |

### Consultas útiles

```sql
-- Cómo quedó
select categoria, count(*) from productos
 where rubro='arbell' and deleted_at is null group by 1 order by 2 desc;

-- Qué está publicado
select count(*) from productos where rubro='arbell' and publicado;

-- Buscar un código de Arbell
select p.codigo, p.nombre, p.precio, v.sku, v.color
  from producto_variantes v join productos p on p.id=v.producto_id
 where v.sku = '3154';

-- Que el borrador no se filtre a la vitrina
set local role anon;
select count(*) from tienda_productos where rubro='arbell';
reset role;
```

---

## ⚠️ Stock: leer antes de publicar

Todo entra con **stock 0**, a propósito: no se inventan cantidades de mercadería que
no está en el salón.

Consecuencia: **cualquier producto Arbell que se publique con stock 0 se va a ver como
«Agotado / Se vendió»** en la vitrina. Lo calcula `tienda.html:582`
(`stock === 0 → 'agotado'`).

O sea: primero se carga la cantidad de lo que ella realmente pidió, y recién ahí se
publica. Si en algún momento se quiere publicar el catálogo completo como «por pedido»
sin stock, hay que tocar `tienda.html` para que `rubro === 'arbell'` no muestre estado
de stock — la vitrina ya declara `sub: 'Por pedido'` para ese rubro, pero el estado no
lo respeta todavía.
