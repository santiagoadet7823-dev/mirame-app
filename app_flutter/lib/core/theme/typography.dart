/// Estilos de texto.
///
/// **Por qué existe este archivo y no se usa `TextStyle` suelto:** Inter y
/// Cormorant Garamond son fuentes VARIABLES (Google Fonts ya no publica
/// instancias estáticas). Con una fuente variable, `fontWeight` por sí solo no
/// mueve el eje de peso de forma confiable: hay que declarar también
/// `fontVariations`.
///
/// Los helpers de abajo lo hacen siempre, en un solo lugar. Si alguien escribe
/// un `TextStyle` a mano y se olvida, el texto sale en peso 400 y nadie se da
/// cuenta hasta compararlo con el original.
library;

import 'package:flutter/painting.dart';

import 'tokens.dart';

/// Texto de interfaz (Inter).
TextStyle sans({
  required double size,
  int weight = 400,
  Color? color,
  double? letterSpacing,
  double? height,
  bool tabular = false,
}) =>
    TextStyle(
      fontFamily: MType.sans,
      fontSize: size,
      fontWeight: _peso(weight),
      fontVariations: [FontVariation('wght', weight.toDouble())],
      color: color ?? MColors.tPrimary,
      letterSpacing: letterSpacing,
      height: height,
      fontFeatures: tabular ? const [FontFeature.tabularFigures()] : null,
    );

/// Display y cifras grandes (Cormorant Garamond).
TextStyle serif({
  required double size,
  int weight = 500,
  Color? color,
  double? letterSpacing,
  double? height,
  bool tabular = false,
}) =>
    TextStyle(
      fontFamily: MType.serif,
      fontSize: size,
      fontWeight: _peso(weight),
      fontVariations: [FontVariation('wght', weight.toDouble())],
      color: color ?? MColors.tPrimary,
      letterSpacing: letterSpacing,
      height: height,
      fontFeatures: tabular ? const [FontFeature.tabularFigures()] : null,
    );

/// Wordmark "Mírame". Parisienne es estática, así que no lleva `fontVariations`.
///
/// ⚠️ Decisión pendiente: el `index.html` original usa Cormorant Garamond acá.
/// Parisienne la introdujo el diseñador en el entregable del splash. Cambiar
/// de una a otra es tocar solo esta función.
TextStyle wordmark({required double size, Color? color}) => TextStyle(
      fontFamily: MType.script,
      fontSize: size,
      color: color ?? MColors.tPrimary,
      height: 1,
    );

FontWeight _peso(int w) => switch (w) {
      <= 300 => FontWeight.w300,
      400 => FontWeight.w400,
      500 => FontWeight.w500,
      600 => FontWeight.w600,
      _ => FontWeight.w700,
    };

/// Escala de la app, con los valores literales de `02-DESIGN-SYSTEM.md`.
abstract final class MText {
  // — Display (Cormorant) —
  static TextStyle get balance =>
      serif(size: 46, weight: 600, letterSpacing: -2, height: 1, tabular: true);
  static TextStyle get cierreNeto =>
      serif(size: 48, weight: 500, letterSpacing: -2, height: 1, tabular: true);
  static TextStyle get kpiHero =>
      serif(size: 42, weight: 600, letterSpacing: -1, height: 1, tabular: true);
  static TextStyle get authMono => serif(
      size: 46,
      weight: 600,
      color: MColors.lav700,
      letterSpacing: 0.5,
      height: 1);
  static TextStyle get authName =>
      serif(size: 40, weight: 600, letterSpacing: 0.3, height: 1);
  static TextStyle get splashName => serif(size: 28, weight: 500, letterSpacing: 0.5);
  static TextStyle get statValor =>
      serif(size: 28, weight: 600, tabular: true);
  static TextStyle get kpiValor =>
      serif(size: 28, weight: 600, letterSpacing: -0.5, height: 1, tabular: true);
  static TextStyle get authTitle => serif(size: 26, weight: 600);
  static TextStyle get saludo => serif(size: 24, weight: 500);
  static TextStyle get cfValor =>
      serif(size: 22, weight: 600, letterSpacing: -0.3, tabular: true);
  static TextStyle get modalTitulo => serif(size: 20, weight: 600);
  static TextStyle get hdrNombre => serif(size: 18, weight: 600);
  static TextStyle get precio => serif(size: 17, weight: 600, tabular: true);

  // — Interfaz (Inter) —
  static TextStyle get btnPrimario =>
      sans(size: 15, weight: 600, color: MColors.tWhite);
  static TextStyle get btnGoogle => sans(size: 15, weight: 600);
  static TextStyle get cuerpo => sans(size: 14);
  static TextStyle get cuerpoSec =>
      sans(size: 13, color: MColors.tSecondary, height: 1.6);
  static TextStyle get chip => sans(size: 13, weight: 500);
  static TextStyle get menor => sans(size: 12, color: MColors.tMuted);
  static TextStyle get pill =>
      sans(size: 12, weight: 500, color: MColors.tSecondary);

  /// Labels en mayúscula. El tracking cambia según el contexto — está en
  /// `02-DESIGN-SYSTEM.md` §2.3.
  static TextStyle label(double tracking, {Color? color}) => sans(
        size: 11,
        weight: 600,
        color: color ?? MColors.tMuted,
        letterSpacing: tracking,
      );

  static TextStyle get authTag => label(2.5);
  static TextStyle get splashSub => sans(
      size: 11, weight: 500, color: MColors.tMuted, letterSpacing: 2.5);
  static TextStyle get secLabel => label(1.2);
  static TextStyle get pie =>
      sans(size: 11, color: MColors.tMuted, height: 1.5);
}
