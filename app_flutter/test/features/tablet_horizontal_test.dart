// La tablet del mostrador no es la PWA en la compu.
//
// Las dos miden 1280 de ancho, así que el único modo de saber si una vista se
// compuso para el dedo o para el mouse es preguntarle al árbol. Este test fija
// esa diferencia: sin él, cambiar `esEscritorio` por `esTabletTactil` en una
// vista y olvidarse en otra no se nota hasta tener la tablet en la mano.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mirame/core/layout/layout.dart';
import 'package:mirame/core/theme/app_theme.dart';
import 'package:mirame/data/local/database.dart' as db;
import 'package:mirame/domain/entities/access.dart';
import 'package:mirame/domain/rules/access.dart';
import 'package:mirame/features/auth/session_controller.dart';
import 'package:mirame/features/caja/caja_view.dart';
import 'package:mirame/features/crm/clients_view.dart';
import 'package:mirame/features/dashboard/dashboard_view.dart';
import 'package:mirame/features/ropa/ropa_view.dart';

class _SinSalon extends SessionController {
  @override
  SessionState build() => const SessionState(decision: GoToLogin());
}

/// Con salón y rol de dueña: hace falta para lo que solo se ve si se puede
/// operar el negocio, como el cobro rápido de Caja.
class _ConSalon extends SessionController {
  @override
  SessionState build() => const SessionState(
        decision: GoToApp(
          tenant: Tenant(
            id: 't1',
            nombre: 'Mírame',
            slug: 'mirame',
            estado: TenantEstado.activo,
          ),
          rol: MiembroRol.owner,
        ),
      );
}

/// Una clienta alcanza: lo que se prueba es la composición, no los datos. Sin
/// ninguna, la tabla y la lista de tarjetas muestran el mismo estado vacío y
/// no se distinguen.
final _unaClienta = [
  db.Client(
    id: 'c1',
    tenantId: 't1',
    createdAt: DateTime(2026, 8, 1),
    updatedAt: DateTime(2026, 8, 1),
    nombre: 'Sofía Gómez',
    telefono: '3875550000',
    vip: true,
  ),
];

/// Un turno de hoy con precio, para el cobro rápido de la tablet.
List<db.Appointment> _unTurnoDeHoy() {
  final hoy = DateTime.now();
  final ymd = '${hoy.year}-${hoy.month.toString().padLeft(2, '0')}-'
      '${hoy.day.toString().padLeft(2, '0')}';
  return [
    db.Appointment(
      id: 'a1',
      tenantId: 't1',
      createdAt: hoy,
      updatedAt: hoy,
      clientId: 'c1',
      fecha: ymd,
      hora: '${hoy.hour.toString().padLeft(2, '0')}:00',
      precio: 18000,
      estado: 'confirmed',
    ),
  ];
}

Future<void> _montar(
  WidgetTester t,
  Widget vista, {
  required bool tactil,
  bool conClienta = false,
  bool conTurno = false,
  bool conSalon = false,
}) async {
  modoTactilForzado = tactil;
  t.view.physicalSize = const Size(1280, 800);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.resetPhysicalSize);
  addTearDown(t.view.resetDevicePixelRatio);
  await t.pumpWidget(
    ProviderScope(
      overrides: [
        sessionProvider
            .overrideWith(conSalon ? _ConSalon.new : _SinSalon.new),
        if (conClienta)
          clientesProvider.overrideWith((ref) => Stream.value(_unaClienta)),
        if (conTurno)
          turnosDeHoyProvider.overrideWith((ref) => Stream.value(_unTurnoDeHoy())),
      ],
      child: MaterialApp(
        theme: buildMirameTheme(),
        home: Scaffold(body: vista),
      ),
    ),
  );
  await t.pump(const Duration(seconds: 1));
}

void main() {
  tearDown(() => modoTactilForzado = null);

  testWidgets('Clientas con el dedo: tarjetas, no tabla', (t) async {
    await _montar(t, const ClientsView(), tactil: true, conClienta: true);
    expect(find.text('Sofía Gómez'), findsOneWidget);
    // 'TURNOS' es un encabezado de columna: solo existe en la tabla densa.
    expect(find.text('TURNOS'), findsNothing);
  });

  testWidgets('Clientas con puntero: sigue la tabla', (t) async {
    await _montar(t, const ClientsView(), tactil: false, conClienta: true);
    expect(find.text('TURNOS'), findsOneWidget);
  });

  testWidgets('Tienda con el dedo: los filtros quedan a la vista', (t) async {
    await _montar(t, const RopaView(), tactil: true);
    expect(find.text('Filtros'), findsOneWidget);
    // Las opciones que en el teléfono viven en el sheet, ahora en la columna.
    expect(find.text('En la tienda'), findsOneWidget);
    expect(find.text('Sin publicar'), findsOneWidget);
  });

  testWidgets('Tienda con puntero: los filtros siguen en el sheet', (t) async {
    await _montar(t, const RopaView(), tactil: false);
    expect(find.text('En la tienda'), findsNothing);
  });

  testWidgets('Caja con el dedo ofrece cobrar el turno de ahora', (t) async {
    await _montar(
      t,
      const CajaView(),
      tactil: true,
      conClienta: true,
      conTurno: true,
      conSalon: true,
    );
    expect(find.text('EL TURNO DE AHORA'), findsOneWidget);
    expect(find.textContaining('Cobrar'), findsOneWidget);
  });

  testWidgets('Caja con puntero no lo ofrece: no es el mostrador', (t) async {
    await _montar(
      t,
      const CajaView(),
      tactil: false,
      conClienta: true,
      conTurno: true,
      conSalon: true,
    );
    expect(find.text('EL TURNO DE AHORA'), findsNothing);
  });
}
