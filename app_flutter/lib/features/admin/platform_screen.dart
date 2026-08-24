/// Panel de plataforma: la lista de salones y la puerta de entrada a cada uno.
///
/// Solo lo ve un superadmin — no porque esta pantalla lo verifique, sino
/// porque `resolveAccess()` es el único que rutea acá. La seguridad real son
/// las RLS: un no-superadmin que llegara por URL vería una lista vacía.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/motion.dart';
import '../../core/theme/shadows.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../data/remote/supabase_client.dart';
import '../../shared/widgets/version_label.dart';
import '../auth/session_controller.dart';

/// Un salón tal como lo ve el panel, con lo necesario para decidir de un
/// vistazo: si opera, hasta cuándo, y cuánta gente tiene adentro.
class TenantResumen {
  const TenantResumen({
    required this.id,
    required this.nombre,
    required this.slug,
    required this.estado,
    required this.plan,
    this.venceAt,
    this.miembros = 0,
    this.esMiembro = false,
  });

  final String id;
  final String nombre;
  final String slug;
  final String estado;
  final String plan;
  final DateTime? venceAt;
  final int miembros;

  /// Si el superadmin además pertenece al salón, entra como tal (con permisos
  /// de escritura) y no queda auditado como acceso externo.
  final bool esMiembro;

  bool get operativo => estado == 'activo' || estado == 'trial';

  bool venceEnMenosDe(int dias, DateTime ahora) {
    final v = venceAt;
    if (v == null) return false;
    return v.difference(ahora).inDays <= dias;
  }
}

final tenantsPlataformaProvider =
    FutureProvider<List<TenantResumen>>((ref) async {
  // Las RLS deciden qué filas vuelven: un superadmin ve todas, un revendedor
  // solo las suyas. No se filtra de nuevo acá — duplicar la regla es la forma
  // de que las dos se desincronicen.
  final filas = await sb
      .from('tenants')
      .select('id, nombre, slug, estado, plan, '
          'licencias(vence_at), tenant_members(user_id, estado)')
      .order('nombre');

  final uid = sb.auth.currentUser?.id;
  return (filas as List).map((f) {
    final row = f as Map<String, dynamic>;
    final lic = row['licencias'];
    final venceRaw = lic is List && lic.isNotEmpty
        ? (lic.first as Map<String, dynamic>)['vence_at']
        : null;
    final miembros = (row['tenant_members'] as List?) ?? const [];
    return TenantResumen(
      id: row['id'] as String,
      nombre: (row['nombre'] as String?) ?? 'Sin nombre',
      slug: (row['slug'] as String?) ?? '',
      estado: (row['estado'] as String?) ?? 'cancelado',
      plan: (row['plan'] as String?) ?? '—',
      venceAt: venceRaw == null ? null : DateTime.tryParse('$venceRaw'),
      miembros: miembros.length,
      esMiembro: miembros.any((m) =>
          (m as Map)['user_id'] == uid && m['estado'] == 'approved'),
    );
  }).toList();
});

class PlatformScreen extends ConsumerWidget {
  const PlatformScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final salones = ref.watch(tenantsPlataformaProvider);

    return Scaffold(
      backgroundColor: MColors.bg,
      body: SafeArea(
        child: RefreshIndicator(
          color: MColors.brand,
          onRefresh: () async => ref.invalidate(tenantsPlataformaProvider),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(22, 26, 22, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Panel de plataforma', style: MText.authTitle),
                      const SizedBox(height: 6),
                      Text(
                        'Los salones que administrás.',
                        style: MText.cuerpoSec,
                      ),
                    ],
                  ),
                ),
              ),
              switch (salones) {
                AsyncData(:final value) when value.isEmpty =>
                  const SliverToBoxAdapter(child: _SinSalones()),
                AsyncData(:final value) => SliverList.builder(
                    itemCount: value.length,
                    // El escalonado se hace con el delay por índice y no con
                    // StaggeredEntrance: ese widget recibe la lista entera de
                    // hijos, y acá se construyen de a uno bajo demanda.
                    itemBuilder: (_, i) => FadeSlideIn(
                      delay: Duration(milliseconds: 40 * i),
                      child: _TarjetaSalon(salon: value[i]),
                    ),
                  ),
                AsyncError(:final error) =>
                  SliverToBoxAdapter(child: _ErrorCarga(error: '$error')),
                _ => const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 60),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: MColors.brand,
                        ),
                      ),
                    ),
                  ),
              },
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(22, 28, 22, 30),
                  child: Column(
                    children: [
                      TextButton(
                        onPressed: () =>
                            ref.read(sessionProvider.notifier).cerrarSesion(),
                        child: Text('Cerrar sesión', style: MText.menor),
                      ),
                      const SizedBox(height: 6),
                      const VersionLabel(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TarjetaSalon extends ConsumerWidget {
  const _TarjetaSalon({required this.salon});

  final TenantResumen salon;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ahora = DateTime.now();
    final porVencer = salon.venceEnMenosDe(30, ahora);

    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 8, 22, 8),
      child: PressableScale(
        onTap: salon.operativo
            ? () => ref.read(sessionProvider.notifier).elegirTenant(salon.id)
            : null,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: MColors.surface,
            borderRadius: BorderRadius.circular(MRadius.lg),
            border: Border.all(color: MColors.border),
            boxShadow: MShadow.sm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      salon.nombre,
                      style: sans(size: 16, weight: 600),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _Pastilla(
                    texto: salon.estado,
                    fondo: salon.operativo
                        ? MColors.successBg
                        : MColors.dangerBg,
                    color: salon.operativo
                        ? MColors.successText
                        : MColors.dangerText,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${salon.plan} · ${salon.miembros} '
                '${salon.miembros == 1 ? "usuaria" : "usuarias"}',
                style: MText.menor,
              ),
              if (salon.venceAt != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Licencia hasta ${_fecha(salon.venceAt!)}',
                  style: sans(
                    size: 12,
                    weight: porVencer ? 600 : 400,
                    // Una licencia por vencer se marca, pero no en rojo: rojo
                    // es "no funciona", y esto todavía funciona.
                    color: porVencer ? MColors.warningText : MColors.tMuted,
                  ),
                ),
              ],
              const SizedBox(height: 14),
              Row(
                children: [
                  Icon(
                    salon.esMiembro
                        ? Icons.login_rounded
                        : Icons.visibility_outlined,
                    size: 16,
                    color: salon.operativo ? MColors.brand : MColors.tLight,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      !salon.operativo
                          ? 'No operativo: no se puede entrar'
                          : salon.esMiembro
                              ? 'Entrar y trabajar'
                              : 'Ver como plataforma (solo lectura, queda '
                                  'registrado)',
                      style: sans(
                        size: 13,
                        weight: 500,
                        color:
                            salon.operativo ? MColors.brand : MColors.tLight,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _fecha(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/'
      '${d.month.toString().padLeft(2, '0')}/${d.year}';
}

class _Pastilla extends StatelessWidget {
  const _Pastilla({
    required this.texto,
    required this.fondo,
    required this.color,
  });

  final String texto;
  final Color fondo;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: fondo,
          borderRadius: BorderRadius.circular(MRadius.full),
        ),
        child: Text(
          texto,
          style: sans(size: 11, weight: 600, color: color),
        ),
      );
}

class _SinSalones extends StatelessWidget {
  const _SinSalones();

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(30, 50, 30, 30),
        child: Column(
          children: [
            Text('Todavía no hay salones', style: MText.authTitle),
            const SizedBox(height: 10),
            Text(
              'Cuando des de alta el primero, va a aparecer acá.',
              textAlign: TextAlign.center,
              style: MText.cuerpoSec,
            ),
          ],
        ),
      );
}

class _ErrorCarga extends StatelessWidget {
  const _ErrorCarga({required this.error});

  final String error;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(30, 50, 30, 30),
        child: Column(
          children: [
            Text('No se pudo cargar', style: MText.authTitle),
            const SizedBox(height: 10),
            Text(
              'Deslizá hacia abajo para reintentar.',
              textAlign: TextAlign.center,
              style: MText.cuerpoSec,
            ),
          ],
        ),
      );
}
