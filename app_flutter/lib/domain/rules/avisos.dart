/// Qué avisos merece recibir quien trabaja en el salón, y a qué hora.
///
/// Dart puro y **sin efectos**: acá se decide *qué* notificar, no *cómo*. El
/// plugin de notificaciones vive en `core/notificaciones/`, y esta separación
/// es lo que permite testear las reglas sin un emulador de Android.
///
/// Las notificaciones de este archivo son para la usuaria del salón, **no para
/// las clientas**: a ellas se les sigue escribiendo por WhatsApp.
library;

import '../entities/entities.dart';
import 'period.dart';
import 'reminders.dart';

/// Canal de Android. Se separan para que la usuaria pueda silenciar los avisos
/// de plata sin perder los de agenda desde los ajustes del sistema.
enum CanalAviso {
  agenda('mirame_agenda', 'Agenda', 'Turnos del día siguiente y retoques'),
  caja('mirame_caja', 'Caja', 'Cierre del día'),
  stock('mirame_stock', 'Stock', 'Productos por agotarse');

  const CanalAviso(this.id, this.nombre, this.descripcion);

  final String id;
  final String nombre;
  final String descripcion;
}

/// Horas fijas, calcadas de `06-NOTIFICACIONES.md`.
const kHoraCumples = 9;
const kHoraRetoques = 10;
const kHoraTurnosDeManana = 20;
const kHoraCierreCaja = 21;

class AvisoProgramado {
  const AvisoProgramado({
    required this.id,
    required this.titulo,
    required this.cuerpo,
    required this.cuando,
    required this.canal,
    this.payload,
  });

  /// Determinista: el mismo aviso reprogramado pisa al anterior en vez de
  /// duplicarse. Android identifica las notificaciones por este entero.
  final int id;
  final String titulo;
  final String cuerpo;
  final DateTime cuando;
  final CanalAviso canal;

  /// Adónde llevar al tocar la notificación (índice de vista del shell).
  final String? payload;
}

/// `hashCode` de String no está garantizado estable entre corridas de Dart, y
/// un id que cambia al reiniciar duplicaría cada aviso. Este sí es estable.
int idEstable(String clave) {
  var h = 0;
  for (final c in clave.codeUnits) {
    h = (h * 31 + c) & 0x3FFFFFFF;
  }
  // El 0 lo usa el plugin como "sin id"; se evita.
  return h == 0 ? 1 : h;
}

DateTime _aLas(DateTime dia, int hora) =>
    DateTime(dia.year, dia.month, dia.day, hora);

/// Arma la agenda completa de avisos para **hoy**.
///
/// Solo devuelve los que todavía no pasaron: programar las 10:00 cuando son
/// las 15:00 haría que Android los dispare al instante, todos juntos.
List<AvisoProgramado> avisosDelDia({
  required Iterable<Client> clients,
  required Iterable<Appointment> appointments,
  required Iterable<Service> services,
  required Iterable<Transaction> transactions,
  required DateTime ahora,
}) {
  final hoy = dateOnly(ahora);
  final manana = hoy.add(const Duration(days: 1));
  final out = <AvisoProgramado>[];

  void agregar(AvisoProgramado a) {
    if (a.cuando.isAfter(ahora)) out.add(a);
  }

  // 1 · Cumpleaños — 9:00
  final cumples = birthdaysToday(clients, hoy);
  if (cumples.isNotEmpty) {
    agregar(AvisoProgramado(
      id: idEstable('cumple-${claveDia(hoy)}'),
      titulo: cumples.length == 1
          ? '🎂 Hoy cumple ${cumples.first.nombre}'
          : '🎂 Hoy cumplen ${cumples.length} clientas',
      cuerpo: cumples.length == 1
          ? 'Un saludo por WhatsApp hace la diferencia'
          : cumples.map((c) => c.nombre).join(', '),
      cuando: _aLas(hoy, kHoraCumples),
      canal: CanalAviso.agenda,
      payload: 'clientas',
    ));
  }

  // 2 · Retoques — 10:00. Se avisa solo de los que vencen hoy o ya vencieron:
  // la lista completa llega hasta 7 días adelante y notificar eso todos los
  // días convierte el aviso en ruido que se termina silenciando.
  final retoques = pendingReminders(
    clients: clients,
    appointments: appointments,
    services: services,
    hoy: hoy,
  ).where((r) => r.diasRestantes <= 0).toList();
  if (retoques.isNotEmpty) {
    agregar(AvisoProgramado(
      id: idEstable('retoque-${claveDia(hoy)}'),
      titulo: '✂️ ${retoques.length} clienta${retoques.length == 1 ? '' : 's'} '
          'para retoque',
      cuerpo: retoques.take(3).map((r) => r.client.nombre).join(', ') +
          (retoques.length > 3 ? ' y ${retoques.length - 3} más' : ''),
      cuando: _aLas(hoy, kHoraRetoques),
      canal: CanalAviso.agenda,
      payload: 'inicio',
    ));
  }

  // 3 · Turnos de mañana — 20:00
  final deManana = appointments
      .where((a) =>
          dateOnly(a.fecha) == manana &&
          a.estado != TurnoEstado.cancelled &&
          a.estado != TurnoEstado.done)
      .toList()
    ..sort((a, b) => (a.hora?.totalMinutes ?? 0).compareTo(b.hora?.totalMinutes ?? 0));
  if (deManana.isNotEmpty) {
    final primero = deManana.first.hora?.toString();
    agregar(AvisoProgramado(
      id: idEstable('manana-${claveDia(hoy)}'),
      titulo: deManana.length == 1
          ? '📅 Mañana tenés 1 turno'
          : '📅 Mañana tenés ${deManana.length} turnos',
      cuerpo: primero == null ? 'Revisá la agenda' : 'El primero a las $primero',
      cuando: _aLas(hoy, kHoraTurnosDeManana),
      canal: CanalAviso.agenda,
      payload: 'agenda',
    ));
  }

  // 4 · Cierre de caja — 21:00, solo si hubo movimiento. Un "cerraste con $0"
  // los días que el salón no abre es exactamente el aviso que enseña a
  // ignorar la app.
  final delDia = transactions.where((t) => dateOnly(t.fecha) == hoy);
  if (delDia.isNotEmpty) {
    var ingresos = 0.0;
    var gastos = 0.0;
    for (final t in delDia) {
      if (t.tipo == TxTipo.income) {
        ingresos += t.monto;
      } else {
        gastos += t.monto;
      }
    }
    agregar(AvisoProgramado(
      id: idEstable('caja-${claveDia(hoy)}'),
      titulo: '💰 Cierre del día',
      cuerpo: 'Ingresos ${_plata(ingresos)} · Gastos ${_plata(gastos)} · '
          'Neto ${_plata(ingresos - gastos)}',
      cuando: _aLas(hoy, kHoraCierreCaja),
      canal: CanalAviso.caja,
      payload: 'caja',
    ));
  }

  return out;
}

/// Aviso inmediato de stock, para mostrar al abrir la app.
///
/// Devuelve `null` si no hay nada que avisar. La regla de "una vez por día" no
/// va acá: es estado, y este archivo no tiene estado.
AvisoProgramado? avisoDeStock(Iterable<StockItem> stock, DateTime ahora) {
  final criticos =
      stock.where((s) => s.cantidad <= s.minimo).toList();
  if (criticos.isEmpty) return null;

  final agotados = criticos.where((s) => s.cantidad <= 0).length;
  return AvisoProgramado(
    id: idEstable('stock-${claveDia(dateOnly(ahora))}'),
    titulo: agotados > 0
        ? '🔴 $agotados producto${agotados == 1 ? '' : 's'} sin stock'
        : '⚠️ ${criticos.length} producto${criticos.length == 1 ? '' : 's'} '
            'por agotarse',
    cuerpo: criticos.take(3).map((s) => s.nombre).join(', ') +
        (criticos.length > 3 ? ' y ${criticos.length - 3} más' : ''),
    cuando: ahora,
    canal: CanalAviso.stock,
    payload: 'stock',
  );
}

String _plata(double n) => '\$${n.round()}';

/// `YYYY-MM-DD` en hora local. Nunca `toIso8601String()`: en Salta (UTC−3) eso
/// corre el día después de las 21:00, que es justo cuando se cierra la caja.
String claveDia(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';
