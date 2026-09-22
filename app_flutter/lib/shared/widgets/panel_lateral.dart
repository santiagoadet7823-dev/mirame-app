/// Maestro-detalle para escritorio: la lista a la izquierda y, cuando hay
/// algo elegido, un panel a la derecha con el detalle.
///
/// En el teléfono el detalle abre en un sheet, como siempre; acá no se dibuja
/// nada distinto. En un monitor, en cambio, abrir la ficha de una clienta en
/// un diálogo que tapa la lista obliga a cerrar para ver la siguiente: el
/// panel deja las dos cosas a la vista, que es para lo que sirve el ancho.
library;

import 'package:flutter/material.dart';

import '../../core/layout/layout.dart';
import '../../core/theme/motion.dart';
import '../../core/theme/shadows.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';

class MaestroDetalle extends StatelessWidget {
  const MaestroDetalle({
    super.key,
    required this.lista,
    this.panel,
    this.anchoPanel = 400,
  });

  final Widget lista;

  /// Null = nada elegido: la lista toma todo el ancho.
  final Widget? panel;
  final double anchoPanel;

  @override
  Widget build(BuildContext context) {
    if (!esEscritorio(context)) return lista;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: lista),
        // Animado para que el panel entre deslizándose y no aparezca de
        // golpe corriendo la tabla.
        AnimatedSize(
          duration: MMotion.t2,
          curve: MMotion.ease,
          alignment: Alignment.centerLeft,
          child: panel == null
              ? const SizedBox.shrink()
              : Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: SizedBox(width: anchoPanel, child: panel),
                ),
        ),
      ],
    );
  }
}

/// El marco del panel: tarjeta con título y botón de cerrar, y el contenido
/// scrolleable abajo.
class PanelLateral extends StatelessWidget {
  const PanelLateral({
    super.key,
    required this.titulo,
    required this.onCerrar,
    required this.child,
  });

  final String titulo;
  final VoidCallback onCerrar;
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: MColors.surface,
          border: Border.all(color: MColors.border),
          borderRadius: BorderRadius.circular(MRadius.lg),
          boxShadow: MShadow.sm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(18, 10, 10, 10),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: MColors.border)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      titulo.toUpperCase(),
                      style: sans(size: 11, weight: 600, color: MColors.tMuted)
                          .copyWith(letterSpacing: 1.2),
                    ),
                  ),
                  Tooltip(
                    message: 'Cerrar',
                    child: PressableScale(
                      onTap: onCerrar,
                      child: Container(
                        width: 30,
                        height: 30,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: MColors.bg2,
                          shape: BoxShape.circle,
                          border: Border.all(color: MColors.border),
                        ),
                        child: const Icon(Icons.close_rounded,
                            size: 15, color: MColors.tSecondary),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: child),
          ],
        ),
      );
}
