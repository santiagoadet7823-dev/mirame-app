/// Las animaciones del `index.html`, como widgets reutilizables.
///
/// **Todas respetan `MediaQuery.disableAnimations`**, que es el equivalente en
/// Flutter de `prefers-reduced-motion: reduce`. El CSS original las anula
/// todas bajo esa media query; acá se salta directo al estado final.
library;

import 'package:flutter/widgets.dart';

import 'tokens.dart';

bool _sinMovimiento(BuildContext c) => MediaQuery.of(c).disableAnimations;

/// `splashIn` — opacidad 0→1 y desplazamiento de 10 px hacia arriba.
/// También sirve para `vRise` (12 px) y `itemIn` (6 px) cambiando [desde].
class FadeSlideIn extends StatefulWidget {
  const FadeSlideIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = MMotion.splashIn,
    this.desde = 10,
  });

  final Widget child;
  final Duration delay;
  final Duration duration;

  /// Píxeles de desplazamiento vertical inicial.
  final double desde;

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: widget.duration);
  late final Animation<double> _a =
      CurvedAnimation(parent: _c, curve: MMotion.easeOut);

  @override
  void initState() {
    super.initState();
    // El delay se resuelve acá y no con un Timer suelto para que se cancele
    // solo si el widget se desmonta antes.
    Future<void>.delayed(widget.delay, () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_sinMovimiento(context)) return widget.child;
    return AnimatedBuilder(
      animation: _a,
      builder: (_, child) => Opacity(
        opacity: _a.value,
        child: Transform.translate(
          offset: Offset(0, widget.desde * (1 - _a.value)),
          child: child,
        ),
      ),
      child: widget.child,
    );
  }
}

/// `authFloat` — sube y baja 6 px cada 5,5 s. Es lo que hace que el emblema
/// del login se sienta vivo sin llamar la atención.
class Floating extends StatefulWidget {
  const Floating({super.key, required this.child, this.amplitud = 6});

  final Widget child;
  final double amplitud;

  @override
  State<Floating> createState() => _FloatingState();
}

class _FloatingState extends State<Floating>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: MMotion.authFloat,
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_sinMovimiento(context)) return widget.child;
    final curva = CurvedAnimation(parent: _c, curve: MMotion.ease);
    return AnimatedBuilder(
      animation: curva,
      builder: (_, child) => Transform.translate(
        offset: Offset(0, -widget.amplitud * curva.value),
        child: child,
      ),
      child: widget.child,
    );
  }
}

/// Escalonado de entrada de una vista: delays .03/.07/.11/.15/.19 s y .22 s
/// del sexto hijo en adelante.
class StaggeredEntrance extends StatelessWidget {
  const StaggeredEntrance({
    super.key,
    required this.children,
    this.duration = MMotion.viewRise,
    this.desde = 12,
  });

  final List<Widget> children;
  final Duration duration;
  final double desde;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < children.length; i++)
            FadeSlideIn(
              delay: MMotion.staggerFor(i),
              duration: duration,
              desde: desde,
              child: children[i],
            ),
        ],
      );
}

/// El original no usa el ripple de Material: al presionar, los controles
/// escalan a 0.97. Esto lo replica.
class PressableScale extends StatefulWidget {
  const PressableScale({
    super.key,
    required this.child,
    this.onTap,
    this.escala = 0.97,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double escala;

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale> {
  bool _presionado = false;

  @override
  Widget build(BuildContext context) {
    final habilitado = widget.onTap != null;
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: habilitado ? (_) => setState(() => _presionado = true) : null,
      onTapUp: habilitado ? (_) => setState(() => _presionado = false) : null,
      onTapCancel:
          habilitado ? () => setState(() => _presionado = false) : null,
      child: AnimatedScale(
        scale: _presionado ? widget.escala : 1,
        duration: MMotion.t1,
        curve: MMotion.ease,
        child: widget.child,
      ),
    );
  }
}
