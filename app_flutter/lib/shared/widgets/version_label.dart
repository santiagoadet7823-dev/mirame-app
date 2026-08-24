/// Versión instalada, discreta al pie.
library;

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../core/theme/typography.dart';

/// Muestra `v1.0.1 (2)`.
///
/// Sale de `package_info_plus`, es decir del `versionName`/`versionCode` reales
/// del APK instalado — no de una constante en Dart, que se olvida de
/// actualizar y termina mintiendo justo cuando hace falta saber la verdad.
///
/// Va visible en el login y en el panel a propósito: cuando alguien reporta un
/// problema por WhatsApp, lo primero que hay que saber es qué versión tiene, y
/// pedirle que la busque en Ajustes de Android no funciona.
class VersionLabel extends StatelessWidget {
  const VersionLabel({super.key, this.prefijo = ''});

  final String prefijo;

  @override
  Widget build(BuildContext context) => FutureBuilder<PackageInfo>(
        future: PackageInfo.fromPlatform(),
        builder: (_, snap) {
          final info = snap.data;
          // Mientras carga no se reserva lugar con un texto vacío: el layout
          // saltaría al aparecer.
          if (info == null) return const SizedBox(height: 14);
          return Text(
            '$prefijo v${info.version} (${info.buildNumber})',
            style: MText.pie,
            textAlign: TextAlign.center,
          );
        },
      );
}
