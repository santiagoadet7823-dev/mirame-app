/// Punto de entrada.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/config/app_config.dart';
import 'core/router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/tokens.dart';
import 'core/theme/typography.dart';
import 'data/remote/supabase_client.dart';
import 'features/update/update_sheet.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // La app es solo vertical, igual que el manifest original
  // (`orientation: portrait`).
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  try {
    await initSupabase();
  } catch (e) {
    // Un `--dart-define` olvidado no debe verse como un error de red críptico
    // tres pantallas más adelante.
    runApp(_ErrorDeArranque(mensaje: '$e'));
    return;
  }

  runApp(const ProviderScope(child: MirameApp()));
}

class MirameApp extends ConsumerWidget {
  const MirameApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => MaterialApp.router(
        title: 'Mírame Lash Studio',
        debugShowCheckedModeBanner: false,
        theme: buildMirameTheme(),
        routerConfig: ref.watch(routerProvider),
        // El aviso de version nueva se monta por encima de todo el arbol de
        // rutas, no dentro de una pantalla: tiene que poder aparecer sea cual
        // sea la vista activa.
        builder: (_, child) => UpdateGate(child: child ?? const SizedBox()),
      );
}

class _ErrorDeArranque extends StatelessWidget {
  const _ErrorDeArranque({required this.mensaje});

  final String mensaje;

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: MColors.bg,
          body: Padding(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('No se pudo iniciar', style: MText.authTitle),
                  const SizedBox(height: 12),
                  Text(
                    mensaje,
                    textAlign: TextAlign.center,
                    style: MText.cuerpoSec,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Flavor: ${AppConfig.flavor}',
                    style: MText.menor,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}
