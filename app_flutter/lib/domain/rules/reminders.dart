/// Recordatorios de retoque. Puerto de `renderReminders` del `index.html`.
///
/// Es la funcionalidad que más plata genera de la app: avisa cuándo cada
/// clienta necesita volver, antes de que se le caigan las pestañas y busque
/// otro salón.
library;

import '../entities/entities.dart';
import 'period.dart';

/// Ventana de aviso, en días respecto de la fecha de retoque.
///
/// Del original: `if (diff <= 7 && diff >= -3) rems.push(...)`.
/// Se avisa desde una semana antes hasta tres días después de vencido.
const kReminderMaxAhead = 7;
const kReminderMaxOverdue = -3;

class Reminder {
  const Reminder({
    required this.client,
    required this.service,
    required this.fechaRetoque,
    required this.diasRestantes,
  });

  final Client client;
  final Service service;
  final DateTime fechaRetoque;

  /// Días hasta el retoque. Negativo si ya venció.
  final int diasRestantes;

  bool get vencido => diasRestantes < 0;

  /// `'Hace 2d'` · `'Hoy'` · `'En 5d'`
  String get etiqueta {
    if (diasRestantes < 0) return 'Hace ${diasRestantes.abs()}d';
    if (diasRestantes == 0) return 'Hoy';
    return 'En ${diasRestantes}d';
  }
}

/// Calcula los recordatorios pendientes.
///
/// Para cada clienta:
///   1. busca su último turno **completado** (`done`), el más reciente por fecha
///   2. resuelve el servicio de ese turno
///   3. si el servicio define `retoqueDias`, la fecha objetivo es
///      `fecha del turno + retoqueDias`
///   4. entra en la lista si faltan entre -3 y 7 días
///
/// **Diferencia con el legacy:** el original vinculaba el servicio por NOMBRE
/// (`sv.name === last.service`), así que renombrar un servicio dejaba a todas
/// sus clientas sin recordatorio, en silencio. Acá se vincula por ID.
///
/// Cuando un turno tiene varios servicios se toma el de retoque **más corto**:
/// es el que manda para saber cuándo tiene que volver.
List<Reminder> pendingReminders({
  required Iterable<Client> clients,
  required Iterable<Appointment> appointments,
  required Iterable<Service> services,
  required DateTime hoy,
}) {
  final serviciosPorId = {for (final s in services) s.id: s};
  final hoyD = dateOnly(hoy);

  // Último turno completado de cada clienta.
  final ultimoPorCliente = <String, Appointment>{};
  for (final a in appointments) {
    if (a.estado != TurnoEstado.done) continue;
    final cid = a.clientId;
    if (cid == null) continue;
    final actual = ultimoPorCliente[cid];
    if (actual == null || a.fecha.isAfter(actual.fecha)) {
      ultimoPorCliente[cid] = a;
    }
  }

  final out = <Reminder>[];
  for (final c in clients) {
    final last = ultimoPorCliente[c.id];
    if (last == null) continue;

    // De los servicios del turno, el que exige volver antes.
    Service? elegido;
    for (final id in last.serviceIds) {
      final s = serviciosPorId[id];
      if (s?.retoqueDias == null) continue;
      if (elegido == null || s!.retoqueDias! < elegido.retoqueDias!) {
        elegido = s;
      }
    }
    if (elegido == null) continue;

    final retoque =
        dateOnly(last.fecha).add(Duration(days: elegido.retoqueDias!));
    final diff = retoque.difference(hoyD).inDays;

    if (diff <= kReminderMaxAhead && diff >= kReminderMaxOverdue) {
      out.add(Reminder(
        client: c,
        service: elegido,
        fechaRetoque: retoque,
        diasRestantes: diff,
      ));
    }
  }

  // Los más urgentes arriba: primero los vencidos, después por cercanía.
  out.sort((a, b) => a.diasRestantes.compareTo(b.diasRestantes));
  return out;
}

/// Clientas que cumplen años hoy. Puerto del chequeo de `renderDash`, que
/// compara `c.birthday.slice(5)` contra `'MM-DD'`: compara mes y día, ignorando
/// el año.
List<Client> birthdaysToday(Iterable<Client> clients, DateTime hoy) => clients
    .where((c) =>
        c.cumple != null &&
        c.cumple!.month == hoy.month &&
        c.cumple!.day == hoy.day)
    .toList();
