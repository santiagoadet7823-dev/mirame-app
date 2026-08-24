import 'package:flutter_test/flutter_test.dart';
import 'package:mirame/domain/entities/entities.dart';
import 'package:mirame/domain/rules/csv.dart';

void main() {
  group('celda', () {
    test('duplica las comillas internas', () {
      // El export de caja del legacy NO hacía esto, así que una descripción
      // con comillas partía la columna y corría toda la fila.
      expect(celda('Pestañas "premium"'), '"Pestañas ""premium"""');
    });

    test('null y vacío dan una celda vacía', () {
      expect(celda(null), '""');
      expect(celda(''), '""');
    });

    test('una coma no rompe la fila', () {
      expect(celda('Retoque, volumen'), '"Retoque, volumen"');
    });
  });

  group('csvDeCaja', () {
    test('lleva BOM, encabezado y los movimientos más nuevos primero', () {
      final csv = csvDeCaja([
        Transaction(
            id: 't1',
            tipo: TxTipo.income,
            fecha: DateTime(2026, 8, 20),
            monto: 5000,
            descripcion: 'Volumen ruso'),
        Transaction(
            id: 't2',
            tipo: TxTipo.expense,
            fecha: DateTime(2026, 8, 24),
            monto: 1200,
            categoria: 'insumos'),
      ]);

      expect(csv.startsWith(bomUtf8), isTrue);
      final lineas = csv.substring(bomUtf8.length).split('\n');
      expect(lineas.first, startsWith('"Fecha","Tipo"'));
      expect(lineas[1], contains('2026-08-24'));
      expect(lineas[1], contains('"Egreso"'));
      expect(lineas[2], contains('"Ingreso"'));
      expect(lineas[2], contains('"Volumen ruso"'));
    });

    test('sin movimientos deja solo el encabezado', () {
      final csv = csvDeCaja(const []);
      expect(csv.substring(bomUtf8.length).split('\n'), hasLength(1));
    });
  });

  group('csvDeClientas', () {
    test('el vip sale como Sí/No, no como booleano', () {
      final csv = csvDeClientas(const [
        Client(id: 'c1', nombre: 'Ana', vip: true, telefono: '3875550000'),
        Client(id: 'c2', nombre: 'Bea'),
      ]);
      final lineas = csv.substring(bomUtf8.length).split('\n');
      expect(lineas[1], contains('"Sí"'));
      expect(lineas[2], contains('"No"'));
      // Los campos que faltan quedan vacíos, no como "null".
      expect(lineas[2], isNot(contains('null')));
    });
  });

  test('nombreArchivo usa la fecha local', () {
    expect(nombreArchivo('caja', DateTime(2026, 8, 24, 23, 30)),
        'caja-2026-08-24.csv');
  });
}
