/// Las piezas de la segunda vuelta de diseño (§4 de `13-BRIEF-UI-UX.md`).
///
/// Todas viven acá y no en la vista que las estrenó, porque la gracia es que
/// sean **una sola**: hasta ahora había tres tarjetas de turno distintas —una
/// en Inicio, otra en la línea de tiempo, otra en la tabla— y cada arreglo
/// había que hacerlo tres veces, mal.
library;

import 'package:flutter/material.dart';

import '../../core/theme/motion.dart';
import '../../core/theme/shadows.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../domain/entities/entities.dart';
import '../../domain/rules/formatting.dart';
import '../../domain/rules/period.dart';

/// Los cinco tintes de la fila de acciones. El quinto no repite el lavanda
/// del primero: dos círculos iguales a 60 px se leen como el mismo botón.
enum TinteChip { lavanda, nude, exito, aviso, cielo }

extension _ColoresTinte on TinteChip {
  Color get fondo => switch (this) {
        TinteChip.lavanda => MColors.lav50,
        TinteChip.nude => MColors.nude100,
        TinteChip.exito => MColors.successBg,
        TinteChip.aviso => MColors.warningBg,
        TinteChip.cielo => MColors.skyBg,
      };

  Color get trazo => switch (this) {
        TinteChip.lavanda => MColors.lav700,
        // `nude700` y no `nude500`: el 500 no llega a 4,5:1 sobre el fondo.
        TinteChip.nude => MColors.nude700,
        TinteChip.exito => MColors.successText,
        TinteChip.aviso => MColors.warningText,
        TinteChip.cielo => MColors.sky700,
      };
}

/// Acción rápida: círculo tintado con el ícono y la etiqueta debajo.
///
/// Reemplaza a las seis tarjetas con emoji del Inicio. Emoji no: cada sistema
/// dibuja el suyo, y a 22 px un 📅 de Samsung y uno de Xiaomi no se parecen.
class ChipIcono extends StatelessWidget {
  const ChipIcono({
    super.key,
    required this.icono,
    required this.etiqueta,
    required this.tinte,
    this.onTap,
    this.lado = 56,
  });

  final IconData icono;
  final String etiqueta;
  final TinteChip tinte;

  /// Null = deshabilitado: se ve apagado pero **no se esconde**, para que la
  /// fila no cambie de forma según la clienta.
  final VoidCallback? onTap;

  /// 56 en el Inicio, 52 en la barra de acciones, 44 en escritorio.
  final double lado;

  @override
  Widget build(BuildContext context) {
    final off = onTap == null;
    return PressableScale(
      onTap: onTap,
      child: Opacity(
        opacity: off ? 0.45 : 1,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: lado,
              height: lado,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: off ? MColors.bg2 : tinte.fondo,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icono,
                size: lado * 0.39,
                color: off ? MColors.tMuted : tinte.trazo,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              etiqueta,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: sans(size: 11, weight: 500, color: MColors.tSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

/// Fila de acciones de una ficha: cinco chips repartidos.
///
/// El orden es fijo —lo más usado a la izquierda— y los que no aplican van
/// deshabilitados, no ausentes: una barra que cambia de forma según la
/// clienta obliga a leerla cada vez.
class BarraDeAcciones extends StatelessWidget {
  const BarraDeAcciones({super.key, required this.acciones, this.lado = 52});

  final List<ChipIcono> acciones;
  final double lado;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          for (final a in acciones)
            Expanded(
              child: ChipIcono(
                icono: a.icono,
                etiqueta: a.etiqueta,
                tinte: a.tinte,
                onTap: a.onTap,
                lado: lado,
              ),
            ),
        ],
      );
}

/// La tarjeta de turno, una sola para las cuatro pantallas.
///
/// [compacta] es la de 46 px (lista de escritorio y widget): sin píldora,
/// con un punto de color, y con la hora en su propia columna.
class TarjetaTurno extends StatelessWidget {
  const TarjetaTurno({
    super.key,
    required this.turno,
    this.nombreCliente,
    this.servicio,
    this.profesional,
    this.compacta = false,
    this.onTap,
    this.destacada = false,
  });

  final Appointment turno;
  final String? nombreCliente;
  final String? servicio;
  final String? profesional;
  final bool compacta;
  final VoidCallback? onTap;

  /// El próximo turno del día: fondo lavanda suave. Es la fila que se mira
  /// primero al abrir la app.
  final bool destacada;

  Color get _colorEstado => switch (turno.estado) {
        TurnoEstado.done => MColors.successText,
        TurnoEstado.pending => MColors.warningText,
        TurnoEstado.cancelled => MColors.dangerText,
        TurnoEstado.confirmed => MColors.brand,
      };

  String get _estadoTexto => switch (turno.estado) {
        TurnoEstado.done => 'Hecho',
        TurnoEstado.pending => 'Pendiente',
        TurnoEstado.cancelled => 'Cancelado',
        TurnoEstado.confirmed => 'Confirmado',
      };

  (Color, Color, Color) get _estadoColores => switch (turno.estado) {
        TurnoEstado.done => (
            MColors.successBg,
            MColors.successBorder,
            MColors.successText
          ),
        TurnoEstado.pending => (
            MColors.warningBg,
            MColors.warningBorder,
            MColors.warningText
          ),
        TurnoEstado.cancelled => (
            MColors.dangerBg,
            MColors.dangerBorder,
            MColors.dangerText
          ),
        TurnoEstado.confirmed => (MColors.lav50, MColors.lav200, MColors.lav700),
      };

  String get _subtitulo => [
        if (servicio?.isNotEmpty ?? false) servicio!,
        if (profesional?.isNotEmpty ?? false) 'con $profesional',
      ].join(' · ');

  @override
  Widget build(BuildContext context) {
    final cancelado = turno.estado == TurnoEstado.cancelled;
    final nombre = nombreCliente?.isNotEmpty ?? false
        ? nombreCliente!
        : (turno.notas?.isNotEmpty ?? false ? turno.notas! : 'Turno');
    final hora = turno.hora?.toString() ?? '';

    final contenido = compacta
        ? Row(
            children: [
              SizedBox(
                width: 38,
                child: Text(
                  hora,
                  style: sans(
                    size: 11.5,
                    weight: 600,
                    tabular: true,
                    color: destacada ? MColors.brandDark : MColors.tSecondary,
                  ),
                ),
              ),
              _Avatar(nombre: nombre, lado: 28, cancelado: cancelado),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      nombre,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: sans(size: 12.5, weight: 600).copyWith(
                        decoration:
                            cancelado ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    if (_subtitulo.isNotEmpty)
                      Text(
                        _subtitulo,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: sans(size: 11, color: MColors.tMuted),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Punto en vez de píldora: en una fila de 46 px la píldora se
              // come el ancho del nombre.
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: _colorEstado,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          )
        : Row(
            children: [
              _Avatar(nombre: nombre, lado: 42, cancelado: cancelado),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            nombre,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: sans(size: 14, weight: 600).copyWith(
                              decoration: cancelado
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: cancelado ? MColors.tMuted : null,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _PildoraEstado(
                          texto: _estadoTexto,
                          colores: _estadoColores,
                        ),
                      ],
                    ),
                    if (_subtitulo.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        _subtitulo,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: sans(size: 12, color: MColors.tSecondary),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (hora.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: turno.estado == TurnoEstado.done
                            ? MColors.bg2
                            : MColors.lav50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        hora,
                        style: sans(
                          size: 12,
                          weight: 700,
                          tabular: true,
                          color: turno.estado == TurnoEstado.done
                              ? MColors.tSecondary
                              : MColors.lav700,
                        ),
                      ),
                    ),
                  if (turno.precio > 0) ...[
                    const SizedBox(height: 4),
                    Text(
                      formatMoney(turno.precio),
                      // El único número grande de la fila.
                      style: serif(
                        size: 17,
                        weight: 600,
                        color: cancelado ? MColors.tLight : MColors.tPrimary,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          );

    return Padding(
      padding: EdgeInsets.only(bottom: compacta ? 6 : 9),
      child: PressableScale(
        onTap: onTap,
        child: Opacity(
          opacity: cancelado ? 0.6 : 1,
          child: Container(
            // Alto MÍNIMO, no fijo: con el texto del sistema en grande la
            // tarjeta tiene que crecer, no recortar el nombre.
            constraints: BoxConstraints(minHeight: compacta ? 46 : 68),
            padding: EdgeInsets.symmetric(
              horizontal: compacta ? 12 : 13,
              vertical: compacta ? 9 : 12,
            ),
            decoration: BoxDecoration(
              color: destacada ? MColors.lav50 : MColors.surface,
              border: Border.all(
                color: destacada ? MColors.lav200 : MColors.border,
              ),
              borderRadius:
                  BorderRadius.circular(compacta ? MRadius.md : MRadius.lg),
              boxShadow: compacta ? null : MShadow.xs,
            ),
            child: contenido,
          ),
        ),
      ),
    );
  }
}

class _PildoraEstado extends StatelessWidget {
  const _PildoraEstado({required this.texto, required this.colores});

  final String texto;
  final (Color, Color, Color) colores;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
        decoration: BoxDecoration(
          color: colores.$1,
          border: Border.all(color: colores.$2),
          borderRadius: BorderRadius.circular(MRadius.full),
        ),
        child: Text(
          texto,
          style: sans(size: 10, weight: 600, color: colores.$3),
        ),
      );
}

/// Avatar con las iniciales sobre el gradiente que le toca al nombre.
class _Avatar extends StatelessWidget {
  const _Avatar({
    required this.nombre,
    required this.lado,
    this.cancelado = false,
  });

  final String nombre;
  final double lado;
  final bool cancelado;

  @override
  Widget build(BuildContext context) => Container(
        width: lado,
        height: lado,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          // Cancelado sin gradiente: el color es para lo que está vivo.
          color: cancelado ? MColors.bg2 : null,
          gradient:
              cancelado ? null : MGradient.avatar(avatarIndex(nombre)),
          shape: BoxShape.circle,
        ),
        child: Text(
          initials(nombre),
          style: sans(
            size: lado * 0.36,
            weight: 700,
            color: cancelado ? MColors.tMuted : MColors.tWhite,
          ),
        ),
      );
}

/// Avatar público, para las vistas que arman su propia fila.
class AvatarMirame extends StatelessWidget {
  const AvatarMirame({super.key, required this.nombre, this.lado = 42});

  final String nombre;
  final double lado;

  @override
  Widget build(BuildContext context) => _Avatar(nombre: nombre, lado: lado);
}

/// Tira de siete días. Reemplaza al calendario del mes como vista por
/// defecto de la Agenda: el mes entero ocupaba media pantalla para contestar
/// una pregunta —"¿qué hay hoy?"— que se contesta con una fila.
class TiraSemanal extends StatelessWidget {
  const TiraSemanal({
    super.key,
    required this.diaElegido,
    required this.diasConTurno,
    required this.onElegirDia,
  });

  final DateTime diaElegido;

  /// Claves `YYYY-MM-DD` con al menos un turno.
  final Set<String> diasConTurno;
  final ValueChanged<DateTime> onElegirDia;

  static const _nombres = ['DOM', 'LUN', 'MAR', 'MIÉ', 'JUE', 'VIE', 'SÁB'];

  @override
  Widget build(BuildContext context) {
    // La semana del día elegido, arrancando en domingo como el calendario.
    final inicio = diaElegido.subtract(Duration(days: diaElegido.weekday % 7));
    final hoy = claveFecha(DateTime.now());
    final elegido = claveFecha(diaElegido);

    return Row(
      children: [
        for (var i = 0; i < 7; i++)
          Builder(
            builder: (_) {
              final d = DateTime(inicio.year, inicio.month, inicio.day + i);
              final clave = claveFecha(d);
              final esElegido = clave == elegido;
              final esHoy = clave == hoy;
              final tiene = diasConTurno.contains(clave);
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: PressableScale(
                    onTap: () => onElegirDia(d),
                    child: AnimatedContainer(
                      duration: MMotion.t1,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: esElegido ? MColors.brand : Colors.transparent,
                        borderRadius: BorderRadius.circular(14),
                        // Hoy + elegido a la vez: gana el fondo.
                        border: esHoy && !esElegido
                            ? Border.all(color: MColors.lav200, width: 1.5)
                            : null,
                        boxShadow: esElegido ? MShadow.brand : null,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _nombres[d.weekday % 7],
                            style: sans(
                              size: 10,
                              weight: 600,
                              color: esElegido
                                  ? MColors.tWhite
                                  : MColors.tMuted,
                            ).copyWith(letterSpacing: 0.3),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${d.day}',
                            style: serif(
                              size: 20,
                              weight: 600,
                              color: esElegido
                                  ? MColors.tWhite
                                  : esHoy
                                      ? MColors.lav700
                                      : MColors.tPrimary,
                            ).copyWith(height: 1),
                          ),
                          const SizedBox(height: 4),
                          // El punto vive SIEMPRE en la misma línea base,
                          // tenga turno o no: si no, la tira salta de alto al
                          // cambiar de semana.
                          Container(
                            width: 5,
                            height: 5,
                            decoration: BoxDecoration(
                              color: !tiene
                                  ? Colors.transparent
                                  : esElegido
                                      ? MColors.tWhite
                                      : MColors.lav300,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}

/// Interruptor de dos opciones (Semana / Mes).
class SelectorDeVista extends StatelessWidget {
  const SelectorDeVista({
    super.key,
    required this.opciones,
    required this.activa,
    required this.onElegir,
  });

  final List<String> opciones;
  final String activa;
  final ValueChanged<String> onElegir;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: MColors.bg2,
          borderRadius: BorderRadius.circular(MRadius.full),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final o in opciones)
              PressableScale(
                onTap: () => onElegir(o),
                child: AnimatedContainer(
                  duration: MMotion.t1,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: o == activa ? MColors.surface : Colors.transparent,
                    borderRadius: BorderRadius.circular(MRadius.full),
                    boxShadow: o == activa ? MShadow.xs : null,
                  ),
                  child: Text(
                    o,
                    style: sans(
                      size: 11.5,
                      weight: o == activa ? 600 : 500,
                      color:
                          o == activa ? MColors.tPrimary : MColors.tMuted,
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
}

/// Pila de avatares superpuestos: quiénes trabajan hoy.
class PilaDeAvatares extends StatelessWidget {
  const PilaDeAvatares({super.key, required this.nombres, this.lado = 30});

  final List<String> nombres;
  final double lado;

  @override
  Widget build(BuildContext context) {
    if (nombres.isEmpty) return const SizedBox.shrink();
    final visibles = nombres.take(4).toList();
    return SizedBox(
      height: lado,
      width: lado + (visibles.length - 1) * (lado - 9),
      child: Stack(
        children: [
          for (var i = 0; i < visibles.length; i++)
            Positioned(
              left: i * (lado - 9),
              child: Container(
                decoration: const BoxDecoration(
                  color: MColors.surface,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(2),
                child: _Avatar(nombre: visibles[i], lado: lado - 4),
              ),
            ),
        ],
      ),
    );
  }
}

/// Tabs con subrayado, para la ficha y el detalle de producto.
class TabsMirame extends StatelessWidget {
  const TabsMirame({
    super.key,
    required this.tabs,
    required this.activa,
    required this.onElegir,
  });

  final List<String> tabs;
  final String activa;
  final ValueChanged<String> onElegir;

  @override
  Widget build(BuildContext context) => Container(
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: MColors.border)),
        ),
        child: Row(
          children: [
            for (final t in tabs)
              Padding(
                padding: const EdgeInsets.only(right: 22),
                child: PressableScale(
                  escala: 1,
                  onTap: () => onElegir(t),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: t == activa
                              ? MColors.brand
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                    child: Text(
                      t,
                      style: sans(
                        size: 13,
                        weight: t == activa ? 600 : 500,
                        color: t == activa ? MColors.lav700 : MColors.tMuted,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
}

/// El botón grande del pie, con el degradé que deja pasar el contenido por
/// debajo sin cortarlo.
class CtaFijo extends StatelessWidget {
  const CtaFijo({
    super.key,
    required this.texto,
    required this.onTap,
    this.icono,
    this.conDegrade = true,
  });

  final String texto;
  final VoidCallback? onTap;
  final IconData? icono;

  /// En un diálogo de escritorio el CTA va al pie con borde superior y sin
  /// degradé: no hay nada que se le pase por abajo.
  final bool conDegrade;

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (conDegrade)
            Container(
              height: 54,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x00FAF8F5), MColors.bg],
                ),
              ),
            ),
          Container(
            width: double.infinity,
            color: conDegrade ? MColors.bg : MColors.surface,
            padding: EdgeInsets.fromLTRB(16, conDegrade ? 0 : 14, 16, 16),
            child: SafeArea(
              top: false,
              child: PressableScale(
                onTap: onTap,
                child: Container(
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: onTap == null ? MColors.bg3 : MColors.brand,
                    borderRadius: BorderRadius.circular(MRadius.full),
                    boxShadow: onTap == null ? null : MShadow.brand,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icono != null) ...[
                        Icon(icono, size: 18, color: MColors.tWhite),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        texto,
                        style: sans(
                            size: 15, weight: 600, color: MColors.tWhite),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      );
}
