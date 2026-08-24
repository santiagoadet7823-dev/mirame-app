/// Traduce filas de Drift a entidades de dominio.
///
/// Existe porque `domain/` es Dart puro y **no conoce Drift** — es lo que
/// permite testear las reglas sin base de datos. El costo es este archivo; el
/// beneficio es que las reglas de negocio ya están probadas y las pantallas
/// no las reimplementan.
///
/// Los dos tipos comparten nombre (`Client`, `Appointment`, …), así que las
/// importaciones van con prefijo: `db.Client` es la fila, `Client` la entidad.
library;

import '../../domain/entities/entities.dart';
import 'database.dart' as db;

/// `'YYYY-MM-DD'` → `DateTime` local a medianoche.
///
/// `DateTime.parse` sobre una fecha sin zona ya devuelve local, pero se
/// construye explícito para dejar claro que **nunca** se pasa por UTC: ese
/// desvío es el que en el legacy corría los turnos un día.
DateTime fechaDesdeTexto(String s) {
  final p = s.split('-');
  if (p.length != 3) return DateTime.now();
  return DateTime(
    int.tryParse(p[0]) ?? 1970,
    int.tryParse(p[1]) ?? 1,
    int.tryParse(p[2]) ?? 1,
  );
}

TurnoEstado estadoDesdeTexto(String? s) => switch (s) {
      'confirmed' || 'confirmado' => TurnoEstado.confirmed,
      'done' || 'hecho' || 'completado' => TurnoEstado.done,
      'cancelled' || 'cancelado' => TurnoEstado.cancelled,
      // Cualquier valor desconocido cae en `pending`: es el estado que no
      // afirma nada de más.
      _ => TurnoEstado.pending,
    };

String textoDesdeEstado(TurnoEstado e) => e.name;

TxTipo tipoDesdeTexto(String? s) =>
    s == 'ingreso' || s == 'income' ? TxTipo.income : TxTipo.expense;

String textoDesdeTipo(TxTipo t) => t == TxTipo.income ? 'ingreso' : 'gasto';

TxMetodo metodoDesdeTexto(String? s) => switch (s) {
      'transferencia' => TxMetodo.transferencia,
      'tarjeta' => TxMetodo.tarjeta,
      _ => TxMetodo.efectivo,
    };

Client aClient(db.Client f) => Client(
      id: f.id,
      nombre: f.nombre,
      telefono: f.telefono,
      email: f.email,
      cumple: f.cumple,
      vip: f.vip,
      notas: f.notas,
    );

Professional aProfessional(db.Professional f) =>
    Professional(id: f.id, nombre: f.nombre, telefono: f.telefono);

Service aService(db.Service f) => Service(
      id: f.id,
      nombre: f.nombre,
      precio: f.precio,
      duracionMin: f.duracionMin,
      retoqueDias: f.retoqueDias,
      mantenimientoDias: f.mantenimientoDias,
      notas: f.notas,
    );

/// [serviceIds] se pasa aparte porque vive en la tabla puente
/// `appointment_services`, no en la fila del turno.
Appointment aAppointment(db.Appointment f, {List<String> serviceIds = const []}) =>
    Appointment(
      id: f.id,
      fecha: fechaDesdeTexto(f.fecha),
      hora: TimeOfDayValue.parse(f.hora),
      clientId: f.clientId,
      professionalId: f.professionalId,
      serviceIds: serviceIds,
      precio: f.precio,
      estado: estadoDesdeTexto(f.estado),
      notas: f.notas,
    );

Transaction aTransaction(db.Transaction f) => Transaction(
      id: f.id,
      tipo: tipoDesdeTexto(f.tipo),
      fecha: fechaDesdeTexto(f.fecha),
      monto: f.monto,
      descripcion: f.descripcion,
      categoria: f.categoria,
      metodo: metodoDesdeTexto(f.metodo),
      clientId: f.clientId,
      appointmentId: f.appointmentId,
    );

StockItem aStockItem(db.StockItem f) => StockItem(
      id: f.id,
      nombre: f.nombre,
      categoria: f.categoria,
      cantidad: f.cantidad,
      minimo: f.minimo,
      unidad: f.unidad ?? 'unidades',
    );
