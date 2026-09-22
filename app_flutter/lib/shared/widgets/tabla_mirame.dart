/// Tabla de datos para escritorio.
///
/// No existe en el `index.html` original, que era una app de teléfono: allá
/// una lista es una pila de tarjetas. En un monitor, cien tarjetas de 1300 px
/// con tres datos cada una desperdician la pantalla y obligan a scrollear
/// para comparar dos clientas. Una tabla muestra veinte por pantalla, se
/// ordena por cualquier columna y es lo que cualquiera espera de un sistema
/// de gestión.
///
/// Se dibuja con los tokens de siempre (`.card`, etiquetas de sección,
/// numerales tabulares) y NO con `DataTable`, que trae el look Material.
/// Desvío documentado en `02-DESIGN-SYSTEM.md` §11.
library;

import 'package:flutter/material.dart';

import '../../core/theme/motion.dart';
import '../../core/theme/shadows.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import 'comportamiento.dart';

/// Una columna: qué muestra, cuánto mide y cómo se ordena.
class ColumnaTabla<T> {
  const ColumnaTabla({
    required this.titulo,
    required this.celda,
    this.ancho,
    this.flex = 1,
    this.numerica = false,
    this.ordenarPor,
    this.opcional = false,
  });

  final String titulo;
  final Widget Function(BuildContext context, T fila) celda;

  /// Ancho fijo. Si es null, la columna reparte lo que sobra según [flex].
  final double? ancho;
  final int flex;

  /// Alineada a la derecha, como corresponde a cantidades y montos.
  final bool numerica;

  /// Clave de orden. Null = no se puede ordenar por esta columna.
  final Comparable<dynamic> Function(T fila)? ordenarPor;

  /// Se puede esconder si no entra. Con el panel lateral abierto la tabla
  /// pierde 400 px; antes que aplastar todo o scrollear de costado, se
  /// sacan las columnas que no hacen falta para reconocer la fila (la fecha
  /// de alta, el teléfono), de la última hacia la primera.
  final bool opcional;
}

/// Texto de celda con el estilo por defecto: 13 px, tabular si es número.
class CeldaTexto extends StatelessWidget {
  const CeldaTexto(
    this.texto, {
    super.key,
    this.peso = 400,
    this.color,
    this.numerica = false,
  });

  final String texto;
  final int peso;
  final Color? color;
  final bool numerica;

  @override
  Widget build(BuildContext context) => Text(
        texto,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: numerica ? TextAlign.right : TextAlign.left,
        style: sans(
          size: 13,
          weight: peso,
          color: color ?? MColors.tPrimary,
          tabular: numerica,
        ),
      );
}

class TablaMirame<T> extends StatefulWidget {
  const TablaMirame({
    super.key,
    required this.columnas,
    required this.filas,
    this.claveDe,
    this.seleccionada,
    this.onTap,
    this.vacio,
    this.altoFila = 52,
    this.expandir = true,
    this.ordenInicial,
  });

  final List<ColumnaTabla<T>> columnas;
  final List<T> filas;

  /// Identidad de una fila, para marcar la seleccionada aunque el objeto se
  /// haya vuelto a leer de la base.
  final Object Function(T fila)? claveDe;
  final Object? seleccionada;
  final void Function(T fila)? onTap;

  /// Qué mostrar sin filas (normalmente un `EstadoVacio`).
  final Widget? vacio;
  final double altoFila;

  /// `true`: la tabla toma el alto disponible y las filas scrollean adentro
  /// (para una vista que es solo la tabla). `false`: se dibuja completa, para
  /// vivir dentro de un `ListView` con otras cosas arriba.
  final bool expandir;

  /// Columna por la que arranca ordenada (índice) y sentido.
  final ({int columna, bool ascendente})? ordenInicial;

  @override
  State<TablaMirame<T>> createState() => _TablaMirameState<T>();
}

class _TablaMirameState<T> extends State<TablaMirame<T>> {
  int? _columnaOrden;
  bool _ascendente = true;

  @override
  void initState() {
    super.initState();
    _columnaOrden = widget.ordenInicial?.columna;
    _ascendente = widget.ordenInicial?.ascendente ?? true;
  }

  List<T> get _ordenadas {
    final c = _columnaOrden;
    if (c == null) return widget.filas;
    final clave = widget.columnas[c].ordenarPor;
    if (clave == null) return widget.filas;
    final copia = [...widget.filas];
    // Orden estable: dos filas iguales quedan como venían.
    final indexado = copia.asMap().entries.toList()
      ..sort((a, b) {
        final r = clave(a.value).compareTo(clave(b.value));
        if (r != 0) return _ascendente ? r : -r;
        return a.key.compareTo(b.key);
      });
    return indexado.map((e) => e.value).toList();
  }

  void _ordenarPor(int i) => setState(() {
        if (_columnaOrden == i) {
          _ascendente = !_ascendente;
        } else {
          _columnaOrden = i;
          _ascendente = true;
        }
      });

  static const _gap = 20.0;

  /// Ancho mínimo para que ninguna columna se aplaste: las fijas completas,
  /// 110 por cada flexible, más los espacios.
  static double _anchoMinimo(List<ColumnaTabla<dynamic>> cols) =>
      cols.fold<double>(
        32 + _gap * (cols.length - 1),
        (acc, c) => acc + (c.ancho ?? 110.0 * c.flex),
      );

  /// Las columnas que entran en [ancho]: se van sacando las opcionales, de
  /// atrás para adelante, hasta que el mínimo quepa.
  List<ColumnaTabla<T>> _visibles(double ancho) {
    var cols = widget.columnas;
    while (_anchoMinimo(cols) > ancho) {
      final i = cols.lastIndexWhere((c) => c.opcional);
      if (i < 0) break;
      cols = [...cols]..removeAt(i);
    }
    return cols;
  }

  Widget _celda(ColumnaTabla<T> c, Widget hijo) {
    final alineado = Align(
      alignment: c.numerica ? Alignment.centerRight : Alignment.centerLeft,
      child: hijo,
    );
    return c.ancho != null
        ? SizedBox(width: c.ancho, child: alineado)
        : Expanded(flex: c.flex, child: alineado);
  }

  Widget _cabecera(List<ColumnaTabla<T>> cols, {bool hayArriba = false}) =>
      AnimatedContainer(
        duration: MMotion.t1,
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: MColors.bg2,
          border: const Border(bottom: BorderSide(color: MColors.border)),
          // La cabecera se queda quieta mientras las filas pasan por debajo;
          // la sombra es lo único que avisa que hay filas más arriba.
          boxShadow: sombraEncabezado(hayArriba),
        ),
        child: Row(
          children: [
            for (var i = 0; i < cols.length; i++) ...[
              if (i > 0) const SizedBox(width: _gap),
              _celda(
                  cols[i],
                  _TituloColumna(
                    texto: cols[i].titulo,
                    numerica: cols[i].numerica,
                    activa: _columnaOrden == widget.columnas.indexOf(cols[i]),
                    ascendente: _ascendente,
                    onTap: cols[i].ordenarPor == null
                        ? null
                        : () => _ordenarPor(widget.columnas.indexOf(cols[i])),
                  )),
            ],
          ],
        ),
      );

  Widget _fila(
    BuildContext context,
    List<ColumnaTabla<T>> cols,
    T fila, {
    required bool ultima,
  }) {
    final clave = widget.claveDe?.call(fila) ?? fila;
    final elegida = widget.seleccionada != null && clave == widget.seleccionada;
    return ConHover(
      builder: (_, encima) => PressableScale(
        escala: 1,
        onTap: widget.onTap == null ? null : () => widget.onTap!(fila),
        child: AnimatedContainer(
          duration: MMotion.t1,
          // Alto MÍNIMO y no fijo: con el texto del sistema al 130 % una fila
          // de 52 px recorta el nombre en vez de crecer.
          constraints: BoxConstraints(minHeight: widget.altoFila),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: elegida
                ? MColors.brandBg
                : encima
                    ? MColors.bg2
                    : MColors.surface,
            border: ultima
                ? null
                : const Border(bottom: BorderSide(color: MColors.border)),
          ),
          child: Row(
            children: [
              for (var i = 0; i < cols.length; i++) ...[
                if (i > 0) const SizedBox(width: _gap),
                _celda(cols[i], cols[i].celda(context, fila)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filas = _ordenadas;

    // `.card`: mismo contenedor que las tarjetas, sin padding, recortando
    // las filas al radio.
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: MColors.surface,
        border: Border.all(color: MColors.border),
        borderRadius: BorderRadius.circular(MRadius.lg),
        boxShadow: MShadow.xs,
      ),
      child: LayoutBuilder(
        builder: (_, restricciones) {
          final cols = _visibles(restricciones.maxWidth);

          Widget cuerpo;
          if (filas.isEmpty) {
            cuerpo = widget.vacio ?? const SizedBox(height: 80);
          } else if (widget.expandir) {
            cuerpo = ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: filas.length,
              itemBuilder: (ctx, i) =>
                  _fila(ctx, cols, filas[i], ultima: i == filas.length - 1),
            );
          } else {
            cuerpo = Column(
              children: [
                for (var i = 0; i < filas.length; i++)
                  _fila(context, cols, filas[i], ultima: i == filas.length - 1),
              ],
            );
          }

          final tabla = widget.expandir
              // Cabecera pegada: queda fuera del scroll y se entera de él
              // para encender la sombra.
              ? ListaConEncabezado(
                  encabezado: (_, hayArriba) =>
                      _cabecera(cols, hayArriba: hayArriba),
                  lista: cuerpo,
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [_cabecera(cols), cuerpo],
                );

          final minimo = _anchoMinimo(cols);
          if (restricciones.maxWidth >= minimo) return tabla;
          // Ni sacando las opcionales entra: scroll horizontal antes que
          // columnas aplastadas.
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(width: minimo, child: tabla),
          );
        },
      ),
    );
  }
}

class _TituloColumna extends StatelessWidget {
  const _TituloColumna({
    required this.texto,
    required this.numerica,
    required this.activa,
    required this.ascendente,
    required this.onTap,
  });

  final String texto;
  final bool numerica;
  final bool activa;
  final bool ascendente;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final etiqueta = Text(
      texto.toUpperCase(),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: sans(
        size: 11,
        weight: 600,
        color: activa ? MColors.brand : MColors.tMuted,
      ).copyWith(letterSpacing: 1.2),
    );
    if (onTap == null) return etiqueta;
    final flecha = Icon(
      ascendente ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
      size: 13,
      color: activa ? MColors.brand : Colors.transparent,
    );
    return PressableScale(
      escala: 1,
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: numerica
            ? [flecha, const SizedBox(width: 3), Flexible(child: etiqueta)]
            : [Flexible(child: etiqueta), const SizedBox(width: 3), flecha],
      ),
    );
  }
}
