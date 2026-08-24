import 'package:flutter_test/flutter_test.dart';
import 'package:mirame/data/remote/access_mappers.dart';
import 'package:mirame/domain/entities/access.dart';

void main() {
  group('enums desde texto — los desconocidos caen al lado seguro', () {
    test('rol', () {
      expect(rolDesdeTexto('owner'), MiembroRol.owner);
      expect(rolDesdeTexto('profesional'), MiembroRol.profesional);
      // Un rol que este cliente no conoce no debe dar permisos de más.
      expect(rolDesdeTexto('rol_del_futuro'), MiembroRol.lectura);
      expect(rolDesdeTexto(null), MiembroRol.lectura);
    });

    test('estado de miembro', () {
      expect(estadoMiembroDesdeTexto('approved'), MiembroEstado.approved);
      expect(estadoMiembroDesdeTexto('blocked'), MiembroEstado.blocked);
      expect(estadoMiembroDesdeTexto(null), MiembroEstado.pending);
    });

    test('estado de tenant', () {
      expect(estadoTenantDesdeTexto('activo'), TenantEstado.activo);
      expect(estadoTenantDesdeTexto('trial'), TenantEstado.trial);
      // Un estado desconocido cierra la puerta, no la abre.
      expect(estadoTenantDesdeTexto('vaya_a_saber'), TenantEstado.cancelado);
    });
  });

  group('filas a entidades', () {
    test('profile con superadmin', () {
      final p = profileDesdeFila({
        'id': 'u1',
        'email': 'a@b.com',
        'nombre': 'Ana',
        'avatar_url': null,
        'plataforma_rol': 'superadmin',
      });
      expect(p.id, 'u1');
      expect(p.esSuperadmin, isTrue);
    });

    test('profile sin rol de plataforma', () {
      final p = profileDesdeFila({'id': 'u2', 'plataforma_rol': null});
      expect(p.esSuperadmin, isFalse);
    });

    test('tenant con defaults tolerantes', () {
      final t = tenantDesdeFila({'id': 't1', 'estado': 'activo'});
      expect(t.nombre, '');
      expect(t.plan, 'basico');
      expect(t.operativo, isTrue);
    });

    test('licencia parsea la fecha ISO a local', () {
      final l = licenseDesdeFila({
        'tenant_id': 't1',
        'vence_at': '2026-12-31T23:59:00Z',
      });
      expect(l.venceAt, isNotNull);
      expect(l.venceAt!.isUtc, isFalse, reason: 'debe convertirse a local');
    });

    test('licencia sin fecha no vence', () {
      final l = licenseDesdeFila({'tenant_id': 't1', 'vence_at': null});
      expect(l.venceAt, isNull);
      expect(l.vigenteA(DateTime(2099)), isTrue);
    });

    test('una fecha ilegible no rompe el arranque', () {
      final l = licenseDesdeFila({'tenant_id': 't1', 'vence_at': 'ayer'});
      expect(l.venceAt, isNull);
    });

    test('membership completa', () {
      final m = membershipDesdeFila({
        'tenant_id': 't1',
        'user_id': 'u1',
        'rol': 'admin',
        'estado': 'approved',
      });
      expect(m.rol, MiembroRol.admin);
      expect(m.aprobada, isTrue);
    });
  });
}
