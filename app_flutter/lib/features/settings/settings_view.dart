/// Ajustes. Por ahora, lo operativo: estado del sync, versión y sesión.
///
/// Servicios, profesionales y datos del salón llegan con el resto de la
/// Fase 5. Se construye esta parte primero porque es la que se necesita para
/// dar soporte: saber qué versión tiene alguien y si sus datos subieron.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/notificaciones/push.dart';
import '../../core/notificaciones/servicio_avisos.dart';
import '../../core/theme/motion.dart';
import '../../core/theme/shadows.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../data/sync/sync_engine.dart';
import '../../shared/widgets/version_label.dart';
import '../auth/session_controller.dart';
import '../shell/app_shell.dart';
import '../update/update_sheet.dart';
import 'backup_view.dart';
import 'catalogo.dart';

class SettingsView extends ConsumerWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tenant = ref.watch(tenantActivoProvider);
    final sync = ref.watch(syncProvider);

    return ListView(
      padding: padVistaMovil,
      children: [
        FadeSlideIn(
          child: Text('Ajustes', style: serif(size: 24, weight: 500)),
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
        const SizedBox(height: 12),

        // Catálogo: es lo que se toca al abrir el salón y después casi nunca,
        // así que va como dos accesos y no como dos listas desplegadas.
        FadeSlideIn(
          delay: const Duration(milliseconds: 100),
          child: Builder(
            builder: (ctx) => Row(
              children: [
                Expanded(
                  child: _Acceso(
                    emoji: '💅',
                    titulo: 'Servicios',
                    onTap: () => mostrarServicios(ctx),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _Acceso(
                    emoji: '👩',
                    titulo: 'Profesionales',
                    onTap: () => mostrarProfesionales(ctx),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _Acceso(
                    emoji: '💾',
                    titulo: 'Backup',
                    onTap: () => exportarBackup(ctx, ref),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        FadeSlideIn(
          delay: const Duration(milliseconds: 130),
          child: const _TarjetaAvisos(),
        ),
        const SizedBox(height: 26),

        FadeSlideIn(
          delay: const Duration(milliseconds: 140),
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
          borderRadius: BorderRadius.circular(MRadius.lg),
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

/// Estado de las notificaciones, con el botón para activarlas si se dijo que
/// no la primera vez.
class _TarjetaAvisos extends StatefulWidget {
  const _TarjetaAvisos();

  @override
  State<_TarjetaAvisos> createState() => _TarjetaAvisosState();
}

class _TarjetaAvisosState extends State<_TarjetaAvisos> {
  @override
  Widget build(BuildContext context) {
    final servicio = ServicioAvisos.instancia;

    return _Tarjeta(
      titulo: 'Avisos',
      filas: [
        (
          'Notificaciones',
          !servicio.disponible
              ? 'No disponibles acá'
              : servicio.permitido
                  ? 'Activadas'
                  : 'Desactivadas'
        ),
        // Se muestra aunque no esté configurado: es la primera pregunta al
        // dar soporte cuando alguien dice "no me llega nada".
        ('Push', Push.instancia.disponible ? 'Conectado' : 'No configurado'),
      ],
      accion: servicio.disponible && !servicio.permitido
          ? TextButton.icon(
              onPressed: () async {
                await servicio.pedirPermiso();
                if (mounted) setState(() {});
              },
              icon: const Icon(Icons.notifications_active_outlined,
                  size: 16, color: MColors.brand),
              label: Text(
                'Activar avisos',
                style: sans(size: 13, weight: 600, color: MColors.brand),
              ),
            )
          : null,
    );
  }
}

/// Tarjeta cuadrada de acceso, con el mismo aire que las de export de Stats.
class _Acceso extends StatelessWidget {
  const _Acceso({
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
