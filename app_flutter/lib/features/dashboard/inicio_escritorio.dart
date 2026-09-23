/// El Inicio de la PWA en la compu del salón.
///
/// En escritorio la KPI hero del teléfono se estiraba a mil píxeles para
/// mostrar cuatro números, y la agenda del día quedaba al lado, vacía y
/// enorme. Acá el mismo contenido se reparte distinto: cuatro tarjetas de
/// KPI arriba, el gráfico ocupando el espacio que sobraba, y la agenda en
/// una columna angosta donde una lista compacta se lee mejor que una tarjeta
/// gigante.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/theme/shadows.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../domain/entities/entities.dart';
import '../../shared/widgets/piezas.dart';

/// Una tarjeta de KPI: etiqueta, número grande, variación y una línea de pie.
class TarjetaKpi extends StatelessWidget {
  const TarjetaKpi({
    super.key,
    required this.etiqueta,
    required this.valor,
    this.variacion,
    this.tono = TonoVariacion.neutro,
    this.pie,
  });

  final String etiqueta;
  final String valor;

  /// "▲ 12 %", "▼ 4 %", "a confirmar". Va en TEXTO y no en píldora: cuatro
  /// píldoras de color seguidas pesan más que el gráfico que tienen al lado.
  final String? variacion;
  final TonoVariacion tono;
  final String? pie;

  Color get _color => switch (tono) {
        TonoVariacion.sube => MColors.successText,
        TonoVariacion.baja => MColors.dangerText,
        TonoVariacion.atencion => MColors.warningText,
        TonoVariacion.neutro => MColors.tMuted,
      };

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
        decoration: BoxDecoration(
          color: MColors.surface,
          border: Border.all(color: MColors.border),
          borderRadius: BorderRadius.circular(MRadius.lg),
          boxShadow: MShadow.xs,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              etiqueta.toUpperCase(),
              style: sans(size: 10.5, weight: 600, color: MColors.tMuted)
                  .copyWith(letterSpacing: 1.2),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Flexible(
                  child: Text(
                    valor,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: serif(size: 34, weight: 500).copyWith(height: 1),
                  ),
                ),
                if (variacion != null) ...[
                  const SizedBox(width: 8),
                  Text(
                    variacion!,
                    style: sans(size: 12, weight: 600, color: _color),
                  ),
                ],
              ],
            ),
            if (pie != null) ...[
              const SizedBox(height: 6),
              Text(
                pie!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: sans(size: 11.5, color: MColors.tMuted),
              ),
            ],
          ],
        ),
      );
}

enum TonoVariacion { sube, baja, atencion, neutro }

/// Gráfico de área de dos series, en pastel.
///
/// Dibuja lo que hay: si una sola semana tiene datos no hay curva que valga,
/// así que muestra el estado vacío en vez de una línea recta que miente.
class GraficoDeArea extends StatelessWidget {
  const GraficoDeArea({
    super.key,
    required this.serieA,
    required this.serieB,
    required this.etiquetas,
    this.nombreA = 'Servicios',
    this.nombreB = 'Tienda',
    this.alto = 200,
  });

  final List<num> serieA;
  final List<num> serieB;
  final List<String> etiquetas;
  final String nombreA;
  final String nombreB;
  final double alto;

  bool get _hayDatos =>
      serieA.length >= 2 &&
      (serieA.any((v) => v > 0) || serieB.any((v) => v > 0));

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
        decoration: BoxDecoration(
          color: MColors.surface,
          border: Border.all(color: MColors.border),
          borderRadius: BorderRadius.circular(MRadius.lg),
          boxShadow: MShadow.xs,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Ingresos por semana',
                    style: serif(size: 22, weight: 500),
                  ),
                ),
                _Leyenda(color: MColors.brand, texto: nombreA),
                const SizedBox(width: 12),
                _Leyenda(color: MColors.nude400, texto: nombreB),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Últimas ${serieA.length} semanas',
              style: sans(size: 12, color: MColors.tMuted),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: _hayDatos
                  ? CustomPaint(
                      painter: _PintorDeArea(serieA: serieA, serieB: serieB),
                      child: const SizedBox.expand(),
                    )
                  : Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Todavía no hay movimientos',
                            style: sans(
                                size: 14,
                                weight: 600,
                                color: MColors.tSecondary),
                          ),
                          const SizedBox(height: 6),
                          SizedBox(
                            width: 300,
                            child: Text(
                              'El gráfico aparece cuando haya al menos dos '
                              'semanas cargadas en Caja.',
                              textAlign: TextAlign.center,
                              style:
                                  sans(size: 12, color: MColors.tMuted),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
            if (_hayDatos && etiquetas.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (final e in etiquetas)
                    Text(
                      e,
                      style: sans(size: 10.5, color: MColors.tMuted),
                    ),
                ],
              ),
            ],
          ],
        ),
      );
}

class _Leyenda extends StatelessWidget {
  const _Leyenda({required this.color, required this.texto});

  final Color color;
  final String texto;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 6),
          Text(texto, style: sans(size: 11, color: MColors.tSecondary)),
        ],
      );
}

class _PintorDeArea extends CustomPainter {
  _PintorDeArea({required this.serieA, required this.serieB});

  final List<num> serieA;
  final List<num> serieB;

  @override
  void paint(Canvas canvas, Size size) {
    // Una escala común para las dos series: escalas distintas harían que la
    // más chica se vea igual de alta que la grande, que es mentir con un
    // gráfico.
    final maximo = [
      ...serieA,
      ...serieB,
    ].fold<num>(1, (a, b) => b > a ? b : a);

    final guia = Paint()
      ..color = const Color(0x0E000000)
      ..strokeWidth = 1;
    for (var i = 0; i <= 3; i++) {
      final y = size.height * i / 3;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), guia);
    }

    void serie(List<num> datos, Color color) {
      if (datos.length < 2) return;
      final paso = size.width / (datos.length - 1);
      final puntos = [
        for (var i = 0; i < datos.length; i++)
          Offset(i * paso, size.height * (1 - datos[i] / maximo)),
      ];

      final relleno = Path()..moveTo(0, size.height);
      for (final p in puntos) {
        relleno.lineTo(p.dx, p.dy);
      }
      relleno
        ..lineTo(size.width, size.height)
        ..close();

      canvas.drawPath(
        relleno,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              color.withValues(alpha: 0.45),
              color.withValues(alpha: 0),
            ],
          ).createShader(Offset.zero & size),
      );

      final linea = Path()..moveTo(puntos.first.dx, puntos.first.dy);
      for (final p in puntos.skip(1)) {
        linea.lineTo(p.dx, p.dy);
      }
      canvas.drawPath(
        linea,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.2
          ..strokeJoin = StrokeJoin.round,
      );

      // El punto del final: es el dato de esta semana, el que se busca.
      canvas.drawCircle(
        puntos.last,
        4.5,
        Paint()..color = MColors.surface,
      );
      canvas.drawCircle(
        puntos.last,
        4.5,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.2,
      );
    }

    serie(serieB, MColors.nude400);
    serie(serieA, MColors.brand);
  }

  // Por contenido y no por identidad: las listas se arman de nuevo en cada
  // build, así que comparar las referencias daba `true` siempre y el gráfico
  // se repintaba en cada frame aunque los números fueran los mismos.
  @override
  bool shouldRepaint(_PintorDeArea viejo) =>
      !listEquals(viejo.serieA, serieA) || !listEquals(viejo.serieB, serieB);
}

/// La agenda del día en la columna angosta del escritorio.
class AgendaCompacta extends StatelessWidget {
  const AgendaCompacta({
    super.key,
    required this.turnos,
    required this.nombrePorId,
    required this.nombreProfesional,
    required this.idProximo,
    required this.onVerAgenda,
  });

  final List<Appointment> turnos;
  final Map<String, String> nombrePorId;
  final Map<String, String> nombreProfesional;
  final String? idProximo;
  final VoidCallback onVerAgenda;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 10),
        decoration: BoxDecoration(
          color: MColors.surface,
          border: Border.all(color: MColors.border),
          borderRadius: BorderRadius.circular(MRadius.lg),
          boxShadow: MShadow.xs,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Agenda de hoy',
                    style: serif(size: 22, weight: 500),
                  ),
                ),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onVerAgenda,
                  child: Text(
                    'Ver agenda',
                    style: sans(
                        size: 12, weight: 600, color: MColors.brandDark),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: turnos.isEmpty
                  ? Center(
                      child: Text(
                        'Sin turnos hoy',
                        style: sans(size: 13, color: MColors.tMuted),
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: turnos.length,
                      itemBuilder: (_, i) => TarjetaTurno(
                        turno: turnos[i],
                        compacta: true,
                        nombreCliente: nombrePorId[turnos[i].clientId],
                        profesional:
                            nombreProfesional[turnos[i].professionalId],
                        destacada: turnos[i].id == idProximo,
                        onTap: onVerAgenda,
                      ),
                    ),
            ),
          ],
        ),
      );
}

/// Formatea una variación como "▲ 12 %" / "▼ 4 %" / "= sin cambio".
(String, TonoVariacion) variacionTexto(num actual, num anterior) {
  if (anterior <= 0) {
    return (actual > 0 ? 'primera semana' : '', TonoVariacion.neutro);
  }
  final pct = ((actual - anterior) / anterior * 100).round();
  if (pct == 0) return ('= sin cambio', TonoVariacion.neutro);
  // Triángulos del sistema y no íconos propios: alineados con el número,
  // cualquier ícono de 12 px se despega de la línea base.
  return pct > 0
      ? ('▲ $pct %', TonoVariacion.sube)
      : ('▼ ${pct.abs()} %', TonoVariacion.baja);
}

/// La suma de una lista de movimientos de ingreso.
num sumaIngresos(Iterable<Transaction> movimientos) => movimientos
    .where((m) => m.tipo == TxTipo.income)
    .fold<num>(0, (a, m) => a + m.monto);
