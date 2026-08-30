/// Quién entra al salón y con qué rol.
///
/// Hasta que existió esta pantalla, aprobar a alguien había que hacerlo por
/// SQL: la persona bajaba la app, pedía acceso, y quedaba en "pendiente" sin
/// que nadie del salón pudiera destrabarlo.
///
/// Lee y escribe directo contra Supabase, como `admin/platform_screen.dart`:
/// `tenant_members` es configuración de plataforma, no vive en Drift ni pasa
/// por el outbox. La policy `members_manage` ya deja que un owner o un admin
/// opere sobre su propio salón.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/motion.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../data/remote/access_mappers.dart';
import '../../data/remote/supabase_client.dart';
import '../../domain/entities/access.dart';
import '../admin/invite_screen.dart';
import '../auth/session_controller.dart';
import '../shell/vistas_comunes.dart';

/// Un miembro tal como lo muestra la pantalla.
class MiembroDelSalon {
  const MiembroDelSalon({
    required this.userId,
    required this.rol,
    required this.estado,
    this.email,
    this.nombre,
  });

  final String userId;
  final MiembroRol rol;
  final MiembroEstado estado;
  final String? email;
  final String? nombre;

  String get comoSeLlama =>
      (nombre?.trim().isNotEmpty ?? false) ? nombre!.trim() : (email ?? '—');
  String get inicial =>
      comoSeLlama.isEmpty ? '?' : comoSeLlama.characters.first.toUpperCase();
}

final equipoProvider =
    FutureProvider.autoDispose<List<MiembroDelSalon>>((ref) async {
  final tenant = ref.watch(tenantActivoProvider);
  if (tenant == null) return const [];

  // El join trae el perfil: sin eso la lista serían UUIDs, que no le dicen
  // nada a nadie.
  final filas = await sb
      .from('tenant_members')
      .select('user_id, rol, estado, profiles(email, nombre)')
      .eq('tenant_id', tenant.id) as List;

  return filas.map((f) {
    final row = f as Map<String, dynamic>;
    final perfil = row['profiles'] as Map<String, dynamic>?;
    return MiembroDelSalon(
      userId: row['user_id'] as String,
      rol: rolDesdeTexto(row['rol'] as String?),
      estado: estadoMiembroDesdeTexto(row['estado'] as String?),
      email: perfil?['email'] as String?,
      nombre: perfil?['nombre'] as String?,
    );
  }).toList()
    // Los pendientes primero: son los que piden una decisión.
    ..sort((a, b) {
      final pa = a.estado == MiembroEstado.pending ? 0 : 1;
      final pb = b.estado == MiembroEstado.pending ? 0 : 1;
      if (pa != pb) return pa - pb;
      return a.comoSeLlama.toLowerCase().compareTo(b.comoSeLlama.toLowerCase());
    });
});

/// Qué hace cada rol, en una línea. Es lo que se lee al elegir.
const _queHace = {
  MiembroRol.owner: 'La dueña. Puede todo, incluso borrar el salón.',
  MiembroRol.admin: 'Todo menos borrar el salón.',
  MiembroRol.encargado:
      'Maneja el negocio: caja, tienda e insumos. No toca usuarios ni ajustes.',
  MiembroRol.profesional: 'Atiende: turnos y clientas. Nada más.',
  MiembroRol.lectura: 'Solo mira. No puede cambiar nada.',
};

const _comoSeLlama = {
  MiembroRol.owner: 'Dueña',
  MiembroRol.admin: 'Administradora',
  MiembroRol.encargado: 'Encargada',
  MiembroRol.profesional: 'Profesional',
  MiembroRol.lectura: 'Solo lectura',
};

Future<void> mostrarEquipo(BuildContext context) => showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const _Equipo(),
    );

class _Equipo extends ConsumerWidget {
  const _Equipo();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final equipo = ref.watch(equipoProvider);
    final yo = sb.auth.currentUser?.id;

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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Equipo', style: serif(size: 22, weight: 600)),
            const SizedBox(height: 4),
            Text(
              'Quién entra al salón y qué puede hacer',
              style: sans(size: 13, color: MColors.tSecondary),
            ),
            const SizedBox(height: 18),
            Flexible(
              child: equipo.when(
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 30),
                  child: Text(
                    'No se pudo traer el equipo. Fijate si tenés internet.',
                    style: sans(size: 13, color: MColors.tSecondary),
                    textAlign: TextAlign.center,
                  ),
                ),
                data: (lista) => lista.isEmpty
                    ? const EstadoVacio(
                        emoji: '👥',
                        titulo: 'Todavía estás sola',
                        detalle: 'Invitá a alguien desde el botón de abajo.',
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        itemCount: lista.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (_, i) => FadeSlideIn(
                          delay: Duration(milliseconds: 30 * i),
                          child: _Fila(
                            miembro: lista[i],
                            esUnoMismo: lista[i].userId == yo,
                          ),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 14),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(MaterialPageRoute<void>(
                  builder: (_) => const InviteScreen(),
                ));
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: MColors.brand,
                  borderRadius: BorderRadius.circular(MRadius.full),
                ),
                child: Text('Invitar a alguien',
                    style: sans(
                        size: 13, weight: 600, color: MColors.tWhite)),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Que escanee el código, baje la app y pida acceso. Acá te aparece '
              'para aprobarla.',
              style: sans(size: 11, color: MColors.tMuted),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _Fila extends ConsumerWidget {
  const _Fila({required this.miembro, required this.esUnoMismo});

  final MiembroDelSalon miembro;
  final bool esUnoMismo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendiente = miembro.estado == MiembroEstado.pending;
    final bloqueado = miembro.estado == MiembroEstado.blocked;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: pendiente ? MColors.warningBg : MColors.bg2,
        border: Border.all(
          color: pendiente ? MColors.warningBorder : MColors.border,
        ),
        borderRadius: BorderRadius.circular(MRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: bloqueado ? MColors.bg3 : MColors.brand,
                  borderRadius: BorderRadius.circular(MRadius.full),
                ),
                child: Text(
                  miembro.inicial,
                  style: serif(
                    size: 17,
                    color: bloqueado ? MColors.tMuted : MColors.tWhite,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      miembro.comoSeLlama + (esUnoMismo ? ' (vos)' : ''),
                      style: sans(size: 14, weight: 600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      bloqueado
                          ? 'Bloqueada'
                          : pendiente
                              ? 'Está esperando que la apruebes'
                              : _comoSeLlama[miembro.rol]!,
                      style: sans(size: 12, color: MColors.tSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),

          // La dueña no se puede degradar ni bloquear a sí misma: es la forma
          // de quedarse afuera del propio salón sin poder volver a entrar.
          if (!esUnoMismo) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _BotonChico(
                    texto: pendiente ? 'Aprobar' : 'Cambiar rol',
                    principal: pendiente,
                    onTap: () => _elegirRol(context, ref),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _BotonChico(
                    texto: bloqueado ? 'Desbloquear' : 'Bloquear',
                    onTap: () => _cambiar(
                      context,
                      ref,
                      estado: bloqueado
                          ? MiembroEstado.approved
                          : MiembroEstado.blocked,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _elegirRol(BuildContext context, WidgetRef ref) async {
    final rol = await showModalBottomSheet<MiembroRol>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: MColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(MRadius.xl)),
        ),
        padding: const EdgeInsets.fromLTRB(22, 18, 22, 24),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('¿Qué va a poder hacer?',
                  style: serif(size: 20, weight: 600)),
              const SizedBox(height: 14),
              // `owner` no se ofrece: el salón tiene una dueña y transferirlo
              // es otra operación, no un cambio de rol.
              for (final r in [
                MiembroRol.admin,
                MiembroRol.encargado,
                MiembroRol.profesional,
                MiembroRol.lectura,
              ])
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => Navigator.of(ctx).pop(r),
                    child: Container(
                      padding: const EdgeInsets.all(13),
                      decoration: BoxDecoration(
                        color: miembro.rol == r ? MColors.lav50 : MColors.bg2,
                        border: Border.all(
                          color: miembro.rol == r
                              ? MColors.brand
                              : MColors.border,
                        ),
                        borderRadius: BorderRadius.circular(MRadius.md),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_comoSeLlama[r]!,
                              style: sans(size: 14, weight: 600)),
                          const SizedBox(height: 3),
                          Text(_queHace[r]!,
                              style:
                                  sans(size: 12, color: MColors.tSecondary)),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
    if (rol == null || !context.mounted) return;
    await _cambiar(context, ref, rol: rol, estado: MiembroEstado.approved);
  }

  Future<void> _cambiar(
    BuildContext context,
    WidgetRef ref, {
    MiembroRol? rol,
    MiembroEstado? estado,
  }) async {
    final tenant = ref.read(tenantActivoProvider);
    if (tenant == null) return;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await sb.from('tenant_members').update({
        if (rol != null) 'rol': rol.name,
        if (estado != null) 'estado': estado.name,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      }).match({'tenant_id': tenant.id, 'user_id': miembro.userId});
      ref.invalidate(equipoProvider);
      messenger.showSnackBar(const SnackBar(content: Text('Listo')));
    } catch (_) {
      messenger.showSnackBar(const SnackBar(
        content: Text('No se pudo. Fijate si tenés internet.'),
      ));
    }
  }
}

class _BotonChico extends StatelessWidget {
  const _BotonChico({
    required this.texto,
    required this.onTap,
    this.principal = false,
  });

  final String texto;
  final VoidCallback onTap;
  final bool principal;

  @override
  Widget build(BuildContext context) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 11),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: principal ? MColors.brand : MColors.surface,
            border: Border.all(
                color: principal ? MColors.brand : MColors.borderMd),
            borderRadius: BorderRadius.circular(MRadius.full),
          ),
          child: Text(
            texto,
            style: sans(
              size: 12,
              weight: 600,
              color: principal ? MColors.tWhite : MColors.tSecondary,
            ),
          ),
        ),
      );
}
