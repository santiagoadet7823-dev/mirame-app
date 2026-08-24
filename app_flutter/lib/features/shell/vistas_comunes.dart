/// Piezas compartidas por las vistas de negocio.
library;

import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 42)),
            const SizedBox(height: 14),
            Text(titulo, style: serif(size: 20, weight: 600)),
            const SizedBox(height: 6),
            Text(
              detalle,
              textAlign: TextAlign.center,
              style: MText.cuerpoSec,
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
