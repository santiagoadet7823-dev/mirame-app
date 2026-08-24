/// Backup JSON. Mismo formato que el `exportData()` del `index.html`.
///
/// El formato NO se toca: es el que tienen los archivos que la dueña ya guardó
/// en Drive, y un backup que la app nueva no puede volver a leer no es un
/// backup.
///
/// ```
/// { ver, at, studio, a: turnos, c: clientas, tx: caja, s: stock,
///   p: profesionales, sv: servicios }
/// ```
library;

import '../entities/entities.dart';
import 'period.dart';

Map<String, Object?> armarBackup({
  required String version,
  required String salon,
  required DateTime ahora,
  required Iterable<Appointment> turnos,
  required Iterable<Client> clientas,
  required Iterable<Transaction> movimientos,
  required Iterable<StockItem> stock,
  required Iterable<Professional> profesionales,
  required Iterable<Service> servicios,
}) =>
    {
      'ver': version,
      'at': ahora.toIso8601String(),
      'studio': salon,
      'a': [for (final t in turnos) _turno(t)],
      'c': [for (final c in clientas) _clienta(c)],
      'tx': [for (final t in movimientos) _movimiento(t)],
      's': [for (final s in stock) _stock(s)],
      'p': [for (final p in profesionales) _profesional(p)],
      'sv': [for (final s in servicios) _servicio(s)],
    };

Map<String, Object?> _turno(Appointment a) => {
      'id': a.id,
      'clientId': a.clientId,
      'proId': a.professionalId,
      'services': a.serviceIds,
      // `claveFecha` y no `toIso8601String()`: el legacy guardaba la fecha
      // local, y exportar en UTC correría un día los turnos de la tarde.
      'date': claveFecha(a.fecha),
      'time': a.hora?.toString(),
      'price': a.precio,
      'status': a.estado.name,
      'notes': a.notas,
    };

Map<String, Object?> _clienta(Client c) => {
      'id': c.id,
      'name': c.nombre,
      'phone': c.telefono,
      'email': c.email,
      'birthday': c.cumple == null ? null : claveFecha(c.cumple!),
      // Booleano de verdad. El legacy guardaba el string `'true'`, y por eso
      // el filtro de VIP fallaba con los registros viejos.
      'vip': c.vip,
      'notes': c.notas,
    };

Map<String, Object?> _movimiento(Transaction t) => {
      'id': t.id,
      'type': t.tipo.name,
      'amount': t.monto,
      'desc': t.descripcion,
      'category': t.categoria,
      'date': claveFecha(t.fecha),
      'payment': t.metodo.name,
      'clientId': t.clientId,
      'apptId': t.appointmentId,
    };

Map<String, Object?> _stock(StockItem s) => {
      'id': s.id,
      'name': s.nombre,
      'category': s.categoria,
      'qty': s.cantidad,
      'min': s.minimo,
      'unit': s.unidad,
    };

Map<String, Object?> _profesional(Professional p) => {
      'id': p.id,
      'name': p.nombre,
      'phone': p.telefono,
    };

Map<String, Object?> _servicio(Service s) => {
      'id': s.id,
      'name': s.nombre,
      'price': s.precio,
      'duration': s.duracionMin,
      'retouch': s.retoqueDias,
      'maintenance': s.mantenimientoDias,
      'notes': s.notas,
    };

/// `mirame-2026-08-24.json`, igual que el legacy.
String nombreBackup(DateTime hoy) => 'mirame-${claveFecha(hoy)}.json';
