/// El buscador del header en pantalla grande: clienta, turno o producto.
///
/// Es el punto 1 de la entrega de escritorio, y está en el header y no dentro
/// de una vista por una razón concreta: con el sidebar, cambiar de sección
/// cuesta un clic, y buscar una clienta terminaba siendo "ir a Clientas, tocar
/// el buscador, tipear". Acá se busca desde donde sea que estés.
///
/// Busca en las tres cosas que se buscan de verdad: **clientas** por nombre o
/// teléfono, **turnos de hoy** por el nombre de la clienta, y **productos** por
/// nombre o código. No busca en movimientos de caja ni en insumos: nadie busca
/// un gasto por nombre, y los insumos se miran en lista.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/layout/layout.dart';
import '../../core/theme/motion.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../data/local/database.dart' as db;
import '../../domain/rules/formatting.dart';
import '../crm/client_detail.dart';
import '../dashboard/dashboard_view.dart';
import '../ropa/ropa_view.dart';
import 'app_shell.dart';
import 'vistas_comunes.dart';

/// La píldora del header. 300 × 38, con el atajo a la derecha.
///
/// El atajo `/` se muestra **solo con puntero**: en la tablet del mostrador no
/// hay teclado, y una tecla dibujada que no se puede apretar es una promesa
/// falsa. Lo dice el brief de la tablet con todas las letras.
class PildoraBuscar extends StatelessWidget {
  const PildoraBuscar({super.key});

  @override
  Widget build(BuildContext context) {
    final conTeclado = esEscritorioPuntero(context);
    return PressableScale(
      escala: 1,
      onTap: () => mostrarBuscadorGlobal(context),
      child: Container(
        width: 300,
        height: 38,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: MColors.bg2,
          border: Border.all(color: MColors.border),
          borderRadius: BorderRadius.circular(MRadius.full),
        ),
        child: Row(
          children: [
            const Icon(Icons.search_rounded, size: 16, color: MColors.tMuted),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Buscar clienta, turno o producto',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: sans(size: 12, color: MColors.tMuted),
              ),
            ),
            if (conTeclado) const _TeclaBarra(),
          ],
        ),
      ),
    );
  }
}

/// La tecla `/` dibujada como tecla, no como texto: es lo que hace que se lea
/// como un atajo y no como parte de la frase.
class _TeclaBarra extends StatelessWidget {
  const _TeclaBarra();

  @override
  Widget build(BuildContext context) => Container(
        width: 18,
        height: 18,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: MColors.surface,
          border: Border.all(color: MColors.border),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text('/', style: sans(size: 11, weight: 600)),
      );
}

/// Envuelve al shell para que `/` abra el buscador desde cualquier vista.
///
/// Va acá y no en cada vista porque el atajo es del caparazón. Y solo engancha
/// con puntero: en un APK táctil un `Shortcuts` sin teclado es un nodo de foco
/// más compitiendo por nada.
class AtajoBuscar extends StatelessWidget {
  const AtajoBuscar({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!esEscritorioPuntero(context)) return child;
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.slash): () =>
            mostrarBuscadorGlobal(context),
      },
      child: child,
    );
  }
}

/// Abre el buscador. Devuelve cuando se cierra.
///
/// Un diálogo propio y no `showAppSheet`: este necesita el foco en el campo al
/// abrirse y cerrarse con Escape, y arriba de todo, porque se llama con una
/// tecla mientras se está mirando cualquier otra cosa.
Future<void> mostrarBuscadorGlobal(BuildContext context) {
  // Sin dos buscadores encimados si se aprieta `/` dos veces.
  if (_abierto) return Future.value();
  _abierto = true;
  return showDialog<void>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.28),
    builder: (_) => const _Buscador(),
  ).whenComplete(() => _abierto = false);
}

bool _abierto = false;

class _Buscador extends ConsumerStatefulWidget {
  const _Buscador();

  @override
  ConsumerState<_Buscador> createState() => _BuscadorState();
}

class _BuscadorState extends ConsumerState<_Buscador> {
  final _texto = TextEditingController();

  @override
  void dispose() {
    _texto.dispose();
    super.dispose();
  }

  /// Va a la sección [indice] y cierra. El orden importa: primero se cierra el
  /// diálogo, porque `NavegadorShell` cuelga del árbol de abajo.
  void _irA(int indice) {
    final navegar = Navigator.of(context);
    final shell = context;
    navegar.pop();
    NavegadorShell.ir(shell, indice);
  }

  @override
  Widget build(BuildContext context) {
    final q = _texto.text.trim().toLowerCase();
    final clientes = ref.watch(clientesProvider).value ?? const <db.Client>[];
    final turnos =
        ref.watch(turnosDeHoyProvider).value ?? const <db.Appointment>[];
    final productos =
        ref.watch(productosProvider).value ?? const <db.Producto>[];

    final nombrePorId = {for (final c in clientes) c.id: c.nombre};

    final clientasHit = q.isEmpty
        ? const <db.Client>[]
        : clientes
            .where((c) =>
                c.nombre.toLowerCase().contains(q) ||
                (c.telefono ?? '').contains(q))
            .take(5)
            .toList();

    final turnosHit = q.isEmpty
        ? const <db.Appointment>[]
        : turnos
            .where((t) =>
                (nombrePorId[t.clientId] ?? '').toLowerCase().contains(q))
            .take(4)
            .toList();

    final productosHit = q.isEmpty
        ? const <db.Producto>[]
        : productos
            .where((p) =>
                p.nombre.toLowerCase().contains(q) ||
                (p.codigo ?? '').toLowerCase().contains(q))
            .take(5)
            .toList();

    final sinNada = q.isNotEmpty &&
        clientasHit.isEmpty &&
        turnosHit.isEmpty &&
        productosHit.isEmpty;

    return Dialog(
      backgroundColor: MColors.surface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 64),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(MRadius.lg),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: MBreak.sheetMaxWidth),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
              child: CampoTexto(
                controlador: _texto,
                etiqueta: 'Buscar clienta, turno o producto',
                autofocus: true,
                onCambio: (_) => setState(() {}),
              ),
            ),
            Flexible(
              child: sinNada
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      child: Text(
                        'Nada con "${_texto.text.trim()}"',
                        style: sans(size: 13, color: MColors.tMuted),
                      ),
                    )
                  : ListView(
                      shrinkWrap: true,
                      padding: const EdgeInsets.only(bottom: 12),
                      children: [
                        if (clientasHit.isNotEmpty) ...[
                          const _Titulo('Clientas'),
                          for (final c in clientasHit)
                            _Resultado(
                              titulo: c.nombre,
                              detalle: c.telefono ?? 'Sin teléfono',
                              icono: Icons.person_outline,
                              onTap: () {
                                Navigator.of(context).pop();
                                mostrarFichaCliente(context, c);
                              },
                            ),
                        ],
                        if (turnosHit.isNotEmpty) ...[
                          const _Titulo('Turnos de hoy'),
                          for (final t in turnosHit)
                            _Resultado(
                              titulo: nombrePorId[t.clientId] ?? 'Sin nombre',
                              detalle: [
                                if (t.hora.isNotEmpty) t.hora,
                                formatMoney(t.precio),
                              ].join(' · '),
                              icono: Icons.event_outlined,
                              onTap: () => _irA(Vistas.agenda),
                            ),
                        ],
                        if (productosHit.isNotEmpty) ...[
                          const _Titulo('Tienda'),
                          for (final p in productosHit)
                            _Resultado(
                              titulo: p.nombre,
                              detalle: [
                                if ((p.codigo ?? '').isNotEmpty) p.codigo!,
                                formatMoney(p.precio),
                              ].join(' · '),
                              icono: Icons.sell_outlined,
                              onTap: () => _irA(Vistas.ropa),
                            ),
                        ],
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Titulo extends StatelessWidget {
  const _Titulo(this.texto);

  final String texto;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 4),
        child: EtiquetaSeccion(texto),
      );
}

class _Resultado extends StatelessWidget {
  const _Resultado({
    required this.titulo,
    required this.detalle,
    required this.icono,
    required this.onTap,
  });

  final String titulo;
  final String detalle;
  final IconData icono;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        child: Padding(
          // 48 de alto mínimo: el buscador también se usa con el dedo en la
          // tablet, donde este diálogo es el mismo.
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          child: Row(
            children: [
              Icon(icono, size: 17, color: MColors.tMuted),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      titulo,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: sans(size: 14, weight: 600),
                    ),
                    Text(
                      detalle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: sans(size: 12, color: MColors.tMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}
