/// Invitar a alguien: QR + link para descargar la app.
///
/// Reemplaza el "pasame el APK por WhatsApp". La persona escanea, cae en una
/// página que le ofrece las dos puertas —instalar el APK o abrir la PWA— y
/// después pide acceso desde adentro de la app.
///
/// El QR apunta a la PWA y no al `.apk` directo a propósito: un `.apk` abierto
/// desde la cámara de un iPhone o desde un navegador sin permiso de instalación
/// es un callejón sin salida. La página web funciona siempre y desde ahí se
/// elige.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/config/app_config.dart';
import '../../core/theme/motion.dart';
import '../../core/theme/shadows.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../auth/session_controller.dart';

class InviteScreen extends ConsumerWidget {
  const InviteScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tenant = ref.watch(tenantActivoProvider);
    // El slug viaja en la URL para que, cuando la persona entre, ya se sepa a
    // qué salón está pidiendo acceso y no haya que preguntárselo.
    final url = AppConfig.urlInvitacion(tenant?.slug);

    return Scaffold(
      backgroundColor: MColors.bg,
      appBar: AppBar(
        backgroundColor: MColors.bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text('Invitar', style: sans(size: 16, weight: 600)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 36),
          child: Column(
            children: [
              FadeSlideIn(
                child: Text(
                  'Que escanee este código',
                  style: MText.authTitle,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 8),
              FadeSlideIn(
                delay: const Duration(milliseconds: 60),
                child: Text(
                  tenant == null
                      ? 'Le va a ofrecer instalar la app o abrirla en el '
                          'navegador.'
                      : 'Va a poder pedir acceso a ${tenant.nombre}.',
                  textAlign: TextAlign.center,
                  style: MText.cuerpoSec,
                ),
              ),
              const SizedBox(height: 26),
              FadeSlideIn(
                delay: const Duration(milliseconds: 120),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: MColors.surface,
                    borderRadius: BorderRadius.circular(MRadius.xl),
                    border: Border.all(color: MColors.border),
                    boxShadow: MShadow.md,
                  ),
                  child: QrImageView(
                    data: url,
                    version: QrVersions.auto,
                    size: 218,
                    // Blanco y negro puro: un QR con los colores de la marca
                    // baja el contraste y algunas cámaras dejan de leerlo. La
                    // marca se pone alrededor, no adentro.
                    backgroundColor: Colors.white,
                    eyeStyle: const QrEyeStyle(
                      eyeShape: QrEyeShape.square,
                      color: Colors.black,
                    ),
                    dataModuleStyle: const QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.square,
                      color: Colors.black,
                    ),
                    // Con corrección media el código tolera un dedo encima o
                    // una pantalla sucia sin volverse ilegible.
                    errorCorrectionLevel: QrErrorCorrectLevel.M,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              FadeSlideIn(
                delay: const Duration(milliseconds: 180),
                child: _CajaLink(url: url),
              ),
              const SizedBox(height: 18),
              FadeSlideIn(
                delay: const Duration(milliseconds: 240),
                child: Row(
                  children: [
                    Expanded(
                      child: _Boton(
                        texto: 'Copiar link',
                        icono: Icons.link_rounded,
                        onTap: () async {
                          await Clipboard.setData(ClipboardData(text: url));
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Link copiado', style: MText.menor),
                              backgroundColor: MColors.surface,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _Boton(
                        texto: 'Compartir',
                        icono: Icons.ios_share_rounded,
                        principal: true,
                        onTap: () => SharePlus.instance.share(
                          ShareParams(
                            text: 'Te invito a usar Mírame'
                                '${tenant == null ? '' : ' en ${tenant.nombre}'}: '
                                '$url',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 26),
              FadeSlideIn(
                delay: const Duration(milliseconds: 300),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: MColors.brandBg,
                    borderRadius: BorderRadius.circular(MRadius.md),
                  ),
                  child: Text(
                    'Cuando entre por primera vez le va a aparecer "Solicitud '
                    'enviada". Tenés que aprobarla vos desde el panel; hasta '
                    'entonces no ve ningún dato del salón.',
                    style: MText.menor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CajaLink extends StatelessWidget {
  const _CajaLink({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          color: MColors.bg2,
          borderRadius: BorderRadius.circular(MRadius.md),
          border: Border.all(color: MColors.border),
        ),
        child: SelectableText(
          url,
          textAlign: TextAlign.center,
          style: sans(size: 13, weight: 500, color: MColors.tSecondary),
        ),
      );
}

class _Boton extends StatelessWidget {
  const _Boton({
    required this.texto,
    required this.icono,
    required this.onTap,
    this.principal = false,
  });

  final String texto;
  final IconData icono;
  final VoidCallback onTap;
  final bool principal;

  @override
  Widget build(BuildContext context) => PressableScale(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: principal ? MColors.brand : MColors.surface,
            borderRadius: BorderRadius.circular(MRadius.full),
            border: Border.all(
              color: principal ? MColors.brand : MColors.borderMd,
            ),
            boxShadow: principal ? MShadow.brand : MShadow.sm,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icono,
                size: 17,
                color: principal ? MColors.tWhite : MColors.tSecondary,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  texto,
                  overflow: TextOverflow.ellipsis,
                  style: sans(
                    size: 14,
                    weight: 600,
                    color: principal ? MColors.tWhite : MColors.tSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}
