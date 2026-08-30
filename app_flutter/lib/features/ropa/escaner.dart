/// Escanear el código de barras de un producto.
///
/// Sirve para dos cosas distintas: cargar una prenda usando su código de
/// fábrica, y encontrarla después apuntando la cámara en vez de tipear.
library;

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';

/// Abre la cámara y devuelve el primer código que lea, o `null` si se cancela.
Future<String?> escanearCodigo(BuildContext context) =>
    Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const _Escaner(), fullscreenDialog: true),
    );

class _Escaner extends StatefulWidget {
  const _Escaner();

  @override
  State<_Escaner> createState() => _EscanerState();
}

class _EscanerState extends State<_Escaner> {
  final _control = MobileScannerController(
    // Solo los formatos que trae un producto real. Restringirlos hace que
    // enfoque más rápido y que no lea por error un QR pegado al lado.
    formats: const [
      BarcodeFormat.ean13,
      BarcodeFormat.ean8,
      BarcodeFormat.upcA,
      BarcodeFormat.upcE,
      BarcodeFormat.code128,
      BarcodeFormat.qrCode,
    ],
    detectionSpeed: DetectionSpeed.noDuplicates,
  );

  /// La cámara sigue leyendo mientras se cierra la pantalla y dispararía el
  /// `pop` varias veces. Sin esta guarda, el segundo cierra la pantalla que
  /// está debajo.
  var _yaLeyo = false;

  @override
  void dispose() {
    _control.dispose();
    super.dispose();
  }

  void _detectado(BarcodeCapture captura) {
    if (_yaLeyo) return;
    final codigo = captura.barcodes
        .map((b) => b.rawValue)
        .firstWhere((v) => v != null && v.trim().isNotEmpty, orElse: () => null);
    if (codigo == null) return;

    _yaLeyo = true;
    Navigator.of(context).pop(codigo.trim());
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 0,
          title: Text('Escanear código',
              style: sans(size: 15, weight: 600, color: MColors.tWhite)),
          actions: [
            IconButton(
              onPressed: () => _control.toggleTorch(),
              icon: const Icon(Icons.flashlight_on_outlined),
              tooltip: 'Linterna',
            ),
          ],
        ),
        body: Stack(
          children: [
            MobileScanner(controller: _control, onDetect: _detectado),

            // La mira: sin una referencia visual la gente acerca demasiado el
            // teléfono y el lector no enfoca.
            Center(
              child: Container(
                width: 250,
                height: 160,
                decoration: BoxDecoration(
                  border: Border.all(color: MColors.tWhite, width: 2),
                  borderRadius: BorderRadius.circular(MRadius.md),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 42,
              child: Text(
                'Apuntá al código de barras',
                textAlign: TextAlign.center,
                style: sans(size: 13, color: MColors.tWhite),
              ),
            ),
          ],
        ),
      );
}
