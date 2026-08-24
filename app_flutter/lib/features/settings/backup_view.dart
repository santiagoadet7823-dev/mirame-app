/// Exportar backup. Puerto de `exportData()` del `index.html`.
///
/// Es la red de seguridad: el archivo JSON abre en la app vieja y en la nueva,
/// y no depende de que Supabase ni Drive existan.
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/local/mappers.dart';
import '../../data/repositories/business_repository.dart';
import '../../domain/rules/backup.dart';
import '../auth/session_controller.dart';

/// Arma el JSON y lo entrega a la hoja de compartir.
Future<void> exportarBackup(BuildContext context, WidgetRef ref) async {
  final messenger = ScaffoldMessenger.maybeOf(context);
  final caja = context.findRenderObject() as RenderBox?;
  final repo = ref.read(businessRepoProvider);
  if (repo == null) return;

  try {
    final todo = await repo.leerTodoParaBackup();
    // Los servicios de cada turno viven en la tabla puente y hay que unirlos:
    // un backup con turnos sin servicio pierde los recordatorios de retoque.
    final porTurno = await repo.verServiciosDeTurnos().first;
    final version = (await PackageInfo.fromPlatform()).version;
    final ahora = DateTime.now();

    final json = const JsonEncoder.withIndent('  ').convert(armarBackup(
      version: version,
      salon: ref.read(tenantActivoProvider)?.nombre ?? 'Mírame',
      ahora: ahora,
      turnos: todo.turnos.map(
          (t) => aAppointment(t, serviceIds: porTurno[t.id] ?? const [])),
      clientas: todo.clientas.map(aClient),
      movimientos: todo.movimientos.map(aTransaction),
      stock: todo.stock.map(aStockItem),
      profesionales: todo.profesionales.map(aProfessional),
      servicios: todo.servicios.map(aService),
    ));

    final nombre = nombreBackup(ahora);
    final archivo = File('${(await getTemporaryDirectory()).path}/$nombre');
    await archivo.writeAsString(json);

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(archivo.path, mimeType: 'application/json')],
        fileNameOverrides: [nombre],
        sharePositionOrigin:
            caja == null ? null : caja.localToGlobal(Offset.zero) & caja.size,
      ),
    );
  } catch (e) {
    debugPrint('backup: no se pudo exportar ($e)');
    messenger?.showSnackBar(
      const SnackBar(content: Text('No se pudo armar el backup')),
    );
  }
}
