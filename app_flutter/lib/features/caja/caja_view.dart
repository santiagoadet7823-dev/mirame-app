/// Caja: ingresos y gastos del mes.
///
/// Los totales salen de `domain/rules/finance.dart`, que ya está testeado —
/// esta pantalla dibuja, no calcula.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/layout/layout.dart';
import '../../core/theme/motion.dart';
import '../../core/theme/shadows.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../data/local/database.dart' as db;
import '../../data/local/mappers.dart';
import '../../data/repositories/business_repository.dart';
import '../../domain/entities/entities.dart';
import '../../domain/rules/access.dart';
import '../../domain/rules/finance.dart';
import '../../domain/rules/formatting.dart';
import '../../domain/rules/period.dart';
import '../../shared/widgets/comportamiento.dart';
import '../../shared/widgets/tabla_mirame.dart';
import '../auth/session_controller.dart';
import 'cierre_sheet.dart';
import '../shell/app_shell.dart';
import '../shell/vistas_comunes.dart';

/// Mes que se está mirando. `0` es el actual, `-1` el anterior.
///
/// Es estado de la pantalla y no un provider global: volver a Caja desde otra
/// sección debe mostrar el mes actual, no el que se miró hace media hora.
/// Movimientos de un mes, con `offset` relativo al actual.
///
/// La clave del `family` es el offset (un int) y no un DateTime: dos DateTime
/// del mismo mes con distinta hora son objetos distintos y crearían un
/// provider nuevo en cada rebuild.
final movimientosDeMesProvider =
    StreamProvider.autoDispose.family<List<db.Transaction>, int>((ref, offset) {
  final repo = ref.watch(businessRepoProvider);
  if (repo == null) return const Stream.empty();
  final hoy = DateTime.now();
  return repo.verMovimientosEntre(
    DateTime(hoy.year, hoy.month + offset, 1),
    // Día 0 del mes siguiente es el último del actual, sin tener que saber
    // cuántos días tiene ni acordarse de los bisiestos.
    DateTime(hoy.year, hoy.month + offset + 1, 0),
  );
});

/// `.cal-hdr` — el mes con las flechas a los costados.
class _SelectorMes extends StatelessWidget {
  const _SelectorMes({
    required this.mes,
    required this.onAnterior,
    this.onSiguiente,
  });

  final DateTime mes;
  final VoidCallback onAnterior;
  final VoidCallback? onSiguiente;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: onAnterior,
            icon: const Icon(Icons.chevron_left_rounded,
                color: MColors.tSecondary),
          ),
          Text(nombreMes(mes), style: sans(size: 15, weight: 600)),
          IconButton(
            onPressed: onSiguiente,
            icon: Icon(
              Icons.chevron_right_rounded,
              color: onSiguiente == null ? MColors.tLight : MColors.tSecondary,
            ),
          ),
        ],
      );
}

class CajaView extends ConsumerStatefulWidget {
  const CajaView({super.key});

  @override
  ConsumerState<CajaView> createState() => _CajaViewState();
}

class _CajaViewState extends ConsumerState<CajaView> {
  int _offsetMes = 0;
  String _filtro = 'all';

  DateTime get _mes {
    final hoy = DateTime.now();
    return DateTime(hoy.year, hoy.month + _offsetMes, 1);
  }

  @override
  Widget build(BuildContext context) {
    final asincronos = ref.watch(movimientosDeMesProvider(_offsetMes));
    final cargando = asincronos.isLoading && !asincronos.hasValue;
    final filas = asincronos.value ?? const <db.Transaction>[];
    final todos = filas.map(aTransaction).toList();
    final resumen = summarize(todos, monthRange(_mes));
    final puedeEscribir = ref.watch(puedeProvider(Permiso.operarNegocio));

    // El filtro se aplica DESPUÉS de calcular los totales: los números de
    // arriba son del mes completo, no de lo que quedó filtrado. Es lo que
    // hace el original y es lo correcto — si no, filtrar por gastos mostraría
    // "ingresos $0".
    final movimientos = switch (_filtro) {
      'income' => todos.where((m) => m.tipo == TxTipo.income).toList(),
      'expense' => todos.where((m) => m.tipo == TxTipo.expense).toList(),
      _ => todos,
    };

    final escritorio = esEscritorio(context);

    final vacio = EstadoVacio(
      emoji: _filtro == 'all' ? '💸' : '🔍',
      titulo: _filtro == 'all' ? 'Sin movimientos' : 'Nada en este filtro',
      detalle: _filtro == 'all'
          ? 'No hay movimientos en ${nombreMes(_mes)}. Los cobros de los '
              'turnos también entran acá.'
          : 'Hay movimientos en ${nombreMes(_mes)}, pero ningún '
              '${_filtro == "income" ? "ingreso" : "gasto"}.',
      accion: _filtro == 'all'
          ? null
          : ('Ver todos', () => setState(() => _filtro = 'all')),
    );

    final selector = _SelectorMes(
      mes: _mes,
      onAnterior: () => setState(() => _offsetMes--),
      // No se puede ir al futuro: no hay movimientos que ver ahí y el
      // botón habilitado invita a un callejón sin salida.
      onSiguiente: _offsetMes < 0 ? () => setState(() => _offsetMes++) : null,
    );
    final filtros = FilaFiltros(
      opciones: const [
        ('all', 'Todos'),
        ('income', 'Ingresos'),
        ('expense', 'Gastos'),
      ],
      activo: _filtro,
      onElegir: (f) => setState(() => _filtro = f),
    );
    final ingresos = _Total(
      etiqueta: 'Ingresos',
      valor: resumen.ingresos,
      color: MColors.successText,
      fondo: MColors.successBg,
    );
    final gastos = _Total(
      etiqueta: 'Gastos',
      valor: resumen.egresos,
      color: MColors.dangerText,
      fondo: MColors.dangerBg,
    );
    final neto = Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MColors.surface,
        borderRadius: BorderRadius.circular(MRadius.md),
        border: Border.all(color: MColors.border),
        boxShadow: MShadow.xs,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Neto del mes', style: MText.menor),
          const SizedBox(height: 2),
          Text(
            formatMoney(resumen.neta),
            style: serif(
              size: 28,
              weight: 600,
              // El rojo se reserva para el neto negativo: es el único
              // número de esta pantalla que exige una decisión.
              color: resumen.neta < 0 ? MColors.dangerText : MColors.tPrimary,
            ),
          ),
        ],
      ),
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: fabVista(
        context,
        visible: puedeEscribir,
        onTap: () => _mostrarFormulario(context, ref),
      ),
      body: ContenidoEscritorio.tabla(
        child: Column(
          children: [
            if (escritorio)
              BarraVista(
                buscador: selector,
                filtros: filtros,
                accion: puedeEscribir
                    ? BotonPrimario(
                        texto: 'Nuevo movimiento',
                        onTap: () => _mostrarFormulario(context, ref),
                      )
                    : null,
              ),
            Expanded(
              child: ListView(
                padding: padVista(context, sinArriba: escritorio),
                children: [
                  if (!escritorio) ...[
                    FadeSlideIn(child: selector),
                    const SizedBox(height: 12),
                  ],
                  if (escritorio)
                    // Los tres números del mes en una sola fila: en un monitor, dos
                    // tarjetas de 600 px y el neto abajo solo se leen como un
                    // formulario de celular.
                    FadeSlideIn(
                      // IntrinsicHeight: dentro de un ListView el alto es
                      // infinito y `stretch` a secas no tiene contra qué
                      // estirar; así las tres tarjetas quedan igual de altas.
                      child: IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(child: ingresos),
                            const SizedBox(width: 12),
                            Expanded(child: gastos),
                            const SizedBox(width: 12),
                            Expanded(child: neto),
                          ],
                        ),
                      ),
                    )
                  else ...[
                    FadeSlideIn(
                      child: Row(
                        children: [
                          Expanded(child: ingresos),
                          const SizedBox(width: 12),
                          Expanded(child: gastos),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 50),
                      child: neto,
                    ),
                  ],
                  const SizedBox(height: 22),
                  if (!escritorio) ...[
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 90),
                      child: filtros,
                    ),
                    const SizedBox(height: 14),
                  ],
                  // `.sec-row` del original: el título de la lista con el cierre a la
                  // derecha, no un botón suelto.
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 110),
                    child: FilaSeccion(
                      titulo: 'MOVIMIENTOS',
                      accion: 'Cierre 📋',
                      onAccion: () => mostrarCierre(
                        context,
                        movimientos: todos,
                        rango: monthRange(_mes),
                        titulo: nombreMes(_mes),
                      ),
                    ),
                  ),
                  if (cargando)
                    const EsqueletoDeLista(
                      filas: 5,
                      alto: 64,
                      padding: EdgeInsets.zero,
                    )
                  else if (escritorio)
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 130),
                      child: _tablaMovimientos(
                        context,
                        ref,
                        movimientos,
                        vacio: vacio,
                      ),
                    )
                  else if (movimientos.isEmpty)
                    vacio
                  else
                    for (var i = 0; i < movimientos.length; i++)
                      FadeSlideIn(
                        delay:
                            Duration(milliseconds: 130 + (i < 8 ? i : 8) * 35),
                        child: _FilaMovimiento(mov: movimientos[i]),
                      ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Los movimientos como tabla, para escritorio: fecha, concepto, categoría,
/// método y el monto con signo y color a la derecha. Ordenable por fecha y
/// por monto; arranca del más nuevo al más viejo, como la lista.
Widget _tablaMovimientos(
  BuildContext context,
  WidgetRef ref,
  List<Transaction> movimientos, {
  required Widget vacio,
}) =>
    TablaMirame<Transaction>(
      filas: movimientos,
      claveDe: (m) => m.id,
      expandir: false,
      vacio: vacio,
      onTap: (m) => _mostrarFormulario(context, ref, mov: m),
      columnas: [
        ColumnaTabla(
          titulo: 'Fecha',
          ancho: 110,
          ordenarPor: (m) => m.fecha,
          celda: (_, m) =>
              CeldaTexto(formatDateShort(m.fecha), color: MColors.tSecondary),
        ),
        ColumnaTabla(
          titulo: 'Concepto',
          flex: 3,
          celda: (_, m) => Row(
            children: [
              Text(
                m.tipo == TxTipo.income ? '✅' : '🔴',
                style: const TextStyle(fontSize: 13),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: CeldaTexto(
                  m.descripcion?.isNotEmpty ?? false
                      ? m.descripcion!
                      : (m.categoria?.isNotEmpty ?? false
                          ? m.categoria!
                          : 'Movimiento'),
                  peso: 500,
                ),
              ),
            ],
          ),
        ),
        ColumnaTabla(
          titulo: 'Categoría',
          opcional: true,
          flex: 2,
          ordenarPor: (m) => (m.categoria ?? '').toLowerCase(),
          celda: (_, m) => CeldaTexto(
            m.categoria?.isNotEmpty ?? false ? m.categoria! : '—',
            color: MColors.tSecondary,
          ),
        ),
        ColumnaTabla(
          titulo: 'Método',
          opcional: true,
          ancho: 120,
          celda: (_, m) => CeldaTexto(
            _FilaMovimiento._metodo(m.metodo),
            color: MColors.tMuted,
          ),
        ),
        ColumnaTabla(
          titulo: 'Monto',
          ancho: 130,
          numerica: true,
          ordenarPor: (m) => m.tipo == TxTipo.income ? m.monto : -m.monto,
          celda: (_, m) {
            final esIngreso = m.tipo == TxTipo.income;
            return CeldaTexto(
              '${esIngreso ? '+' : '-'}${formatMoney(m.monto)}',
              numerica: true,
              peso: 700,
              color: esIngreso ? MColors.ingreso : MColors.gasto,
            );
          },
        ),
      ],
    );

class _Total extends StatelessWidget {
  const _Total({
    required this.etiqueta,
    required this.valor,
    required this.color,
    required this.fondo,
  });

  final String etiqueta;
  final num valor;
  final Color color;
  final Color fondo;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: fondo,
          borderRadius: BorderRadius.circular(MRadius.md),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(etiqueta, style: sans(size: 11.5, weight: 600, color: color)),
            const SizedBox(height: 4),
            Text(
              formatMoney(valor),
              style: sans(size: 17, weight: 600, color: color),
            ),
          ],
        ),
      );
}

/// `.tx-item` — ícono de 40 con el fondo del tipo, descripción, la meta
/// "fecha · método" y el monto con signo.
///
/// El original usa emoji (✅ / 🔴) y no íconos de línea: es lo que le da el
/// aire de la app, y a 17px se leen mejor que un trazo fino.
class _FilaMovimiento extends ConsumerWidget {
  const _FilaMovimiento({required this.mov});

  final Transaction mov;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final esIngreso = mov.tipo == TxTipo.income;
    return TarjetaMirame(
      margenInferior: 7,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      onTap: () => _mostrarFormulario(context, ref, mov: mov),
      hijo: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: esIngreso ? MColors.successBg : MColors.dangerBg,
              border: Border.all(
                color: esIngreso ? MColors.successBorder : MColors.dangerBorder,
              ),
              borderRadius: BorderRadius.circular(MRadius.sm),
            ),
            child: Text(
              esIngreso ? '✅' : '🔴',
              style: const TextStyle(fontSize: 17),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  // El original cae a la categoría y después a "Movimiento":
                  // una fila sin texto no se puede distinguir de otra.
                  mov.descripcion?.isNotEmpty ?? false
                      ? mov.descripcion!
                      : (mov.categoria?.isNotEmpty ?? false
                          ? mov.categoria!
                          : 'Movimiento'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: sans(size: 13, weight: 500),
                ),
                const SizedBox(height: 2),
                Text(
                  '${formatDateShort(mov.fecha)} · ${_metodo(mov.metodo)}',
                  style: sans(size: 11, color: MColors.tMuted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${esIngreso ? '+' : '-'}${formatMoney(mov.monto)}',
            style: sans(
              size: 14,
              weight: 700,
              color: esIngreso ? MColors.ingreso : MColors.gasto,
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 4),
            child: Text('›',
                style: TextStyle(fontSize: 18, color: MColors.tMuted)),
          ),
        ],
      ),
    );
  }

  static String _metodo(TxMetodo m) => switch (m) {
        TxMetodo.transferencia => 'Transferencia',
        TxMetodo.tarjeta => 'Tarjeta',
        TxMetodo.efectivo => 'Efectivo',
      };
}

Future<void> _mostrarFormulario(
  BuildContext context,
  WidgetRef ref, {
  Transaction? mov,
}) =>
    showAppSheet<void>(
      context,
      builder: (_) => _FormularioMovimiento(mov: mov),
    );

class _FormularioMovimiento extends ConsumerStatefulWidget {
  const _FormularioMovimiento({this.mov});

  final Transaction? mov;

  @override
  ConsumerState<_FormularioMovimiento> createState() => _FormMovState();
}

class _FormMovState extends ConsumerState<_FormularioMovimiento> {
  late final TextEditingController _monto;
  late final TextEditingController _descripcion;
  late bool _esIngreso;
  bool _guardando = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final m = widget.mov;
    _monto = TextEditingController(
      text: m == null ? '' : m.monto.toStringAsFixed(0),
    );
    _descripcion = TextEditingController(text: m?.descripcion ?? '');
    _esIngreso = m == null || m.tipo == TxTipo.income;
  }

  @override
  void dispose() {
    _monto.dispose();
    _descripcion.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    // Se aceptan coma y punto como separador decimal: en Argentina se escribe
    // con coma y el teclado numérico ofrece las dos.
    final crudo = _monto.text.trim().replaceAll('.', '').replaceAll(',', '.');
    final monto = double.tryParse(crudo);
    if (monto == null || monto <= 0) {
      setState(() => _error = 'Poné un monto mayor a cero.');
      return;
    }
    final repo = ref.read(businessRepoProvider);
    if (repo == null) return;

    setState(() {
      _guardando = true;
      _error = null;
    });
    final nav = Navigator.of(context);
    try {
      await repo.guardarMovimiento(
        id: widget.mov?.id,
        // Los valores del enum del servidor, no traducciones.
        tipo: _esIngreso ? 'income' : 'expense',
        monto: monto,
        fecha: widget.mov?.fecha ?? DateTime.now(),
        descripcion:
            _descripcion.text.trim().isEmpty ? null : _descripcion.text.trim(),
      );
      nav.pop();
    } catch (_) {
      if (mounted) {
        setState(() {
          _guardando = false;
          _error = 'No se pudo guardar en este dispositivo.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => SheetFormulario(
        titulo: widget.mov == null ? 'Nuevo movimiento' : 'Editar movimiento',
        error: _error,
        guardando: _guardando,
        onGuardar: _guardar,
        onBorrar: widget.mov == null
            ? null
            : () async {
                final nav = Navigator.of(context);
                await ref
                    .read(businessRepoProvider)
                    ?.borrar('transactions', widget.mov!.id);
                nav.pop();
              },
        campos: [
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: true, label: Text('Ingreso')),
                ButtonSegment(value: false, label: Text('Gasto')),
              ],
              selected: {_esIngreso},
              onSelectionChanged: (s) => setState(() => _esIngreso = s.first),
              style: SegmentedButton.styleFrom(
                selectedBackgroundColor: MColors.brandBg,
                selectedForegroundColor: MColors.brandDark,
                textStyle: sans(size: 13, weight: 600),
              ),
            ),
          ),
          CampoTexto(
            controlador: _monto,
            etiqueta: 'Monto',
            prefijo: r'$ ',
            teclado: const TextInputType.numberWithOptions(decimal: true),
            autofocus: true,
          ),
          CampoTexto(controlador: _descripcion, etiqueta: 'Descripción'),
        ],
      );
}
