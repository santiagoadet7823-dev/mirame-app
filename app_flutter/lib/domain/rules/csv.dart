/// Armado de los CSV que exporta Estadísticas. Puerto de `exportCajaCSV` y
/// `exportClientsCSV`.
///
/// Dart puro: el archivo se escribe y se comparte en la capa de features. Las
/// columnas y su orden son los del original — es lo que la dueña ya tiene
/// pegado en su planilla.
library;

import '../entities/entities.dart';
import 'period.dart';

/// Escapa un valor para CSV.
///
/// El original de caja hacía `"${v}"` **sin** duplicar las comillas internas,
/// así que una descripción con comillas partía la columna y corría toda la
/// fila. Acá se escapa siempre, como ya hacía el export de clientas.
String celda(Object? v) {
  final s = v?.toString() ?? '';
  return '"${s.replaceAll('"', '""')}"';
}

String _filas(List<List<Object?>> filas) =>
    filas.map((f) => f.map(celda).join(',')).join('\n');

/// El BOM va sí o sí: sin él, Excel en Windows abre el archivo en la
/// codificación del sistema y "Depilación" aparece roto.
const bomUtf8 = '﻿';

String csvDeCaja(Iterable<Transaction> movimientos) {
  final ordenados = movimientos.toList()
    ..sort((a, b) => b.fecha.compareTo(a.fecha));

  return bomUtf8 +
      _filas([
        const ['Fecha', 'Tipo', 'Descripción', 'Categoría', 'Método', 'Monto'],
        for (final t in ordenados)
          [
            claveFecha(t.fecha),
            t.tipo == TxTipo.income ? 'Ingreso' : 'Egreso',
            t.descripcion ?? '',
            t.categoria ?? '',
            t.metodo.name,
            t.monto,
          ],
      ]);
}

String csvDeClientas(Iterable<Client> clientas) => bomUtf8 +
    _filas([
      const ['Nombre', 'Teléfono', 'Email', 'VIP', 'Notas'],
      for (final c in clientas)
        [
          c.nombre,
          c.telefono ?? '',
          c.email ?? '',
          c.vip ? 'Sí' : 'No',
          c.notas ?? '',
        ],
    ]);

/// `caja-2026-08-24.csv`. Nombre con fecha para que dos exports del mismo mes
/// no se pisen en la carpeta de descargas.
String nombreArchivo(String prefijo, DateTime hoy) =>
    '$prefijo-${claveFecha(hoy)}.csv';
