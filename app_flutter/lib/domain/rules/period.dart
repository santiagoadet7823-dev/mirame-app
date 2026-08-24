/// Rangos de fechas.
///
/// El legacy compara strings: arma `'YYYY-MM-01'` y `'YYYY-MM-31'` y filtra con
/// `t.date >= ms && t.date <= me`. Funciona por casualidad — ningún día del mes
/// supera lexicográficamente al 31 — pero es frágil.
///
/// Acá se usan fechas reales con el último día correcto del mes. El resultado
/// es idéntico para los datos existentes, y deja de depender de esa casualidad.
///
/// **Zona horaria:** todo se calcula en hora LOCAL. El legacy usaba
/// `toISOString()`, que devuelve el día en UTC, así que en Argentina (UTC−3)
/// después de las 21:00 el "hoy" saltaba al día siguiente. Ese bug no se
/// reproduce.
library;

/// Un rango de días cerrado en ambos extremos, normalizado a medianoche local.
class DateRange {
  DateRange(DateTime desde, DateTime hasta)
      : desde = dateOnly(desde),
        hasta = dateOnly(hasta);

  final DateTime desde;
  final DateTime hasta;

  bool contains(DateTime d) {
    final x = dateOnly(d);
    return !x.isBefore(desde) && !x.isAfter(hasta);
  }

  /// Cantidad de días del rango, ambos extremos incluidos.
  int get days => hasta.difference(desde).inDays + 1;
}

/// Descarta la hora. Todas las comparaciones de fecha del dominio pasan por acá.
DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// Último día del mes de [d]. `DateTime(y, m+1, 0)` da el día 0 del mes
/// siguiente, que Dart normaliza al último del mes actual — el mismo truco que
/// usa el original con `new Date(y, m+1, 0).getDate()`.
int daysInMonth(DateTime d) => DateTime(d.year, d.month + 1, 0).day;

/// El mes completo que contiene a [d].
DateRange monthRange(DateTime d) => DateRange(
    DateTime(d.year, d.month, 1), DateTime(d.year, d.month, daysInMonth(d)));

/// Desde el día 1 del mes hasta [hoy] inclusive.
///
/// Es el rango que usa la proyección del dashboard: acumulado del mes **hasta
/// hoy**, no el mes entero.
DateRange monthToDate(DateTime hoy) =>
    DateRange(DateTime(hoy.year, hoy.month, 1), hoy);

/// La semana que contiene a [d], **empezando el domingo**.
///
/// El original hace `wk.setDate(wk.getDate() - wk.getDay())`, y `getDay()`
/// devuelve 0 para domingo. En Dart `weekday` va de 1 (lunes) a 7 (domingo),
/// así que `weekday % 7` reproduce el `getDay()` de JS.
DateRange weekRange(DateTime d) {
  final base = dateOnly(d);
  final inicio = base.subtract(Duration(days: base.weekday % 7));
  return DateRange(inicio, inicio.add(const Duration(days: 6)));
}

/// El mes desplazado [offset] meses respecto de [d]. `-1` es el mes anterior.
DateRange monthOffset(DateTime d, int offset) =>
    monthRange(DateTime(d.year, d.month + offset, 1));

/// `YYYY-MM-DD` en hora LOCAL.
///
/// Nunca `toIso8601String()`: en Salta (UTC−3) eso corre el día después de las
/// 21:00, que es exactamente cuando se cierra la caja. Era el bug del `td()`
/// del legacy.
String claveFecha(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-'
    '${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';
