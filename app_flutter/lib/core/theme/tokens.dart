/// Tokens de diseño de Mírame.
///
/// Portados LITERALMENTE del bloque `:root` de `index.html` (líneas 27-98).
/// No se aproximan, no se redondean, no se "mejoran": la app nueva tiene que
/// verse idéntica a la que la dueña ya usa todos los días.
///
/// Referencia completa: `android/02-DESIGN-SYSTEM.md`.
library;

import 'dart:ui' show Color;

// `Cubic` vive en el paquete de animación de Flutter, no en `dart:ui`.
import 'package:flutter/animation.dart' show Cubic;

/// Paleta. Los nombres replican los de las custom properties del CSS para que
/// buscar `--lav-500` en el original lleve directo a `MColors.lav500`.
abstract final class MColors {
  // — Colores base —
  static const bg = Color(0xFFFAF8F5);
  static const bg2 = Color(0xFFF4F1EC);
  static const bg3 = Color(0xFFEDE9E2);
  static const surface = Color(0xFFFFFFFF);
  static const surface2 = Color(0xFFFDFCFB);

  // — Lavender palette —
  static const lav50 = Color(0xFFF5F3FF);
  static const lav100 = Color(0xFFEDE9FD);
  static const lav200 = Color(0xFFDDD6FB);
  static const lav300 = Color(0xFFC4B8F8);
  static const lav400 = Color(0xFFA898F3);
  static const lav500 = Color(0xFF8B77EC);
  static const lav600 = Color(0xFF7459D9);
  static const lav700 = Color(0xFF5F45BE);
  static const lav800 = Color(0xFF4E389A);
  static const lav900 = Color(0xFF3D2C7A);

  // — Nude / Rose —
  static const nude100 = Color(0xFFFDF0EC);
  static const nude200 = Color(0xFFF8DDD4);
  static const nude300 = Color(0xFFF0C4B8);
  static const nude400 = Color(0xFFE4A898);
  static const nude500 = Color(0xFFD4897A);
  static const roseSoft = Color(0xFFF9E8E8);
  static const roseMid = Color(0xFFE8B4B4);

  // — Texto —
  static const tPrimary = Color(0xFF1A1612);
  static const tSecondary = Color(0xFF5C5248);
  static const tMuted = Color(0xFF9C9088);
  static const tLight = Color(0xFFC4BDB5);
  static const tWhite = Color(0xFFFFFFFF);

  // — Bordes —
  /// `rgba(0,0,0,0.07)`
  static const border = Color(0x12000000);

  /// `rgba(0,0,0,0.11)`
  static const borderMd = Color(0x1C000000);

  /// `rgba(139,119,236,0.18)`
  static const borderLav = Color(0x2E8B77EC);

  // — Brand principal —
  static const brand = lav500;
  static const brandDark = lav700;
  static const brandLight = lav100;
  static const brandBg = lav50;

  // — Semánticos (hardcodeados en el CSS, no eran custom properties) —
  static const successBg = Color(0xFFF0FDF4);
  static const successBorder = Color(0xFFBBF7D0);
  static const successText = Color(0xFF166534);

  static const warningBg = Color(0xFFFFFBEB);
  static const warningBorder = Color(0xFFFDE68A);
  static const warningText = Color(0xFF92400E);

  static const dangerBg = Color(0xFFFFF1F2);
  static const dangerBorder = Color(0xFFFECDD3);
  static const dangerText = Color(0xFF9F1239);
  static const dangerBgActive = Color(0xFFFFE4E6);

  static const skyBg = Color(0xFFF0F9FF);
  static const skyBorder = Color(0xFFBAE6FD);

  /// Montos de ingreso y egreso en la lista de caja.
  static const income = Color(0xFF1A7A4A);
  static const expense = Color(0xFFA83232);

  /// Barras de stock según estado.
  static const stockOk = Color(0xFF34D399);
  static const stockLow = Color(0xFFF59E0B);
  static const stockOut = Color(0xFFF87171);

  static const whatsapp = Color(0xFF25D366);

  /// Overlay de los modales: `rgba(10,8,6,0.5)`.
  static const scrim = Color(0x800A0806);
}

/// Series de datos. El orden importa: el índice determina el color, así que
/// reordenarlas cambia los colores del donut y de los gastos por categoría.
abstract final class MSeries {
  /// Porciones del donut de servicios populares.
  static const services = <Color>[
    Color(0xFFA898F3),
    Color(0xFFD4896E),
    Color(0xFF7BB8A4),
    Color(0xFFD4A0C8),
    Color(0xFF8FB4E0),
    Color(0xFFC8A87A),
    Color(0xFFA0C878),
    Color(0xFFE0A0A0),
  ];

  /// Barras de gastos por categoría.
  static const expenses = <Color>[
    Color(0xFFE11D48),
    Color(0xFF9F1239),
    Color(0xFFC026D3),
    Color(0xFF7C3AED),
    Color(0xFF2563EB),
    Color(0xFF0891B2),
    Color(0xFF059669),
  ];

  /// Gradientes de avatar `av-a` … `av-f`, en `linear-gradient(135deg, …)`.
  /// El índice sale de `avatarIndex(nombre)` — ver `domain/rules/avatar.dart`.
  static const avatars = <(Color, Color)>[
    (Color(0xFFA898F3), Color(0xFF8B77EC)), // av-a
    (Color(0xFFD4896E), Color(0xFFE4A898)), // av-b
    (Color(0xFF7BB8A4), Color(0xFF5DA090)), // av-c
    (Color(0xFFD4A0C8), Color(0xFFC084B4)), // av-d
    (Color(0xFF8FB4E0), Color(0xFF6594C8)), // av-e
    (Color(0xFFC8A87A), Color(0xFFB8906A)), // av-f
  ];
}

/// Radios. `rFull` se usa como píldora (`StadiumBorder` en la práctica).
abstract final class MRadius {
  static const sm = 10.0;
  static const md = 14.0;
  static const lg = 20.0;
  static const xl = 26.0;
  static const x2 = 36.0;
  static const full = 999.0;
}

/// Movimiento.
///
/// `Curves.easeInOut` NO equivale a `--ease`. Se definen los cúbicos exactos.
abstract final class MMotion {
  /// `cubic-bezier(0.4, 0, 0.2, 1)`
  static const ease = Cubic(0.4, 0.0, 0.2, 1.0);

  /// `cubic-bezier(0, 0, 0.2, 1)`
  static const easeOut = Cubic(0.0, 0.0, 0.2, 1.0);

  static const t1 = Duration(milliseconds: 120);
  static const t2 = Duration(milliseconds: 220);
  static const t3 = Duration(milliseconds: 350);

  // Duraciones de las animaciones nombradas.
  static const splashIn = Duration(milliseconds: 600);
  static const fadeUp = Duration(milliseconds: 200);
  static const gdPulse = Duration(milliseconds: 1000);
  static const authFloat = Duration(milliseconds: 5500);
  static const viewRise = Duration(milliseconds: 420);
  static const fabPop = Duration(milliseconds: 340);
  static const itemIn = Duration(milliseconds: 400);
  static const sheet = Duration(milliseconds: 320);

  /// Escalonado de entrada: hijos 1 a 5 de una vista, y 220 ms del 6 en adelante.
  /// CSS: `.view.active > *:nth-child(n)` con delays .03/.07/.11/.15/.19/.22s.
  static const staggerDelays = <int>[30, 70, 110, 150, 190];
  static const staggerTail = 220;

  static Duration staggerFor(int index) => Duration(
        milliseconds:
            index < staggerDelays.length ? staggerDelays[index] : staggerTail,
      );

  // Transiciones de barras. Sin esto los gráficos aparecen de golpe.
  static const barStock = Duration(milliseconds: 500);
  static const barChart = Duration(milliseconds: 600);
  static const barRank = Duration(milliseconds: 700);
  static const barCategory = Duration(milliseconds: 800);
  static const barProjection = Duration(milliseconds: 1000);
}

/// Familias tipográficas. Se empaquetan como assets locales: la app tiene que
/// abrir sin red, así que nada de cargar fuentes por CDN.
abstract final class MType {
  /// Títulos y cifras grandes.
  static const serif = 'CormorantGaramond';

  /// Toda la interfaz.
  static const sans = 'Inter';

  /// Wordmark "Mírame" del splash y el login. La introdujo el diseñador; el
  /// original usaba [serif] ahí. Ver HANDOFF §9.
  static const script = 'Parisienne';
}

/// Breakpoints. El CSS define tres modos y hay que replicar los tres.
abstract final class MBreak {
  /// A partir de acá el contenido se centra con ancho máximo.
  static const tablet = 600.0;

  /// A partir de acá aparece el sidebar y los modales pasan a ser diálogos.
  static const desktop = 900.0;

  /// `#app { max-width: 430px }` en >= 600px.
  static const contentMaxWidth = 430.0;

  /// Ancho del sidebar en modo desktop.
  static const sidebarWidth = 248.0;

  /// `max-width: 1040px` del contenido en modo desktop.
  static const desktopContentMaxWidth = 1040.0;

  /// Ancho máximo de los modales.
  static const sheetMaxWidth = 560.0;
}
