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
import '../../data/repositories/access_repository.dart';
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

class _MiTienda extends ConsumerStatefulWidget {
  const _MiTienda();

  @override
  ConsumerState<_MiTienda> createState() => _MiTiendaState();
}

class _MiTiendaState extends ConsumerState<_MiTienda> {
  late final _tel = TextEditingController(
      text: ref.read(tenantActivoProvider)?.telefono ?? '');
  late final _dir = TextEditingController(
      text: ref.read(tenantActivoProvider)?.direccion ?? '');
  late final _ig = TextEditingController(
      text: ref.read(tenantActivoProvider)?.instagram ?? '');
  var _guardando = false;

  @override
  void dispose() {
    _tel.dispose();
    _dir.dispose();
    _ig.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    final tenant = ref.read(tenantActivoProvider);
    if (tenant == null) return;
    setState(() => _guardando = true);
    try {
      await const AccessRepository().guardarDatosPublicos(
        tenant.id,
        telefono: _tel.text,
        direccion: _dir.text,
        instagram: _ig.text,
      );
      // Sin esto el Tenant en memoria sigue con el teléfono viejo y la pantalla
      // mostraría el aviso de "falta el WhatsApp" recién guardado.
      await ref.read(sessionProvider.notifier).refrescar();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Datos guardados')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('No se pudo guardar. Fijate si tenés internet.')),
        );
      }
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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

              const SizedBox(height: 12),
              const EtiquetaSeccion('LO QUE SE VE EN LA TIENDA'),
              Text(
                'El WhatsApp es por donde te escriben; la dirección sale en '
                '"lo retirás". Sin el WhatsApp no tienen cómo contactarte.',
                style: sans(size: 12, color: MColors.tSecondary),
              ),
              const SizedBox(height: 10),
              CampoTexto(
                controlador: _tel,
                etiqueta: 'WhatsApp — con código de área, sin el 15',
                teclado: TextInputType.phone,
              ),
              CampoTexto(
                controlador: _dir,
                etiqueta: 'Dirección donde retiran',
              ),
              CampoTexto(
                controlador: _ig,
                etiqueta: 'Instagram (sin la arroba)',
              ),
              _Boton(
                icono: Icons.check_rounded,
                texto: _guardando ? 'Guardando…' : 'Guardar',
                principal: true,
                onTap: _guardando ? () {} : _guardar,
              ),
              const SizedBox(height: 4),
              if ((tenant?.telefono ?? '').trim().isEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    color: MColors.warningBg,
                    border: Border.all(color: MColors.warningBorder),
                    borderRadius: BorderRadius.circular(MRadius.sm),
                  ),
                  child: Text(
                    'Todavía no cargaste tu WhatsApp, así que en la tienda no '
                    'aparece el botón para escribirte.',
                    style: sans(size: 12, color: MColors.warningText),
                  ),
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
