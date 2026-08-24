import 'package:flutter_test/flutter_test.dart';
import 'package:mirame/domain/entities/entities.dart';
import 'package:mirame/domain/rules/backup.dart';

Map<String, Object?> backupCon({
  List<Appointment> turnos = const [],
  List<Client> clientas = const [],
  List<Transaction> movimientos = const [],
  List<StockItem> stock = const [],
  List<Professional> profesionales = const [],
  List<Service> servicios = const [],
}) =>
    armarBackup(
      version: '1.4.0',
      salon: 'Mírame',
      ahora: DateTime(2026, 8, 24, 10),
      turnos: turnos,
      clientas: clientas,
      movimientos: movimientos,
      stock: stock,
      profesionales: profesionales,
      servicios: servicios,
    );

void main() {
  test('las claves son las del formato legacy, ni una más', () {
    // Si esto cambia, los backups que la dueña ya tiene en Drive dejan de
    // poder restaurarse. El formato NO se toca.
    expect(
      backupCon().keys.toList(),
      ['ver', 'at', 'studio', 'a', 'c', 'tx', 's', 'p', 'sv'],
    );
  });

  test('la fecha de un turno sale local, no en UTC', () {
    // Un turno de las 22:00 en Salta (UTC−3) es del día siguiente en UTC.
    // Exportarlo en UTC correría todos los turnos de la tarde un día.
    final b = backupCon(turnos: [
      Appointment(
        id: 'a1',
        fecha: DateTime(2026, 8, 24),
        hora: const TimeOfDayValue(22, 0),
      ),
    ]);
    final turno = (b['a']! as List).single as Map<String, Object?>;
    expect(turno['date'], '2026-08-24');
    expect(turno['time'], '22:00');
  });

  test('el turno lleva sus serviceIds', () {
    final b = backupCon(turnos: [
      Appointment(
          id: 'a1', fecha: DateTime(2026, 8, 24), serviceIds: const ['s1', 's2']),
    ]);
    final turno = (b['a']! as List).single as Map<String, Object?>;
    expect(turno['services'], ['s1', 's2']);
  });

  test('vip sale como booleano, no como el string del legacy', () {
    final b = backupCon(clientas: const [
      Client(id: 'c1', nombre: 'Ana', vip: true),
    ]);
    final c = (b['c']! as List).single as Map<String, Object?>;
    expect(c['vip'], isTrue);
    expect(c['vip'], isNot('true'));
  });

  test('el cumpleaños sin cargar queda en null, no en una fecha inventada', () {
    final b = backupCon(clientas: const [Client(id: 'c1', nombre: 'Ana')]);
    final c = (b['c']! as List).single as Map<String, Object?>;
    expect(c['birthday'], isNull);
  });

  test('las seis colecciones existen aunque estén vacías', () {
    final b = backupCon();
    for (final k in ['a', 'c', 'tx', 's', 'p', 'sv']) {
      expect(b[k], isA<List<Object?>>(), reason: 'falta $k');
      expect(b[k] as List, isEmpty);
    }
  });

  test('nombreBackup usa el mismo patrón que el legacy', () {
    expect(nombreBackup(DateTime(2026, 8, 24)), 'mirame-2026-08-24.json');
  });
}
