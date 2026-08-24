/// Botones de las pantallas de acceso.
library;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/theme/motion.dart';
import '../../../core/theme/shadows.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/theme/typography.dart';

/// `.btn-google` — blanco, píldora, con el logo de 4 colores.
class GoogleButton extends StatelessWidget {
  const GoogleButton({super.key, this.onTap, this.cargando = false});

  final VoidCallback? onTap;
  final bool cargando;

  @override
  Widget build(BuildContext context) {
    final habilitado = onTap != null && !cargando;
    return Opacity(
      opacity: habilitado ? 1 : 0.65,
      child: PressableScale(
        onTap: habilitado ? onTap : null,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
          decoration: BoxDecoration(
            color: MColors.surface,
            border: Border.all(color: MColors.borderMd),
            borderRadius: BorderRadius.circular(MRadius.full),
            boxShadow: MShadow.sm,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (cargando)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: MColors.tMuted,
                  ),
                )
              else
                SvgPicture.asset('assets/icons/google.svg',
                    width: 18, height: 18),
              const SizedBox(width: 11),
              Flexible(
                child: Text(
                  cargando ? 'Conectando…' : 'Continuar con Google',
                  textAlign: TextAlign.center,
                  style: MText.btnGoogle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// `.auth-wa` — verde WhatsApp, con su logo.
class WhatsappButton extends StatelessWidget {
  const WhatsappButton({super.key, required this.texto, this.onTap});

  final String texto;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => PressableScale(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 13),
          decoration: BoxDecoration(
            color: MColors.whatsapp,
            borderRadius: BorderRadius.circular(MRadius.full),
            boxShadow: MShadow.whatsapp,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                'assets/icons/whatsapp.svg',
                width: 19,
                height: 19,
                colorFilter:
                    const ColorFilter.mode(MColors.tWhite, BlendMode.srcIn),
              ),
              const SizedBox(width: 9),
              // Flexible y no Text pelado: con la fuente del sistema escalada
              // por accesibilidad, o con una etiqueta más larga, el Row se
              // desborda. Un test de widget lo detectó antes de que llegara a
              // un teléfono.
              Flexible(
                child: Text(
                  texto,
                  textAlign: TextAlign.center,
                  style: sans(size: 14, weight: 600, color: MColors.tWhite),
                ),
              ),
            ],
          ),
        ),
      );
}

/// `.auth-ghost` — el "Cerrar sesión" de las pantallas de estado.
class GhostButton extends StatelessWidget {
  const GhostButton({super.key, required this.texto, this.onTap});

  final String texto;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => PressableScale(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 11),
          decoration: BoxDecoration(
            border: Border.all(color: MColors.borderMd),
            borderRadius: BorderRadius.circular(MRadius.full),
          ),
          child: Text(
            texto,
            textAlign: TextAlign.center,
            style: sans(size: 13, weight: 500, color: MColors.tSecondary),
          ),
        ),
      );
}

/// `.auth-foot` — candado + nota al pie del login.
class AuthFootnote extends StatelessWidget {
  const AuthFootnote(this.texto, {super.key});

  final String texto;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 3),
            child: SvgPicture.asset(
              'assets/icons/lock.svg',
              width: 11,
              height: 11,
              colorFilter:
                  const ColorFilter.mode(MColors.tLight, BlendMode.srcIn),
            ),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(texto,
                style: MText.pie, textAlign: TextAlign.center),
          ),
        ],
      );
}
