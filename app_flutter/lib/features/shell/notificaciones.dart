/// Panel de notificaciones. Portado de `showNotifs()` del `index.html`.
///
/// Junta dos cosas que hay que ver al abrir la app: los turnos de hoy que
/// todavía no ocurrieron, y el stock que está en el mínimo o agotado.
///
/// Lo importante del original: cuando no hay nada, dice **"✅ Todo en orden"**.
/// Un panel vacío deja la duda de si falló al cargar.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../data/local/database.dart' as db;
import '../../data/local/mappers.dart';
import '../../domain/rules/stock.dart';
import '../dashboard/dashboard_view.dart';
import '../stock/stock_view.dart';

class Aviso {
  const Aviso({
    required this.icono,
    required this.titulo,
    required this.detalle,
    required this.color,
  });

  final String icono;
  final String titulo;
  final String detalle;
  final Color color;
}

/// Los avisos de hoy. Se calcula acá y no en la vista para que la campanita
/// pueda mostrar el número sin abrir el panel.
final avisosProvider = Provider<List<Aviso>>((ref) {
  final turnos = ref.watch(turnosDeHoyProvider).value ?? const <db.Appointment>[];
  final stock = (ref.watch(stockProvider).value ?? const <db.StockItem>[])
      .map(aStockItem)
      .toList();
  final clientes = ref.watch(clientesProvider).value ?? const <db.Client>[];
  final nombres = {for (final c in clientes) c.id: c.nombre};

  return [
    // Turnos de hoy que todavía no pasaron. Los hechos y los cancelados no
    // son un aviso: ya no hay nada que hacer con ellos.
    for (final t in turnos)
      if (t.estado == 'pending' || t.estado == 'confirmed')
        Aviso(
          icono: '📅',
          titulo: nombres[t.clientId] ?? 'Clienta',
          detalle: t.hora,
          color: MColors.brand,
        ),
    for (final s in stock)
      if (stockStatus(s) != StockStatus.ok)
        Aviso(
          icono: stockStatus(s) == StockStatus.out ? '🔴' : '⚠️',
          titulo: stockStatus(s) == StockStatus.out
              ? 'Sin stock: ${s.nombre}'
              : 'Bajo: ${s.nombre}',
          detalle: '${s.cantidad} ${s.unidad}',
          color: MColors.warningText,
        ),
  ];
});

Future<void> mostrarNotificaciones(BuildContext context) =>
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const _PanelNotificaciones(),
    );

class _PanelNotificaciones extends ConsumerWidget {
  const _PanelNotificaciones();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final avisos = ref.watch(avisosProvider);

    return Container(
      decoration: const BoxDecoration(
        color: MColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(MRadius.xl)),
      ),
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Notificaciones', style: serif(size: 16, weight: 600)),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => Navigator.of(context).pop(),
                  child: Text(
                    '✕',
                    style: sans(size: 16, color: MColors.tMuted),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (avisos.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  '✅  Todo en orden',
                  textAlign: TextAlign.center,
                  style: sans(size: 13, color: MColors.tMuted),
                ),
              )
            else
              // Con muchos avisos el sheet no puede crecer sin límite.
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.sizeOf(context).height * 0.5,
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: avisos.length,
                  itemBuilder: (_, i) => _FilaAviso(aviso: avisos[i]),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _FilaAviso extends StatelessWidget {
  const _FilaAviso({required this.aviso});

  final Aviso aviso;

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: MColors.bg2,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Text(aviso.icono, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    aviso.titulo,
                    style:
                        sans(size: 13, weight: 500, color: aviso.color),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 1),
                  Text(
                    aviso.detalle,
                    style: sans(size: 11, color: MColors.tMuted),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}
