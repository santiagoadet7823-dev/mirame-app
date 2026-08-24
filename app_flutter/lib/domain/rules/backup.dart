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

// ─────────────────────────────────────────────────────────────────────────────
// Lectura
// ─────────────────────────────────────────────────────────────────────────────

/// Lo que trae un archivo de backup, ya validado.
class BackupLeido {
  const BackupLeido({
    required this.version,
    required this.salon,
    required this.turnos,
    required this.clientas,
    required this.movimientos,
    required this.stock,
    required this.profesionales,
    required this.servicios,
  });

  final String version;
  final String salon;
  final List<Appointment> turnos;
  final List<Client> clientas;
  final List<Transaction> movimientos;
  final List<StockItem> stock;
  final List<Professional> profesionales;
  final List<Service> servicios;

  int get total =>
      turnos.length +
      clientas.length +
      movimientos.length +
      stock.length +
      profesionales.length +
      servicios.length;
}

class BackupInvalido implements Exception {
  const BackupInvalido(this.motivo);
  final String motivo;
  @override
  String toString() => motivo;
}

/// Lee un backup, sea de la app vieja o de la nueva.
///
/// Es deliberadamente tolerante con los TIPOS y estricto con la ESTRUCTURA: el
/// legacy guardaba números como strings y `vip` como `'true'`, así que rechazar
/// eso volvería inservibles los archivos que la dueña ya tiene. Pero si no
/// aparece ninguna de las seis colecciones, el archivo no es un backup y se
/// avisa en vez de importar cero filas en silencio.
BackupLeido leerBackup(Object? crudo) {
  if (crudo is! Map) {
    throw const BackupInvalido('El archivo no tiene el formato esperado');
  }
  const claves = ['a', 'c', 'tx', 's', 'p', 'sv'];
  if (!claves.any((k) => crudo[k] is List)) {
    throw const BackupInvalido('Esto no parece un backup de Mírame');
  }

  List<Map<String, Object?>> filas(String k) => [
        for (final f in (crudo[k] as List? ?? const []))
          if (f is Map) f.cast<String, Object?>(),
      ];

  return BackupLeido(
    version: _txt(crudo['ver']) ?? '?',
    salon: _txt(crudo['studio']) ?? 'Mírame',
    turnos: [for (final f in filas('a')) _leerTurno(f)],
    clientas: [for (final f in filas('c')) _leerClienta(f)],
    movimientos: [for (final f in filas('tx')) _leerMovimiento(f)],
    stock: [for (final f in filas('s')) _leerStock(f)],
    profesionales: [for (final f in filas('p')) _leerProfesional(f)],
    servicios: [for (final f in filas('sv')) _leerServicio(f)],
  );
}

Appointment _leerTurno(Map<String, Object?> f) => Appointment(
      id: _id(f['id']),
      clientId: _txt(f['clientId']),
      professionalId: _txt(f['proId']),
      // En el legacy esto era una lista de NOMBRES de servicio. Se conserva tal
      // cual: quien restaura decide cómo resolverlos, acá no se inventa nada.
      serviceIds: [
        for (final s in (f['services'] as List? ?? const []))
          if (_txt(s) case final v?) v,
      ],
      fecha: _fecha(f['date']) ?? DateTime.now(),
      hora: TimeOfDayValue.parse(_txt(f['time'])),
      precio: _num(f['price']) ?? 0,
      estado: _estado(_txt(f['status'])),
      notas: _txt(f['notes']),
    );

Client _leerClienta(Map<String, Object?> f) => Client(
      id: _id(f['id']),
      nombre: _txt(f['name']) ?? 'Sin nombre',
      telefono: _txt(f['phone']),
      email: _txt(f['email']),
      cumple: _fecha(f['birthday']),
      // `true` real o el string `'true'` del legacy: los dos valen.
      vip: f['vip'] == true || f['vip'] == 'true',
      notas: _txt(f['notes']),
    );

Transaction _leerMovimiento(Map<String, Object?> f) => Transaction(
      id: _id(f['id']),
      tipo: _txt(f['type']) == 'expense' ? TxTipo.expense : TxTipo.income,
      monto: _num(f['amount']) ?? 0,
      descripcion: _txt(f['desc']),
      categoria: _txt(f['category']),
      fecha: _fecha(f['date']) ?? DateTime.now(),
      metodo: switch (_txt(f['payment'])) {
        'transferencia' => TxMetodo.transferencia,
        'tarjeta' => TxMetodo.tarjeta,
        _ => TxMetodo.efectivo,
      },
      clientId: _txt(f['clientId']),
      appointmentId: _txt(f['apptId']),
    );

StockItem _leerStock(Map<String, Object?> f) => StockItem(
      id: _id(f['id']),
      nombre: _txt(f['name']) ?? 'Sin nombre',
      categoria: _txt(f['category']),
      cantidad: _num(f['qty'])?.round() ?? 0,
      minimo: _num(f['min'])?.round() ?? 0,
      unidad: _txt(f['unit']) ?? 'unidades',
    );

Professional _leerProfesional(Map<String, Object?> f) => Professional(
      id: _id(f['id']),
      nombre: _txt(f['name']) ?? 'Sin nombre',
      telefono: _txt(f['phone']),
    );

Service _leerServicio(Map<String, Object?> f) => Service(
      id: _id(f['id']),
      nombre: _txt(f['name']) ?? 'Sin nombre',
      precio: _num(f['price']) ?? 0,
      duracionMin: _num(f['duration'])?.round() ?? 60,
      retoqueDias: _num(f['retouch'])?.round(),
      mantenimientoDias: _num(f['maintenance'])?.round(),
      notas: _txt(f['notes']),
    );

TurnoEstado _estado(String? crudo) => switch (crudo) {
      'pending' => TurnoEstado.pending,
      'done' => TurnoEstado.done,
      'cancelled' => TurnoEstado.cancelled,
      _ => TurnoEstado.confirmed,
    };

/// El legacy usaba enteros autoincrementales de IndexedDB. Se conservan como
/// texto para poder cruzar `clientId` y `services` dentro del mismo archivo;
/// el mapeo a uuid lo hace quien importa.
String _id(Object? v) => v?.toString() ?? '';

String? _txt(Object? v) {
  if (v == null) return null;
  final s = v.toString().trim();
  return s.isEmpty ? null : s;
}

/// Acepta número o string: el legacy guardaba `input.value`, que es string.
num? _num(Object? v) {
  if (v is num) return v;
  if (v is String) return num.tryParse(v.replaceAll(',', '.'));
  return null;
}

/// `YYYY-MM-DD` en local. Si viniera un ISO completo se queda con la fecha, sin
/// pasar por UTC — convertir correría un día los turnos de la tarde.
DateTime? _fecha(Object? v) {
  final s = _txt(v);
  if (s == null) return null;
  final partes = s.split('T').first.split('-');
  if (partes.length < 3) return null;
  final a = int.tryParse(partes[0]);
  final m = int.tryParse(partes[1]);
  final d = int.tryParse(partes[2]);
  if (a == null || m == null || d == null) return null;
  return DateTime(a, m, d);
}
