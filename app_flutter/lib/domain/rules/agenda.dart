/// Reglas de agenda: turnos libres, agrupado por hora y solapamientos.
///
/// Portadas de `genTurnos`, `renderAgenda` y `apptCardHTML` del `index.html`.
library;

import '../entities/entities.dart';
import 'period.dart';

/// Horario del salón. En el original están hardcodeados en `genTurnos`
/// (`OPEN=9, CLOSE=19`) y los domingos se saltean.
///
/// Deberían pasar a ser configuración por tenant cuando se venda a otro salón:
/// no todos abren de 9 a 19 ni cierran el domingo.
const kOpenHour = 9;
const kCloseHour = 19;

/// Días en los que el salón no atiende. `DateTime.sunday` es 7 en Dart.
const kClosedWeekdays = {DateTime.sunday};

/// Un turno cuenta como ocupando el horario salvo que esté cancelado.
bool ocupaHorario(Appointment a) => a.estado != TurnoEstado.cancelled;

/// Horarios libres de un día, en slots de una hora en punto.
///
/// Puerto de `genTurnos`: si [dia] es hoy, se saltean las horas que ya pasaron
/// (`h <= now.getHours()`, es decir la hora actual también se descarta).
List<TimeOfDayValue> freeSlots({
  required Iterable<Appointment> appointments,
  required DateTime dia,
  required DateTime ahora,
}) {
  final d = dateOnly(dia);
  if (kClosedWeekdays.contains(d.weekday)) return const [];

  final esHoy = d == dateOnly(ahora);

  final ocupados = appointments
      .where((a) => dateOnly(a.fecha) == d && ocupaHorario(a) && a.hora != null)
      .map((a) => a.hora!.hour)
      .toSet();

  final libres = <TimeOfDayValue>[];
  for (var h = kOpenHour; h < kCloseHour; h++) {
    if (esHoy && h <= ahora.hour) continue;
    if (ocupados.contains(h)) continue;
    libres.add(TimeOfDayValue(h, 0));
  }
  return libres;
}

/// Los próximos [dias] días con al menos un horario libre.
/// El original arma 7 días y muestra hasta 6 slots por día.
List<({DateTime dia, List<TimeOfDayValue> libres})> upcomingFreeSlots({
  required Iterable<Appointment> appointments,
  required DateTime ahora,
  int dias = 7,
  int maxPorDia = 6,
}) {
  final out = <({DateTime dia, List<TimeOfDayValue> libres})>[];
  for (var i = 0; i < dias; i++) {
    final d = dateOnly(ahora).add(Duration(days: i));
    final libres = freeSlots(appointments: appointments, dia: d, ahora: ahora);
    if (libres.isEmpty) continue;
    out.add((dia: d, libres: libres.take(maxPorDia).toList()));
  }
  return out;
}

/// Turnos de un día, ordenados por hora y agrupados por hora en punto — que es
/// como los dibuja el timeline de la agenda.
///
/// Los turnos sin hora van al final, en un grupo aparte con clave `null`.
List<({int? hora, List<Appointment> turnos})> groupByHour(
  Iterable<Appointment> appointments,
  DateTime dia,
) {
  final d = dateOnly(dia);
  final delDia = appointments.where((a) => dateOnly(a.fecha) == d).toList()
    ..sort((a, b) {
      final ha = a.hora, hb = b.hora;
      if (ha == null && hb == null) return 0;
      if (ha == null) return 1;
      if (hb == null) return -1;
      return ha.compareTo(hb);
    });

  final grupos = <int?, List<Appointment>>{};
  for (final a in delDia) {
    grupos.putIfAbsent(a.hora?.hour, () => []).add(a);
  }

  return grupos.entries.map((e) => (hora: e.key, turnos: e.value)).toList();
}

// ─────────────────────────────────────────────────────────────────────────────
// Solapamientos — funcionalidad NUEVA
// ─────────────────────────────────────────────────────────────────────────────

/// El legacy **no valida solapamientos ni usa `service.duration`**: se pueden
/// crear dos turnos a la misma hora con la misma profesional, sin ningún aviso.
///
/// Acá se detecta. No se BLOQUEA el guardado: a veces la dueña sabe lo que hace
/// (dos clientas en paralelo, un turno que se acorta). Se avisa y ella decide.
/// Bloquear una operación legítima que antes funcionaba es peor que el bug.

/// Fin estimado de un turno, según la duración de sus servicios.
/// Si el turno no tiene servicios con duración, se asume 1 hora.
TimeOfDayValue? appointmentEnd(
  Appointment a,
  Map<String, Service> serviciosPorId,
) {
  final inicio = a.hora;
  if (inicio == null) return null;

  var duracion = 0;
  for (final id in a.serviceIds) {
    duracion += serviciosPorId[id]?.duracionMin ?? 0;
  }
  if (duracion == 0) duracion = 60;

  final fin = inicio.totalMinutes + duracion;
  // Un turno que pasaría de medianoche se recorta a las 23:59.
  if (fin >= 24 * 60) return const TimeOfDayValue(23, 59);
  return TimeOfDayValue(fin ~/ 60, fin % 60);
}

/// Turnos que se pisan con [candidato] — misma profesional, mismo día, horarios
/// superpuestos. Los cancelados no cuentan.
///
/// Un turno que empieza justo cuando termina el otro **no** se considera
/// solapado.
List<Appointment> overlappingAppointments({
  required Appointment candidato,
  required Iterable<Appointment> existentes,
  required Map<String, Service> serviciosPorId,
}) {
  if (!ocupaHorario(candidato)) return const [];
  final ini = candidato.hora;
  final fin = appointmentEnd(candidato, serviciosPorId);
  if (ini == null || fin == null) return const [];

  final dia = dateOnly(candidato.fecha);

  return existentes.where((o) {
    if (o.id == candidato.id) return false;
    if (!ocupaHorario(o)) return false;
    if (dateOnly(o.fecha) != dia) return false;

    // Sin profesional asignada no se puede afirmar que haya conflicto.
    if (o.professionalId == null || candidato.professionalId == null) {
      return false;
    }
    if (o.professionalId != candidato.professionalId) return false;

    final oIni = o.hora;
    final oFin = appointmentEnd(o, serviciosPorId);
    if (oIni == null || oFin == null) return false;

    return ini.totalMinutes < oFin.totalMinutes &&
        oIni.totalMinutes < fin.totalMinutes;
  }).toList();
}
