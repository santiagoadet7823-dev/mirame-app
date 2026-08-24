/// `ThemeData` de la app.
///
/// La app es **solo modo claro**, igual que el `index.html`. No es una omisión:
/// la paleta original no tiene contraparte oscura, y una inversión automática
/// arruinaría los gradientes lavanda→nude. Si se quiere modo oscuro hace falta
/// mapear los ~40 tokens a mano (está pedido en `11-BRIEF-DISENADOR.md` §4.6).
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'tokens.dart';
import 'typography.dart';

ThemeData buildMirameTheme() {
  const scheme = ColorScheme.light(
    primary: MColors.brand,
    onPrimary: MColors.tWhite,
    secondary: MColors.nude400,
    onSecondary: MColors.tWhite,
    surface: MColors.surface,
    onSurface: MColors.tPrimary,
    error: MColors.dangerText,
    onError: MColors.tWhite,
    outline: MColors.borderMd,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: MColors.bg,
    fontFamily: MType.sans,

    // El original no tiene ripple de Material: los toques responden con una
    // escala (`transform: scale(.97)`). Se quita acá y se replica por widget.
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,

    textTheme: TextTheme(
      displayLarge: MText.kpiHero,
      headlineLarge: MText.authName,
      headlineMedium: MText.authTitle,
      titleLarge: MText.modalTitulo,
      bodyLarge: MText.cuerpo,
      bodyMedium: MText.cuerpoSec,
      labelLarge: MText.chip,
      labelSmall: MText.secLabel,
    ),

    appBarTheme: AppBarTheme(
      backgroundColor: MColors.bg,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: MText.hdrNombre,
      systemOverlayStyle: SystemUiOverlayStyle.dark.copyWith(
        // `theme-color` del manifest original.
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: MColors.bg,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    ),

    // `.fi` del CSS: fondo bg2, radio 14, y al enfocar borde lav-300 sobre
    // fondo lav-50.
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: MColors.bg2,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      hintStyle: MText.cuerpo.copyWith(color: MColors.tLight),
      border: _borde(MColors.border),
      enabledBorder: _borde(MColors.border),
      focusedBorder: _borde(MColors.lav300),
      errorBorder: _borde(MColors.dangerBorder),
      focusedErrorBorder: _borde(MColors.dangerBorder),
    ),

    dividerTheme: const DividerThemeData(
      color: MColors.border,
      thickness: 1,
      space: 1,
    ),

    // Los toques de la app vibran suave, como el `navigator.vibrate(6)` del
    // original.
    pageTransitionsTheme: const PageTransitionsTheme(builders: {
      TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
    }),
  );
}

OutlineInputBorder _borde(Color color) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(MRadius.md),
      borderSide: BorderSide(color: color),
    );
