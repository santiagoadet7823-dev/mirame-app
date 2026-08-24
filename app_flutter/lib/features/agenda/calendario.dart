/// Calendario del mes. Portado del `renderCal()` y del `.cal-*` del CSS.
///
/// ```
/// .cal-wrap      { es una .card, margin-bottom 14 }
/// .cal-hdr       { padding 16px 18px 10px; flechas a los costados }
/// .cal-nav-btn   { 32x32; círculo; bg2 con borde }
/// .cal-month-lbl { Cormorant 17/600; letter-spacing .2 }
/// .cal-grid      { 7 columnas; gap 2; padding 0 12px 14px }
/// .cal-dh        { 10px/600; t-muted — DO LU MA MI JU VI SA }
/// .cal-d         { cuadrado, círculo, 13px/400, t-secondary }
/// .cal-d.today   { fondo brand, texto blanco, 700 }
/// .cal-d.sel     { brand-bg, lav-700, 600, borde 1.5 border-lav }
/// .cal-d.other   { t-light — los días del mes vecino }
/// .cal-d.has::after { punto de 4px abajo, brand al 60% }
/// ```
library;

import 'package:flutter/material.dart';

import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../domain/rules/period.dart';
import '../../domain/rules/formatting.dart';
import '../shell/vistas_comunes.dart';

class CalendarioMes extends StatelessWidget {
  const CalendarioMes({
    super.key,
    required this.mes,
    required this.diaElegido,
    required this.diasConTurno,
    required this.onElegirDia,
    required this.onCambiarMes,
  });

  /// Cualquier día del mes que se muestra.
  final DateTime mes;
  final DateTime diaElegido;

  /// Claves `YYYY-MM-DD` que tienen al menos un turno: llevan el puntito.
  final Set<String> diasConTurno;

  final ValueChanged<DateTime> onElegirDia;

  /// `+1` mes siguiente, `-1` anterior.
  final ValueChanged<int> onCambiarMes;

  @override
  Widget build(BuildContext context) {
    final hoy = DateTime.now();
    final claveHoy = claveFecha(hoy);
    final claveSel = claveFecha(diaElegido);

    // `getDay()` de JS: domingo = 0. `weekday` de Dart: lunes = 1, domingo = 7.
    final primero = DateTime(mes.year, mes.month, 1);
    final huecoInicial = primero.weekday % 7;
    final diasDelMes = DateTime(mes.year, mes.month + 1, 0).day;
    final diasMesAnterior = DateTime(mes.year, mes.month, 0).day;

    final celdas = <Widget>[];

    // Cola del mes anterior, en gris.
    for (var i = huecoInicial - 1; i >= 0; i--) {
      celdas.add(_Dia(numero: diasMesAnterior - i, deOtroMes: true));
    }

    for (var d = 1; d <= diasDelMes; d++) {
      final fecha = DateTime(mes.year, mes.month, d);
      final clave = claveFecha(fecha);
      celdas.add(
        _Dia(
          numero: d,
          esHoy: clave == claveHoy,
          // El original no marca "sel" si además es hoy: hoy ya se distingue
          // solo, y superponer los dos estados se ve sucio.
          esElegido: clave == claveSel && clave != claveHoy,
          tieneTurno: diasConTurno.contains(clave),
          onTap: () => onElegirDia(fecha),
        ),
      );
    }

    // Relleno hasta completar la última semana.
    final resto = (huecoInicial + diasDelMes) % 7;
    if (resto != 0) {
      for (var i = 1; i <= 7 - resto; i++) {
        celdas.add(_Dia(numero: i, deOtroMes: true));
      }
    }

    return TarjetaMirame(
      margenInferior: 14,
      padding: EdgeInsets.zero,
      hijo: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _BotonNav(simbolo: '‹', onTap: () => onCambiarMes(-1)),
                Text(
                  // "Agosto 2026" — el original capitaliza el mes.
                  '${monthName(mes.month)} ${mes.year}',
                  style: serif(size: 17, weight: 600)
                      .copyWith(letterSpacing: 0.2),
                ),
                _BotonNav(simbolo: '›', onTap: () => onCambiarMes(1)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 14),
            child: Column(
              children: [
                Row(
                  children: [
                    for (final d in const ['DO', 'LU', 'MA', 'MI', 'JU',
                        'VI', 'SA'])
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: Text(
                            d,
                            textAlign: TextAlign.center,
                            style: sans(
                              size: 10,
                              weight: 600,
                              color: MColors.tMuted,
                            ).copyWith(letterSpacing: 0.3),
                          ),
                        ),
                      ),
                  ],
                ),
                GridView.count(
                  crossAxisCount: 7,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 2,
                  crossAxisSpacing: 2,
                  // `aspect-ratio: 1` — las celdas son cuadradas.
                  childAspectRatio: 1,
                  children: celdas,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BotonNav extends StatelessWidget {
  const _BotonNav({required this.simbolo, required this.onTap});

  final String simbolo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: MColors.bg2,
            shape: BoxShape.circle,
            border: Border.all(color: MColors.border),
          ),
          child: Text(
            simbolo,
            style: sans(size: 16, color: MColors.tSecondary),
          ),
        ),
      );
}

class _Dia extends StatelessWidget {
  const _Dia({
    required this.numero,
    this.esHoy = false,
    this.esElegido = false,
    this.tieneTurno = false,
    this.deOtroMes = false,
    this.onTap,
  });

  final int numero;
  final bool esHoy;
  final bool esElegido;
  final bool tieneTurno;
  final bool deOtroMes;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = deOtroMes
        ? MColors.tLight
        : esHoy
            ? MColors.tWhite
            : esElegido
                ? MColors.lav700
                : MColors.tSecondary;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: MMotion.t1,
        decoration: BoxDecoration(
          color: esHoy
              ? MColors.brand
              : esElegido
                  ? MColors.brandBg
                  : Colors.transparent,
          shape: BoxShape.circle,
          border: esElegido
              ? Border.all(color: MColors.borderLav, width: 1.5)
              : null,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              '$numero',
              style: sans(
                size: 13,
                weight: esHoy ? 700 : (esElegido ? 600 : 400),
                color: color,
              ),
            ),
            // `.cal-d.has::after` — el punto que avisa que ese día hay turnos.
            // Sobre "hoy" va blanco, porque el lavanda sobre lavanda no se ve.
            if (tieneTurno && !deOtroMes)
              Positioned(
                bottom: 4,
                child: Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: esHoy
                        ? MColors.tWhite
                        : MColors.brand.withValues(alpha: 0.6),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
