/// Ajustes. Por ahora, lo operativo: estado del sync, versión y sesión.
///
/// Servicios, profesionales y datos del salón llegan con el resto de la
/// Fase 5. Se construye esta parte primero porque es la que se necesita para
/// dar soporte: saber qué versión tiene alguien y si sus datos subieron.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/motion.dart';
import '../../core/theme/shadows.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../data/sync/sync_engine.dart';
import '../../shared/widgets/version_label.dart';
import '../auth/session_controller.dart';
import '../update/update_sheet.dart';

class SettingsView extends ConsumerWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tenant = ref.watch(tenantActivoProvider);
    final sync = ref.watch(syncProvider);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 90),
      children: [
        FadeSlideIn(
          child: Text('Ajustes', style: serif(size: 28, weight: 600)),
        ),
        const SizedBox(height: 20),

        if (tenant != null)
          FadeSlideIn(
            delay: const Duration(milliseconds: 40),
            child: _Tarjeta(
              titulo: 'Salón',
              filas: [
                ('Nombre', tenant.nombre),
                ('Identificador', tenant.slug),
              ],
            ),
          ),
        const SizedBox(height: 12),

        FadeSlideIn(
          delay: const Duration(milliseconds: 80),
          child: _Tarjeta(
            titulo: 'Sincronización',
            filas: [
              (
                'Estado',
                switch (sync.estado) {
                  EstadoSync.sincronizando => 'Sincronizando…',
                  EstadoSync.sinRed => 'Sin conexión',
                  EstadoSync.error => 'Con problemas, reintentando',
                  EstadoSync.inactivo => 'Al día',
                }
              ),
              (
                'Sin subir',
                sync.pendientes == 0
                    ? 'Nada pendiente'
                    : '${sync.pendientes} '
                        '${sync.pendientes == 1 ? "cambio" : "cambios"}'
              ),
              (
                'Última vez',
                sync.ultimoOk == null
                    ? 'Todavía no'
                    : _hora(sync.ultimoOk!),
              ),
            ],
            accion: TextButton.icon(
              onPressed: () =>
                  ref.read(syncProvider.notifier).sincronizar(),
              icon: const Icon(Icons.sync_rounded,
                  size: 16, color: MColors.brand),
              label: Text(
                'Sincronizar ahora',
                style: sans(size: 13, weight: 600, color: MColors.brand),
              ),
            ),
          ),
        ),
        const SizedBox(height: 26),

        FadeSlideIn(
          delay: const Duration(milliseconds: 120),
          child: Column(
            children: [
              const BotonBuscarActualizacion(),
              const SizedBox(height: 2),
              const VersionLabel(),
              const SizedBox(height: 14),
              TextButton(
                onPressed: () =>
                    ref.read(sessionProvider.notifier).cerrarSesion(),
                child: Text(
                  'Cerrar sesión',
                  style: sans(
                      size: 13, weight: 500, color: MColors.dangerText),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static String _hora(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:'
      '${d.minute.toString().padLeft(2, '0')}';
}

class _Tarjeta extends StatelessWidget {
  const _Tarjeta({
    required this.titulo,
    required this.filas,
    this.accion,
  });

  final String titulo;
  final List<(String, String)> filas;
  final Widget? accion;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
        decoration: BoxDecoration(
          color: MColors.surface,
          borderRadius: BorderRadius.circular(MRadius.md),
          border: Border.all(color: MColors.border),
          boxShadow: MShadow.xs,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(titulo, style: sans(size: 14, weight: 600)),
            const SizedBox(height: 10),
            for (final (etiqueta, valor) in filas)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 96,
                      child: Text(etiqueta, style: MText.menor),
                    ),
                    Expanded(
                      child: Text(
                        valor,
                        style: sans(
                            size: 13,
                            weight: 500,
                            color: MColors.tSecondary),
                      ),
                    ),
                  ],
                ),
              ),
            if (accion != null) ...[
              const SizedBox(height: 2),
              Align(alignment: Alignment.centerLeft, child: accion!),
            ],
          ],
        ),
      );
}
