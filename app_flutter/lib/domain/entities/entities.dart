/// Entidades de negocio. Dart puro: sin Flutter, sin Supabase, sin Drift.
///
/// Los tipos ya son los CORREGIDOS respecto del modelo legacy de IndexedDB
/// (ver `android/CLAUDE.md` § Deuda heredada):
///   · precios y cantidades son `num`/`int`, no strings de `input.value`
///   · `vip` es `bool`, no el string `'true'`
///   · los servicios de un turno se vinculan por ID, no por nombre
library;

enum TurnoEstado { confirmed, pending, done, cancelled }

enum TxTipo { income, expense }

enum TxMetodo { efectivo, transferencia, tarjeta }

class Professional {
  const Professional({required this.id, required this.nombre, this.telefono});

  final String id;
  final String nombre;
  final String? telefono;
}

class Service {
  const Service({
    required this.id,
    required this.nombre,
    this.precio = 0,
    this.duracionMin = 60,
    this.retoqueDias,
    this.mantenimientoDias,
    this.notas,
  });

  final String id;
  final String nombre;
  final num precio;
  final int duracionMin;

  /// Días hasta el retoque. Si es null, el servicio no genera recordatorio.
  final int? retoqueDias;
  final int? mantenimientoDias;
  final String? notas;
}

class Client {
  const Client({
    required this.id,
    required this.nombre,
    this.telefono,
    this.email,
    this.cumple,
    this.vip = false,
    this.notas,
  });

  final String id;
  final String nombre;
  final String? telefono;
  final String? email;
  final DateTime? cumple;
  final bool vip;
  final String? notas;
}

class Appointment {
  const Appointment({
    required this.id,
    required this.fecha,
    this.clientId,
    this.professionalId,
    this.serviceIds = const [],
    this.hora,
    this.precio = 0,
    this.estado = TurnoEstado.confirmed,
    this.notas,
  });

  final String id;
  final String? clientId;
  final String? professionalId;

  /// IDs de servicios. En el legacy era una lista de NOMBRES, y por eso
  /// renombrar un servicio rompía los recordatorios de retoque.
  final List<String> serviceIds;

  /// Solo la fecha; la hora va aparte, igual que en el modelo original.
  final DateTime fecha;
  final TimeOfDayValue? hora;
  final num precio;
  final TurnoEstado estado;
  final String? notas;
}

class Transaction {
  const Transaction({
    required this.id,
    required this.tipo,
    required this.fecha,
    this.monto = 0,
    this.descripcion,
    this.categoria,
    this.metodo = TxMetodo.efectivo,
    this.clientId,
    this.appointmentId,
  });

  final String id;
  final TxTipo tipo;
  final num monto;
  final String? descripcion;

  /// Categoría cruda. El default al agrupar es `'servicio'` para ingresos y
  /// `'otro-gasto'` para egresos — ver `rules/cash_close.dart`.
  final String? categoria;
  final DateTime fecha;
  final TxMetodo metodo;

  /// El legacy leía este campo en el CRM pero nunca lo escribía, así que
  /// "gastado por clienta" siempre daba $0. Acá se escribe.
  final String? clientId;
  final String? appointmentId;
}

class StockItem {
  const StockItem({
    required this.id,
    required this.nombre,
    this.categoria,
    this.cantidad = 0,
    this.minimo = 5,
    this.unidad = 'unidades',
  });

  final String id;
  final String nombre;
  final String? categoria;
  final int cantidad;
  final int minimo;
  final String unidad;
}

/// Hora del día sin fecha. Se define acá para que `domain/` no dependa de
/// Flutter (el `TimeOfDay` del framework vive en `material.dart`).
class TimeOfDayValue implements Comparable<TimeOfDayValue> {
  const TimeOfDayValue(this.hour, this.minute);

  /// Parsea `'HH:mm'`, el formato que guardaba el legacy. Devuelve null si el
  /// string no tiene esa forma, en vez de lanzar: hay datos viejos sin hora.
  static TimeOfDayValue? parse(String? raw) {
    if (raw == null) return null;
    final parts = raw.split(':');
    if (parts.length < 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return null;
    if (h < 0 || h > 23 || m < 0 || m > 59) return null;
    return TimeOfDayValue(h, m);
  }

  final int hour;
  final int minute;

  int get totalMinutes => hour * 60 + minute;

  /// `'09:30'` — el mismo formato que usaba el original para ordenar.
  @override
  String toString() =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

  /// Formato de 12 horas con AM/PM, como lo muestra la agenda: `(9, '30', 'AM')`.
  (int, String, String) to12h() {
    final ap = hour >= 12 ? 'PM' : 'AM';
    final h12 = hour % 12 == 0 ? 12 : hour % 12;
    return (h12, minute.toString().padLeft(2, '0'), ap);
  }

  @override
  int compareTo(TimeOfDayValue other) =>
      totalMinutes.compareTo(other.totalMinutes);

  @override
  bool operator ==(Object other) =>
      other is TimeOfDayValue && other.hour == hour && other.minute == minute;

  @override
  int get hashCode => Object.hash(hour, minute);
}
