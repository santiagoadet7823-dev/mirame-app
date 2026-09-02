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
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/config/app_config.dart';
import '../ropa/mi_tienda.dart';
import '../update/update_sheet.dart';
import 'backup_view.dart';
import 'restaurar_backup.dart';
import '../../domain/rules/access.dart';
import 'catalogo.dart';
import 'equipo_view.dart';

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

        // El link de la tienda va ACÁ y no solo dentro de Ropa: es lo que se
        // manda por WhatsApp varias veces por día, y buscarlo dos pantallas
        // adentro cada vez es exactamente el tipo de fricción que hace que se
        // deje de usar.
        FadeSlideIn(
          delay: const Duration(milliseconds: 60),
          child: _LinkTienda(slug: tenant?.slug),
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
              // Cinco esperando señal se resuelven solas; cinco rechazadas por
              // el servidor no se resuelven nunca. Con un solo número se veían
              // igual, y un alta trabada pasó un día entero sin que se notara.
              if (sync.trabados > 0)
                (
                  'Trabados',
                  '${sync.trabados} '
                      '${sync.trabados == 1 ? "cambio" : "cambios"} '
                      'que el servidor rechazó'
                ),
              (
                'Última vez',
                sync.ultimoOk == null
                    ? 'Todavía no'
                    : _hora(sync.ultimoOk!),
              ),
              // El texto del error, no solo "con problemas". Sin esto, dar
              // soporte a distancia es adivinar.
              if (sync.error case final e?) ('Detalle', e),
            ],
            accion: Row(
              children: [
                TextButton.icon(
                  onPressed: () =>
                      ref.read(syncProvider.notifier).sincronizar(),
                  icon: const Icon(Icons.sync_rounded,
                      size: 16, color: MColors.brand),
                  label: Text(
                    'Sincronizar',
                    style: sans(size: 13, weight: 600, color: MColors.brand),
                  ),
                ),
                // Un sync normal solo pide lo NUEVO. Si un dispositivo quedó
                // con datos a medias, hay que pedir todo otra vez, y sin esto
                // la única salida era desinstalar.
                TextButton.icon(
                  onPressed: () =>
                      ref.read(syncProvider.notifier).resincronizarTodo(),
                  icon: const Icon(Icons.cloud_download_outlined,
                      size: 16, color: MColors.tMuted),
                  label: Text(
                    'Bajar todo',
                    style: sans(size: 13, weight: 600, color: MColors.tMuted),
                  ),
                ),
                // Una fila que agotó sus intentos queda fuera del push para
                // siempre. Sin este botón, arreglar la causa del rechazo no
                // alcanzaba: la única salida era borrar los datos de la app.
                if (sync.trabados > 0)
                  TextButton.icon(
                    onPressed: () =>
                        ref.read(syncProvider.notifier).reintentarTrabados(),
                    icon: const Icon(Icons.refresh_rounded,
                        size: 16, color: MColors.dangerText),
                    label: Text(
                      'Reintentar',
                      style: sans(
                          size: 13, weight: 600, color: MColors.dangerText),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Catálogo: es lo que se toca al abrir el salón y después casi nunca,
        // así que va como dos accesos y no como dos listas desplegadas.
        FadeSlideIn(
          delay: const Duration(milliseconds: 100),
          child: Builder(
            // DOS por fila, no cuatro. Con cuatro cada tarjeta queda en
            // ~80 px y "Profesionales" o "Guardar backup" no entran: el texto
            // se corta y las tarjetas parecen de tamaños distintos.
            builder: (ctx) => Column(
              children: [
                Row(
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
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _Acceso(
                        emoji: '💾',
                        titulo: 'Guardar backup',
                        onTap: () => exportarBackup(ctx, ref),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _Acceso(
                        emoji: '📥',
                        titulo: 'Restaurar',
                        onTap: () => restaurarBackup(ctx, ref),
                      ),
                    ),
                  ],
                ),
                if (ref.watch(puedeProvider(Permiso.gestionarUsuarios))) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _Acceso(
                          emoji: '👥',
                          titulo: 'Equipo',
                          onTap: () => mostrarEquipo(ctx),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(child: SizedBox()),
                    ],
                  ),
                ],
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
  int _agendados = 0;

  @override
  void initState() {
    super.initState();
    _refrescar();
  }

  Future<void> _refrescar() async {
    await ServicioAvisos.instancia.refrescarPermiso();
    final n = await ServicioAvisos.instancia.cuantosAgendados();
    if (mounted) setState(() => _agendados = n);
  }

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
        // "0 agendados" con el permiso dado significa que no había nada que
        // avisar, no que estén rotas. Son dos problemas muy distintos y sin
        // este número no se pueden separar.
        ('Agendados', '$_agendados'),
        // Se muestra aunque no esté configurado: es la primera pregunta al
        // dar soporte cuando alguien dice "no me llega nada".
        ('Push', Push.instancia.disponible ? 'Conectado' : 'No configurado'),
      ],
      accion: !servicio.disponible
          ? null
          : Row(
              children: [
                if (!servicio.permitido)
                  TextButton.icon(
                    onPressed: () async {
                      await servicio.pedirPermiso();
                      await _refrescar();
                    },
                    icon: const Icon(Icons.notifications_active_outlined,
                        size: 16, color: MColors.brand),
                    label: Text(
                      'Activar',
                      style:
                          sans(size: 13, weight: 600, color: MColors.brand),
                    ),
                  ),
                TextButton.icon(
                  onPressed: () async {
                    await servicio.probar();
                    await _refrescar();
                  },
                  icon: const Icon(Icons.play_arrow_rounded,
                      size: 16, color: MColors.tMuted),
                  label: Text(
                    'Probar aviso',
                    style: sans(size: 13, weight: 600, color: MColors.tMuted),
                  ),
                ),
              ],
            ),
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
              // Centrado y a dos líneas: "Guardar backup" no entra en una sola
              // en pantallas angostas, y cortarlo se ve peor que envolverlo.
              Text(
                titulo,
                textAlign: TextAlign.center,
                maxLines: 2,
                style: sans(size: 12, weight: 500),
              ),
            ],
          ),
        ),
      );
}

/// El link de la vitrina, listo para copiar o compartir.
class _LinkTienda extends StatelessWidget {
  const _LinkTienda({required this.slug});

  final String? slug;

  @override
  Widget build(BuildContext context) {
    final url = AppConfig.urlTienda(slug);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MColors.lav50,
        border: Border.all(color: MColors.borderLav),
        borderRadius: BorderRadius.circular(MRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🛍️', style: TextStyle(fontSize: 17)),
              const SizedBox(width: 8),
              Text('Mi tienda', style: sans(size: 14, weight: 600)),
              const Spacer(),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => mostrarMiTienda(context),
                child: Text('Ver QR',
                    style:
                        sans(size: 12, weight: 600, color: MColors.brand)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text('El link que les mandás a tus clientas',
              style: sans(size: 11, color: MColors.tSecondary)),
          const SizedBox(height: 11),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
            decoration: BoxDecoration(
              color: MColors.surface,
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
                child: _MiniBoton(
                  icono: Icons.share_outlined,
                  texto: 'Compartir',
                  principal: true,
                  onTap: () => SharePlus.instance.share(
                      ShareParams(text: 'Mirá lo que tengo 👗\n$url')),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MiniBoton(
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

class _MiniBoton extends StatelessWidget {
  const _MiniBoton({
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
          padding: const EdgeInsets.symmetric(vertical: 11),
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
                  size: 14,
                  color: principal ? MColors.tWhite : MColors.tSecondary),
              const SizedBox(width: 6),
              Text(texto,
                  style: sans(
                    size: 12,
                    weight: 600,
                    color: principal ? MColors.tWhite : MColors.tSecondary,
                  )),
            ],
          ),
        ),
      );
}
