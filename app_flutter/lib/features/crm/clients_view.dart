/// Clientas: buscar, ver y cargar.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/motion.dart';
import '../../core/theme/shadows.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../data/local/database.dart';
import '../../data/repositories/business_repository.dart';
import '../../domain/rules/access.dart';
import '../../domain/rules/formatting.dart';
import '../auth/session_controller.dart';
import '../dashboard/dashboard_view.dart';
import '../shell/app_shell.dart';
import '../shell/vistas_comunes.dart';
import 'client_detail.dart';

class ClientsView extends ConsumerStatefulWidget {
  const ClientsView({super.key});

  @override
  ConsumerState<ClientsView> createState() => _ClientsViewState();
}

/// Turnos y gasto por clienta. Va aparte del listado para que escribir una
/// clienta no obligue a recalcular los agregados de todas.
final resumenClientesProvider =
    StreamProvider.autoDispose<Map<String, ({int turnos, double gastado})>>(
        (ref) {
  final repo = ref.watch(businessRepoProvider);
  if (repo == null) return const Stream.empty();
  return repo.verResumenClientes();
});

class _ClientsViewState extends ConsumerState<ClientsView> {
  // La búsqueda es estado de ESTA pantalla, no del programa: guardarla en un
  // provider global la dejaría escrita al volver desde otra sección.
  String _busqueda = '';
  String _filtro = 'all';

  @override
  Widget build(BuildContext context) {
    final todas = ref.watch(clientesProvider).value ?? const <Client>[];
    final busqueda = _busqueda.trim().toLowerCase();
    final puedeEscribir = ref.watch(puedeProvider(Permiso.escribirAgenda));
    final resumen = ref.watch(resumenClientesProvider).value ??
        const <String, ({int turnos, double gastado})>{};

    // El filtro corre en memoria y no en SQL: son decenas o cientos de
    // clientas, no millones, y así la búsqueda responde sin ir al disco en
    // cada tecla.
    var lista = busqueda.isEmpty
        ? todas
        : todas.where((c) {
            final t = (c.telefono ?? '').toLowerCase();
            return c.nombre.toLowerCase().contains(busqueda) ||
                t.contains(busqueda);
          }).toList();

    // `renderClients` del original: 'vip' filtra, 'recent' ordena por alta y
    // se queda con 20.
    if (_filtro == 'vip') {
      lista = lista.where((c) => c.vip).toList();
    } else if (_filtro == 'recent') {
      lista = [...lista]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      lista = lista.take(20).toList();
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: puedeEscribir
          ? Padding(
              // `bottom: 80px + safe` y `right: 18px` del CSS. El
              // Scaffold ya separa 16 del borde, así que acá van 2.
              padding: const EdgeInsets.only(right: 2, bottom: 8),
              child: FabMirame(onTap: () => mostrarFormularioCliente(context, ref)),
            )
          : null,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
            child: TextField(
              onChanged: (v) => setState(() => _busqueda = v),
              style: sans(size: 14, weight: 500),
              decoration: InputDecoration(
                hintText: 'Buscar por nombre o teléfono',
                hintStyle: MText.menor,
                prefixIcon: const Icon(Icons.search_rounded,
                    size: 19, color: MColors.tLight),
                filled: true,
                fillColor: MColors.surface,
                contentPadding: const EdgeInsets.symmetric(vertical: 4),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(MRadius.full),
                  borderSide: const BorderSide(color: MColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(MRadius.full),
                  borderSide: const BorderSide(color: MColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(MRadius.full),
                  borderSide: const BorderSide(color: MColors.brand),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: FilaFiltros(
              opciones: const [
                ('all', 'Todas'),
                ('vip', 'VIP'),
                ('recent', 'Recientes'),
              ],
              activo: _filtro,
              onElegir: (f) => setState(() => _filtro = f),
            ),
          ),
          Expanded(
            child: lista.isEmpty
                ? EstadoVacio(
                    // Textos literales de `renderClients`.
                    emoji: busqueda.isEmpty ? '🌸' : '🔍',
                    titulo: busqueda.isEmpty ? 'Sin clientas' : 'Sin resultados',
                    detalle: busqueda.isEmpty
                        ? 'Registrá tu primera clienta'
                        : 'Probá con otro nombre o teléfono',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                    itemCount: lista.length,
                    itemBuilder: (_, i) => FadeSlideIn(
                      delay: Duration(milliseconds: (i < 8 ? i : 8) * 35),
                      child: _FilaCliente(
                        cliente: lista[i],
                        turnos: resumen[lista[i].id]?.turnos ?? 0,
                        gastado: resumen[lista[i].id]?.gastado ?? 0,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

/// `.cli-card` — avatar de 46, nombre, tag VIP, teléfono, estadísticas y la
/// flecha `›` a la derecha.
///
/// Las estadísticas ("N turnos · $X") son parte de la tarjeta en el original y
/// son la razón de ser de la lista: sin ellas es una agenda de contactos.
class _FilaCliente extends ConsumerWidget {
  const _FilaCliente({
    required this.cliente,
    required this.turnos,
    required this.gastado,
  });

  final Client cliente;
  final int turnos;
  final num gastado;

  @override
  Widget build(BuildContext context, WidgetRef ref) => TarjetaMirame(
        margenInferior: 8,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        // Abre la ficha, no la edición: lo que se hace todo el tiempo es
        // mirar el historial, no cambiarle el nombre.
        onTap: () => mostrarFichaCliente(context, cliente),
        hijo: Row(
          children: [
            // `.cli-av { 46x46; 17px; weight 700 }`
            Container(
              width: 46,
              height: 46,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: MGradient.avatar(avatarIndex(cliente.nombre)),
                shape: BoxShape.circle,
              ),
              child: Text(
                initials(cliente.nombre),
                style: sans(size: 17, weight: 700, color: MColors.tWhite),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          cliente.nombre,
                          style: sans(size: 14, weight: 600),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (cliente.vip) ...[
                        const SizedBox(width: 7),
                        const TagVip(),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    // El original escribe "Sin teléfono" en vez de dejar el
                    // renglón vacío: así la tarjeta no cambia de alto.
                    cliente.telefono?.isNotEmpty ?? false
                        ? cliente.telefono!
                        : 'Sin teléfono',
                    style: sans(size: 12, color: MColors.tSecondary),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _Estadistica(valor: '$turnos', sufijo: 'turnos'),
                      if (gastado > 0) ...[
                        const SizedBox(width: 10),
                        _Estadistica(valor: formatMoney(gastado)),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            if (cliente.telefono?.isNotEmpty ?? false)
              _BotonWhatsapp(telefono: cliente.telefono!),
            // `.ch-arrow` — la flecha que indica que la fila se abre.
            const Padding(
              padding: EdgeInsets.only(left: 4),
              child: Text(
                '›',
                style: TextStyle(fontSize: 16, color: MColors.tLight),
              ),
            ),
          ],
        ),
      );
}

/// `.vip-tag` — nude-100 sobre borde nude-300, texto nude-500, 9px/700.
class TagVip extends StatelessWidget {
  const TagVip({super.key});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        decoration: BoxDecoration(
          color: MColors.nude100,
          border: Border.all(color: MColors.nude300),
          borderRadius: BorderRadius.circular(MRadius.full),
        ),
        child: Text(
          'VIP 🌸',
          style: sans(size: 9, weight: 700, color: MColors.nude500)
              .copyWith(letterSpacing: 0.3),
        ),
      );
}

/// `.cst` — el número en lav-600 y el resto en t-muted.
class _Estadistica extends StatelessWidget {
  const _Estadistica({required this.valor, this.sufijo});

  final String valor;
  final String? sufijo;

  @override
  Widget build(BuildContext context) => Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: valor,
              style: sans(size: 11, weight: 600, color: MColors.lav600),
            ),
            if (sufijo != null)
              TextSpan(
                text: ' $sufijo',
                style: sans(size: 11, color: MColors.tMuted),
              ),
          ],
        ),
      );
}

class _BotonWhatsapp extends StatelessWidget {
  const _BotonWhatsapp({required this.telefono});

  final String telefono;

  @override
  Widget build(BuildContext context) => IconButton(
        tooltip: 'WhatsApp',
        visualDensity: VisualDensity.compact,
        onPressed: () async {
          // Solo dígitos: los teléfonos se cargan con espacios, guiones y
          // paréntesis, y wa.me los rechaza.
          final limpio = telefono.replaceAll(RegExp(r'\D'), '');
          if (limpio.isEmpty) return;
          await launchUrl(
            Uri.parse('https://wa.me/$limpio'),
            mode: LaunchMode.externalApplication,
          );
        },
        icon: const Icon(Icons.chat_bubble_outline_rounded,
            size: 18, color: MColors.whatsapp),
      );
}

/// Alta y edición. Es un sheet en móvil, igual que los modales del original.
Future<void> mostrarFormularioCliente(
  BuildContext context,
  WidgetRef ref, {
  Client? cliente,
}) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FormularioCliente(cliente: cliente),
    );

class _FormularioCliente extends ConsumerStatefulWidget {
  const _FormularioCliente({this.cliente});

  final Client? cliente;

  @override
  ConsumerState<_FormularioCliente> createState() => _FormClienteState();
}

class _FormClienteState extends ConsumerState<_FormularioCliente> {
  late final TextEditingController _nombre;
  late final TextEditingController _telefono;
  late final TextEditingController _notas;
  late bool _vip;
  bool _guardando = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _nombre = TextEditingController(text: widget.cliente?.nombre ?? '');
    _telefono = TextEditingController(text: widget.cliente?.telefono ?? '');
    _notas = TextEditingController(text: widget.cliente?.notas ?? '');
    _vip = widget.cliente?.vip ?? false;
  }

  @override
  void dispose() {
    _nombre.dispose();
    _telefono.dispose();
    _notas.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    final nombre = _nombre.text.trim();
    if (nombre.isEmpty) {
      setState(() => _error = 'El nombre no puede quedar vacío.');
      return;
    }
    final repo = ref.read(businessRepoProvider);
    if (repo == null) return;

    setState(() {
      _guardando = true;
      _error = null;
    });
    try {
      await repo.guardarCliente(
        id: widget.cliente?.id,
        nombre: nombre,
        telefono: _telefono.text.trim().isEmpty ? null : _telefono.text.trim(),
        vip: _vip,
        notas: _notas.text.trim().isEmpty ? null : _notas.text.trim(),
      );
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      // Guardar escribe en SQLite, no en la red: si falla acá es un problema
      // real del dispositivo y hay que decirlo, no tragarlo.
      if (mounted) {
        setState(() {
          _guardando = false;
          _error = 'No se pudo guardar en este dispositivo.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => SheetFormulario(
        titulo: widget.cliente == null ? 'Nueva clienta' : 'Editar clienta',
        error: _error,
        guardando: _guardando,
        onGuardar: _guardar,
        onBorrar: widget.cliente == null
            ? null
            : () async {
                // El Navigator se toma ANTES del await: después el context
                // de este build puede haber dejado de ser válido, y el
                // analizador tiene razón en no aceptar un `mounted` que mira
                // otra cosa.
                final nav = Navigator.of(context);
                final repo = ref.read(businessRepoProvider);
                await repo?.borrar('clients', widget.cliente!.id);
                nav.pop();
              },
        campos: [
          CampoTexto(controlador: _nombre, etiqueta: 'Nombre', autofocus: true),
          CampoTexto(
            controlador: _telefono,
            etiqueta: 'Teléfono',
            teclado: TextInputType.phone,
          ),
          CampoTexto(
            controlador: _notas,
            etiqueta: 'Notas',
            lineas: 3,
          ),
          SwitchListTile.adaptive(
            value: _vip,
            onChanged: (v) => setState(() => _vip = v),
            activeThumbColor: MColors.brand,
            contentPadding: EdgeInsets.zero,
            title: Text('Clienta VIP', style: sans(size: 14, weight: 500)),
          ),
        ],
      );
}
