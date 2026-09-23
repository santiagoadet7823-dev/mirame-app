/// Piezas compartidas por las vistas de negocio.
library;

import 'package:flutter/material.dart';

import '../../core/layout/layout.dart';
import '../../shared/widgets/comportamiento.dart';
import '../../core/theme/motion.dart';
import '../../core/theme/shadows.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';

/// Estado vacío. Dice qué falta y **cómo se llena**: un "no hay nada" a secas
/// deja a la persona sin saber si la app se rompió o si todavía no cargó nada.
class EstadoVacio extends StatelessWidget {
  const EstadoVacio({
    super.key,
    required this.emoji,
    required this.titulo,
    required this.detalle,
    this.accion,
  });

  final String emoji;
  final String titulo;
  final String detalle;

  /// Salida del callejón: `(etiqueta, qué hace)`. Un vacío por filtro tiene
  /// arreglo —"Ver todos"— y un vacío de verdad no; por eso es opcional.
  final (String, VoidCallback)? accion;

  /// `.empty-s { padding:52px 20px; gap:8px }`
  /// `.empty-ic { font-size:40px; opacity:.25 }` — el emoji va DESVAÍDO; a
  /// opacidad plena compite con el contenido real de la pantalla.
  /// `.empty-t { 16px/600 t-secondary }` · `.empty-d { 13px t-muted, max 200 }`
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 52, horizontal: 20),
        child: Column(
          children: [
            Opacity(
              opacity: 0.25,
              child: Text(emoji, style: const TextStyle(fontSize: 40)),
            ),
            const SizedBox(height: 8),
            Text(
              titulo,
              style: sans(size: 16, weight: 600, color: MColors.tSecondary),
            ),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 200),
              child: Text(
                detalle,
                textAlign: TextAlign.center,
                style:
                    sans(size: 13, color: MColors.tMuted).copyWith(height: 1.6),
              ),
            ),
            if (accion case final a?) ...[
              const SizedBox(height: 16),
              PressableScale(
                onTap: a.$2,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  decoration: BoxDecoration(
                    color: MColors.bg2,
                    border: Border.all(color: MColors.borderMd),
                    borderRadius: BorderRadius.circular(MRadius.full),
                  ),
                  child: Text(
                    a.$1,
                    style:
                        sans(size: 13, weight: 600, color: MColors.tSecondary),
                  ),
                ),
              ),
            ],
          ],
        ),
      );
}

/// Andamio de las vistas que todavía no se construyeron.
///
/// Es explícito a propósito: una pantalla en blanco se lee como un error de la
/// app, y hace perder tiempo buscando un bug que no existe.
class VistaEnConstruccion extends StatelessWidget {
  const VistaEnConstruccion({
    super.key,
    required this.nombre,
    required this.cuando,
  });

  final String nombre;
  final String cuando;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.construction_outlined,
                  size: 34, color: MColors.tLight),
              const SizedBox(height: 14),
              Text(nombre, style: serif(size: 22, weight: 600)),
              const SizedBox(height: 6),
              Text(
                'Todavía no está construida. $cuando',
                textAlign: TextAlign.center,
                style: MText.cuerpoSec,
              ),
            ],
          ),
        ),
      );
}

/// Abre un panel modal como corresponde al tamaño de pantalla.
///
/// En el teléfono es el sheet de siempre, desde abajo. En escritorio es un
/// **diálogo centrado** de hasta 560 px: un sheet a todo el ancho de un
/// monitor de 1600 px es una franja de formulario de un metro, y es lo que
/// hacía que la PWA pareciera un celular estirado. Lo decide el ancho, no la
/// plataforma: una ventana angosta en la compu se comporta como un teléfono.
///
/// Todos los sheets de la app pasan por acá; ninguna vista llama a
/// `showModalBottomSheet` directo.
Future<T?> showAppSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  bool descartable = true,
}) {
  if (!esPantallaGrande(context)) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: descartable,
      enableDrag: descartable,
      builder: builder,
    );
  }
  return showDialog<T>(
    context: context,
    barrierColor: MColors.scrim,
    barrierDismissible: descartable,
    builder: (ctx) {
      final alto = MediaQuery.sizeOf(ctx).height;
      return Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(MRadius.xl),
        ),
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MBreak.sheetMaxWidth,
            // `max-height: 88vh` del `.modal-sh` de escritorio.
            maxHeight: alto * 0.88,
          ),
          decoration: BoxDecoration(
            color: MColors.surface,
            borderRadius: BorderRadius.circular(MRadius.xl),
            boxShadow: MShadow.sheetDesktop,
          ),
          child: EnDialogo(child: Builder(builder: builder)),
        ),
      );
    },
  );
}

/// Marca que el contenido está adentro de un diálogo de escritorio y no de un
/// sheet: el `SheetFormulario` y los paneles lo usan para no dibujar la
/// manija de arrastre ni el radio solo-arriba.
class EnDialogo extends InheritedWidget {
  const EnDialogo({super.key, required super.child});

  static bool de(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<EnDialogo>() != null;

  @override
  bool updateShouldNotify(EnDialogo viejo) => false;
}

/// La manija de arrastre de los sheets (`.sheet-handle`, 38×4). En un diálogo
/// de escritorio no se dibuja: no hay nada que arrastrar.
class ManijaSheet extends StatelessWidget {
  const ManijaSheet({super.key});

  @override
  Widget build(BuildContext context) {
    if (EnDialogo.de(context)) return const SizedBox.shrink();
    return Center(
      child: Container(
        width: 38,
        height: 4,
        decoration: BoxDecoration(
          color: MColors.borderMd,
          borderRadius: BorderRadius.circular(MRadius.full),
        ),
      ),
    );
  }
}

/// Sheet de formulario. Lo comparten todas las altas y ediciones para que
/// crear una clienta y crear un movimiento se sientan igual.
class SheetFormulario extends StatelessWidget {
  const SheetFormulario({
    super.key,
    required this.titulo,
    required this.campos,
    required this.onGuardar,
    this.onBorrar,
    this.error,
    this.guardando = false,
    this.etiquetaGuardando,
  });

  final String titulo;
  final List<Widget> campos;
  final VoidCallback onGuardar;
  final VoidCallback? onBorrar;
  final String? error;
  final bool guardando;

  /// Qué está pasando mientras se guarda, si hay algo que valga la pena decir.
  ///
  /// Un spinner mudo durante media subida se lee como colgado. Con texto, el
  /// botón dice "Subiendo 2 de 5" y la espera se entiende. En null vuelve al
  /// spinner de siempre, que es lo correcto para un guardado instantáneo.
  final String? etiquetaGuardando;

  @override
  Widget build(BuildContext context) {
    final enDialogo = EnDialogo.de(context);
    return Padding(
      // El teclado tapa los campos de abajo si no se le cede el espacio.
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: MColors.surface,
          borderRadius: enDialogo
              ? BorderRadius.circular(MRadius.xl)
              : const BorderRadius.vertical(top: Radius.circular(MRadius.xl)),
        ),
        padding: enDialogo
            ? const EdgeInsets.fromLTRB(28, 26, 28, 26)
            : const EdgeInsets.fromLTRB(22, 12, 22, 24),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!enDialogo) ...[
                  const ManijaSheet(),
                  const SizedBox(height: 18),
                ],
                Text(titulo, style: serif(size: 22, weight: 600)),
                const SizedBox(height: 16),
                ...campos,
                if (error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    error!,
                    style:
                        sans(size: 13, weight: 500, color: MColors.dangerText),
                  ),
                ],
                const SizedBox(height: 20),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: MColors.brand,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(MRadius.full),
                    ),
                  ),
                  onPressed: guardando ? null : onGuardar,
                  child: guardando
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: MColors.tWhite,
                              ),
                            ),
                            if (etiquetaGuardando != null) ...[
                              const SizedBox(width: 10),
                              Text(
                                etiquetaGuardando!,
                                style: sans(
                                    size: 15,
                                    weight: 600,
                                    color: MColors.tWhite),
                              ),
                            ],
                          ],
                        )
                      : Text(
                          'Guardar',
                          style: sans(
                              size: 15, weight: 600, color: MColors.tWhite),
                        ),
                ),
                if (onBorrar != null) ...[
                  const SizedBox(height: 6),
                  TextButton(
                    onPressed: guardando
                        ? null
                        : () => _confirmarBorrado(context, onBorrar!),
                    child: Text(
                      'Eliminar',
                      style: sans(
                          size: 13, weight: 500, color: MColors.dangerText),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Borrar siempre pregunta. Es la única acción de estas pantallas que la
  /// persona no puede deshacer sola.
  static Future<void> _confirmarBorrado(
    BuildContext context,
    VoidCallback onSi,
  ) async {
    final si = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: MColors.surface,
        title: Text('¿Eliminar?', style: serif(size: 20, weight: 600)),
        content: Text(
          'No se puede deshacer desde la app.',
          style: MText.cuerpoSec,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Cancelar', style: MText.menor),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              'Eliminar',
              style: sans(size: 13, weight: 600, color: MColors.dangerText),
            ),
          ),
        ],
      ),
    );
    if (si ?? false) onSi();
  }
}

class CampoTexto extends StatelessWidget {
  const CampoTexto({
    super.key,
    required this.controlador,
    required this.etiqueta,
    this.teclado,
    this.lineas = 1,
    this.autofocus = false,
    this.prefijo,
    this.onCambio,
  });

  final TextEditingController controlador;
  final String etiqueta;
  final TextInputType? teclado;
  final int lineas;
  final bool autofocus;
  final String? prefijo;

  /// Para los campos que filtran mientras se tipea, como la busqueda del
  /// catalogo.
  final ValueChanged<String>? onCambio;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextField(
          controller: controlador,
          onChanged: onCambio,
          keyboardType: teclado,
          maxLines: lineas,
          autofocus: autofocus,
          style: sans(size: 14, weight: 500),
          decoration: InputDecoration(
            labelText: etiqueta,
            labelStyle: MText.menor,
            prefixText: prefijo,
            filled: true,
            fillColor: MColors.bg2,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(MRadius.md),
              borderSide: const BorderSide(color: MColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(MRadius.md),
              borderSide: const BorderSide(color: MColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(MRadius.md),
              borderSide: const BorderSide(color: MColors.brand),
            ),
          ),
        ),
      );
}

/// `.card` del original — `border-radius: var(--r-lg)` (20 px), borde 1 px y
/// sombra `xs`. Se usa el radio LARGE, no el medio: es la diferencia que hace
/// que las tarjetas se vean del original y no de una app Material cualquiera.
class TarjetaMirame extends StatelessWidget {
  const TarjetaMirame({
    super.key,
    required this.hijo,
    this.padding = const EdgeInsets.all(14),
    this.margenInferior = 0,
    this.onTap,
    this.onLongPress,
    this.borde,
    this.fondo,
  });

  final Widget hijo;
  final EdgeInsets padding;
  final double margenInferior;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Color? borde;

  /// Para marcar la tarjeta abierta cuando la lista convive con un panel.
  final Color? fondo;

  @override
  Widget build(BuildContext context) {
    final tarjeta = Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: fondo ?? MColors.surface,
        border: Border.all(color: borde ?? MColors.border),
        borderRadius: BorderRadius.circular(MRadius.lg),
        boxShadow: MShadow.xs,
      ),
      child: hijo,
    );
    return Padding(
      padding: EdgeInsets.only(bottom: margenInferior),
      child: onTap == null && onLongPress == null
          ? tarjeta
          : PressableScale(
              onTap: onTap,
              onLongPress: onLongPress,
              child: tarjeta,
            ),
    );
  }
}

/// Barra de herramientas de una vista con lista: buscador, filtros y la
/// acción primaria.
///
/// En móvil es lo de siempre, apilado, y la acción primaria no va acá (es el
/// FAB). En escritorio va todo en una fila: el buscador con ancho fijo —un
/// campo de búsqueda de 1300 px es un error clásico de "app de celular
/// estirada"—, los filtros al lado y el botón de crear a la derecha, donde
/// cualquier sistema de gestión lo pone.
class BarraVista extends StatelessWidget {
  const BarraVista({
    super.key,
    this.buscador,
    this.filtros,
    this.accion,
  });

  final Widget? buscador;
  final Widget? filtros;

  /// Normalmente un [BotonPrimario]. Solo se muestra en escritorio.
  final Widget? accion;

  @override
  Widget build(BuildContext context) {
    if (!esPantallaGrande(context)) {
      return Column(
        children: [
          if (buscador != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
              child: buscador,
            ),
          if (filtros != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: filtros,
            ),
        ],
      );
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 24, 32, 18),
      child: Row(
        children: [
          if (buscador != null) ...[
            SizedBox(width: 340, child: buscador),
            const SizedBox(width: 14),
          ],
          if (filtros != null) Expanded(child: filtros!) else const Spacer(),
          if (accion != null) ...[
            const SizedBox(width: 14),
            accion!,
          ],
        ],
      ),
    );
  }
}

/// El botón de crear en escritorio: píldora brand, ícono + texto. Reemplaza al
/// FAB, que en un monitor queda flotando a medio metro de lo que crea.
class BotonPrimario extends StatelessWidget {
  const BotonPrimario({
    super.key,
    required this.texto,
    required this.onTap,
    this.icono = Icons.add_rounded,
  });

  final String texto;
  final VoidCallback? onTap;
  final IconData icono;

  @override
  Widget build(BuildContext context) => FilledButton.icon(
        style: FilledButton.styleFrom(
          backgroundColor: MColors.brand,
          disabledBackgroundColor: MColors.bg3,
          padding: const EdgeInsets.fromLTRB(16, 0, 20, 0),
          minimumSize: const Size(0, 42),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(MRadius.full),
          ),
        ),
        onPressed: onTap,
        icon: Icon(icono, size: 18, color: MColors.tWhite),
        label: Text(
          texto,
          style: sans(size: 13, weight: 600, color: MColors.tWhite),
        ),
      );
}

/// `.sec-t` — el encabezado de sección.
class TituloSeccion extends StatelessWidget {
  const TituloSeccion(this.texto, {super.key, this.accion});

  final String texto;
  final Widget? accion;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            texto,
            style: sans(size: 13, weight: 600, color: MColors.tSecondary)
                .copyWith(letterSpacing: 0.3),
          ),
          if (accion != null) accion!,
        ],
      );
}

/// Una píldora chica de estado con colores a elección: `.badge` sin el
/// diccionario de estados de turno. Para "En la tienda", "3 en stock", etc.
class Pildora extends StatelessWidget {
  const Pildora({
    super.key,
    required this.texto,
    required this.fondo,
    required this.color,
    this.borde,
  });

  final String texto;
  final Color fondo;
  final Color color;
  final Color? borde;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
        decoration: BoxDecoration(
          color: fondo,
          border: Border.all(color: borde ?? MColors.border),
          borderRadius: BorderRadius.circular(MRadius.full),
        ),
        child: Text(
          texto,
          style: sans(size: 10, weight: 600, color: color),
        ),
      );
}

/// `.badge` — la píldora de estado de un turno. Cada estado tiene su terna de
/// fondo, borde y texto en el CSS original.
class BadgeEstado extends StatelessWidget {
  const BadgeEstado(this.estado, {super.key});

  final String estado;

  @override
  Widget build(BuildContext context) {
    final (texto, fondo, borde, color) = switch (estado) {
      'confirmed' || 'confirmado' => (
          'Confirmado',
          MColors.lav50,
          MColors.lav200,
          MColors.lav700
        ),
      'done' || 'hecho' || 'completado' => (
          'Hecho',
          MColors.successBg,
          MColors.successBorder,
          MColors.successText
        ),
      'cancelled' || 'cancelado' => (
          'Cancelado',
          MColors.dangerBg,
          MColors.dangerBorder,
          MColors.dangerText
        ),
      _ => (
          'Pendiente',
          MColors.warningBg,
          MColors.warningBorder,
          MColors.warningText
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: fondo,
        border: Border.all(color: borde),
        borderRadius: BorderRadius.circular(MRadius.full),
      ),
      child: Text(
        texto,
        style: sans(size: 10, weight: 600, color: color),
      ),
    );
  }
}

/// `.chip` / `.pill` del original — la fila de filtros.
///
/// El activo usa el fondo lavanda de la marca; el resto, bg2 con borde. Es el
/// mismo control que en el original y por eso comparte medidas: `padding
/// 8px 15px`, `border-radius: full`, `font-size 12/500`.
class FilaFiltros extends StatelessWidget {
  const FilaFiltros({
    super.key,
    required this.opciones,
    required this.activo,
    required this.onElegir,
  });

  /// `(clave, etiqueta)`. La clave es la que viaja al filtro; la etiqueta es
  /// lo que se lee.
  final List<(String, String)> opciones;
  final String activo;
  final ValueChanged<String> onElegir;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 34,
        // Los filtros casi nunca entran enteros en 390: el degradé de la
        // derecha es lo que avisa que la fila sigue.
        child: DegradeDeCorte(
          ancho: 20,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.zero,
            itemCount: opciones.length,
            separatorBuilder: (_, __) => const SizedBox(width: 7),
            itemBuilder: (_, i) {
              final (clave, etiqueta) = opciones[i];
              final esActivo = clave == activo;
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onElegir(clave),
                child: AnimatedContainer(
                  duration: MMotion.t1,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                  decoration: BoxDecoration(
                    color: esActivo ? MColors.brandBg : MColors.bg2,
                    border: Border.all(
                      color: esActivo ? MColors.borderLav : MColors.border,
                    ),
                    borderRadius: BorderRadius.circular(MRadius.full),
                  ),
                  child: Text(
                    etiqueta,
                    style: sans(
                      size: 12,
                      weight: esActivo ? 600 : 500,
                      color: esActivo ? MColors.brandDark : MColors.tSecondary,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );
}

/// `.sec-label` — el encabezado de sección, en mayúsculas y tracking amplio.
class EtiquetaSeccion extends StatelessWidget {
  const EtiquetaSeccion(this.texto, {super.key});

  final String texto;

  @override
  Widget build(BuildContext context) => Padding(
        // `margin: 20px 0 8px 2px`
        padding: const EdgeInsets.fromLTRB(2, 20, 0, 8),
        child: Text(
          texto,
          style: sans(size: 11, weight: 600, color: MColors.tMuted)
              .copyWith(letterSpacing: 1.2),
        ),
      );
}

/// `.sec-row` — encabezado con una acción a la derecha ("Ver todo").
class FilaSeccion extends StatelessWidget {
  const FilaSeccion({
    super.key,
    required this.titulo,
    required this.accion,
    required this.onAccion,
  });

  final String titulo;
  final String accion;
  final VoidCallback onAccion;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(2, 20, 2, 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              titulo,
              style: sans(size: 11, weight: 600, color: MColors.tMuted)
                  .copyWith(letterSpacing: 1.2),
            ),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onAccion,
              child: Text(
                accion,
                style: sans(size: 13, weight: 500, color: MColors.brand),
              ),
            ),
          ],
        ),
      );
}
