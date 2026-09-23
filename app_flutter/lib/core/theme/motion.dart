/// Las animaciones del `index.html`, como widgets reutilizables.
///
/// **Todas respetan `MediaQuery.disableAnimations`**, que es el equivalente en
/// Flutter de `prefers-reduced-motion: reduce`. El CSS original las anula
/// todas bajo esa media query; acá se salta directo al estado final.
library;

import 'package:flutter/widgets.dart';

import '../layout/layout.dart';

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
  // El delay va DENTRO de la animación, como un tramo quieto al principio, y
  // no en un `Future.delayed` que arranca el controlador más tarde. Con un
  // temporizador suelto la espera corre igual en una vista que nadie ve —el
  // shell las tiene todas montadas— y además quedaba un timer pendiente que
  // no depende de que haya frames; el tramo quieto se congela con la vista.
  late final Duration _total = widget.delay + widget.duration;
  late final AnimationController _c =
      AnimationController(vsync: this, duration: _total);
  late final Animation<double> _a = CurvedAnimation(
    parent: _c,
    curve: Interval(
      _total.inMicroseconds == 0
          ? 0
          : widget.delay.inMicroseconds / _total.inMicroseconds,
      1,
      curve: MMotion.easeOut,
    ),
  );

  @override
  void initState() {
    super.initState();
    _c.forward();
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
    this.onLongPress,
    this.escala = 0.97,
  });

  final Widget child;
  final VoidCallback? onTap;

  /// Atajo del toque largo. Nunca es la única forma de hacer algo: lo que
  /// esté acá tiene que poder hacerse también abriendo la ficha.
  final VoidCallback? onLongPress;
  final double escala;

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale> {
  bool _presionado = false;

  @override
  Widget build(BuildContext context) {
    final habilitado = widget.onTap != null;
    return MouseRegion(
      // En escritorio, lo que se puede tocar muestra la manito. Sin esto la
      // PWA se siente como una foto de la app: nada avisa que responde.
      cursor: habilitado ? SystemMouseCursors.click : MouseCursor.defer,
      child: GestureDetector(
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        onTapDown:
            habilitado ? (_) => setState(() => _presionado = true) : null,
        onTapUp: habilitado ? (_) => setState(() => _presionado = false) : null,
        onTapCancel:
            habilitado ? () => setState(() => _presionado = false) : null,
        child: AnimatedScale(
          scale: _presionado ? widget.escala : 1,
          duration: MMotion.t1,
          curve: MMotion.ease,
          child: widget.child,
        ),
      ),
    );
  }
}

/// Expone si el puntero está encima, para pintar un hover. En un teléfono
/// nunca es `true` y el widget se ve igual que siempre.
///
/// Es un builder y no un `Container` con color porque cada fila decide qué
/// cambia al pasar el mouse: el fondo, el borde o un botón que aparece.
class ConHover extends StatefulWidget {
  const ConHover({super.key, required this.builder});

  final Widget Function(BuildContext context, bool encima) builder;

  @override
  State<ConHover> createState() => _ConHoverState();
}

class _ConHoverState extends State<ConHover> {
  bool _encima = false;

  @override
  Widget build(BuildContext context) {
    // Con el dedo no hay puntero, así que el `MouseRegion` no puede hacer nada
    // más que costar. Y no es uno: `TablaMirame` envuelve **cada fila**, y en
    // la tablet del mostrador una tabla de Caja son decenas de regiones vivas
    // esperando un evento que nunca llega.
    if (esTactil) return widget.builder(context, false);
    return MouseRegion(
      onEnter: (_) => setState(() => _encima = true),
      onExit: (_) => setState(() => _encima = false),
      child: widget.builder(context, _encima),
    );
  }
}
