/// El único lugar que decide en qué modo de pantalla está la app.
///
/// Las vistas no comparan anchos por su cuenta: preguntan acá. Si cada una
/// eligiera su propio umbral, el shell mostraría sidebar mientras una vista
/// sigue creyendo que está en un teléfono — que es exactamente lo que pasaba
/// con la PWA en escritorio: sidebar de 248 px y adentro un calendario de
/// celular estirado a 1300 px.
///
/// Todo es **fluido**, no por resolución: las grillas se arman por ancho
/// mínimo de celda y el contenido se centra con un tope. Así una notebook de
/// 1024, un monitor de 1600 y uno de 2560 se ven bien sin un caso especial
/// para cada uno.
library;

import 'package:flutter/widgets.dart';

import '../theme/tokens.dart';

enum ModoLayout { movil, tablet, escritorio }

/// El modo sale del tamaño ENTERO, no solo del ancho.
///
/// Un celular acostado mide más de 900 px de ancho (un Pixel 7 da 915) y por
/// ancho solo caería en el layout de la compu: sidebar de 248 px y tablas de
/// filas finas en una pantalla de 6 pulgadas. Lo que distingue a un teléfono
/// de una tablet es el **lado corto**: menos de 600 px es un teléfono, lo
/// pongas como lo pongas. Es el mismo criterio que usa Android con
/// `sw600dp`.
ModoLayout modoPara(Size tamano) {
  final esDispositivoGrande = tamano.shortestSide >= MBreak.tablet;
  if (tamano.width >= MBreak.desktop && esDispositivoGrande) {
    return ModoLayout.escritorio;
  }
  if (tamano.width >= MBreak.tablet) return ModoLayout.tablet;
  return ModoLayout.movil;
}

ModoLayout modoDe(BuildContext context) =>
    modoPara(MediaQuery.sizeOf(context));

bool esEscritorio(BuildContext context) =>
    modoDe(context) == ModoLayout.escritorio;

/// `.view { padding:16px 16px 96px }` en móvil: los 96 de abajo dejan pasar el
/// FAB y la barra de navegación. En escritorio no hay ni FAB ni barra, y el
/// CSS dice `30px 32px 40px`.
///
/// [sinArriba] es para la lista que va debajo de una [BarraVista]: la barra
/// ya puso el aire de arriba.
EdgeInsets padVista(BuildContext context, {bool sinArriba = false}) {
  final p = esEscritorio(context)
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

/// Centra el contenido de una vista en escritorio con un ancho tope. En móvil
/// y tablet no hace nada: el shell ya centra a 430 desde 600 px.
///
/// [lectura] es para Inicio, Stats, Ajustes (1040, el `max-width` del CSS).
/// [tabla] es para las vistas con listas largas o maestro-detalle: más ancho,
/// porque una tabla de clientas a 1040 desperdicia medio monitor, pero con
/// tope igual, porque a 2500 px una fila no se puede leer de punta a punta.
class ContenidoEscritorio extends StatelessWidget {
  const ContenidoEscritorio.lectura({super.key, required this.child})
      : maxWidth = MBreak.desktopContentMaxWidth;

  const ContenidoEscritorio.tabla({super.key, required this.child})
      : maxWidth = MBreak.tablaMaxWidth;

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    if (!esEscritorio(context)) return child;
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
