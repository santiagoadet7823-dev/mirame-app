/// Piezas compartidas por las vistas de negocio.
library;

import 'package:flutter/material.dart';

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
  });

  final String emoji;
  final String titulo;
  final String detalle;

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
                style: sans(size: 13, color: MColors.tMuted)
                    .copyWith(height: 1.6),
              ),
            ),
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
  });

  final String titulo;
  final List<Widget> campos;
  final VoidCallback onGuardar;
  final VoidCallback? onBorrar;
  final String? error;
  final bool guardando;

  @override
  Widget build(BuildContext context) => Padding(
        // El teclado tapa los campos de abajo si no se le cede el espacio.
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Container(
          decoration: const BoxDecoration(
            color: MColors.surface,
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(MRadius.xl)),
          ),
          padding: const EdgeInsets.fromLTRB(22, 12, 22, 24),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 38,
                      height: 4,
                      decoration: BoxDecoration(
                        color: MColors.borderMd,
                        borderRadius: BorderRadius.circular(MRadius.full),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(titulo, style: serif(size: 22, weight: 600)),
                  const SizedBox(height: 16),
                  ...campos,
                  if (error != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      error!,
                      style: sans(
                          size: 13, weight: 500, color: MColors.dangerText),
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
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: MColors.tWhite,
                            ),
                          )
                        : Text(
                            'Guardar',
                            style: sans(
                                size: 15,
                                weight: 600,
                                color: MColors.tWhite),
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
                            size: 13,
                            weight: 500,
                            color: MColors.dangerText),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      );

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
              style:
                  sans(size: 13, weight: 600, color: MColors.dangerText),
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
  });

  final TextEditingController controlador;
  final String etiqueta;
  final TextInputType? teclado;
  final int lineas;
  final bool autofocus;
  final String? prefijo;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextField(
          controller: controlador,
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
    this.borde,
  });

  final Widget hijo;
  final EdgeInsets padding;
  final double margenInferior;
  final VoidCallback? onTap;
  final Color? borde;

  @override
  Widget build(BuildContext context) {
    final tarjeta = Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: MColors.surface,
        border: Border.all(color: borde ?? MColors.border),
        borderRadius: BorderRadius.circular(MRadius.lg),
        boxShadow: MShadow.xs,
      ),
      child: hijo,
    );
    return Padding(
      padding: EdgeInsets.only(bottom: margenInferior),
      child: onTap == null
          ? tarjeta
          : PressableScale(onTap: onTap, child: tarjeta),
    );
  }
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


/// `.badge` — la píldora de estado de un turno. Cada estado tiene su terna de
/// fondo, borde y texto en el CSS original.
class BadgeEstado extends StatelessWidget {
  const BadgeEstado(this.estado, {super.key});

  final String estado;

  @override
  Widget build(BuildContext context) {
    final (texto, fondo, borde, color) = switch (estado) {
      'confirmed' || 'confirmado' =>
        ('Confirmado', MColors.lav50, MColors.lav200, MColors.lav700),
      'done' || 'hecho' || 'completado' =>
        ('Hecho', MColors.successBg, MColors.successBorder, MColors.successText),
      'cancelled' || 'cancelado' =>
        ('Cancelado', MColors.dangerBg, MColors.dangerBorder, MColors.dangerText),
      _ => ('Pendiente', MColors.warningBg, MColors.warningBorder,
          MColors.warningText),
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
