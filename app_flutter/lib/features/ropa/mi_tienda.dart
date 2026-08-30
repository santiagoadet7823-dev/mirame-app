/// El link de la vitrina, para mandárselo a las clientas.
///
/// Muestra también qué van a ver: cuántas prendas están publicadas y cuántas
/// no. Una tienda con dos prendas publicadas de cuarenta es el error más fácil
/// de cometer y el más difícil de notar, porque desde adentro el catálogo se
/// ve completo.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/config/app_config.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../auth/session_controller.dart';
import '../shell/vistas_comunes.dart';
import 'ropa_view.dart';

Future<void> mostrarMiTienda(BuildContext context) => showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const _MiTienda(),
    );

class _MiTienda extends ConsumerWidget {
  const _MiTienda();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tenant = ref.watch(tenantActivoProvider);
    final productos = ref.watch(productosProvider).value ?? const [];
    final publicados = productos.where((p) => p.publicado).length;
    final url = AppConfig.urlTienda(tenant?.slug);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.9,
      ),
      decoration: const BoxDecoration(
        color: MColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(MRadius.xl)),
      ),
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 24),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Mi tienda', style: serif(size: 22, weight: 600)),
              const SizedBox(height: 4),
              Text(
                'Mandales este link a tus clientas',
                style: sans(size: 13, color: MColors.tSecondary),
              ),
              const SizedBox(height: 18),

              // El QR sirve en el mostrador: se muestra la pantalla y la
              // clienta lo escanea, sin tener que pedirle el teléfono.
              Center(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: MColors.surface,
                    border: Border.all(color: MColors.border),
                    borderRadius: BorderRadius.circular(MRadius.md),
                  ),
                  child: QrImageView(
                    data: url,
                    size: 176,
                    backgroundColor: MColors.surface,
                    eyeStyle: const QrEyeStyle(
                      eyeShape: QrEyeShape.square,
                      color: MColors.tPrimary,
                    ),
                    dataModuleStyle: const QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.square,
                      color: MColors.tPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: MColors.bg2,
                  borderRadius: BorderRadius.circular(MRadius.sm),
                ),
                child: Text(
                  url,
                  textAlign: TextAlign.center,
                  style: sans(size: 12, color: MColors.tSecondary),
                ),
              ),
              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: _Boton(
                      icono: Icons.share_outlined,
                      texto: 'Compartir',
                      principal: true,
                      onTap: () => SharePlus.instance.share(ShareParams(
                        text: 'Mirá lo que tengo 👗\n$url',
                      )),
                    ),
                  ),
                  const SizedBox(width: 10),
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
              const SizedBox(height: 8),
              _Boton(
                icono: Icons.open_in_new_rounded,
                texto: 'Ver cómo la ven ellas',
                onTap: () => launchUrl(Uri.parse(url),
                    mode: LaunchMode.externalApplication),
              ),

              const SizedBox(height: 20),
              const EtiquetaSeccion('QUÉ SE VE'),
              _Dato(
                etiqueta: 'Prendas publicadas',
                valor: '$publicados',
                alerta: publicados == 0,
              ),
              _Dato(
                etiqueta: 'Sin publicar',
                valor: '${productos.length - publicados}',
              ),

              if (publicados == 0)
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    color: MColors.warningBg,
                    border: Border.all(color: MColors.warningBorder),
                    borderRadius: BorderRadius.circular(MRadius.sm),
                  ),
                  child: Text(
                    'Tu tienda está vacía. Entrá a una prenda y activá '
                    '"Mostrar en la tienda" para que las clientas la vean.',
                    style: sans(size: 12, color: MColors.warningText),
                  ),
                ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

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
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: principal ? MColors.brand : MColors.surface,
            border: Border.all(
                color: principal ? MColors.brand : MColors.borderMd),
            borderRadius: BorderRadius.circular(MRadius.full),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icono,
                  size: 16,
                  color: principal ? MColors.tWhite : MColors.tSecondary),
              const SizedBox(width: 7),
              Text(
                texto,
                style: sans(
                  size: 13,
                  weight: 600,
                  color: principal ? MColors.tWhite : MColors.tSecondary,
                ),
              ),
            ],
          ),
        ),
      );
}

class _Dato extends StatelessWidget {
  const _Dato({
    required this.etiqueta,
    required this.valor,
    this.alerta = false,
  });

  final String etiqueta;
  final String valor;
  final bool alerta;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 7),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(etiqueta, style: sans(size: 13, color: MColors.tSecondary)),
            Text(
              valor,
              style: sans(
                size: 15,
                weight: 700,
                color: alerta ? MColors.warningText : MColors.tPrimary,
              ),
            ),
          ],
        ),
      );
}
