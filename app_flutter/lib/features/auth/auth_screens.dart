/// Las 5 pantallas del gate: splash, login, pendiente, bloqueado y vencido.
///
/// Réplica de `#splash` y los cuatro `.auth-screen` del `index.html`. Los
/// textos son los del original, palabra por palabra: la dueña ya los conoce.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/motion.dart';
import '../../core/theme/shadows.dart';
import '../../core/theme/tokens.dart';
import '../../shared/widgets/version_label.dart';
import '../../core/theme/typography.dart';
import '../../data/repositories/access_repository.dart';
import '../../domain/rules/access.dart';
import 'session_controller.dart';
import 'widgets/auth_buttons.dart';
import 'widgets/auth_scaffold.dart';

/// WhatsApp de la administradora, heredado del legacy (`ADMIN_WA`).
/// TODO(fase-6): que salga de `app_config` para que cada revendedor ponga el suyo.
const kWhatsappAdmin = '5493877404245';

// ─────────────────────────────────────────────────────────────────────────────

/// `#splash` — logo, nombre y tagline. Se ve menos de un segundo.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: MColors.bg,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FadeSlideIn(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: MColors.surface,
                    boxShadow: MShadow.md,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.asset(
                    'assets/brand/logo-mirame.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              FadeSlideIn(
                delay: const Duration(milliseconds: 150),
                child: Text('Mírame', style: MText.splashName),
              ),
              const SizedBox(height: 16),
              FadeSlideIn(
                delay: const Duration(milliseconds: 250),
                child: Text('LASH STUDIO', style: MText.splashSub),
              ),
            ],
          ),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estado = ref.watch(sessionProvider);
    return AuthScaffold(
      children: [
        const AuthEmblem(),
        const SizedBox(height: 24),
        FadeSlideIn(
          delay: const Duration(milliseconds: 100),
          child: Text('Mírame', style: MText.authName),
        ),
        const SizedBox(height: 11),
        FadeSlideIn(
          delay: const Duration(milliseconds: 180),
          child: const AuthTag('Lash Studio'),
        ),
        const SizedBox(height: 18),
        FadeSlideIn(
          delay: const Duration(milliseconds: 240),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 280),
            child: Text(
              'Gestión de turnos, clientas y caja para tu estudio.',
              textAlign: TextAlign.center,
              style: MText.cuerpoSec,
            ),
          ),
        ),
        const SizedBox(height: 30),
        FadeSlideIn(
          delay: const Duration(milliseconds: 320),
          child: GoogleButton(
            cargando: estado.cargando,
            onTap: () => ref.read(sessionProvider.notifier).entrarConGoogle(),
          ),
        ),
        if (estado.error != null) ...[
          const SizedBox(height: 16),
          AuthError(estado.error!),
        ],
        const SizedBox(height: 26),
        FadeSlideIn(
          delay: const Duration(milliseconds: 400),
          child: const AuthFootnote(
            'Solo usuarias autorizadas por la administradora',
          ),
        ),
        const SizedBox(height: 14),
        // Visible a proposito: cuando alguien reporta un problema, lo primero
        // que hace falta saber es que version tiene, y mandarla a buscarlo a
        // los Ajustes de Android no funciona.
        const FadeSlideIn(
          delay: Duration(milliseconds: 460),
          child: VersionLabel(),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class PendingScreen extends ConsumerWidget {
  const PendingScreen({super.key, this.email});

  final String? email;

  @override
  Widget build(BuildContext context, WidgetRef ref) => AuthScaffold(
        children: [
          const AuthBigEmoji('⏳'),
          const SizedBox(height: 22),
          FadeSlideIn(
            delay: const Duration(milliseconds: 100),
            child: Text('Solicitud enviada', style: MText.authTitle),
          ),
          const SizedBox(height: 18),
          FadeSlideIn(
            delay: const Duration(milliseconds: 240),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 280),
              child: Text(
                'Tu cuenta está pendiente de aprobación.\n'
                'La administradora te habilitará en breve.',
                textAlign: TextAlign.center,
                style: MText.cuerpoSec,
              ),
            ),
          ),
          if (email != null) ...[
            const SizedBox(height: 18),
            FadeSlideIn(
              delay: const Duration(milliseconds: 280),
              child: AuthPill(email!),
            ),
          ],
          const SizedBox(height: 18),
          FadeSlideIn(
            delay: const Duration(milliseconds: 320),
            child: WhatsappButton(
              texto: 'Avisar por WhatsApp',
              onTap: () => _abrirWhatsapp(email),
            ),
          ),
          const SizedBox(height: 10),
          FadeSlideIn(
            delay: const Duration(milliseconds: 360),
            child: GhostButton(
              texto: 'Cerrar sesión',
              onTap: () => ref.read(sessionProvider.notifier).cerrarSesion(),
            ),
          ),
        ],
      );

  Future<void> _abrirWhatsapp(String? email) async {
    final url = Uri.parse(urlWhatsappSolicitud(kWhatsappAdmin, email));
    // Si no hay WhatsApp instalado, `launchUrl` devuelve false en vez de
    // lanzar: no tiene sentido mostrar un error por eso.
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class BlockedScreen extends ConsumerWidget {
  const BlockedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => AuthScaffold(
        children: [
          const AuthBigEmoji('🚫'),
          const SizedBox(height: 22),
          FadeSlideIn(
            delay: const Duration(milliseconds: 100),
            child: Text('Acceso denegado', style: MText.authTitle),
          ),
          const SizedBox(height: 18),
          FadeSlideIn(
            delay: const Duration(milliseconds: 240),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 280),
              child: Text(
                'Tu cuenta no tiene acceso a esta aplicación.\n'
                'Contactá a la administradora si creés que es un error.',
                textAlign: TextAlign.center,
                style: MText.cuerpoSec,
              ),
            ),
          ),
          const SizedBox(height: 18),
          FadeSlideIn(
            delay: const Duration(milliseconds: 360),
            child: GhostButton(
              texto: 'Cerrar sesión',
              onTap: () => ref.read(sessionProvider.notifier).cerrarSesion(),
            ),
          ),
        ],
      );
}

// ─────────────────────────────────────────────────────────────────────────────

class ExpiredScreen extends ConsumerWidget {
  const ExpiredScreen({super.key, this.venceAt, required this.motivo});

  final DateTime? venceAt;
  final MotivoExpiracion motivo;

  @override
  Widget build(BuildContext context, WidgetRef ref) => AuthScaffold(
        children: [
          const AuthBigEmoji('📅'),
          const SizedBox(height: 22),
          FadeSlideIn(
            delay: const Duration(milliseconds: 100),
            child: Text('Mensualidad vencida', style: MText.authTitle),
          ),
          const SizedBox(height: 18),
          FadeSlideIn(
            delay: const Duration(milliseconds: 240),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 280),
              child: Text(
                _mensaje,
                textAlign: TextAlign.center,
                style: MText.cuerpoSec,
              ),
            ),
          ),
          if (venceAt != null) ...[
            const SizedBox(height: 18),
            FadeSlideIn(
              delay: const Duration(milliseconds: 280),
              child: AuthPill('Venció el ${_fecha(venceAt!)}'),
            ),
          ],
          const SizedBox(height: 18),
          FadeSlideIn(
            delay: const Duration(milliseconds: 320),
            child: WhatsappButton(
              texto: 'Renovar por WhatsApp',
              onTap: () => launchUrl(
                Uri.parse(urlWhatsappSolicitud(kWhatsappAdmin, null)),
                mode: LaunchMode.externalApplication,
              ),
            ),
          ),
          const SizedBox(height: 10),
          FadeSlideIn(
            delay: const Duration(milliseconds: 360),
            child: GhostButton(
              texto: 'Cerrar sesión',
              onTap: () => ref.read(sessionProvider.notifier).cerrarSesion(),
            ),
          ),
        ],
      );

  /// Los tres motivos dicen cosas distintas. Mandar a alguien a "renovar"
  /// cuando en realidad se quedó sin señal hace que llame por nada.
  String get _mensaje => switch (motivo) {
        MotivoExpiracion.licencia =>
          'Tu suscripción venció. Contactá a la administradora para renovar '
              'y seguir usando la app.',
        MotivoExpiracion.suspendido =>
          'El acceso de este estudio está suspendido. Contactá a la '
              'administradora para reactivarlo.',
        MotivoExpiracion.graciaAgotada =>
          'Hace varios días que no podemos verificar tu suscripción. '
              'Conectate a internet una vez para seguir usando la app.',
      };

  static String _fecha(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/'
      '${d.month.toString().padLeft(2, '0')}/${d.year}';
}
