/// El comprobante de liquidación, en PDF.
///
/// Es el documento que se le manda al proveedor o al vendedor cuando se le
/// paga. Va **detallado prenda por prenda** a propósito: un papel que solo diga
/// "te debo $180.000" no sirve para lo único para lo que se usa un
/// comprobante, que es resolver una discusión sobre un número.
///
/// Se usa el paquete `pdf` solo, sin `printing`: este archivo se comparte por
/// WhatsApp, no se manda a una impresora, y `printing` arrastra un plugin
/// nativo por plataforma que no haría falta.
library;

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show BuildContext, RenderBox, Offset;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../../domain/rules/consignacion.dart';
import '../../domain/rules/formatting.dart';
import '../../domain/rules/period.dart';

/// La paleta de la marca, traducida a PDF. Los valores son los mismos tokens
/// del `index.html`, para que el comprobante se vea de la misma familia que la
/// app y no como un remito genérico.
const _lavanda = PdfColor.fromInt(0xFF8B77EC);
const _tinta = PdfColor.fromInt(0xFF1A1612);
const _gris = PdfColor.fromInt(0xFF5C5248);
const _grisClaro = PdfColor.fromInt(0xFF9C9088);
const _fondoSuave = PdfColor.fromInt(0xFFF5F3FF);
const _borde = PdfColor.fromInt(0xFFDDD6FB);

/// Arma el PDF y devuelve los bytes.
Future<Uint8List> construirLiquidacionPdf({
  required DetalleLiquidacion detalle,
  required String salon,
  required DateTime emitido,
}) async {
  final doc = pw.Document(
    title: 'Liquidación ${detalle.destinatario}',
    author: salon,
  );

  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.fromLTRB(38, 44, 38, 38),
      // El encabezado se repite en cada hoja: una liquidación de dos páginas
      // que en la segunda no dice de quién es se vuelve inútil apenas se
      // imprime y se sueltan las hojas.
      header: (ctx) => ctx.pageNumber == 1
          ? pw.SizedBox()
          : pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 14),
              child: pw.Text(
                '${detalle.destinatario} · '
                '${claveFecha(detalle.desde)} a ${claveFecha(detalle.hasta)}',
                style: pw.TextStyle(fontSize: 9, color: _grisClaro),
              ),
            ),
      footer: (ctx) => pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(salon,
              style: pw.TextStyle(fontSize: 8, color: _grisClaro)),
          pw.Text('Página ${ctx.pageNumber} de ${ctx.pagesCount}',
              style: pw.TextStyle(fontSize: 8, color: _grisClaro)),
        ],
      ),
      build: (ctx) => [
        _encabezado(detalle, salon, emitido),
        pw.SizedBox(height: 20),
        _resumen(detalle),
        pw.SizedBox(height: 20),
        _tabla(detalle),
        pw.SizedBox(height: 18),
        _pie(detalle),
      ],
    ),
  );

  return doc.save();
}

pw.Widget _encabezado(DetalleLiquidacion d, String salon, DateTime emitido) =>
    pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(salon,
                style: pw.TextStyle(
                    fontSize: 20,
                    color: _tinta,
                    fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 2),
            pw.Text('LIQUIDACIÓN',
                style: pw.TextStyle(
                    fontSize: 9, color: _lavanda, letterSpacing: 2)),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text('Emitido ${claveFecha(emitido)}',
                style: pw.TextStyle(fontSize: 9, color: _gris)),
            pw.SizedBox(height: 2),
            pw.Text(
                'Período ${claveFecha(d.desde)} — ${claveFecha(d.hasta)}',
                style: pw.TextStyle(fontSize: 9, color: _gris)),
          ],
        ),
      ],
    );

pw.Widget _resumen(DetalleLiquidacion d) => pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: _fondoSuave,
        border: pw.Border.all(color: _borde),
        borderRadius: pw.BorderRadius.circular(10),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(d.tipo.etiqueta.toUpperCase(),
                  style: pw.TextStyle(
                      fontSize: 8, color: _grisClaro, letterSpacing: 1)),
              pw.SizedBox(height: 3),
              pw.Text(d.destinatario,
                  style: pw.TextStyle(
                      fontSize: 15,
                      color: _tinta,
                      fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 6),
              pw.Text(d.tipo.concepto,
                  style: pw.TextStyle(fontSize: 9, color: _gris)),
              pw.Text(
                  '${d.prendas} ${d.prendas == 1 ? "prenda" : "prendas"} · '
                  '${d.filas.length} ${d.filas.length == 1 ? "venta" : "ventas"}',
                  style: pw.TextStyle(fontSize: 9, color: _gris)),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text('TOTAL A PAGAR',
                  style: pw.TextStyle(
                      fontSize: 8, color: _grisClaro, letterSpacing: 1)),
              pw.SizedBox(height: 3),
              pw.Text(formatMoney(d.total),
                  style: pw.TextStyle(
                      fontSize: 24,
                      color: _lavanda,
                      fontWeight: pw.FontWeight.bold)),
            ],
          ),
        ],
      ),
    );

pw.Widget _tabla(DetalleLiquidacion d) {
  pw.Widget celda(String t,
          {bool encabezado = false,
          pw.Alignment alineacion = pw.Alignment.centerLeft}) =>
      pw.Container(
        alignment: alineacion,
        padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        child: pw.Text(
          t,
          style: pw.TextStyle(
            fontSize: encabezado ? 8 : 9,
            color: encabezado ? _grisClaro : _tinta,
            fontWeight: encabezado ? pw.FontWeight.bold : pw.FontWeight.normal,
            letterSpacing: encabezado ? 0.6 : 0,
          ),
        ),
      );

  return pw.Table(
    border: pw.TableBorder(
      horizontalInside: pw.BorderSide(color: _borde, width: .5),
      bottom: pw.BorderSide(color: _borde, width: .5),
    ),
    columnWidths: const {
      0: pw.FlexColumnWidth(1.5), // fecha
      1: pw.FlexColumnWidth(1.2), // código
      2: pw.FlexColumnWidth(3.6), // prenda
      3: pw.FlexColumnWidth(0.7), // cantidad
      4: pw.FlexColumnWidth(1.6), // precio
      5: pw.FlexColumnWidth(0.8), // %
      6: pw.FlexColumnWidth(1.8), // monto
    },
    children: [
      pw.TableRow(
        decoration: const pw.BoxDecoration(
          border: pw.Border(bottom: pw.BorderSide(color: _lavanda, width: 1)),
        ),
        children: [
          celda('FECHA', encabezado: true),
          celda('CÓDIGO', encabezado: true),
          celda('PRENDA', encabezado: true),
          celda('CANT', encabezado: true, alineacion: pw.Alignment.center),
          celda('PRECIO',
              encabezado: true, alineacion: pw.Alignment.centerRight),
          celda('%', encabezado: true, alineacion: pw.Alignment.centerRight),
          celda('MONTO',
              encabezado: true, alineacion: pw.Alignment.centerRight),
        ],
      ),
      for (final f in d.filas)
        pw.TableRow(children: [
          celda(claveFecha(f.fecha)),
          celda(f.codigo ?? '—'),
          celda([f.prenda, if (f.variante?.isNotEmpty ?? false) f.variante!]
              .join('\n')),
          celda('${f.cantidad}', alineacion: pw.Alignment.center),
          celda(formatMoney(f.precioUnit),
              alineacion: pw.Alignment.centerRight),
          celda('${f.pct.round()}%', alineacion: pw.Alignment.centerRight),
          celda(formatMoney(f.monto), alineacion: pw.Alignment.centerRight),
        ]),
    ],
  );
}

pw.Widget _pie(DetalleLiquidacion d) => pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: pw.BoxDecoration(
            color: _fondoSuave,
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: pw.Row(mainAxisSize: pw.MainAxisSize.min, children: [
            pw.Text('TOTAL  ',
                style: pw.TextStyle(fontSize: 10, color: _gris)),
            pw.Text(formatMoney(d.total),
                style: pw.TextStyle(
                    fontSize: 15,
                    color: _tinta,
                    fontWeight: pw.FontWeight.bold)),
          ]),
        ),
        pw.SizedBox(height: 34),
        // Espacio de firma: en la práctica esto se imprime y se firma al
        // entregar la plata, y es lo que después evita el "yo no cobré".
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            _firma('Entregó'),
            pw.SizedBox(width: 30),
            _firma('Recibió conforme'),
          ],
        ),
      ],
    );

pw.Widget _firma(String rotulo) => pw.Expanded(
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(height: .5, color: _grisClaro),
          pw.SizedBox(height: 4),
          pw.Text(rotulo,
              style: pw.TextStyle(fontSize: 8, color: _grisClaro)),
        ],
      ),
    );

/// Nombre del archivo: `liquidacion-proveedor-2026-08-25.pdf`.
String nombreLiquidacion(DetalleLiquidacion d, DateTime emitido) =>
    'liquidacion-${d.tipo.name}-${claveFecha(emitido)}.pdf';

/// Genera el PDF y abre la hoja de compartir.
Future<void> compartirLiquidacion(
  BuildContext context, {
  required DetalleLiquidacion detalle,
  required String salon,
}) async {
  final caja = context.findRenderObject() as RenderBox?;
  final origen =
      caja == null ? null : caja.localToGlobal(Offset.zero) & caja.size;
  try {
    final ahora = DateTime.now();
    final bytes = await construirLiquidacionPdf(
      detalle: detalle,
      salon: salon,
      emitido: ahora,
    );
    final nombre = nombreLiquidacion(detalle, ahora);
    final archivo = File('${(await getTemporaryDirectory()).path}/$nombre');
    await archivo.writeAsBytes(bytes);

    await SharePlus.instance.share(ShareParams(
      files: [XFile(archivo.path, mimeType: 'application/pdf')],
      fileNameOverrides: [nombre],
      sharePositionOrigin: origen,
    ));
  } catch (e) {
    debugPrint('liquidacion: no se pudo generar el pdf ($e)');
    rethrow;
  }
}
