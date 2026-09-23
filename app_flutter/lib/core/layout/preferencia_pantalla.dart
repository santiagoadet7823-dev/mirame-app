/// El interruptor de Ajustes → Pantalla, y lo que el aparato dice de sí mismo.
///
/// Por qué existe: `modoPara` decide por el tamaño en píxeles **lógicos**, y
/// hay aparatos que mienten. Una tablet de 1280×800 de marca blanca que reporta
/// densidad 1,5 entrega 853×533 lógicos, y con eso caía en la composición del
/// teléfono — la app vertical con los laterales vacíos — mientras todo el
/// trabajo de tablet quedaba escrito y sin ejecutarse.
///
/// Ningún umbral acierta con todos los aparatos, así que hay dos cosas: se
/// puede forzar el modo a mano, y la app muestra lo que mide. Con eso, un
/// aparato raro se resuelve en el momento y no esperando otra release.
library;

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/local/database.dart' show guardadoWeb;
import 'layout.dart';

/// Clave de la preferencia. Ausente = automático.
const _kModoPantalla = 'mirame.modo_pantalla';

/// El modo elegido a mano, persistido.
///
/// Arranca en [ModoPantalla.automatico] y se corrige cuando
/// `SharedPreferences` contesta. Eso significa que el primer frame puede salir
/// en automático y reacomodarse enseguida; es preferible a bloquear el arranque
/// esperando el disco.
class PreferenciaPantalla extends Notifier<ModoPantalla> {
  @override
  ModoPantalla build() {
    _leer();
    return ModoPantalla.automatico;
  }

  Future<void> _leer() async {
    final p = await SharedPreferences.getInstance();
    final guardado = p.getString(_kModoPantalla);
    if (guardado == null) return;
    final modo = ModoPantalla.values.where((m) => m.name == guardado).firstOrNull;
    if (modo != null) state = modo;
  }

  Future<void> elegir(ModoPantalla modo) async {
    state = modo;
    final p = await SharedPreferences.getInstance();
    await p.setString(_kModoPantalla, modo.name);
  }
}

final preferenciaPantallaProvider =
    NotifierProvider<PreferenciaPantalla, ModoPantalla>(
  PreferenciaPantalla.new,
);

/// Lo que el aparato mide, para poder leerlo en voz alta.
///
/// Es el dato que faltó toda esta vuelta: sin saber qué devuelve
/// `MediaQuery.sizeOf` en la tablet de verdad, cualquier umbral es una
/// adivinanza.
class MedidaDePantalla {
  const MedidaDePantalla({
    required this.logico,
    required this.fisico,
    required this.densidad,
    required this.modo,
    required this.tactil,
  });

  factory MedidaDePantalla.de(BuildContext context) {
    final mq = MediaQuery.of(context);
    return MedidaDePantalla(
      logico: mq.size,
      fisico: View.of(context).physicalSize,
      densidad: mq.devicePixelRatio,
      modo: esPantallaGrande(context) ? ModoLayout.grande : ModoLayout.movil,
      tactil: esTactil,
    );
  }

  final Size logico;
  final Size fisico;
  final double densidad;
  final ModoLayout modo;
  final bool tactil;

  String get resumen {
    final l = '${logico.width.round()}×${logico.height.round()}';
    final f = '${fisico.width.round()}×${fisico.height.round()}';
    final d = densidad.toStringAsFixed(2);
    final m = modo == ModoLayout.grande
        ? (tactil ? 'tablet' : 'escritorio')
        : 'teléfono';
    return '$l lógicos · $f reales · densidad $d · $m';
  }

  /// Dónde guarda la PWA, o null en el APK.
  ///
  /// Se muestra porque una PWA que degradó a memoria —y por lo tanto pierde
  /// todo al cerrar la ventana— se ve **exactamente igual** que una sana.
  String? get guardado => guardadoWeb;
}
