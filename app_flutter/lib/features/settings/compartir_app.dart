/// Pasarle la app a otra persona: el link y el QR.
///
/// Esto ya existía — en `features/admin/invite_screen.dart`, con su QR y todo —
/// pero colgado del panel de plataforma: llegaba el superadmin y nadie más. La
/// dueña, que es justamente quien le pasa la app a su socia o a otra colega, no
/// tenía de dónde sacar el link.
///
/// El link va a `descargar.html` y **no** al `.apk` directo. Un `.apk` abierto
/// desde la cámara de un iPhone, o desde un navegador sin permiso de
/// instalación, es un callejón sin salida; la página funciona siempre y desde
/// ahí se elige. Tampoco lleva el slug del salón: esto es "bajate la app", no
/// "entrá a mi salón" — para eso está Equipo, que invita a alguien puntual.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/config/app_config.dart';
import '../../core/theme/shadows.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../shell/vistas_comunes.dart';

/// La tarjeta de Ajustes. [onQr] la deja testear sin abrir el sheet.
class TarjetaCompartirApp extends StatelessWidget {
  const TarjetaCompartirApp({super.key});

  @override
  Widget build(BuildContext context) {
    final url = AppConfig.urlInvitacion(null);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MColors.surface,
        border: Border.all(color: MColors.border),
        borderRadius: BorderRadius.circular(MRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('📲', style: TextStyle(fontSize: 17)),
              const SizedBox(width: 8),
              Text('Pasar la app', style: sans(size: 14, weight: 600)),
              const Spacer(),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => mostrarQrDeDescarga(context),
                child: Text(
                  'Ver QR',
                  style: sans(size: 12, weight: 600, color: MColors.brand),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Para que otra persona se la instale',
            style: sans(size: 11, color: MColors.tSecondary),
          ),
          const SizedBox(height: 11),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
            decoration: BoxDecoration(
              color: MColors.bg2,
              borderRadius: BorderRadius.circular(MRadius.sm),
            ),
            child: Text(
              url,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: sans(size: 11, color: MColors.tSecondary),
            ),
          ),
          const SizedBox(height: 9),
          Row(
            children: [
              Expanded(
                child: _Boton(
                  icono: Icons.share_outlined,
                  texto: 'Compartir',
                  principal: true,
                  // Texto y link, sin archivos: `SharePlus` con archivos no
                  // funciona en la PWA, pero compartir un link sí, en los dos
                  // lados.
                  onTap: () => SharePlus.instance.share(
                    ShareParams(
                      text: 'Te paso Mírame, la app con la que manejo el '
                          'salón 💅\n$url',
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _Boton(
                  icono: Icons.copy_rounded,
                  texto: 'Copiar',
                  onTap: () async {
                    await Clipboard.setData(ClipboardData(text: url));
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Link copiado')),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// El QR, para que lo escaneen acá mismo.
///
/// Es el caso de "estamos las dos en el mostrador": no hace falta mandar nada
/// por WhatsApp, apunta la cámara y listo.
Future<void> mostrarQrDeDescarga(BuildContext context) =>
    showAppSheet<void>(context, builder: (_) => const _HojaQr());

class _HojaQr extends StatelessWidget {
  const _HojaQr();

  @override
  Widget build(BuildContext context) {
    final url = AppConfig.urlInvitacion(null);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Que escanee este código', style: serif(size: 22, weight: 600)),
          const SizedBox(height: 6),
          Text(
            'Lo lleva a la página de descarga, y desde ahí elige Android o '
            'navegador.',
            textAlign: TextAlign.center,
            style: sans(size: 12.5, color: MColors.tSecondary),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(MRadius.xl),
              border: Border.all(color: MColors.border),
              boxShadow: MShadow.md,
            ),
            child: QrImageView(
              data: url,
              version: QrVersions.auto,
              size: 210,
              // Blanco y negro puro, igual que el QR de invitación: con los
              // colores de la marca baja el contraste y algunas cámaras dejan
              // de leerlo. La marca va alrededor, no adentro.
              backgroundColor: Colors.white,
              eyeStyle: const QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color: Colors.black,
              ),
              dataModuleStyle: const QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.square,
                color: Colors.black,
              ),
              // Corrección media: tolera un dedo encima o un reflejo sin
              // volverse ilegible.
              errorCorrectionLevel: QrErrorCorrectLevel.M,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            url,
            textAlign: TextAlign.center,
            style: sans(size: 11, color: MColors.tMuted),
          ),
        ],
      ),
    );
  }
}

/// Botón chico de la tarjeta. Es el mismo de los otros bloques de Ajustes; se
/// repite acá y no se comparte porque el de allá es privado del archivo y
/// hacerlo público solo para esto ataría dos pantallas sin motivo.
class _Boton extends StatelessWidget {
  const _Boton({
    required this.icono,
    required this.texto,
    required this.onTap,
    this.principal = false,
  });

  final IconData icono;
  final String texto;
  final VoidCallback onTap;
  final bool principal;

  @override
  Widget build(BuildContext context) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: principal ? MColors.brand : MColors.bg2,
            borderRadius: BorderRadius.circular(MRadius.full),
            border: Border.all(
              color: principal ? MColors.brand : MColors.border,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icono,
                size: 14,
                color: principal ? MColors.tWhite : MColors.tSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                texto,
                style: sans(
                  size: 12.5,
                  weight: 600,
                  color: principal ? MColors.tWhite : MColors.tSecondary,
                ),
              ),
            ],
          ),
        ),
      );
}
