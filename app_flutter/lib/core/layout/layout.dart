/// El único lugar que decide en qué modo de pantalla está la app.
///
/// Las vistas no comparan anchos por su cuenta: preguntan acá. **Y el shell
/// tampoco.** Que el shell tuviera su propio umbral (`ancho >= 900`) mientras
/// las vistas usaban otro (ancho + lado corto) es lo que produjo el híbrido
/// más difícil de explicar: el riel de la tablet dibujado al costado y adentro
/// las pantallas del teléfono estiradas, con la franja de 96 px reservada para
/// una barra inferior que esa rama no dibujaba. Una sola función, un solo
/// umbral: si esto se vuelve a duplicar, vuelve el bug.
///
/// Todo es **fluido**, no por resolución: las grillas se arman por ancho
/// mínimo de celda y el contenido se centra con un tope. Así una notebook de
/// 1024, un monitor de 1600 y uno de 2560 se ven bien sin un caso especial
/// para cada uno.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../theme/tokens.dart';

/// **Dos** composiciones, no tres.
///
/// Antes había un `tablet` en el medio (600–900 px) que ningún lugar del
/// código leía: caía igual en la rama del teléfono, centrado con
/// `max-width: 430`, o sea la app vertical con franjas vacías a los costados.
/// Un modo que nadie implementa no es un modo, es un agujero. El diseñador
/// pide lo mismo en el brief de la tablet: con menos de 900 px de ancho es el
/// layout del celular, sin diseño aparte.
enum ModoLayout { movil, grande }

/// El modo sale del tamaño ENTERO, no solo del ancho.
///
/// Un celular acostado mide más de 840 px de ancho (un Pixel 7 da 915) y por
/// ancho solo caería en el layout de la compu: riel al costado y tablas en una
/// pantalla de 6 pulgadas. Lo que distingue a un teléfono de una tablet es el
/// **lado corto**.
///
/// Los umbrales son 520 y 840, y no los 600/900 de `sw600dp`, por una razón
/// medida: `MediaQuery.size` son píxeles **lógicos** (físicos / densidad), y
/// las tablets de marca blanca reportan densidades infladas. Una de 1280×800
/// que dice tener densidad 1,5 entrega **853×533 lógicos** — con 600/900 caía
/// en el layout del celular, y eso apagaba de un saque las seis composiciones
/// de tablet. 520 sigue dejando afuera a cualquier teléfono acostado: el lado
/// corto de los más grandes llega a 430 (el Pixel 7 da 412, el iPhone 15 Pro
/// Max 430).
///
/// Ningún umbral acierta con todos los aparatos, así que además hay un
/// interruptor a mano en Ajustes → Pantalla: ver [PantallaPreferida].
ModoLayout modoPara(Size tamano) =>
    tamano.shortestSide >= MBreak.ladoCortoGrande &&
            tamano.width >= MBreak.anchoGrande
        ? ModoLayout.grande
        : ModoLayout.movil;

/// Lo que la persona eligió a mano en Ajustes → Pantalla.
enum ModoPantalla {
  /// Lo decide el tamaño, con [modoPara].
  automatico,

  /// Composición de teléfono, sin importar el tamaño.
  telefono,

  /// Composición de pantalla grande, sin importar lo que reporte el aparato.
  tablet,
}

/// Mete la preferencia de Ajustes en el árbol, para que [esPantallaGrande] la
/// pueda leer sin un `WidgetRef`.
///
/// Es un `InheritedWidget` y no una variable global porque cambiar el modo
/// tiene que **reconstruir** todo lo que dependa de él. Con una global, mover
/// el interruptor en Ajustes no repintaba nada hasta el siguiente rebuild por
/// otro motivo.
class PantallaPreferida extends InheritedWidget {
  const PantallaPreferida({
    super.key,
    required this.modo,
    required super.child,
  });

  final ModoPantalla modo;

  static ModoPantalla de(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<PantallaPreferida>()?.modo ??
      ModoPantalla.automatico;

  @override
  bool updateShouldNotify(PantallaPreferida viejo) => viejo.modo != modo;
}

/// Forzar el eje táctil en los tests. En la app siempre es null.
@visibleForTesting
bool? modoTactilForzado;

/// Se maneja con el dedo, no con un mouse.
///
/// Es un eje APARTE del tamaño, y hace falta: una tablet acostada mide 1280,
/// lo mismo que la PWA en la compu del salón, pero no se usan igual. El
/// escritorio tiene hover, atajo `/` y puede con filas finas de 52 px; la
/// tablet no tiene puntero, así que nada puede depender de pasar el mouse por
/// encima y todo lo tocable necesita 44 px.
///
/// Se decide por plataforma y no por el tamaño: en la web siempre hay puntero
/// (aunque sea una tablet con el navegador), y en un APK nunca.
bool get esTactil {
  if (modoTactilForzado != null) return modoTactilForzado!;
  if (kIsWeb) return false;
  return defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;
}

/// Pantalla grande: la tablet del mostrador **o** la compu del salón.
///
/// La usan el shell y todas las vistas. Se llamaba `esEscritorio`, y el nombre
/// era parte del problema: en la tablet también era `true`, así que cualquiera
/// que leyera el código asumía "acá hay mouse" y le dejaba hover, filas finas
/// y un atajo de teclado. Para eso está [esEscritorioPuntero].
bool esPantallaGrande(BuildContext context) =>
    switch (PantallaPreferida.de(context)) {
      ModoPantalla.telefono => false,
      ModoPantalla.tablet => true,
      ModoPantalla.automatico =>
        modoPara(MediaQuery.sizeOf(context)) == ModoLayout.grande,
    };

/// Pantalla grande manejada con el dedo: la tablet del mostrador.
bool esTabletTactil(BuildContext context) =>
    esTactil && esPantallaGrande(context);

/// Pantalla grande con puntero: la PWA en la compu.
bool esEscritorioPuntero(BuildContext context) =>
    !esTactil && esPantallaGrande(context);

/// Alto mínimo de lo que se toca. Android pide 48; con mouse alcanza menos.
double toqueMinimo(BuildContext context) => esTactil ? 48 : 36;

/// `.view { padding:16px 16px 96px }` en móvil: los 96 de abajo dejan pasar el
/// FAB y la barra de navegación. En pantalla grande no hay ni FAB ni barra, y
/// el CSS dice `30px 32px 40px`.
///
/// Los 96 se atan a [esPantallaGrande], que es **la misma** condición con la
/// que el shell decide dibujar la barra inferior. Mientras fueran dos
/// condiciones distintas había un caso con riel al costado y 96 px muertos
/// abajo.
///
/// [sinArriba] es para la lista que va debajo de una `BarraVista`: la barra ya
/// puso el aire de arriba.
EdgeInsets padVista(BuildContext context, {bool sinArriba = false}) {
  final p = esPantallaGrande(context)
      ? const EdgeInsets.fromLTRB(32, 30, 32, 40)
      : const EdgeInsets.fromLTRB(16, 16, 16, 96);
  return sinArriba ? p.copyWith(top: 0) : p;
}

/// Cuántas columnas entran en [ancho] si cada una necesita al menos
/// [minAncho]. Nunca menos de 1 ni más de [max].
int columnasPara(double ancho, {required double minAncho, int max = 6}) {
  if (ancho <= 0 || minAncho <= 0) return 1;
  final n = (ancho / minAncho).floor();
  return n.clamp(1, max);
}

/// Centra el contenido de una vista en pantalla grande con un ancho tope. En
/// móvil no hace nada.
///
/// [lectura] es para Inicio, Stats, Ajustes (el `max-width` del CSS). [tabla]
/// es para las vistas con listas largas o maestro-detalle: más ancho, porque
/// una tabla de clientas a 1040 desperdicia medio monitor, pero con tope
/// igual, porque a 2500 px una fila no se puede leer de punta a punta.
///
/// Con el dedo el tope de lectura sube: en la tablet de 1280 el riel ya se
/// llevó 92 px, y toparlo en 1040 dejaba 74 px vacíos a cada lado — o sea el
/// síntoma que estábamos tratando de sacar.
class ContenidoEscritorio extends StatelessWidget {
  const ContenidoEscritorio.lectura({super.key, required this.child})
      : _maxWidth = null;

  const ContenidoEscritorio.tabla({super.key, required this.child})
      : _maxWidth = MBreak.tablaMaxWidth;

  final Widget child;
  final double? _maxWidth;

  @override
  Widget build(BuildContext context) {
    if (!esPantallaGrande(context)) return child;
    final tope = _maxWidth ??
        (esTactil
            ? MBreak.lecturaTactilMaxWidth
            : MBreak.desktopContentMaxWidth);
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: tope),
        child: child,
      ),
    );
  }
}
