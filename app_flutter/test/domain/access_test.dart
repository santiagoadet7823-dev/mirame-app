import 'package:flutter_test/flutter_test.dart';
import 'package:mirame/domain/entities/access.dart';
import 'package:mirame/domain/rules/access.dart';

final ahora = DateTime(2026, 8, 23, 10);

const owner = Profile(id: 'u1', email: 'duenia@mail.com', nombre: 'Dueña');
const superadmin = Profile(
  id: 'u9',
  email: 'jefe@mail.com',
  plataformaRol: PlataformaRol.superadmin,
);

const salonA = Tenant(
  id: 't1',
  nombre: 'Mírame',
  slug: 'mirame',
  estado: TenantEstado.activo,
);
const salonB = Tenant(
  id: 't2',
  nombre: 'Bella Lash',
  slug: 'bella',
  estado: TenantEstado.activo,
);

Membership miembro(
  String tenant,
  String user, {
  MiembroRol rol = MiembroRol.owner,
  MiembroEstado estado = MiembroEstado.approved,
}) =>
    Membership(tenantId: tenant, userId: user, rol: rol, estado: estado);

License licencia(String tenant, DateTime? vence) =>
    License(tenantId: tenant, venceAt: vence);

void main() {
  group('sin sesión', () {
    test('va al login', () {
      expect(resolveAccess(const AccessContext(), ahora), isA<GoToLogin>());
    });
  });

  group('usuario nuevo', () {
    test('sin membresías va a pendiente, con su email a la vista', () {
      final d = resolveAccess(const AccessContext(profile: owner), ahora);
      expect(d, isA<GoToPending>());
      expect((d as GoToPending).email, 'duenia@mail.com');
    });

    test('con la membresía en pending sigue en pendiente', () {
      final d = resolveAccess(
        AccessContext(
          profile: owner,
          memberships: [miembro('t1', 'u1', estado: MiembroEstado.pending)],
          tenants: const [salonA],
        ),
        ahora,
      );
      expect(d, isA<GoToPending>());
    });
  });

  group('bloqueo', () {
    test('una membresía bloqueada manda a la pantalla de bloqueo', () {
      final d = resolveAccess(
        AccessContext(
          profile: owner,
          memberships: [miembro('t1', 'u1', estado: MiembroEstado.blocked)],
          tenants: const [salonA],
        ),
        ahora,
      );
      expect(d, isA<GoToBlocked>());
    });

    test('estar bloqueado en un salón no se esquiva teniendo otro pendiente', () {
      // Sin esta regla, un bloqueo se evade pidiendo acceso a otro salón.
      final d = resolveAccess(
        AccessContext(
          profile: owner,
          memberships: [
            miembro('t1', 'u1', estado: MiembroEstado.blocked),
            miembro('t2', 'u1', estado: MiembroEstado.pending),
          ],
          tenants: const [salonA, salonB],
        ),
        ahora,
      );
      expect(d, isA<GoToBlocked>());
    });

    test('pero sí puede entrar a otro salón donde SÍ está aprobado', () {
      final d = resolveAccess(
        AccessContext(
          profile: owner,
          memberships: [
            miembro('t1', 'u1', estado: MiembroEstado.blocked),
            miembro('t2', 'u1', rol: MiembroRol.profesional),
          ],
          tenants: const [salonA, salonB],
          licenses: const [],
        ),
        ahora,
      );
      expect(d, isA<GoToApp>());
      expect((d as GoToApp).tenant.id, 't2');
    });
  });

  group('acceso normal', () {
    test('aprobado y con licencia vigente entra, con su rol', () {
      final d = resolveAccess(
        AccessContext(
          profile: owner,
          memberships: [miembro('t1', 'u1')],
          tenants: const [salonA],
          licenses: [licencia('t1', DateTime(2027, 1, 1))],
        ),
        ahora,
      );
      expect(d, isA<GoToApp>());
      final app = d as GoToApp;
      expect(app.tenant.id, 't1');
      expect(app.rol, MiembroRol.owner);
      expect(app.enGracia, isFalse);
      expect(app.impersonando, isFalse);
    });

    test('una licencia sin fecha no vence nunca', () {
      final d = resolveAccess(
        AccessContext(
          profile: owner,
          memberships: [miembro('t1', 'u1')],
          tenants: const [salonA],
          licenses: [licencia('t1', null)],
        ),
        ahora,
      );
      expect(d, isA<GoToApp>());
    });

    test('respeta el salón elegido cuando pertenece a varios', () {
      final d = resolveAccess(
        AccessContext(
          profile: owner,
          memberships: [miembro('t1', 'u1'), miembro('t2', 'u1')],
          tenants: const [salonA, salonB],
          tenantActivoId: 't2',
        ),
        ahora,
      );
      expect((d as GoToApp).tenant.id, 't2');
    });

    test('si el salón guardado ya no le corresponde, cae en uno válido', () {
      // Le sacaron el acceso al salón que tenía abierto: no debe quedar afuera.
      final d = resolveAccess(
        AccessContext(
          profile: owner,
          memberships: [miembro('t1', 'u1')],
          tenants: const [salonA, salonB],
          tenantActivoId: 't2',
        ),
        ahora,
      );
      expect((d as GoToApp).tenant.id, 't1');
    });
  });

  group('vencimiento', () {
    test('licencia vencida manda a /vencido con la fecha', () {
      final vencio = DateTime(2026, 8, 1);
      final d = resolveAccess(
        AccessContext(
          profile: owner,
          memberships: [miembro('t1', 'u1')],
          tenants: const [salonA],
          licenses: [licencia('t1', vencio)],
        ),
        ahora,
      );
      expect(d, isA<GoToExpired>());
      final e = d as GoToExpired;
      expect(e.venceAt, vencio);
      expect(e.motivo, MotivoExpiracion.licencia);
    });

    test('un salón suspendido cierra aunque la licencia esté al día', () {
      const suspendido = Tenant(
        id: 't1',
        nombre: 'Mírame',
        slug: 'mirame',
        estado: TenantEstado.suspendido,
      );
      final d = resolveAccess(
        AccessContext(
          profile: owner,
          memberships: [miembro('t1', 'u1')],
          tenants: const [suspendido],
          licenses: [licencia('t1', DateTime(2027, 1, 1))],
        ),
        ahora,
      );
      expect(d, isA<GoToExpired>());
      expect((d as GoToExpired).motivo, MotivoExpiracion.suspendido);
    });

    test('un salón cancelado también', () {
      const cancelado = Tenant(
        id: 't1',
        nombre: 'Mírame',
        slug: 'mirame',
        estado: TenantEstado.cancelado,
      );
      final d = resolveAccess(
        AccessContext(
          profile: owner,
          memberships: [miembro('t1', 'u1')],
          tenants: const [cancelado],
        ),
        ahora,
      );
      expect(d, isA<GoToExpired>());
    });
  });

  group('offline y gracia', () {
    AccessContext sinRed(DateTime? ultimaValidacion, {DateTime? vence}) =>
        AccessContext(
          profile: owner,
          memberships: [miembro('t1', 'u1')],
          tenants: const [salonA],
          licenses: [licencia('t1', vence ?? DateTime(2027, 1, 1))],
          ultimaValidacion: ultimaValidacion,
          hayRed: false,
        );

    test('sin red entra igual y avisa que está en gracia', () {
      final d = resolveAccess(sinRed(ahora.subtract(const Duration(days: 2))), ahora);
      expect(d, isA<GoToApp>());
      expect((d as GoToApp).enGracia, isTrue);
    });

    test('al día 6 todavía entra', () {
      final d = resolveAccess(sinRed(ahora.subtract(const Duration(days: 6))), ahora);
      expect(d, isA<GoToApp>());
    });

    test('al día 7 se acabó la gracia', () {
      final d = resolveAccess(sinRed(ahora.subtract(const Duration(days: 7))), ahora);
      expect(d, isA<GoToExpired>());
      expect((d as GoToExpired).motivo, MotivoExpiracion.graciaAgotada);
    });

    test('sin ninguna validación previa no hay gracia', () {
      // Nunca se pudo confirmar que la licencia exista: no se regala acceso.
      expect(resolveAccess(sinRed(null), ahora), isA<GoToExpired>());
    });

    test('una licencia YA vencida no se perdona por estar offline', () {
      final d = resolveAccess(
        sinRed(ahora.subtract(const Duration(days: 1)), vence: DateTime(2026, 8, 1)),
        ahora,
      );
      expect(d, isA<GoToExpired>());
      expect((d as GoToExpired).motivo, MotivoExpiracion.licencia);
    });

    test('los días restantes se cuentan bien', () {
      expect(diasDeGraciaRestantes(ahora.subtract(const Duration(days: 2)), ahora), 5);
      expect(diasDeGraciaRestantes(ahora, ahora), 7);
      expect(diasDeGraciaRestantes(ahora.subtract(const Duration(days: 99)), ahora), 0);
      expect(diasDeGraciaRestantes(null, ahora), 0);
    });
  });

  group('superadmin', () {
    test('sin salón elegido ni membresías va al panel de plataforma', () {
      final d = resolveAccess(const AccessContext(profile: superadmin), ahora);
      expect(d, isA<GoToPlatformAdmin>());
    });

    test('si trabaja en un salón entra al suyo, no al panel', () {
      // El bug que costó caro: la dueña es superadmin Y owner de su salón.
      // Abría la app, veía el panel de administración vacío y concluía que se
      // habían perdido sus datos. El panel queda a un toque, en el header.
      final d = resolveAccess(
        AccessContext(
          profile: superadmin,
          memberships: [miembro('t1', 'u9')],
          tenants: const [salonA],
        ),
        ahora,
      );
      expect(d, isA<GoToApp>());
      final app = d as GoToApp;
      expect(app.tenant.id, 't1');
      expect(app.impersonando, isFalse);
    });

    test('con varios salones NO adivina: va al panel', () {
      final d = resolveAccess(
        AccessContext(
          profile: superadmin,
          memberships: [miembro('t1', 'u9'), miembro('t2', 'u9')],
          tenants: const [salonA, salonB],
        ),
        ahora,
      );
      expect(d, isA<GoToPlatformAdmin>());
    });

    test('entra a cualquier salón, marcado como impersonando', () {
      final d = resolveAccess(
        const AccessContext(
          profile: superadmin,
          tenants: [salonA],
          tenantActivoId: 't1',
        ),
        ahora,
      );
      expect(d, isA<GoToApp>());
      final app = d as GoToApp;
      expect(app.impersonando, isTrue);
      expect(app.rol, MiembroRol.lectura);
    });

    test('si además es miembro, opera normal y NO se lo audita', () {
      final d = resolveAccess(
        AccessContext(
          profile: superadmin,
          memberships: [miembro('t1', 'u9')],
          tenants: const [salonA],
          tenantActivoId: 't1',
        ),
        ahora,
      );
      final app = d as GoToApp;
      expect(app.impersonando, isFalse);
      expect(app.rol, MiembroRol.owner);
    });

    test('una licencia vencida no le cierra la puerta', () {
      // Justamente tiene que poder entrar a un salón vencido para renovarlo.
      final d = resolveAccess(
        AccessContext(
          profile: superadmin,
          tenants: const [salonA],
          licenses: [licencia('t1', DateTime(2020, 1, 1))],
          tenantActivoId: 't1',
        ),
        ahora,
      );
      expect(d, isA<GoToApp>());
    });

    test('un salón inexistente lo devuelve al panel', () {
      final d = resolveAccess(
        const AccessContext(profile: superadmin, tenantActivoId: 'no-existe'),
        ahora,
      );
      expect(d, isA<GoToPlatformAdmin>());
    });
  });

  group('permisos — espejo de las RLS', () {
    test('owner puede todo', () {
      for (final p in Permiso.values) {
        expect(puede(MiembroRol.owner, p), isTrue, reason: p.name);
      }
    });

    test('admin hace todo menos borrar el salón', () {
      expect(puede(MiembroRol.admin, Permiso.escribirAgenda), isTrue);
      expect(puede(MiembroRol.admin, Permiso.operarNegocio), isTrue);
      expect(puede(MiembroRol.admin, Permiso.gestionarUsuarios), isTrue);
      expect(puede(MiembroRol.admin, Permiso.editarAjustes), isTrue);
      expect(puede(MiembroRol.admin, Permiso.borrarTenant), isFalse);
    });

    test('encargado maneja el negocio pero no toca usuarios ni ajustes', () {
      expect(puede(MiembroRol.encargado, Permiso.escribirAgenda), isTrue);
      expect(puede(MiembroRol.encargado, Permiso.operarNegocio), isTrue);
      expect(puede(MiembroRol.encargado, Permiso.verReportes), isTrue);
      expect(puede(MiembroRol.encargado, Permiso.gestionarUsuarios), isFalse);
      expect(puede(MiembroRol.encargado, Permiso.editarAjustes), isFalse);
      expect(puede(MiembroRol.encargado, Permiso.borrarTenant), isFalse);
    });

    test('profesional atiende y nada más', () {
      expect(puede(MiembroRol.profesional, Permiso.escribirAgenda), isTrue);
      // La distinción que motivó todo esto: la tienda y la caja no son suyas.
      expect(puede(MiembroRol.profesional, Permiso.operarNegocio), isFalse);
      expect(puede(MiembroRol.profesional, Permiso.verReportes), isFalse);
      expect(puede(MiembroRol.profesional, Permiso.gestionarUsuarios), isFalse);
      expect(puede(MiembroRol.profesional, Permiso.editarAjustes), isFalse);
    });

    test('lectura solo ve', () {
      expect(puede(MiembroRol.lectura, Permiso.escribirAgenda), isFalse);
      expect(puede(MiembroRol.lectura, Permiso.operarNegocio), isFalse);
      expect(puede(MiembroRol.lectura, Permiso.gestionarUsuarios), isFalse);
      expect(puede(MiembroRol.lectura, Permiso.verReportes), isTrue);
    });

    test('impersonando, ni el superadmin escribe', () {
      // Espeja la policy: el revendedor lee para dar soporte, no opera.
      const acceso = GoToApp(
        tenant: salonA,
        rol: MiembroRol.owner,
        impersonando: true,
      );
      expect(puedeEnDecision(acceso, Permiso.escribirAgenda), isFalse);
      expect(puedeEnDecision(acceso, Permiso.operarNegocio), isFalse);
      expect(puedeEnDecision(acceso, Permiso.gestionarUsuarios), isFalse);
      expect(puedeEnDecision(acceso, Permiso.verReportes), isTrue);
    });

    test('sin impersonar, manda el rol', () {
      const acceso = GoToApp(tenant: salonA, rol: MiembroRol.profesional);
      expect(puedeEnDecision(acceso, Permiso.escribirAgenda), isTrue);
      expect(puedeEnDecision(acceso, Permiso.operarNegocio), isFalse);
      expect(puedeEnDecision(acceso, Permiso.editarAjustes), isFalse);
    });
  });
}
