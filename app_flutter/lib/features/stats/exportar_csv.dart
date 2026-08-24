/// Las dos tarjetas de export al pie de Estadísticas. Puerto de
/// `exportCajaCSV()` y `exportClientsCSV()`.
///
/// En la web el original hacía `URL.createObjectURL` + `a.click()`. En Android
/// eso no existe: el archivo se escribe en el directorio temporal de la app y
/// se entrega a la hoja de compartir del sistema, que es de donde la dueña lo
/// manda por WhatsApp o lo guarda en Drive.
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/theme/shadows.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../domain/rules/csv.dart';

/// Escribe el CSV y abre la hoja de compartir.
///
/// [origen] posiciona el menú en iPad; en Android se ignora, pero omitirlo
/// hace que `share_plus` lance ahí.
Future<void> compartirCsv(
  BuildContext context, {
  required String contenido,
  required String nombre,
}) async {
  final messenger = ScaffoldMessenger.maybeOf(context);
  final caja = context.findRenderObject() as RenderBox?;
  try {
    final dir = await getTemporaryDirectory();
    final archivo = File('${dir.path}/$nombre');
    await archivo.writeAsString(contenido);

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(archivo.path, mimeType: 'text/csv')],
        fileNameOverrides: [nombre],
        sharePositionOrigin:
            caja == null ? null : caja.localToGlobal(Offset.zero) & caja.size,
      ),
    );
  } catch (e) {
    debugPrint('csv: no se pudo exportar ($e)');
    messenger?.showSnackBar(
      const SnackBar(content: Text('No se pudo exportar el archivo')),
    );
  }
}

/// `.two-col` con dos `.card-p` centradas — el pie exacto del original.
class FilaExports extends StatelessWidget {
  const FilaExports({super.key, required this.onCaja, required this.onClientas});

  final VoidCallback onCaja;
  final VoidCallback onClientas;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(
            child: _TarjetaExport(
              emoji: '📊',
              titulo: 'Caja CSV',
              onTap: onCaja,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _TarjetaExport(
              emoji: '👥',
              titulo: 'Clientas CSV',
              onTap: onClientas,
            ),
          ),
        ],
      );
}

class _TarjetaExport extends StatelessWidget {
  const _TarjetaExport({
    required this.emoji,
    required this.titulo,
    required this.onTap,
  });

  final String emoji;
  final String titulo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: MColors.surface,
            borderRadius: BorderRadius.circular(MRadius.md),
            border: Border.all(color: MColors.border),
            boxShadow: MShadow.xs,
          ),
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(height: 6),
              Text(titulo, style: sans(size: 12, weight: 500)),
            ],
          ),
        ),
      );
}

/// Nombre del archivo con la fecha, como el original.
String nombreCsvCaja(DateTime hoy) => nombreArchivo('caja', hoy);

String nombreCsvClientas(DateTime hoy) => nombreArchivo('clientas', hoy);
