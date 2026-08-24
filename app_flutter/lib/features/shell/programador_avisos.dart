/// Mantiene la agenda de notificaciones al día mientras la app está abierta.
///
/// Va montado dentro del shell y no en `main()` a propósito: los providers de
/// datos son `autoDispose`, así que necesitan un oyente vivo, y además así los
/// avisos solo se programan para alguien ya logueado y con un salón activo.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/notificaciones/push.dart';
import '../../core/notificaciones/servicio_avisos.dart';
import '../../data/local/database.dart' as db;
import '../../data/local/mappers.dart';
import '../../data/repositories/business_repository.dart';
import '../../domain/rules/avisos.dart';
import '../../domain/rules/access.dart';
import '../auth/session_controller.dart';
import '../dashboard/dashboard_view.dart';
import '../stock/stock_view.dart';

/// Turnos de mañana, para el resumen de las 20:00.
final turnosDeMananaProvider =
    StreamProvider.autoDispose<List<db.Appointment>>((ref) {
  final repo = ref.watch(businessRepoProvider);
  if (repo == null) return Stream.value(const []);
  return repo.verTurnosDe(DateTime.now().add(const Duration(days: 1)));
});

class ProgramadorAvisos extends ConsumerStatefulWidget {
  const ProgramadorAvisos({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<ProgramadorAvisos> createState() => _ProgramadorAvisosState();
}

class _ProgramadorAvisosState extends ConsumerState<ProgramadorAvisos> {
  Timer? _rebote;

  @override
  void initState() {
    super.initState();
    // Después del primer frame: `iniciar()` toca canales de Android y no tiene
    // por qué demorar el arranque de la UI.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ServicioAvisos.instancia.iniciar();
      if (!mounted) return;
      unawaited(_avisarStockUnaVezPorDia());

      // El push arranca acá y no en `main()`: recién con un salón activo hay
      // algo que registrar, y sin `google-services.json` esto simplemente no
      // hace nada en vez de romper el arranque.
      await Push.instancia.iniciar();
      if (!mounted) return;
      final d = ref.read(sessionProvider).decision;
      unawaited(Push.instancia
          .registrar(tenantId: d is GoToApp ? d.tenant.id : null));
    });
  }

  @override
  void dispose() {
    _rebote?.cancel();
    super.dispose();
  }

  /// Cada tecla de un formulario dispara un evento de Drift. Sin rebote se
  /// reprogramarían las notificaciones decenas de veces por segundo.
  void _reprogramarPronto() {
    _rebote?.cancel();
    _rebote = Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      unawaited(ServicioAvisos.instancia.reprogramar(_calcular()));
    });
  }

  List<AvisoProgramado> _calcular() {
    final turnos = [
      ...?ref.read(turnosDeHoyProvider).value,
      ...?ref.read(turnosDeMananaProvider).value,
      ...?ref.read(turnosRecientesProvider).value,
    ];
    final porTurno = ref.read(serviciosDeTurnosProvider).value ??
        const <String, List<String>>{};

    return avisosDelDia(
      clients: (ref.read(clientesProvider).value ?? const <db.Client>[])
          .map(aClient),
      // Los servicios del turno viven en la tabla puente: sin unirlos, la
      // regla de retoque no encuentra los días y no avisa nunca.
      appointments: turnos.map(
          (t) => aAppointment(t, serviceIds: porTurno[t.id] ?? const [])),
      services: (ref.read(serviciosProvider).value ?? const <db.Service>[])
          .map(aService),
      transactions:
          (ref.read(movimientosDelMesProvider).value ?? const <db.Transaction>[])
              .map(aTransaction),
      ahora: DateTime.now(),
    );
  }

  /// El aviso de stock es el único inmediato. Se limita a uno por día: abrir y
  /// cerrar la app cinco veces no tiene que dejar cinco notificaciones iguales.
  Future<void> _avisarStockUnaVezPorDia() async {
    final aviso = avisoDeStock(
      (ref.read(stockProvider).value ?? const <db.StockItem>[]).map(aStockItem),
      DateTime.now(),
    );
    if (aviso == null) return;

    final prefs = await SharedPreferences.getInstance();
    const clave = 'aviso_stock_ultimo_dia';
    final hoy = claveDia(DateTime.now());
    if (prefs.getString(clave) == hoy) return;
    await prefs.setString(clave, hoy);
    await ServicioAvisos.instancia.mostrarYa(aviso);
  }

  @override
  Widget build(BuildContext context) {
    // Basta con observarlos: cualquier cambio en los datos que alimentan un
    // aviso vuelve a disparar el build y con él el rebote.
    ref.watch(turnosDeHoyProvider);
    ref.watch(turnosDeMananaProvider);
    ref.watch(turnosRecientesProvider);
    ref.watch(serviciosDeTurnosProvider);
    ref.watch(serviciosProvider);
    ref.watch(clientesProvider);
    ref.watch(movimientosDelMesProvider);
    ref.watch(stockProvider);
    _reprogramarPronto();

    return widget.child;
  }
}
