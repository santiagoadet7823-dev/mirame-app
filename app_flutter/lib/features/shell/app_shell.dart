/// El caparazón de la app: header, contenido y navegación.
///
/// **Portado medida por medida del `index.html`**, no aproximado. Los valores
/// de este archivo salen del CSS original:
///
/// ```
/// #hdr        { padding:12px 18px 10px; background:surface; border-bottom:1px }
/// .hdr-logo   { 40x40; border-radius:50%; border:1.5px border-md; sh-xs }
/// .hdr-name   { Cormorant 18px/600, letter-spacing .2px }
/// .hdr-tagline{ 10px/500, letter-spacing 1.5px, UPPERCASE, t-muted }
/// #nav        { background:surface; border-top:1px; padding:0 8px 8px+safe }
/// .nav-it     { column; gap:3px; padding:10px 4px 6px }
/// .nav-ic     { 32x32; border-radius:10px; activo → brand-bg }
/// .nav-lb     { 10px/500 → activo 600 }
/// .nav-it::after { barra 22x3 ARRIBA, escala en X al activarse }
/// .view       { padding:16px 16px 96px (móvil) · 18px lados (tablet) }
/// .fab        { 54x54; bottom:80+safe; right:18; sh-brand + sh-md }
/// ```
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/motion.dart';
import '../../core/theme/shadows.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../data/sync/sync_engine.dart';
import '../auth/session_controller.dart';
import 'notificaciones.dart';
import 'programador_avisos.dart';
import '../../core/notificaciones/servicio_avisos.dart';

class ItemNav {
  const ItemNav(this.icono, this.etiqueta);
  final IconData icono;
  final String etiqueta;
}

/// **CINCO** ítems, como el `#nav` del original — ni uno más.
///
/// Estadísticas y Ajustes NO están acá a propósito: en el `index.html` se
/// llega a Stats desde una acción rápida del Inicio y a Ajustes desde el
/// engranaje del header. Siete ítems dejan cada uno en ~53 px y las etiquetas
/// se aprietan; con cinco respiran.
const itemsNav = <ItemNav>[
  ItemNav(Icons.home_outlined, 'Inicio'),
  ItemNav(Icons.calendar_today_outlined, 'Agenda'),
  ItemNav(Icons.people_outline, 'Clientas'),
  ItemNav(Icons.attach_money_rounded, 'Caja'),
  ItemNav(Icons.inventory_2_outlined, 'Insumos'),
];

/// Índices de las vistas que no están en el nav. El orden tiene que coincidir
/// con la lista que recibe `AppShell`.
/// Lo que ve el sidebar de escritorio: las cinco del nav más las dos que en
/// móvil viven en otro lado.
const itemsSidebar = <ItemNav>[
  ...itemsNav,
  ItemNav(Icons.bar_chart_rounded, 'Stats'),
  ItemNav(Icons.settings_outlined, 'Ajustes'),
  ItemNav(Icons.storefront_outlined, 'Tienda'),
];

abstract final class Vistas {
  static const inicio = 0;
  static const agenda = 1;
  static const clientas = 2;
  static const caja = 3;
  static const stock = 4;
  static const stats = 5;
  static const ajustes = 6;

  /// La tienda NO entra al nav: son cinco items, como el original. Se llega
  /// una accion rapida del Inicio, igual que Stats.
  static const ropa = 7;
}

/// `.view { padding: 16px 16px 96px }` — los 96 de abajo dejan pasar el FAB y
/// la barra de navegación sin que tapen la última fila.
const padVistaMovil = EdgeInsets.fromLTRB(16, 16, 16, 96);

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key, required this.vistas});

  final List<Widget> vistas;

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

/// Permite que una vista mande a otra sección — lo usan las acciones rápidas
/// del Inicio ("Ver todo", "Estadísticas").
///
/// Es un `InheritedWidget` y no un provider global: la sección activa es
/// estado de ESTE shell, y con dos salones abiertos en escritorio un provider
/// global los pondría de acuerdo cuando no deberían estarlo.
class NavegadorShell extends InheritedWidget {
  const NavegadorShell({
    super.key,
    required this.irA,
    required super.child,
  });

  final void Function(int) irA;

  static void ir(BuildContext context, int indice) =>
      context.dependOnInheritedWidgetOfExactType<NavegadorShell>()?.irA(indice);

  @override
  bool updateShouldNotify(NavegadorShell viejo) => false;
}

class _AppShellState extends ConsumerState<AppShell> {
  int _indice = 0;

  /// Secciones a las que puede llevar una notificación. El payload es texto y
  /// no un índice: un número guardado por Android sobreviviría a un cambio de
  /// orden del nav y abriría la vista equivocada.
  static const _destinos = {
    'inicio': Vistas.inicio,
    'agenda': Vistas.agenda,
    'clientas': Vistas.clientas,
    'caja': Vistas.caja,
    'stock': Vistas.stock,
  };

  @override
  void initState() {
    super.initState();
    payloadTocadoNotifier.addListener(_abrirDesdeNotificacion);
  }

  @override
  void dispose() {
    payloadTocadoNotifier.removeListener(_abrirDesdeNotificacion);
    super.dispose();
  }

  void _abrirDesdeNotificacion() {
    final destino = _destinos[payloadTocadoNotifier.value];
    if (destino == null || !mounted) return;
    setState(() => _indice = destino);
    // Se limpia para que no vuelva a saltar al siguiente rebuild.
    payloadTocadoNotifier.value = null;
  }

  @override
  Widget build(BuildContext context) {
    final ancho = MediaQuery.sizeOf(context).width;
    final conSidebar = ancho >= MBreak.desktop;

    void irA(int i) => setState(() => _indice = i);

    final cuerpo = NavegadorShell(
      irA: irA,
      child: ProgramadorAvisos(
        child: Column(
          children: [
            const _BarraSync(),
            Expanded(
              child: IndexedStack(index: _indice, children: widget.vistas),
            ),
          ],
        ),
      ),
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
              Expanded(
                child: Column(
                  children: [
                    _Header(
                      titulo: itemsSidebar[_indice].etiqueta,
                      onAjustes: () => irA(Vistas.ajustes),
                    ),
                    Expanded(child: cuerpo),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: MColors.bg,
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            // `max-width:430px` centrado desde 600 px — el modo tablet del
            // original.
            constraints: BoxConstraints(
              maxWidth: ancho >= MBreak.tablet ? 430 : double.infinity,
            ),
            child: Column(
              children: [
                _Header(onAjustes: () => irA(Vistas.ajustes)),
                Expanded(child: cuerpo),
              ],
            ),
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
  const _Header({this.titulo, required this.onAjustes});

  /// `.hdr-actions` del original tiene tres botones: cambiar de modo,
  /// notificaciones y ajustes. El de modo NO se porta: en el original alterna
  /// entre el layout móvil y el de escritorio a mano, y acá eso lo decide el
  /// ancho de la pantalla — un botón que pelea con el `LayoutBuilder` es una
  /// fuente de bugs, no una función.
  final VoidCallback onAjustes;

  /// En escritorio la marca se oculta (`body.desktop #hdr .hdr-brand
  /// {display:none}`) y en su lugar va el título de la sección.
  final String? titulo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tenant = ref.watch(tenantActivoProvider);
    final puedeVolver = ref.watch(puedeVolverAlPanelProvider);
    final esEscritorio = titulo != null;

    return Container(
      width: double.infinity,
      padding: esEscritorio
          ? const EdgeInsets.fromLTRB(32, 16, 32, 16)
          : const EdgeInsets.fromLTRB(18, 12, 18, 10),
      decoration: const BoxDecoration(
        color: MColors.surface,
        border: Border(bottom: BorderSide(color: MColors.border)),
      ),
      child: Row(
        children: [
          if (esEscritorio)
            Expanded(
              child: Text(
                titulo!,
                style:
                    serif(size: 26, weight: 600).copyWith(letterSpacing: 0.2),
              ),
            )
          else ...[
            const _LogoRedondo(),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Mírame',
                    style: serif(size: 18, weight: 600)
                        .copyWith(letterSpacing: 0.2),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    // El original dice siempre "Lash Studio". Con varios
                    // salones, el nombre del salón activo informa más que
                    // repetir la marca dos renglones seguidos.
                    (tenant?.nombre ?? 'Lash Studio').toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: sans(size: 10, weight: 500, color: MColors.tMuted)
                        .copyWith(letterSpacing: 1.5),
                  ),
                ],
              ),
            ),
          ],
          if (puedeVolver) ...[
            _BotonHeader(
              icono: Icons.apartment_outlined,
              tooltip: 'Volver al panel de plataforma',
              onTap: () => ref.read(sessionProvider.notifier).salirDelTenant(),
            ),
            const SizedBox(width: 6),
          ],
          const _BotonNotificaciones(),
          const SizedBox(width: 6),
          _BotonHeader(
            icono: Icons.settings_outlined,
            tooltip: 'Ajustes',
            onTap: onAjustes,
          ),
        ],
      ),
    );
  }
}

/// `.hdr-logo` — 40×40, círculo, borde 1.5 px, sombra xs.
class _LogoRedondo extends StatelessWidget {
  const _LogoRedondo();

  @override
  Widget build(BuildContext context) => Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: MColors.borderMd, width: 1.5),
          boxShadow: MShadow.xs,
        ),
        child: ClipOval(
          child: Image.asset(
            'assets/brand/logo-mirame.jpg',
            fit: BoxFit.cover,
          ),
        ),
      );
}

/// `.hdr-btn` — 36×36, círculo, fondo bg2, borde 1 px.
class _BotonHeader extends StatelessWidget {
  const _BotonHeader({
    required this.icono,
    required this.onTap,
    this.tooltip,
  });

  final IconData icono;
  final VoidCallback onTap;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final boton = PressableScale(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: MColors.bg2,
          shape: BoxShape.circle,
          border: Border.all(color: MColors.border),
        ),
        child: Icon(icono, size: 17, color: MColors.tSecondary),
      ),
    );
    return tooltip == null ? boton : Tooltip(message: tooltip!, child: boton);
  }
}

/// La campanita, con el contador de avisos encima.
///
/// El número va en una burbuja y no como texto al lado: es lo que se mira de
/// reojo, y un "3" suelto se confunde con parte del ícono.
class _BotonNotificaciones extends ConsumerWidget {
  const _BotonNotificaciones();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cuantos = ref.watch(avisosProvider).length;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        _BotonHeader(
          icono: Icons.notifications_none_rounded,
          tooltip: 'Notificaciones',
          onTap: () => mostrarNotificaciones(context),
        ),
        if (cuantos > 0)
          Positioned(
            top: -2,
            right: -2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              constraints: const BoxConstraints(minWidth: 16),
              decoration: BoxDecoration(
                color: MColors.brand,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(MRadius.full),
                border: Border.all(color: MColors.surface, width: 1.5),
              ),
              child: Text(
                // Más de 9 avisos no entran y tampoco aportan: lo que importa
                // es que hay varios.
                cuantos > 9 ? '9+' : '$cuantos',
                textAlign: TextAlign.center,
                style: sans(size: 9, weight: 700, color: MColors.tWhite),
              ),
            ),
          ),
      ],
    );
  }
}

/// Franja de estado del sync. **Solo aparece cuando hay algo que decir.**
///
/// No existe en el original porque el original no sincronizaba. Ocupa el lugar
/// y el estilo de `.bk-bar`, la barra de backup.
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
      EstadoSync.sinRed => (
          'Sin conexión · trabajando local',
          MColors.bg3,
          MColors.tSecondary,
        ),
      EstadoSync.error => (
          'No se pudo sincronizar. Se reintenta solo.',
          MColors.dangerBg,
          MColors.dangerText,
        ),
      _ when s.pendientes > 0 => (
          '${s.pendientes} por subir',
          MColors.brandBg,
          MColors.brandDark,
        ),
      _ => (null, MColors.bg, MColors.tMuted),
    };

    if (texto == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      color: fondo,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
      child: Text(
        texto,
        textAlign: TextAlign.center,
        style: sans(size: 11, weight: 500, color: color),
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
        ),
        // `padding: 0 8px calc(8px + safe-bottom)`
        padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
        child: SafeArea(
          top: false,
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
        // Opaque: sin esto el toque solo cuenta sobre el píxel del ícono.
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Padding(
              // `.nav-it { padding:10px 4px 6px; gap:3px }`
              padding: const EdgeInsets.fromLTRB(4, 10, 4, 6),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: MMotion.t1,
                    curve: MMotion.ease,
                    width: 32,
                    height: 32,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: activo ? MColors.brandBg : Colors.transparent,
                      // Radio 10, NO píldora: el original usa un cuadrado
                      // redondeado y la diferencia se nota.
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      item.icono,
                      size: 18,
                      color: activo ? MColors.brand : MColors.tMuted,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.etiqueta,
                    maxLines: 1,
                    style: sans(
                      size: 10,
                      weight: activo ? 600 : 500,
                      color: activo ? MColors.brand : MColors.tMuted,
                    ),
                  ),
                ],
              ),
            ),
            // `.nav-it::after` — barra de 22×3 arriba, que escala en X.
            AnimatedScale(
              duration: MMotion.t2,
              curve: MMotion.ease,
              scale: activo ? 1 : 0,
              child: Container(
                width: 22,
                height: 3,
                decoration: const BoxDecoration(
                  color: MColors.brand,
                  borderRadius:
                      BorderRadius.vertical(bottom: Radius.circular(3)),
                ),
              ),
            ),
          ],
        ),
      );
}

/// Sidebar de escritorio: 248 px, degradado surface→bg2, ítems en fila con
/// radio 12 y sin la barrita superior.
class _Sidebar extends StatelessWidget {
  const _Sidebar({required this.indice, required this.onElegir});

  final int indice;
  final ValueChanged<int> onElegir;

  @override
  Widget build(BuildContext context) => Container(
        width: 248,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [MColors.surface, MColors.bg2],
          ),
          border: Border(right: BorderSide(color: MColors.border)),
        ),
        padding: const EdgeInsets.fromLTRB(14, 22, 14, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const _LogoRedondo(),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mírame',
                        style: serif(size: 18, weight: 600)
                            .copyWith(letterSpacing: 0.2),
                      ),
                      Text(
                        'LASH STUDIO',
                        style: sans(
                          size: 10,
                          weight: 500,
                          color: MColors.tMuted,
                        ).copyWith(letterSpacing: 1.5),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            // En escritorio sí entran las siete: el sidebar tiene 248 px y
            // esconder Stats detrás de una tarjeta ahí no tiene sentido.
            for (var i = 0; i < itemsSidebar.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: PressableScale(
                  onTap: () => onElegir(i),
                  child: AnimatedContainer(
                    duration: MMotion.t1,
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 13, vertical: 11),
                    decoration: BoxDecoration(
                      color: i == indice
                          ? MColors.brandBg
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 34,
                          height: 34,
                          child: Icon(
                            itemsSidebar[i].icono,
                            size: 18,
                            color:
                                i == indice ? MColors.brand : MColors.tMuted,
                          ),
                        ),
                        const SizedBox(width: 13),
                        Text(
                          itemsSidebar[i].etiqueta,
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

/// `.fab` — 54×54, `bottom: 80px + safe`, `right: 18px`, sombra brand + md.
///
/// Se define acá en vez de usar `FloatingActionButton`: el de Material mide
/// 56, se posiciona distinto y trae su propia elevación.
class FabMirame extends StatelessWidget {
  const FabMirame({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => PressableScale(
        onTap: onTap,
        child: Container(
          width: 54,
          height: 54,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: MColors.brand,
            shape: BoxShape.circle,
            boxShadow: [...MShadow.brand, ...MShadow.md],
          ),
          child:
              const Icon(Icons.add_rounded, size: 26, color: MColors.tWhite),
        ),
      );
}
