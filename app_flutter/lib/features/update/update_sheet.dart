/// Aviso de versión nueva.
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/router.dart';
import '../../core/theme/motion.dart';
import '../../core/theme/shadows.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import 'updater.dart';

/// Envuelve la parte autorizada de la app y ofrece la actualización cuando
/// corresponde.
///
/// Va acá y no en el arranque porque `app_config` exige sesión (política
/// `cfg_select`): consultarlo antes del login siempre devolvería vacío.
class UpdateGate extends ConsumerStatefulWidget {
  const UpdateGate({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<UpdateGate> createState() => _UpdateGateState();
}

class _UpdateGateState extends ConsumerState<UpdateGate> {
  bool _yaOfrecida = false;

  @override
  Widget build(BuildContext context) {
    // `watch` además de `listen`: sin alguien observándolo, el provider es
    // perezoso y podría no llegar a ejecutarse nunca.
    ref.watch(actualizacionProvider);
    ref.listen(actualizacionProvider, (_, next) {
      final info = next.value;
      if (info == null || !info.ofrecible || _yaOfrecida) return;
      _yaOfrecida = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // El contexto del Navigator raíz, NO el de este widget: `UpdateGate`
        // vive en el `builder` de MaterialApp.router, por encima del
        // Navigator, y con su propio contexto el sheet no puede abrirse.
        final ctx = navigatorKey.currentContext;
        if (mounted && ctx != null) _mostrar(ctx, info);
      });
    });
    return widget.child;
  }

  void _mostrar(BuildContext context, InfoActualizacion info) =>
      showModalBottomSheet<void>(
        context: context,
        backgroundColor: Colors.transparent,
        // Una actualización obligatoria no se descarta tocando afuera.
        isDismissible: !info.obligatoria,
        enableDrag: !info.obligatoria,
        builder: (_) => PopScope(
          canPop: !info.obligatoria,
          child: UpdateSheet(info: info),
        ),
      );
}

class UpdateSheet extends ConsumerStatefulWidget {
  const UpdateSheet({super.key, required this.info});

  final InfoActualizacion info;

  @override
  ConsumerState<UpdateSheet> createState() => _UpdateSheetState();
}

class _UpdateSheetState extends ConsumerState<UpdateSheet> {
  double? _progreso;
  String? _error;
  bool _instalando = false;

  Future<void> _actualizar() async {
    final updater = ref.read(updaterProvider);
    setState(() {
      _progreso = 0;
      _error = null;
    });
    try {
      final apk = await updater.descargar(
        widget.info.apkUrl!,
        onProgreso: (p) => mounted ? setState(() => _progreso = p) : null,
      );
      setState(() => _instalando = true);
      final r = await updater.instalar(apk);
      if (!mounted) return;
      switch (r) {
        case ResultadoInstalacion.necesitaPermiso:
          setState(() {
            _instalando = false;
            _progreso = null;
            _error = 'Android necesita tu permiso para instalar la '
                'actualización. Te abro los ajustes: activá "Permitir de esta '
                'fuente" y volvé.';
          });
          await updater.abrirAjustesPermiso();
        case ResultadoInstalacion.error:
          setState(() {
            _instalando = false;
            _progreso = null;
            _error = 'No se pudo instalar. Probá de nuevo más tarde.';
          });
        // En los dos caminos buenos el sistema toma el control: si es
        // silencioso, la app se reinicia sola; si es con diálogo, aparece el
        // del sistema. No hay nada más que hacer acá.
        case ResultadoInstalacion.silenciosa:
        case ResultadoInstalacion.conDialogo:
          break;
      }
    } on Object catch (e) {
      if (!mounted) return;
      setState(() {
        _instalando = false;
        _progreso = null;
        _error = _mensajeDeError(e);
      });
    }
  }

  String _mensajeDeError(Object e) {
    if (e is SocketException) {
      return 'Sin conexión. Probá de nuevo cuando tengas señal.';
    }
    return 'No se pudo descargar la actualización.';
  }

  @override
  Widget build(BuildContext context) {
    final info = widget.info;
    final descargando = _progreso != null && !_instalando;

    return Container(
      decoration: const BoxDecoration(
        color: MColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(MRadius.xl)),
        boxShadow: MShadow.sheetMovil,
      ),
      padding: const EdgeInsets.fromLTRB(24, 14, 24, 30),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: MColors.borderMd,
                borderRadius: BorderRadius.circular(MRadius.full),
              ),
            ),
            const SizedBox(height: 22),
            Text('Nueva versión de la app', style: MText.authTitle),
            const SizedBox(height: 10),
            Text(
              info.obligatoria
                  ? 'Esta actualización es necesaria para seguir usando Mírame.'
                  : 'Hay una versión nueva disponible.',
              textAlign: TextAlign.center,
              style: MText.cuerpoSec,
            ),
            const SizedBox(height: 6),
            Text(
              '${info.instalada}  →  ${info.latestVersion}',
              style: MText.menor,
            ),
            if (info.mensajeGlobal?.isNotEmpty ?? false) ...[
              const SizedBox(height: 14),
              Text(
                info.mensajeGlobal!,
                textAlign: TextAlign.center,
                style: MText.cuerpoSec,
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: sans(size: 13, weight: 500, color: MColors.dangerText),
              ),
            ],
            const SizedBox(height: 24),
            if (descargando) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(MRadius.full),
                child: LinearProgressIndicator(
                  value: _progreso,
                  minHeight: 6,
                  backgroundColor: MColors.bg3,
                  color: MColors.brand,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Descargando… ${((_progreso ?? 0) * 100).round()}%',
                style: MText.menor,
              ),
            ] else if (_instalando) ...[
              const SizedBox(height: 4),
              Text('Instalando…', style: MText.menor),
            ] else ...[
              PressableScale(
                onTap: _actualizar,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    color: MColors.brand,
                    borderRadius: BorderRadius.circular(MRadius.full),
                    boxShadow: MShadow.sm,
                  ),
                  child: Text(
                    _error == null ? 'Actualizar ahora' : 'Reintentar',
                    textAlign: TextAlign.center,
                    style: sans(size: 15, weight: 600, color: MColors.tWhite),
                  ),
                ),
              ),
              if (!info.obligatoria) ...[
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Más tarde', style: MText.menor),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}


/// Botón de "Buscar actualización".
///
/// El chequeo automático corre al entrar; este botón existe para poder
/// verificarlo sin reiniciar la app, y para que en soporte se pueda pedir
/// "tocá acá" en vez de "cerrá y volvé a abrir". Dice SIEMPRE algo: un botón
/// que no responde no se distingue de uno roto.
class BotonBuscarActualizacion extends ConsumerStatefulWidget {
  const BotonBuscarActualizacion({super.key});

  @override
  ConsumerState<BotonBuscarActualizacion> createState() =>
      _BotonBuscarState();
}

class _BotonBuscarState extends ConsumerState<BotonBuscarActualizacion> {
  bool _buscando = false;

  Future<void> _buscar() async {
    setState(() => _buscando = true);
    ref.invalidate(actualizacionProvider);
    final info = await ref.read(actualizacionProvider.future);
    if (!mounted) return;
    setState(() => _buscando = false);

    if (info != null && info.ofrecible) {
      await showModalBottomSheet<void>(
        context: context,
        backgroundColor: Colors.transparent,
        isDismissible: !info.obligatoria,
        builder: (_) => UpdateSheet(info: info),
      );
      return;
    }

    final mensaje = switch (info) {
      null => 'No se pudo consultar. Revisá la conexión.',
      final i when !i.hayNueva => 'Ya tenés la última versión (${i.instalada}).',
      // Hay versión nueva pero sin URL publicada: decirlo tal cual evita que
      // se persiga un bug del teléfono cuando el problema está en el release.
      _ => 'Hay una versión nueva pero todavía no está publicada.',
    };
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje, style: MText.menor),
        backgroundColor: MColors.surface,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => TextButton.icon(
        onPressed: _buscando ? null : _buscar,
        icon: _buscando
            ? const SizedBox(
                width: 13,
                height: 13,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: MColors.tMuted,
                ),
              )
            : const Icon(Icons.refresh_rounded,
                size: 16, color: MColors.tMuted),
        label: Text(
          _buscando ? 'Buscando…' : 'Buscar actualización',
          style: MText.menor,
        ),
      );
}
