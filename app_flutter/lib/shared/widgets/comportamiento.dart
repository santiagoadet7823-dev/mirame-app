/// La capa de comportamiento: lo que pasa cuando la lista se mueve.
///
/// Los mockups son fotos fijas; nada de esto se ve ahí. Son las señales que
/// hacen que una lista larga no se sienta como un pozo: una sombra que avisa
/// que hay contenido arriba, un degradé que avisa que la fila sigue a la
/// derecha, un cierre que avisa que llegaste al final.
///
/// Todo vive acá y no en cada vista para que las cinco pantallas se comporten
/// igual: una sombra que aparece a los 4 px en Agenda y a los 20 en Clientas
/// se lee como un error, no como un estilo.
library;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/sync/sync_engine.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';

/// A partir de cuántos píxeles de scroll se considera que "hay algo arriba".
/// Dos píxeles alcanzan y evitan que la sombra parpadee con el rebote.
const _kUmbral = 2.0;

/// Encabezado pegado arriba de una lista, que gana una sombra cuando hay
/// contenido scrolleado por debajo.
///
/// Sin esto, una cabecera blanca sobre una lista blanca no se distingue de la
/// primera fila y nada avisa que hay filas más arriba.
class ListaConEncabezado extends StatefulWidget {
  const ListaConEncabezado({
    super.key,
    required this.encabezado,
    required this.lista,
  });

  /// Recibe si hay contenido scrolleado por encima, para decidir su sombra.
  final Widget Function(BuildContext context, bool hayArriba) encabezado;
  final Widget lista;

  @override
  State<ListaConEncabezado> createState() => _ListaConEncabezadoState();
}

class _ListaConEncabezadoState extends State<ListaConEncabezado> {
  bool _hayArriba = false;

  bool _onScroll(ScrollNotification n) {
    // Solo el scroll vertical del cuerpo: una fila de chips horizontal no
    // tiene por qué encender la sombra del encabezado.
    if (n.metrics.axis != Axis.vertical) return false;
    final v = n.metrics.pixels > _kUmbral;
    if (v != _hayArriba) setState(() => _hayArriba = v);
    return false;
  }

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          widget.encabezado(context, _hayArriba),
          Expanded(
            child: NotificationListener<ScrollNotification>(
              onNotification: _onScroll,
              child: widget.lista,
            ),
          ),
        ],
      );
}

/// La sombra que usa un encabezado pegado. Animada: aparecer de golpe se lee
/// como un parpadeo.
List<BoxShadow> sombraEncabezado(bool hayArriba) => hayArriba
    ? const [
        BoxShadow(
          color: Color(0x14000000),
          offset: Offset(0, 2),
          blurRadius: 6,
        ),
      ]
    : const <BoxShadow>[];

/// Degradé de corte al final de una fila horizontal: avisa que sigue.
///
/// Sin esto una fila de chips que se pasa del borde parece terminar ahí, y
/// nadie desliza lo que no sabe que existe.
class DegradeDeCorte extends StatefulWidget {
  const DegradeDeCorte({
    super.key,
    required this.child,
    this.color = MColors.bg,
    this.ancho = 24,
  });

  final Widget child;

  /// El color del fondo sobre el que se dibuja: el degradé va de ese color a
  /// transparente.
  final Color color;
  final double ancho;

  @override
  State<DegradeDeCorte> createState() => _DegradeDeCorteState();
}

class _DegradeDeCorteState extends State<DegradeDeCorte> {
  // Arranca en true: mientras no se midió, es más seguro insinuar que sigue
  // que prometer que termina.
  bool _sigueDerecha = true;
  bool _sigueIzquierda = false;

  bool _onScroll(ScrollNotification n) {
    if (n.metrics.axis != Axis.horizontal) return false;
    final der = n.metrics.pixels < n.metrics.maxScrollExtent - 1;
    final izq = n.metrics.pixels > 1;
    if (der != _sigueDerecha || izq != _sigueIzquierda) {
      setState(() {
        _sigueDerecha = der;
        _sigueIzquierda = izq;
      });
    }
    return false;
  }

  Widget _velo({required bool izquierda, required bool visible}) =>
      IgnorePointer(
        child: AnimatedOpacity(
          opacity: visible ? 1 : 0,
          duration: MMotion.t1,
          child: Container(
            width: widget.ancho,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: izquierda ? Alignment.centerLeft : Alignment.centerRight,
                end: izquierda ? Alignment.centerRight : Alignment.centerLeft,
                colors: [widget.color, widget.color.withValues(alpha: 0)],
              ),
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) => Stack(
        children: [
          NotificationListener<ScrollNotification>(
            onNotification: _onScroll,
            child: widget.child,
          ),
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: _velo(izquierda: true, visible: _sigueIzquierda),
          ),
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: _velo(izquierda: false, visible: _sigueDerecha),
          ),
        ],
      );
}

/// El cierre de una lista larga. Una lista que termina sin decir nada parece
/// cortada por un error de carga.
class FinDeLista extends StatelessWidget {
  const FinDeLista(this.texto, {super.key});

  final String texto;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 6),
        child: Row(
          children: [
            const Expanded(child: Divider(color: MColors.border, height: 1)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                texto,
                style: sans(size: 11, weight: 500, color: MColors.tLight),
              ),
            ),
            const Expanded(child: Divider(color: MColors.border, height: 1)),
          ],
        ),
      );
}

/// Un bloque gris con la forma de lo que se está por cargar.
///
/// Reemplaza al spinner centrado: un spinner no dice qué va a aparecer y,
/// sobre todo, se confunde con "no hay nada". Eso pasaba de verdad: mientras
/// la base abría, Clientas mostraba "Sin clientas".
class Esqueleto extends StatefulWidget {
  const Esqueleto({
    super.key,
    this.ancho,
    this.alto = 14,
    this.radio = MRadius.sm,
  });

  final double? ancho;
  final double alto;
  final double radio;

  @override
  State<Esqueleto> createState() => _EsqueletoState();
}

/// El latido que comparten todos los esqueletos de un grupo.
///
/// Antes cada barra creaba su propio `AnimationController`: una lista de seis
/// filas eran dieciocho relojes latiendo cada uno por su cuenta. Con el
/// `IndexedStack` del shell, que monta las ocho vistas a la vez, eso pasaba
/// también en las que nadie estaba mirando. Uno por grupo alcanza, y de paso
/// laten sincronizados, que es como se ve bien.
class LatidoEsqueleto extends StatefulWidget {
  const LatidoEsqueleto({super.key, required this.child});

  final Widget child;

  /// El latido de arriba, o null si este esqueleto está solo.
  static Animation<double>? de(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_LatidoHeredado>()?.animacion;

  @override
  State<LatidoEsqueleto> createState() => _LatidoEsqueletoState();
}

class _LatidoEsqueletoState extends State<LatidoEsqueleto>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat(reverse: true);

  late final Animation<double> _opacidad =
      Tween<double>(begin: 0.45, end: 0.9).animate(
    CurvedAnimation(parent: _c, curve: MMotion.ease),
  );

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      _LatidoHeredado(animacion: _opacidad, child: widget.child);
}

class _LatidoHeredado extends InheritedWidget {
  const _LatidoHeredado({required this.animacion, required super.child});

  final Animation<double> animacion;

  @override
  bool updateShouldNotify(_LatidoHeredado viejo) =>
      viejo.animacion != animacion;
}

class _EsqueletoState extends State<Esqueleto>
    with SingleTickerProviderStateMixin {
  AnimationController? _c;
  Animation<double>? _propio;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reloj propio solo si no hay uno compartido arriba.
    if (_c == null && LatidoEsqueleto.de(context) == null) {
      _c = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1100),
      )..repeat(reverse: true);
      _propio = Tween<double>(begin: 0.45, end: 0.9).animate(
        CurvedAnimation(parent: _c!, curve: MMotion.ease),
      );
    }
  }

  @override
  void dispose() {
    _c?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Con "reducir movimiento" activado no late: queda en un gris fijo.
    final anima = !MediaQuery.disableAnimationsOf(context);
    final latido = LatidoEsqueleto.de(context) ?? _propio;
    return FadeTransition(
      opacity: anima && latido != null
          ? latido
          : const AlwaysStoppedAnimation(0.6),
      child: Container(
        width: widget.ancho,
        height: widget.alto,
        decoration: BoxDecoration(
          color: MColors.bg3,
          borderRadius: BorderRadius.circular(widget.radio),
        ),
      ),
    );
  }
}

/// Varias tarjetas fantasma con la forma de una fila con avatar.
class EsqueletoDeLista extends StatelessWidget {
  const EsqueletoDeLista({
    super.key,
    this.filas = 5,
    this.alto = 72,
    this.padding = const EdgeInsets.fromLTRB(16, 0, 16, 0),
    this.desplazable = true,
  });

  final int filas;
  final double alto;
  final EdgeInsets padding;

  /// `false` cuando ya vive adentro de otra lista (Caja, Insumos): ahí se
  /// dibuja como columna. Un `ListView` dentro de otro revienta con
  /// "vertical viewport was given unbounded height" — lo agarró el test de
  /// humo antes de llegar al teléfono.
  final bool desplazable;

  @override
  Widget build(BuildContext context) {
    final items = [for (var i = 0; i < filas; i++) _fila(i)];
    // Un solo latido para las tres barras de cada fila.
    return LatidoEsqueleto(
      child: !desplazable
          ? Padding(
              padding: padding,
              child: Column(mainAxisSize: MainAxisSize.min, children: items),
            )
          : ListView(
              padding: padding,
              // No hay nada que tocar mientras carga.
              physics: const NeverScrollableScrollPhysics(),
              children: items,
            ),
    );
  }

  Widget _fila(int i) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Container(
          height: alto,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: MColors.surface,
            border: Border.all(color: MColors.border),
            borderRadius: BorderRadius.circular(MRadius.lg),
          ),
          child: Row(
            children: [
              const Esqueleto(ancho: 42, alto: 42, radio: MRadius.full),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Anchos distintos por fila: todos iguales se ven como
                    // una grilla rota, no como texto.
                    Esqueleto(ancho: 120 + (i % 3) * 28, alto: 13),
                    const SizedBox(height: 7),
                    Esqueleto(ancho: 80 + (i % 2) * 34, alto: 11),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const Esqueleto(ancho: 54, alto: 13),
            ],
          ),
        ),
      );
}

/// Tirar para refrescar: fuerza una sincronización y espera a que termine.
///
/// La app es local-first y el sync corre solo cada 3 minutos, así que esto no
/// trae datos "nuevos" que no fueran a llegar igual: sirve para la persona que
/// acaba de cargar algo en otro dispositivo y quiere verlo **ahora**, y para
/// tener algo que hacer cuando se duda de si está actualizado.
class TirarParaRefrescar extends ConsumerWidget {
  const TirarParaRefrescar({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) => RefreshIndicator(
        color: MColors.brand,
        backgroundColor: MColors.surface,
        edgeOffset: 0,
        onRefresh: () => ref.read(syncProvider.notifier).sincronizar(),
        child: child,
      );
}

/// Lo que el shell sabe del scroll de la vista activa.
///
/// El FAB y el header viven FUERA del cuerpo que scrollea (son del
/// `Scaffold`), así que no se enteran solos: las notificaciones de scroll
/// suben por el árbol del cuerpo y ahí se quedan. El shell las escucha una
/// vez y las publica acá, y cada pieza decide qué hacer.
class EstadoScroll {
  const EstadoScroll({this.hayArriba = false, this.bajando = false});

  /// Hay contenido scrolleado por encima: el header se despega del fondo.
  final bool hayArriba;

  /// Se está yendo hacia abajo de la lista: el FAB se achica para no tapar
  /// la fila que se está leyendo.
  final bool bajando;

  EstadoScroll copyWith({bool? hayArriba, bool? bajando}) => EstadoScroll(
        hayArriba: hayArriba ?? this.hayArriba,
        bajando: bajando ?? this.bajando,
      );

  @override
  bool operator ==(Object other) =>
      other is EstadoScroll &&
      other.hayArriba == hayArriba &&
      other.bajando == bajando;

  @override
  int get hashCode => Object.hash(hayArriba, bajando);
}

/// Escucha el scroll del cuerpo y lo publica a sus descendientes.
class ObservadorDeScroll extends StatefulWidget {
  const ObservadorDeScroll({super.key, required this.child});

  final Widget child;

  @override
  State<ObservadorDeScroll> createState() => _ObservadorDeScrollState();
}

class _ObservadorDeScrollState extends State<ObservadorDeScroll> {
  final _estado = ValueNotifier(const EstadoScroll());

  @override
  void dispose() {
    _estado.dispose();
    super.dispose();
  }

  bool _onScroll(ScrollNotification n) {
    if (n.metrics.axis != Axis.vertical) return false;
    var v = _estado.value.copyWith(hayArriba: n.metrics.pixels > _kUmbral);
    if (n is UserScrollNotification) {
      // `idle` se ignora: al soltar el dedo el FAB no tiene por qué volver a
      // crecer de golpe, queda como estaba hasta el próximo movimiento.
      switch (n.direction) {
        case ScrollDirection.reverse:
          v = v.copyWith(bajando: true);
        case ScrollDirection.forward:
          v = v.copyWith(bajando: false);
        case ScrollDirection.idle:
          break;
      }
    }
    // Arriba de todo el FAB siempre está entero.
    if (!v.hayArriba) v = v.copyWith(bajando: false);
    _estado.value = v;
    return false;
  }

  @override
  Widget build(BuildContext context) =>
      NotificationListener<ScrollNotification>(
        onNotification: _onScroll,
        child: ValueListenableBuilder(
          valueListenable: _estado,
          builder: (_, valor, hijo) =>
              _ScrollHeredado(estado: valor, child: hijo!),
          child: widget.child,
        ),
      );
}

class _ScrollHeredado extends InheritedWidget {
  const _ScrollHeredado({required this.estado, required super.child});

  final EstadoScroll estado;

  @override
  bool updateShouldNotify(_ScrollHeredado viejo) => viejo.estado != estado;
}

/// Lee el estado de scroll publicado por el shell. Fuera de él, todo en
/// reposo: así una vista montada sola en un test no se rompe.
EstadoScroll estadoScrollDe(BuildContext context) =>
    context.dependOnInheritedWidgetOfExactType<_ScrollHeredado>()?.estado ??
    const EstadoScroll();
