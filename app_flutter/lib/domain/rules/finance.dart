/// Reglas de caja, proyección y estadísticas.
///
/// Portadas de `renderProjection`, `openCierre`, `renderStats`, `renderExpByCat`,
/// `renderBarChart`, `renderDonut`, `renderTopClients` y `renderMonthlyComp`
/// del `index.html`.
///
/// Estos números son los que la dueña usa para cobrar y para decidir. Cualquier
/// diferencia con la app vieja es un error, aunque parezca una mejora.
library;

import '../entities/entities.dart';
import 'period.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Totales de un período
// ─────────────────────────────────────────────────────────────────────────────

class CashSummary {
  const CashSummary({required this.ingresos, required this.egresos});

  final num ingresos;
  final num egresos;

  num get neta => ingresos - egresos;

  /// Margen en porcentaje entero. El original: `inc>0 ? round(neta/inc*100) : 0`.
  ///
  /// Puede ser **negativo** si los egresos superan a los ingresos, y así se
  /// muestra. No se recorta acá — el recorte es solo para el ancho de la barra.
  int get margenPct => ingresos > 0 ? (neta / ingresos * 100).round() : 0;

  /// El ancho de la barra de margen sí se recorta a 0..100, porque una barra
  /// no puede medir -40%. El TEXTO muestra `margenPct` sin recortar: es la
  /// distinción que hace el original entre `st-margen` y `st-margen-bar`.
  int get margenBarPct => margenPct.clamp(0, 100);
}

CashSummary summarize(Iterable<Transaction> txs, DateRange range) {
  num inc = 0;
  num exp = 0;
  for (final t in txs) {
    if (!range.contains(t.fecha)) continue;
    if (t.tipo == TxTipo.income) {
      inc += t.monto;
    } else {
      exp += t.monto;
    }
  }
  return CashSummary(ingresos: inc, egresos: exp);
}

num totalIngresos(Iterable<Transaction> txs, DateRange range) =>
    summarize(txs, range).ingresos;

// ─────────────────────────────────────────────────────────────────────────────
// Proyección del mes
// ─────────────────────────────────────────────────────────────────────────────

class Projection {
  const Projection({
    required this.acumulado,
    required this.proyectado,
    required this.promedioDiario,
    required this.pct,
    required this.diaActual,
    required this.diasDelMes,
  });

  final num acumulado;
  final num proyectado;
  final num promedioDiario;

  /// Progreso del acumulado sobre el proyectado, recortado a 0..100.
  final int pct;
  final int diaActual;
  final int diasDelMes;

  /// El dashboard esconde la tarjeta cuando no hay ingresos: proyectar sobre
  /// cero no dice nada.
  bool get visible => acumulado != 0;

  /// `'Día 12 de 31 · 39% del mes'`
  String get subtitulo {
    final pctMes = (diaActual / diasDelMes * 100).round();
    return 'Día $diaActual de $diasDelMes · $pctMes% del mes';
  }
}

/// Proyección de ingresos a fin de mes. Puerto de `renderProjection`:
///
/// ```js
/// const days = Math.max(1, now.getDate()), dM = <días del mes>;
/// const cur = <ingresos del mes hasta hoy>;
/// if (!cur) return;
/// const proj = Math.round((cur/days) * dM);
/// const pct  = Math.min(100, Math.round((cur/Math.max(proj,1)) * 100));
/// ```
Projection projectMonth(Iterable<Transaction> txs, DateTime hoy) {
  final dias = hoy.day < 1 ? 1 : hoy.day;
  final diasMes = daysInMonth(hoy);
  final acumulado = totalIngresos(txs, monthToDate(hoy));

  final proyectado = (acumulado / dias * diasMes).round();
  final pct = proyectado <= 0
      ? 0
      : (acumulado / (proyectado < 1 ? 1 : proyectado) * 100)
          .round()
          .clamp(0, 100);

  return Projection(
    acumulado: acumulado,
    proyectado: proyectado,
    promedioDiario: (acumulado / dias).round(),
    pct: pct,
    diaActual: hoy.day,
    diasDelMes: diasMes,
  );
}

/// Proyección de ganancia NETA, la variante que muestra la pantalla de stats:
/// se proyectan los ingresos y se restan los egresos ya registrados.
num projectNet(Iterable<Transaction> txs, DateTime hoy) {
  final s = summarize(txs, monthRange(hoy));
  final dias = hoy.day < 1 ? 1 : hoy.day;
  final proyInc = (s.ingresos / dias * daysInMonth(hoy)).round();
  return proyInc - s.egresos;
}

// ─────────────────────────────────────────────────────────────────────────────
// Cierre de caja
// ─────────────────────────────────────────────────────────────────────────────

/// Categoría por defecto de un ingreso sin categorizar, en el agrupado.
const kDefaultIncomeCategory = 'servicio';

/// Categoría por defecto de un egreso sin categorizar.
const kDefaultExpenseCategory = 'otro-gasto';

class CashClose {
  const CashClose({
    required this.summary,
    required this.porCategoriaIngreso,
    required this.porCategoriaEgreso,
    required this.porMetodo,
  });

  final CashSummary summary;

  /// Todos ordenados de mayor a menor, como en el modal original.
  final List<MapEntry<String, num>> porCategoriaIngreso;
  final List<MapEntry<String, num>> porCategoriaEgreso;

  /// Solo INGRESOS. El original nunca acumula egresos por método de pago.
  final List<MapEntry<String, num>> porMetodo;
}

/// Puerto de `openCierre`.
CashClose closeCash(Iterable<Transaction> txs, DateRange range) {
  final inc = <String, num>{};
  final exp = <String, num>{};
  final pay = <String, num>{};

  for (final t in txs) {
    if (!range.contains(t.fecha)) continue;
    if (t.tipo == TxTipo.income) {
      final cat = _blankToNull(t.categoria) ?? kDefaultIncomeCategory;
      inc[cat] = (inc[cat] ?? 0) + t.monto;
      final m = t.metodo.name;
      pay[m] = (pay[m] ?? 0) + t.monto;
    } else {
      final cat = _blankToNull(t.categoria) ?? kDefaultExpenseCategory;
      exp[cat] = (exp[cat] ?? 0) + t.monto;
    }
  }

  return CashClose(
    summary: summarize(txs, range),
    porCategoriaIngreso: _sortedDesc(inc),
    porCategoriaEgreso: _sortedDesc(exp),
    porMetodo: _sortedDesc(pay),
  );
}

/// Gastos del período por categoría, con su porcentaje sobre el total.
/// Puerto de `renderExpByCat`.
List<({String categoria, num monto, int pct})> expensesByCategory(
  Iterable<Transaction> txs,
  DateRange range,
) {
  final byCat = <String, num>{};
  for (final t in txs) {
    if (t.tipo != TxTipo.expense || !range.contains(t.fecha)) continue;
    final cat = _blankToNull(t.categoria) ?? kDefaultExpenseCategory;
    byCat[cat] = (byCat[cat] ?? 0) + t.monto;
  }
  final entries = _sortedDesc(byCat);
  if (entries.isEmpty) return const [];

  final total = entries.fold<num>(0, (s, e) => s + e.value);
  final divisor = total == 0 ? 1 : total;
  return entries
      .map((e) => (
            categoria: e.key,
            monto: e.value,
            pct: (e.value / divisor * 100).round(),
          ))
      .toList();
}

// ─────────────────────────────────────────────────────────────────────────────
// Gráficos
// ─────────────────────────────────────────────────────────────────────────────

/// Ingresos de las últimas 8 semanas, de la más vieja a la más reciente.
/// Puerto de `renderBarChart`: recorre `i` de 7 a 0, toma `hoy - i*7` y arma la
/// semana domingo-sábado que la contiene.
List<({DateTime inicio, num total, int pctAlto})> weeklyIncome(
  Iterable<Transaction> txs,
  DateTime hoy,
) {
  final semanas = <({DateTime inicio, num total})>[];
  for (var i = 7; i >= 0; i--) {
    final d = dateOnly(hoy).subtract(Duration(days: i * 7));
    final r = weekRange(d);
    semanas.add((inicio: r.desde, total: totalIngresos(txs, r)));
  }

  final maxTotal = semanas.fold<num>(0, (m, s) => s.total > m ? s.total : m);
  final divisor = maxTotal < 1 ? 1 : maxTotal;

  return semanas
      .map((s) => (
            inicio: s.inicio,
            total: s.total,
            pctAlto: (s.total / divisor * 100).round(),
          ))
      .toList();
}

/// Los 5 servicios más usados, contando apariciones en TODOS los turnos
/// (sin filtrar por fecha ni por estado). Puerto de `renderDonut`.
List<({String serviceId, int cantidad})> topServices(
  Iterable<Appointment> appts, {
  int limit = 5,
}) {
  final cnt = <String, int>{};
  for (final a in appts) {
    for (final id in a.serviceIds) {
      cnt[id] = (cnt[id] ?? 0) + 1;
    }
  }
  final entries = cnt.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  return entries
      .take(limit)
      .map((e) => (serviceId: e.key, cantidad: e.value))
      .toList();
}

/// Las 5 clientas que más gastaron, sumando el PRECIO DE LOS TURNOS —
/// no las transacciones. Puerto de `renderTopClients`.
///
/// Es una decisión del original que conviene conservar: los turnos tienen
/// clienta asignada siempre, y las transacciones históricas no.
List<({String clientId, num total, int pctBarra})> topClients(
  Iterable<Appointment> appts, {
  int limit = 5,
}) {
  final gasto = <String, num>{};
  for (final a in appts) {
    final id = a.clientId;
    if (id == null || a.precio == 0) continue;
    gasto[id] = (gasto[id] ?? 0) + a.precio;
  }
  final entries = gasto.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  final top = entries.take(limit).toList();
  if (top.isEmpty) return const [];

  final max = top.first.value;
  final divisor = max == 0 ? 1 : max;
  return top
      .map((e) => (
            clientId: e.key,
            total: e.value,
            pctBarra: (e.value / divisor * 100).round(),
          ))
      .toList();
}

/// Ticket promedio del mes: ingresos sobre cantidad de turnos del mes.
/// Devuelve 0 si no hubo turnos, en vez de dividir por cero.
num averageTicket(
  Iterable<Transaction> txs,
  Iterable<Appointment> appts,
  DateTime mes,
) {
  final range = monthRange(mes);
  final inc = totalIngresos(txs, range);
  final n = appts.where((a) => range.contains(a.fecha)).length;
  return n == 0 ? 0 : (inc / n).round();
}

/// Comparativa de ingresos de este mes contra el anterior.
/// Puerto de `renderMonthlyComp`.
({num actual, num anterior, int pctActual, int pctAnterior}) monthlyComparison(
  Iterable<Transaction> txs,
  DateTime hoy,
) {
  final actual = totalIngresos(txs, monthRange(hoy));
  final anterior = totalIngresos(txs, monthOffset(hoy, -1));
  final max = [actual, anterior, 1].reduce((a, b) => a > b ? a : b);
  return (
    actual: actual,
    anterior: anterior,
    pctActual: (actual / max * 100).round(),
    pctAnterior: (anterior / max * 100).round(),
  );
}

// ─────────────────────────────────────────────────────────────────────────────

String? _blankToNull(String? s) => (s == null || s.trim().isEmpty) ? null : s;

List<MapEntry<String, num>> _sortedDesc(Map<String, num> m) {
  final l = m.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
  return l;
}
