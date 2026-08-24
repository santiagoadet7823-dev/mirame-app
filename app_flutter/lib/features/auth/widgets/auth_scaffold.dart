/// El armazón visual de las 5 pantallas de acceso.
///
/// Replica `.auth-screen` del CSS: fondo `--bg`, dos halos radiales
/// desenfocados en las esquinas opuestas, y el contenido centrado con
/// `max-width: 336px`.
library;

import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../../../core/theme/motion.dart';
import '../../../core/theme/shadows.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/theme/typography.dart';

class AuthScaffold extends StatelessWidget {
  const AuthScaffold({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: MColors.bg,
        body: Stack(
          children: [
            // `.auth-screen::before` — 340 px, lavanda al 16%, arriba a la izquierda.
            const _Halo(
              size: 340,
              top: -130,
              left: -120,
              color: Color(0x298B77EC),
            ),
            // `.auth-screen::after` — 380 px, nude al 15%, abajo a la derecha.
            const _Halo(
              size: 380,
              bottom: -150,
              right: -130,
              color: Color(0x26D4897A),
            ),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32, vertical: 40),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 336),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: children,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
}

class _Halo extends StatelessWidget {
  const _Halo({
    required this.size,
    required this.color,
    this.top,
    this.left,
    this.right,
    this.bottom,
  });

  final double size;
  final Color color;
  final double? top, left, right, bottom;

  @override
  Widget build(BuildContext context) => Positioned(
        top: top,
        left: left,
        right: right,
        bottom: bottom,
        child: IgnorePointer(
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                // `radial-gradient(circle, color 0%, transparent 70%)`
                gradient: RadialGradient(
                  colors: [color, color.withAlpha(0)],
                  stops: const [0, 0.7],
                ),
              ),
            ),
          ),
        ),
      );
}

/// Emblema circular con el monograma "M". `.auth-emblem` + `.auth-mono`.
class AuthEmblem extends StatelessWidget {
  const AuthEmblem({super.key});

  @override
  Widget build(BuildContext context) => Floating(
        child: FadeSlideIn(
          child: Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: MGradient.authEmblem,
              border: Border.all(color: MColors.borderLav, width: 1.5),
              boxShadow: MShadow.authEmblem,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // `.auth-emblem::after` — anillo interior a 7 px del borde.
                Positioned.fill(
                  child: Container(
                    margin: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0x8CFFFFFF)),
                    ),
                  ),
                ),
                Text('M', style: MText.authMono),
              ],
            ),
          ),
        ),
      );
}

/// Emoji grande de las pantallas de estado. `.auth-big` — 50 px, flotando.
class AuthBigEmoji extends StatelessWidget {
  const AuthBigEmoji(this.emoji, {super.key});

  final String emoji;

  @override
  Widget build(BuildContext context) => Floating(
        child: FadeSlideIn(
          duration: const Duration(milliseconds: 500),
          child: Text(
            emoji,
            style: const TextStyle(fontSize: 50, height: 1),
          ),
        ),
      );
}

/// `.auth-tag` — label en mayúscula con una línea a cada lado.
class AuthTag extends StatelessWidget {
  const AuthTag(this.texto, {super.key});

  final String texto;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _Rayita(),
          const SizedBox(width: 8),
          Text(texto.toUpperCase(), style: MText.authTag),
          const SizedBox(width: 8),
          const _Rayita(),
        ],
      );
}

class _Rayita extends StatelessWidget {
  const _Rayita();
  @override
  Widget build(BuildContext context) =>
      Container(width: 18, height: 1, color: MColors.borderMd);
}

/// `.auth-pill` — el email del solicitante, en una píldora.
class AuthPill extends StatelessWidget {
  const AuthPill(this.texto, {super.key});

  final String texto;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: MColors.surface,
          borderRadius: BorderRadius.circular(MRadius.full),
          border: Border.all(color: MColors.border),
          boxShadow: MShadow.xs,
        ),
        child: Text(texto, style: MText.pill),
      );
}

/// `.auth-error` — bloque rojo suave.
class AuthError extends StatelessWidget {
  const AuthError(this.mensaje, {super.key});

  final String mensaje;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: MColors.dangerBg,
          border: Border.all(color: MColors.dangerBorder),
          borderRadius: BorderRadius.circular(MRadius.md),
        ),
        child: Text(
          mensaje,
          textAlign: TextAlign.center,
          style: sans(size: 13, weight: 500, color: MColors.dangerText),
        ),
      );
}
