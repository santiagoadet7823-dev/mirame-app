/// Restaurar un backup JSON. Puerto de `importData()` del `index.html`.
///
/// **Agrega, no reemplaza.** El original borraba todo y volvía a cargar; acá
/// se hace upsert por id, así restaurar dos veces el mismo archivo deja los
/// mismos datos y no el doble. Nada de lo que ya existe se pierde.
///
/// Los ids del legacy son enteros autoincrementales de IndexedDB, así que se
/// traducen a uuid deterministas: el mismo archivo importado en dos teléfonos
/// produce los mismos ids y el sync no duplica.
library;

import 'dart:convert';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../data/repositories/business_repository.dart';
import '../../domain/rules/backup.dart';

/// Abre el selector, muestra qué trae el archivo y restaura si dan el OK.
Future<void> restaurarBackup(BuildContext context, WidgetRef ref) async {
  final repo = ref.read(businessRepoProvider);
  if (repo == null) return;
  final messenger = ScaffoldMessenger.maybeOf(context);

  BackupLeido leido;
  try {
    // SAF: el selector del sistema. No hace falta permiso de almacenamiento.
    final archivo = await openFile(acceptedTypeGroups: const [
      XTypeGroup(label: 'Backup de Mírame', extensions: ['json']),
    ]);
    if (archivo == null) return;
    leido = leerBackup(jsonDecode(await archivo.readAsString()));
  } on BackupInvalido catch (e) {
    messenger?.showSnackBar(SnackBar(content: Text(e.motivo)));
    return;
  } catch (e) {
    debugPrint('backup: no se pudo leer ($e)');
    messenger?.showSnackBar(
      const SnackBar(content: Text('No se pudo leer el archivo')),
    );
    return;
  }

  if (!context.mounted) return;
  final seguir = await showDialog<bool>(
    context: context,
    builder: (ctx) => _DialogoConfirmar(backup: leido),
  );
  if (seguir != true) return;

  try {
    final cuantos = await _restaurar(repo, leido);
    messenger?.showSnackBar(
      SnackBar(content: Text('✅ Se restauraron $cuantos registros')),
    );
  } catch (e) {
    debugPrint('backup: falló la restauración ($e)');
    messenger?.showSnackBar(
      const SnackBar(content: Text('No se pudo restaurar el backup')),
    );
  }
}

/// Escribe todo, en el orden en que las cosas se referencian: primero el
/// catálogo, después las clientas, y al final lo que apunta a ellas.
Future<int> _restaurar(BusinessRepository repo, BackupLeido b) async {
  var n = 0;

  // Los ids viejos son enteros de IndexedDB. Se mapea legacy → uuid una sola
  // vez y se reusa, para que `clientId` de un turno siga apuntando a la misma
  // clienta después de traducir.
  final ids = <String, String>{};
  String uuid(String legacy) =>
      ids.putIfAbsent(legacy, () => idDesdeLegacy(repo.tenantId, legacy));

  for (final s in b.servicios) {
    await repo.guardarServicio(
      id: uuid('sv:${s.id}'),
      nombre: s.nombre,
      precio: s.precio,
      duracionMin: s.duracionMin,
      retoqueDias: s.retoqueDias,
      mantenimientoDias: s.mantenimientoDias,
      notas: s.notas,
    );
    n++;
  }

  for (final p in b.profesionales) {
    await repo.guardarProfesional(
      id: uuid('p:${p.id}'),
      nombre: p.nombre,
      telefono: p.telefono,
    );
    n++;
  }

  for (final c in b.clientas) {
    await repo.guardarCliente(
      id: uuid('c:${c.id}'),
      nombre: c.nombre,
      telefono: c.telefono,
      email: c.email,
      cumple: c.cumple,
      vip: c.vip,
      notas: c.notas,
    );
    n++;
  }

  for (final s in b.stock) {
    await repo.guardarStock(
      id: uuid('s:${s.id}'),
      nombre: s.nombre,
      cantidad: s.cantidad,
      minimo: s.minimo,
      categoria: s.categoria,
      unidad: s.unidad,
    );
    n++;
  }

  // Los servicios de un turno: en la app nueva vienen por id; en los archivos
  // viejos son NOMBRES. Se resuelven contra el catálogo del mismo archivo, que
  // es la única fuente confiable que tenemos acá.
  final porNombre = {
    for (final s in b.servicios) s.nombre.toLowerCase(): uuid('sv:${s.id}'),
  };
  final porIdLegacy = {for (final s in b.servicios) s.id: uuid('sv:${s.id}')};

  for (final t in b.turnos) {
    await repo.guardarTurno(
      id: uuid('a:${t.id}'),
      clientId: t.clientId == null ? null : uuid('c:${t.clientId}'),
      professionalId:
          t.professionalId == null ? null : uuid('p:${t.professionalId}'),
      serviceIds: [
        for (final ref in t.serviceIds)
          if (porIdLegacy[ref] ?? porNombre[ref.toLowerCase()] case final id?)
            id,
      ],
      fecha: t.fecha,
      hora: t.hora?.toString() ?? '00:00',
      precio: t.precio.toDouble(),
      estado: t.estado.name,
      notas: t.notas,
    );
    n++;
  }

  for (final m in b.movimientos) {
    await repo.guardarMovimiento(
      id: uuid('tx:${m.id}'),
      tipo: m.tipo.name,
      monto: m.monto.toDouble(),
      descripcion: m.descripcion,
      categoria: m.categoria,
      fecha: m.fecha,
      metodo: m.metodo.name,
      clientId: m.clientId == null ? null : uuid('c:${m.clientId}'),
    );
    n++;
  }

  return n;
}

class _DialogoConfirmar extends StatelessWidget {
  const _DialogoConfirmar({required this.backup});

  final BackupLeido backup;

  @override
  Widget build(BuildContext context) => AlertDialog(
        backgroundColor: MColors.surface,
        title: Text('Restaurar backup', style: serif(size: 18, weight: 600)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${backup.salon} · versión ${backup.version}',
              style: sans(size: 12, color: MColors.tMuted),
            ),
            const SizedBox(height: 12),
            _Linea('Clientas', backup.clientas.length),
            _Linea('Turnos', backup.turnos.length),
            _Linea('Movimientos', backup.movimientos.length),
            _Linea('Servicios', backup.servicios.length),
            _Linea('Profesionales', backup.profesionales.length),
            _Linea('Stock', backup.stock.length),
            const SizedBox(height: 12),
            Text(
              'Se agregan a lo que ya tenés. Nada se borra, y si algo ya '
              'estaba se actualiza.',
              style: sans(size: 12, color: MColors.tSecondary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child:
                Text('Cancelar', style: sans(size: 13, color: MColors.tMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Restaurar',
                style: sans(size: 13, weight: 600, color: MColors.brand)),
          ),
        ],
      );
}

class _Linea extends StatelessWidget {
  const _Linea(this.etiqueta, this.cuantos);

  final String etiqueta;
  final int cuantos;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 3),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(etiqueta, style: sans(size: 13)),
            Text('$cuantos', style: sans(size: 13, weight: 600)),
          ],
        ),
      );
}
