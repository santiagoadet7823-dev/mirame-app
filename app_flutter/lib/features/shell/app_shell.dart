/// El caparazón de la app: header, contenido y navegación.
///
/// Replica los tres modos del CSS original: móvil a pantalla completa, tablet
/// con la columna centrada a 430 px, y escritorio con sidebar de 248 px.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/motion.dart';
import '../../core/theme/shadows.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../data/sync/sync_engine.dart';
import '../auth/session_controller.dart';

class ItemNav {
  const ItemNav(this.icono, this.etiqueta);
  final IconData icono;
  final String etiqueta;
}

const itemsNav = <ItemNav>[
  ItemNav(Icons.dashboard_outlined, 'Inicio'),
  ItemNav(Icons.calendar_month_outlined, 'Agenda'),
  ItemNav(Icons.people_outline, 'Clientas'),
  ItemNav(Icons.account_balance_wallet_outlined, 'Caja'),
  ItemNav(Icons.inventory_2_outlined, 'Stock'),
  ItemNav(Icons.bar_chart_outlined, 'Stats'),
  ItemNav(Icons.settings_outlined, 'Ajustes'),
];

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key, required this.vistas});

  final List<Widget> vistas;

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  int _indice = 0;

  @override
  Widget build(BuildContext context) {
    final ancho = MediaQuery.sizeOf(context).width;
    final conSidebar = ancho >= MBreak.desktop;

    final contenido = Column(
      children: [
        const _Header(),
        const _BarraSync(),
        Expanded(
          child: IndexedStack(index: _indice, children: widget.vistas),
        ),
      ],
    );

    if (conSidebar) {
      return Scaffold(
        backgroundColor: MColors.bg,
        body: SafeArea(
          child: Row(
            children: [
              _Sidebar(
                indice: _indice,
                onElegir: (i) => setState(() => _indice = i),
              ),
              Expanded(child: contenido),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: MColors.bg,
      body: SafeArea(
        bottom: false,
        // En tablet el original centra la columna a 430 px en vez de estirar
        // los contenidos a lo ancho, que se ve desangelado.
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: ancho >= MBreak.tablet ? 430 : double.infinity,
            ),
            child: contenido,
          ),
        ),
      ),
      bottomNavigationBar: _BottomNav(
        indice: _indice,
        onElegir: (i) => setState(() => _indice = i),
      ),
    );
  }
}

class _Header extends ConsumerWidget {
  const _Header();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tenant = ref.watch(tenantActivoProvider);
    final esSuper = ref.watch(puedeVolverAlPanelProvider);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 14, 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Mírame', style: serif(size: 26, weight: 600)),
                if (tenant != null)
                  Text(
                    tenant.nombre,
                    style: MText.menor,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          if (esSuper)
            IconButton(
              tooltip: 'Volver al panel de plataforma',
              icon: const Icon(Icons.apartment_outlined,
                  size: 21, color: MColors.tMuted),
              onPressed: () =>
                  ref.read(sessionProvider.notifier).salirDelTenant(),
            ),
        ],
      ),
    );
  }
}

/// Franja de estado del sync. **Solo aparece cuando hay algo que decir.**
///
/// Una barra permanente de "todo bien" es ruido que se deja de mirar, y
/// entonces tampoco se ve el día que dice algo importante.
class _BarraSync extends ConsumerWidget {
  const _BarraSync();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(syncProvider);

    final (texto, fondo, color) = switch (s.estado) {
      EstadoSync.sinRed when s.pendientes > 0 => (
          'Sin conexión · ${s.pendientes} '
              '${s.pendientes == 1 ? "cambio" : "cambios"} por subir',
          MColors.warningBg,
          MColors.warningText,
        ),
      EstadoSync.sinRed => ('Sin conexión · trabajando local',
          MColors.bg3, MColors.tSecondary),
      EstadoSync.error => ('No se pudo sincronizar. Se reintenta solo.',
          MColors.dangerBg, MColors.dangerText),
      _ when s.pendientes > 0 => (
          '${s.pendientes} por subir',
          MColors.brandBg,
          MColors.brandDark,
        ),
      _ => (null, MColors.bg, MColors.tMuted),
    };

    if (texto == null) return const SizedBox.shrink();

    return AnimatedContainer(
      duration: MMotion.t2,
      width: double.infinity,
      color: fondo,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
      child: Text(
        texto,
        textAlign: TextAlign.center,
        style: sans(size: 12, weight: 500, color: color),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.indice, required this.onElegir});

  final int indice;
  final ValueChanged<int> onElegir;

  @override
  Widget build(BuildContext context) => Container(
        decoration: const BoxDecoration(
          color: MColors.surface,
          border: Border(top: BorderSide(color: MColors.border)),
          boxShadow: MShadow.lg,
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 58,
            child: Row(
              children: [
                for (var i = 0; i < itemsNav.length; i++)
                  Expanded(
                    child: _ItemBottom(
                      item: itemsNav[i],
                      activo: i == indice,
                      onTap: () => onElegir(i),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
}

class _ItemBottom extends StatelessWidget {
  const _ItemBottom({
    required this.item,
    required this.activo,
    required this.onTap,
  });

  final ItemNav item;
  final bool activo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        // Opaque y no el default: sin esto el toque solo cuenta sobre el
        // pixel del ícono y la mitad de los toques no hacen nada.
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: MMotion.t2,
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 4),
              decoration: BoxDecoration(
                color: activo ? MColors.brandBg : Colors.transparent,
                borderRadius: BorderRadius.circular(MRadius.full),
              ),
              child: Icon(
                item.icono,
                size: 20,
                color: activo ? MColors.brand : MColors.tLight,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              item.etiqueta,
              maxLines: 1,
              overflow: TextOverflow.clip,
              style: sans(
                size: 9.5,
                weight: activo ? 600 : 500,
                color: activo ? MColors.brand : MColors.tLight,
              ),
            ),
          ],
        ),
      );
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({required this.indice, required this.onElegir});

  final int indice;
  final ValueChanged<int> onElegir;

  @override
  Widget build(BuildContext context) => Container(
        width: 248,
        decoration: const BoxDecoration(
          color: MColors.surface,
          border: Border(right: BorderSide(color: MColors.border)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 0, 22),
              child: Text('Mírame', style: serif(size: 28, weight: 600)),
            ),
            for (var i = 0; i < itemsNav.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: PressableScale(
                  onTap: () => onElegir(i),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 13, vertical: 11),
                    decoration: BoxDecoration(
                      color:
                          i == indice ? MColors.brandBg : Colors.transparent,
                      borderRadius: BorderRadius.circular(MRadius.md),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          itemsNav[i].icono,
                          size: 19,
                          color: i == indice
                              ? MColors.brand
                              : MColors.tSecondary,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          itemsNav[i].etiqueta,
                          style: sans(
                            size: 14,
                            weight: i == indice ? 600 : 500,
                            color: i == indice
                                ? MColors.brand
                                : MColors.tSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
}
