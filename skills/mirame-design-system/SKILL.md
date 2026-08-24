---
name: mirame-design-system
description: Fuente de verdad visual de la app Mírame (Flutter). Usar SIEMPRE antes de escribir o modificar cualquier widget, pantalla, color, tipografía, sombra, radio o animación de este proyecto. Contiene los tokens literales extraídos del index.html original, que la app nueva debe replicar al pixel.
---

# Design system de Mírame

## Regla número uno

**La estética es un requisito, no una preferencia.** La app Flutter tiene que verse idéntica al
`index.html` original. Ningún valor visual se estima, se redondea ni se "mejora".

Si vas a escribir un color, un tamaño, un radio, una sombra o una duración: **está en la tabla**.
Si no está, se lee del CSS original antes de inventarlo.

## Dónde están los valores

`android/02-DESIGN-SYSTEM.md` — tabla completa y literal. Leelo antes de escribir el widget, no
después.

Origen: `index.html` líneas 20–1258 (CSS inline).

## Los que más se usan

```dart
// Marca
const brand      = Color(0xFF8B77EC);   // --lav-500
const brandDark  = Color(0xFF7459D9);   // --lav-700 es 0xFF5F45BE
const brandBg    = Color(0xFFF5F3FF);   // --lav-50

// Fondos
const bg       = Color(0xFFFAF8F5);
const bg2      = Color(0xFFF4F1EC);
const surface  = Color(0xFFFFFFFF);

// Texto
const tPrimary   = Color(0xFF1A1612);
const tSecondary = Color(0xFF5C5248);
const tMuted     = Color(0xFF9C9088);

// Movimiento — NO usar Curves.easeInOut, no es equivalente
const easeStd = Cubic(0.4, 0.0, 0.2, 1.0);
const easeOut = Cubic(0.0, 0.0, 0.2, 1.0);
const t1 = Duration(milliseconds: 120);
const t2 = Duration(milliseconds: 220);
const t3 = Duration(milliseconds: 350);
```

Radios: 10 / 14 / 20 / 26 / 36 / píldora.

## Errores que se repiten

| Error | Correcto |
|---|---|
| `Curves.easeInOut` | `Cubic(0.4, 0, 0.2, 1)` — no son la misma curva |
| `google_fonts` desde CDN | Fuentes locales en `assets/fonts/`. La app abre sin red |
| Meter `fl_chart` para el donut | `CustomPainter`. El original lo hace con SVG a mano |
| Inventar un color "parecido" | Buscarlo en `02-DESIGN-SYSTEM.md` |
| Poner 7 pestañas en el nav | **Son 5.** Stats y Ajustes se abren desde otro lado |
| Asignar colores de avatar al azar | `avatarIndex(name)` con `h = (h*31 + c) % 6` acumulado por iteración |
| Ignorar `disableAnimations` | Toda animación consulta `MediaQuery.disableAnimations` |
| Olvidar las safe areas | El bottom nav y el FAB dependen de `viewPadding.bottom` |

## Los tres breakpoints

| Ancho | Qué cambia |
|---|---|
| `< 600` | Móvil, bottom nav, modales como bottom sheet |
| `>= 600` | Contenido con `maxWidth: 430` centrado; FAB reposicionado |
| `>= 900` | Sidebar de 248 px, contenido `maxWidth: 1040`, **modales como diálogo centrado** |

## Verificar fidelidad

No se aprueba a ojo. Abrir `index.html` en el navegador al mismo ancho, comparar lado a lado, y
chequear los valores contra la tabla — no contra la impresión visual.

## Skills complementarias

`ui-ux-pro-max` (patrones Flutter), `apple-design` (gestos y sheets), `emil-design-eng` (criterio
de polish), `find-animation-opportunities` (después de tener la UI montada).

Informan **el cómo**, no el qué. Ningún valor del original se cambia porque una skill sugiera otra
cosa.
