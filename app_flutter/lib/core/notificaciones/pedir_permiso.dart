/// El pedido de permiso de notificaciones, con su explicación.
///
/// Android 13+ da **una** oportunidad: si la persona toca "No permitir", el
/// sistema no vuelve a mostrar el diálogo nunca más y hay que ir a Ajustes a
/// mano. Por eso primero se explica qué va a recibir, y recién si dice que sí
/// se dispara el diálogo del sistema.
library;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/tokens.dart';
import '../theme/typography.dart';
import 'servicio_avisos.dart';

const _kYaPreguntado = 'mirame.permiso_avisos_preguntado';

/// Pide el permiso **una sola vez en la vida de la instalación**, y solo
/// después de que la usuaria hizo algo que se beneficia (guardar un turno).
///
/// No hace nada si ya lo tiene, si ya se preguntó, o si el plugin no está.
Future<void> pedirPermisoDeAvisos(BuildContext context) async {
  final servicio = ServicioAvisos.instancia;
  if (!servicio.disponible || servicio.permitido) return;

  final prefs = await SharedPreferences.getInstance();
  if (prefs.getBool(_kYaPreguntado) ?? false) return;
  if (!context.mounted) return;

  final quiere = await showModalBottomSheet<bool>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) => const _SheetPermiso(),
  );

  // Se marca haya dicho que sí o que no: insistir es la forma más rápida de
  // que desinstalen la app.
  await prefs.setBool(_kYaPreguntado, true);
  if (quiere == true) await servicio.pedirPermiso();
}

class _SheetPermiso extends StatelessWidget {
  const _SheetPermiso();

  @override
  Widget build(BuildContext context) => Container(
        decoration: const BoxDecoration(
          color: MColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(MRadius.xl)),
        ),
        padding: const EdgeInsets.fromLTRB(22, 22, 22, 26),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('🔔', style: const TextStyle(fontSize: 34)),
              const SizedBox(height: 10),
              Text('¿Te aviso?', style: serif(size: 22, weight: 600)),
              const SizedBox(height: 8),
              Text(
                'Sin abrir la app, en el celular:',
                style: sans(size: 13, color: MColors.tSecondary),
              ),
              const SizedBox(height: 12),
              const _Punto('📅', 'Los turnos de mañana, a las 20:00'),
              const _Punto('✂️', 'Qué clientas toca llamar para el retoque'),
              const _Punto('💰', 'Cómo cerró la caja del día'),
              const _Punto('⚠️', 'Cuando un producto se está por acabar'),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Sí, avisame'),
                ),
              ),
              const SizedBox(height: 6),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(
                    'Ahora no',
                    style: sans(size: 13, color: MColors.tMuted),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}

class _Punto extends StatelessWidget {
  const _Punto(this.emoji, this.texto);

  final String emoji;
  final String texto;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 15)),
            const SizedBox(width: 10),
            Expanded(child: Text(texto, style: sans(size: 13))),
          ],
        ),
      );
}
