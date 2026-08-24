/// Sombras, portadas del CSS.
///
/// Nota sobre unidades: el `blur-radius` de CSS y el `blurRadius` de Flutter
/// NO son lo mismo — CSS usa una desviación estándar de blur/2. En la práctica
/// pasar el valor tal cual da un resultado muy cercano; si al comparar lado a
/// lado una sombra se ve más dura, se ajusta el blur, nunca el color.
library;

import 'package:flutter/painting.dart';

abstract final class MShadow {
  /// `0 1px 3px rgba(0,0,0,.06)`
  static const xs = [
    BoxShadow(color: Color(0x0F000000), offset: Offset(0, 1), blurRadius: 3),
  ];

  /// `0 2px 8px rgba(0,0,0,.07)`
  static const sm = [
    BoxShadow(color: Color(0x12000000), offset: Offset(0, 2), blurRadius: 8),
  ];

  /// `0 4px 16px rgba(0,0,0,.08)`
  static const md = [
    BoxShadow(color: Color(0x14000000), offset: Offset(0, 4), blurRadius: 16),
  ];

  /// `0 8px 28px rgba(0,0,0,.09)`
  static const lg = [
    BoxShadow(color: Color(0x17000000), offset: Offset(0, 8), blurRadius: 28),
  ];

  /// `0 4px 14px rgba(139,119,236,.22)`
  static const brand = [
    BoxShadow(color: Color(0x388B77EC), offset: Offset(0, 4), blurRadius: 14),
  ];

  /// Emblema del login: `sh-lg` + halo lavanda.
  ///
  /// El `inset 0 1px 2px rgba(255,255,255,.9)` del original no existe en
  /// `BoxShadow`; se resuelve con el anillo interior blanco que ya lleva el
  /// widget (`::after` en el CSS), así que no se pierde nada.
  static const authEmblem = [
    BoxShadow(color: Color(0x17000000), offset: Offset(0, 8), blurRadius: 28),
    BoxShadow(color: Color(0x298B77EC), offset: Offset(0, 12), blurRadius: 30),
  ];

  /// Botón de WhatsApp: `0 6px 16px rgba(37,211,102,.32)`.
  static const whatsapp = [
    BoxShadow(color: Color(0x5225D366), offset: Offset(0, 6), blurRadius: 16),
  ];

  /// Al presionar: `0 3px 10px rgba(37,211,102,.26)`.
  static const whatsappActivo = [
    BoxShadow(color: Color(0x4225D366), offset: Offset(0, 3), blurRadius: 10),
  ];

  /// Bottom sheet en móvil: `0 -8px 40px rgba(0,0,0,.12)`.
  static const sheetMovil = [
    BoxShadow(color: Color(0x1F000000), offset: Offset(0, -8), blurRadius: 40),
  ];

  /// Diálogo en desktop: `0 24px 60px rgba(10,8,6,.28)`.
  static const sheetDesktop = [
    BoxShadow(color: Color(0x470A0806), offset: Offset(0, 24), blurRadius: 60),
  ];

  /// Knob del toggle: `0 1px 4px rgba(0,0,0,.2)`.
  static const toggleKnob = [
    BoxShadow(color: Color(0x33000000), offset: Offset(0, 1), blurRadius: 4),
  ];

  /// Pill activa: `0 1px 6px rgba(139,119,236,.14)`.
  static const pillOn = [
    BoxShadow(color: Color(0x248B77EC), offset: Offset(0, 1), blurRadius: 6),
  ];
}

/// Gradientes con nombre. Todos a 135° salvo donde se indique.
abstract final class MGradient {
  static const _tl = Alignment.topLeft;
  static const _br = Alignment.bottomRight;

  /// `linear-gradient(150deg, lav-100, nude-100)` — emblema del login.
  static const authEmblem = LinearGradient(
    begin: Alignment(-0.5, -1),
    end: Alignment(0.5, 1),
    colors: [Color(0xFFEDE9FD), Color(0xFFFDF0EC)],
  );

  /// `linear-gradient(140deg, lav-50, nude-100)` — tarjeta de balance.
  static const balance = LinearGradient(
    begin: Alignment(-0.6, -1),
    end: Alignment(0.6, 1),
    colors: [Color(0xFFF5F3FF), Color(0xFFFDF0EC)],
  );

  /// `linear-gradient(135deg, lav-50, nude-100)` — KPI hero.
  static const kpiHero = LinearGradient(
    begin: _tl,
    end: _br,
    colors: [Color(0xFFF5F3FF), Color(0xFFFDF0EC)],
  );

  /// `linear-gradient(145deg, lav-50, nude-100)` — estado vacío y perfil.
  static const suave = LinearGradient(
    begin: Alignment(-0.7, -1),
    end: Alignment(0.7, 1),
    colors: [Color(0xFFF5F3FF), Color(0xFFFDF0EC)],
  );

  /// Avatar `av-a` … `av-f`, a 135°.
  static LinearGradient avatar(int indice) {
    final (a, b) = _avatares[indice % _avatares.length];
    return LinearGradient(begin: _tl, end: _br, colors: [a, b]);
  }

  static const _avatares = <(Color, Color)>[
    (Color(0xFFA898F3), Color(0xFF8B77EC)),
    (Color(0xFFD4896E), Color(0xFFE4A898)),
    (Color(0xFF7BB8A4), Color(0xFF5DA090)),
    (Color(0xFFD4A0C8), Color(0xFFC084B4)),
    (Color(0xFF8FB4E0), Color(0xFF6594C8)),
    (Color(0xFFC8A87A), Color(0xFFB8906A)),
  ];
}
