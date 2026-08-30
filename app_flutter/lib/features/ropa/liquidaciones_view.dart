/// Liquidar a un proveedor o a un vendedor.
///
/// El flujo es a propósito de dos pasos: primero se **mira** qué se le debe y
/// se puede mandar el PDF, y recién después se marca como pagado. Un botón
/// único que liquidara y cerrara de una haría que un toque equivocado marque
/// como pagada plata que todavía no salió, y eso no se puede deshacer sin
/// tocar la base.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../data/repositories/ropa_repository.dart';
import '../../domain/entities/ropa.dart' as dom;
import '../../domain/rules/consignacion.dart';
import '../../domain/rules/formatting.dart';
import '../../domain/rules/period.dart';
import '../auth/session_controller.dart';
import '../shell/vistas_comunes.dart';
import 'liquidacion_pdf.dart';
import 'ropa_view.dart';

Future<void> mostrarLiquidaciones(BuildContext context) =>
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const _Panel(),
    );

class _Panel extends ConsumerStatefulWidget {
  const _Panel();

  @override
  ConsumerState<_Panel> createState() => _PanelState();
}

class _PanelState extends ConsumerState<_Panel> {
  /// Meses hacia atrás desde hoy. 0 = este mes.
  int _offset = 0;
  DetalleLiquidacion? _detalle;
  String? _destinatarioId;
  var _cargando = false;

  DateTimeRange get _periodo {
    final hoy = DateTime.now();
    final desde = DateTime(hoy.year, hoy.month + _offset, 1);
    // Día 0 del mes siguiente es el último del actual, sin tener que saber
    // cuántos días tiene.
    final hasta = DateTime(hoy.year, hoy.month + _offset + 1, 0);
    return DateTimeRange(start: desde, end: hasta);
  }

  Future<void> _calcular(String id, String nombre) async {
    final repo = ref.read(ropaRepoProvider);
    if (repo == null) return;
    setState(() {
      _cargando = true;
      _destinatarioId = id;
    });

    final d = await repo.armarLiquidacion(
      destinatarioId: id,
      destinatarioNombre: nombre,
      tipo: dom.LiquidacionTipo.proveedor,
      desde: _periodo.start,
      hasta: _periodo.end,
    );
    if (mounted) {
      setState(() {
        _detalle = d;
        _cargando = false;
      });
    }
  }

  Future<void> _marcarPagada() async {
    final d = _detalle;
    final id = _destinatarioId;
    if (d == null || id == null) return;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: MColors.surface,
        title: Text('¿Ya le pagaste?', style: serif(size: 17, weight: 600)),
        content: Text(
          'Se van a marcar ${d.filas.length} prendas como liquidadas por '
          '${formatMoney(d.total)}. No van a volver a aparecer en el próximo '
          'período.',
          style: sans(size: 13, color: MColors.tSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child:
                Text('Todavía no', style: sans(size: 13, color: MColors.tMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('Sí, ya le pagué',
                style: sans(size: 13, weight: 600, color: MColors.brand)),
          ),
        ],
      ),
    );
    if (ok != true) return;

    final repo = ref.read(ropaRepoProvider);
    await repo?.cerrarLiquidacion(detalle: d, destinatarioId: id);
    if (mounted) {
      setState(() {
        _detalle = null;
        _destinatarioId = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Liquidación cerrada')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final proveedores = ref.watch(proveedoresProvider).value ?? const [];
    final tenant = ref.watch(tenantActivoProvider);
    final d = _detalle;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.9,
      ),
      decoration: const BoxDecoration(
        color: MColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(MRadius.xl)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Liquidar', style: serif(size: 20, weight: 600)),
                if (d != null)
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => setState(() => _detalle = null),
                    child: Text('Volver',
                        style: sans(
                            size: 13, weight: 600, color: MColors.brand)),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Selector de mes.
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _flecha(Icons.chevron_left_rounded,
                    () => setState(() {
                          _offset--;
                          _detalle = null;
                        })),
                Text(nombreMes(_periodo.start),
                    style: sans(size: 14, weight: 600)),
                _flecha(
                  Icons.chevron_right_rounded,
                  _offset < 0
                      ? () => setState(() {
                            _offset++;
                            _detalle = null;
                          })
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 14),

            Flexible(
              child: _cargando
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : d == null
                      ? _listaProveedores(proveedores)
                      : _detalleLiquidacion(d, tenant?.nombre ?? 'Mírame'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _flecha(IconData i, VoidCallback? onTap) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          width: 34,
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: MColors.bg2,
            borderRadius: BorderRadius.circular(MRadius.sm),
          ),
          child: Icon(i,
              size: 19,
              color: onTap == null ? MColors.tLight : MColors.tSecondary),
        ),
      );

  Widget _listaProveedores(List<dynamic> proveedores) => proveedores.isEmpty
      ? Padding(
          padding: const EdgeInsets.symmetric(vertical: 30),
          child: Text('Cargá un proveedor primero',
              textAlign: TextAlign.center,
              style: sans(size: 13, color: MColors.tMuted)),
        )
      : ListView(
          shrinkWrap: true,
          children: [
            Text('Elegí a quién le vas a pagar',
                style: sans(size: 12, color: MColors.tMuted)),
            const SizedBox(height: 10),
            for (final p in proveedores)
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _calcular(p.id as String, p.nombre as String),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 7),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 13),
                  decoration: BoxDecoration(
                    color: MColors.bg2,
                    borderRadius: BorderRadius.circular(MRadius.sm),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(p.nombre as String,
                            style: sans(size: 13, weight: 600)),
                      ),
                      const Icon(Icons.chevron_right_rounded,
                          size: 18, color: MColors.tLight),
                    ],
                  ),
                ),
              ),
          ],
        );

  Widget _detalleLiquidacion(DetalleLiquidacion d, String salon) {
    if (d.filas.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 34),
        child: Column(
          children: [
            Opacity(
              opacity: .25,
              child: Text('📋', style: const TextStyle(fontSize: 38)),
            ),
            const SizedBox(height: 10),
            Text('No hay nada pendiente de ${d.destinatario}',
                textAlign: TextAlign.center,
                style: sans(size: 13, color: MColors.tMuted)),
            const SizedBox(height: 4),
            Text('en ${nombreMes(_periodo.start)}',
                style: sans(size: 12, color: MColors.tLight)),
          ],
        ),
      );
    }

    return ListView(
      shrinkWrap: true,
      children: [
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: MColors.lav50,
            border: Border.all(color: MColors.borderLav),
            borderRadius: BorderRadius.circular(MRadius.md),
          ),
          child: Column(
            children: [
              Text(d.destinatario, style: sans(size: 14, weight: 600)),
              const SizedBox(height: 8),
              Text(formatMoney(d.total),
                  style: serif(size: 30, weight: 600, color: MColors.brand)),
              const SizedBox(height: 4),
              Text(
                '${d.prendas} ${d.prendas == 1 ? "prenda" : "prendas"} · '
                '${d.filas.length} ${d.filas.length == 1 ? "venta" : "ventas"}',
                style: sans(size: 12, color: MColors.tSecondary),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        const EtiquetaSeccion('DETALLE'),
        for (final f in d.filas)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        [f.codigo, f.prenda]
                            .where((x) => x != null && x.isNotEmpty)
                            .join(' · '),
                        style: sans(size: 12, weight: 500),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        [
                          claveFecha(f.fecha),
                          if (f.variante?.isNotEmpty ?? false) f.variante!,
                          '${f.pct.round()}%',
                        ].join(' · '),
                        style: sans(size: 10, color: MColors.tMuted),
                      ),
                    ],
                  ),
                ),
                Text(formatMoney(f.monto),
                    style: sans(size: 13, weight: 600)),
              ],
            ),
          ),

        const SizedBox(height: 14),
        _BotonAncho(
          icono: Icons.picture_as_pdf_outlined,
          texto: 'Mandar el comprobante',
          principal: true,
          onTap: () => compartirLiquidacion(context,
              detalle: d, salon: salon),
        ),
        const SizedBox(height: 8),
        _BotonAncho(
          icono: Icons.check_rounded,
          texto: 'Ya le pagué',
          onTap: _marcarPagada,
        ),
        const SizedBox(height: 10),
        Text(
          'Marcarlo como pagado saca estas prendas de los próximos períodos.',
          textAlign: TextAlign.center,
          style: sans(size: 11, color: MColors.tMuted),
        ),
      ],
    );
  }
}

class _BotonAncho extends StatelessWidget {
  const _BotonAncho({
    required this.icono,
    required this.texto,
    required this.onTap,
    this.principal = false,
  });

  final IconData icono;
  final String texto;
  final VoidCallback onTap;
  final bool principal;

  @override
  Widget build(BuildContext context) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: principal ? MColors.brand : MColors.surface,
            border: Border.all(
                color: principal ? MColors.brand : MColors.borderMd),
            borderRadius: BorderRadius.circular(MRadius.full),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icono,
                  size: 16,
                  color: principal ? MColors.tWhite : MColors.tSecondary),
              const SizedBox(width: 7),
              Text(texto,
                  style: sans(
                    size: 13,
                    weight: 600,
                    color: principal ? MColors.tWhite : MColors.tSecondary,
                  )),
            ],
          ),
        ),
      );
}
