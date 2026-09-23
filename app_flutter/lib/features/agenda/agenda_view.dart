/// Agenda: los turnos del día elegido.
///
/// La detección de solapamientos sale de `domain/rules/agenda.dart` — es una
/// corrección respecto del legacy, que no la tenía y dejaba pisar turnos.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/notificaciones/pedir_permiso.dart';
import '../../core/layout/layout.dart';
import '../../core/theme/motion.dart';
import '../../core/theme/shadows.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../data/local/database.dart' as db;
import '../../data/local/mappers.dart';
import '../../data/repositories/business_repository.dart';
import '../../domain/entities/entities.dart';
import '../../domain/rules/access.dart';
import '../../domain/rules/formatting.dart';
import '../../domain/rules/period.dart';
import '../auth/session_controller.dart';
import '../dashboard/dashboard_view.dart';
import '../settings/catalogo.dart';
import 'calendario.dart';
import '../shell/app_shell.dart';
import '../../shared/widgets/comportamiento.dart';
import '../../shared/widgets/piezas.dart';
import '../shell/vistas_comunes.dart';

/// Turnos del día que se está mirando.
final turnosDelDiaProvider =
    StreamProvider.autoDispose.family<List<db.Appointment>, String>(
  (ref, claveDia) {
    final repo = ref.watch(businessRepoProvider);
    if (repo == null) return Stream.value(const []);
    // La clave es el 'YYYY-MM-DD' y no un DateTime: dos DateTime del mismo día
    // con distinta hora son objetos distintos, y `family` crearía un provider
    // nuevo en cada rebuild.
    return repo.verTurnosDe(fechaDesdeTexto(claveDia));
  },
);

/// Turnos del mes visible, solo para marcar con un punto los días que tienen
/// algo. Va aparte de los del día para que cambiar de día no vuelva a
/// consultar el mes entero.
final turnosDelMesVisibleProvider = StreamProvider.autoDispose
    .family<List<db.Appointment>, String>((ref, claveMes) {
  final repo = ref.watch(businessRepoProvider);
  if (repo == null) return Stream.value(const []);
  final partes = claveMes.split('-');
  final y = int.parse(partes[0]);
  final m = int.parse(partes[1]);
  return repo.verTurnosEntre(DateTime(y, m, 1), DateTime(y, m + 1, 0));
});

class AgendaView extends ConsumerStatefulWidget {
  const AgendaView({super.key});

  @override
  ConsumerState<AgendaView> createState() => _AgendaViewState();
}

class _AgendaViewState extends ConsumerState<AgendaView> {
  DateTime _dia = DateTime.now();
  late DateTime _mes = DateTime(_dia.year, _dia.month, 1);
  String _filtro = 'all';

  /// La vista arranca en semana. El mes entero ocupaba media pantalla para
  /// contestar "¿qué hay hoy?", que se contesta con una fila de siete días;
  /// el calendario completo sigue estando, a un toque del interruptor.
  String _vista = 'Semana';

  /// El día elegido no es hoy. Mientras sea cierto aparece el botón "Hoy":
  /// tres toques de mes adelante y volver se hacía deslizando a ciegas.
  bool get _lejosDeHoy => claveFecha(_dia) != claveFecha(DateTime.now());

  void _correrDia(int dias) => setState(() {
        _dia = _dia.add(Duration(days: dias));
        _mes = DateTime(_dia.year, _dia.month, 1);
      });

  void _volverAHoy() {
    final hoy = DateTime.now();
    setState(() {
      _dia = hoy;
      _mes = DateTime(hoy.year, hoy.month, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final clave = claveFecha(_dia);
    final claveMes = '${_mes.year}-${_mes.month.toString().padLeft(2, '0')}';
    final delDia = ref.watch(turnosDelDiaProvider(clave));
    // Mientras la base abre no hay turnos todavía, y eso NO es un día libre:
    // mostrar "Sin turnos" ahí hacía creer que se habían borrado.
    final cargando = delDia.isLoading && !delDia.hasValue;
    final filas = delDia.value ?? const <db.Appointment>[];
    final todos = filas.map((f) => aAppointment(f)).toList();
    // El filtro se aplica a la lista, NO al calendario: los puntos del mes
    // tienen que seguir mostrando que ahí hay algo aunque el filtro activo lo
    // esconda de la lista.
    final turnos = _filtro == 'all'
        ? todos
        : todos.where((t) => textoDesdeEstado(t.estado) == _filtro).toList();

    final delMes = ref.watch(turnosDelMesVisibleProvider(claveMes)).value ??
        const <db.Appointment>[];
    final diasConTurno = {for (final t in delMes) t.fecha};
    final clientes = ref.watch(clientesProvider).value ?? const <db.Client>[];
    final puedeEscribir = ref.watch(puedeProvider(Permiso.escribirAgenda));

    final nombrePorId = {for (final c in clientes) c.id: c.nombre};

    // Quiénes trabajan en el día que se está mirando. Sale de los turnos, no
    // de una tabla de horarios: lo que importa es quién TIENE trabajo.
    final profesionales =
        ref.watch(profesionalesProvider).value ?? const <db.Professional>[];
    final nombreProfesional = {for (final p in profesionales) p.id: p.nombre};
    final profesionalesDelDia = <String>{
      for (final t in todos)
        if (nombreProfesional[t.professionalId] case final n?) n,
    }.toList();

    final escritorio = esEscritorio(context);

    final calendario = CalendarioMes(
      mes: _mes,
      diaElegido: _dia,
      diasConTurno: diasConTurno,
      onElegirDia: (d) => setState(() {
        _dia = d;
        _mes = DateTime(d.year, d.month, 1);
      }),
      onCambiarMes: (delta) => setState(() {
        _mes = DateTime(_mes.year, _mes.month + delta, 1);
      }),
    );
    final filtros = FilaFiltros(
      opciones: const [
        ('all', 'Todos'),
        ('confirmed', 'Confirmados'),
        ('pending', 'Pendientes'),
        ('done', 'Completados'),
      ],
      activo: _filtro,
      onElegir: (f) => setState(() => _filtro = f),
    );
    final lista = cargando
        ? EsqueletoDeLista(
            filas: 4,
            alto: 64,
            padding: escritorio
                ? const EdgeInsets.fromLTRB(0, 0, 32, 40)
                : const EdgeInsets.fromLTRB(16, 0, 16, 96),
          )
        : turnos.isEmpty
            ? EstadoVacio(
                // Vacío por filtro y vacío de verdad no son lo mismo: uno se
                // arregla tocando "Todos" y el otro cargando un turno.
                emoji: _filtro == 'all' ? '📅' : '🔍',
                titulo: _filtro == 'all' ? 'Sin turnos' : 'Nada con ese filtro',
                detalle: _filtro == 'all'
                    ? 'No hay turnos para este día. Tocá + para agendar uno.'
                    : 'Hay turnos este día, pero ninguno en este estado.',
                accion: _filtro == 'all'
                    ? null
                    : ('Ver todos', () => setState(() => _filtro = 'all')),
              )
            : _Timeline(
                turnos: turnos,
                nombrePorId: nombrePorId,
                nombreProfesional: nombreProfesional,
                esHoy: !_lejosDeHoy,
                padding: escritorio
                    ? const EdgeInsets.fromLTRB(0, 0, 32, 40)
                    : const EdgeInsets.fromLTRB(16, 0, 16, 96),
              );

    void nuevoTurno() => _mostrarFormulario(context, ref, dia: _dia);

    final botonHoy = _lejosDeHoy
        ? Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: PressableScale(
              onTap: _volverAHoy,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                decoration: BoxDecoration(
                  color: MColors.surface,
                  borderRadius: BorderRadius.circular(MRadius.full),
                  border: Border.all(color: MColors.borderMd),
                  boxShadow: MShadow.md,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.today_outlined,
                        size: 15, color: MColors.brand),
                    const SizedBox(width: 6),
                    Text(
                      'Hoy',
                      style:
                          sans(size: 13, weight: 600, color: MColors.brandDark),
                    ),
                  ],
                ),
              ),
            ),
          )
        : const SizedBox.shrink();

    if (escritorio) {
      // Dos paneles: el mes a la izquierda con ancho fijo —así las celdas
      // quedan de ~48 px y no de 185 como cuando el calendario tomaba todo
      // el monitor— y el día elegido a la derecha, con el espacio que sobre.
      //
      // Con teclado, las flechas corren el día: en el mostrador se revisa
      // "¿y mañana?" muchas veces por hora y tocar el número exacto del mes
      // es más lento que una flecha.
      return CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.arrowLeft): () =>
              _correrDia(-1),
          const SingleActivator(LogicalKeyboardKey.arrowRight): () =>
              _correrDia(1),
          const SingleActivator(LogicalKeyboardKey.keyT): _volverAHoy,
        },
        child: Focus(
          // Solo si es la vista que se esta viendo: las ocho estan montadas.
          autofocus: NavegadorShell.esLaVista(context, Vistas.agenda),
          child: ContenidoEscritorio.tabla(
            child: Column(
              children: [
                BarraVista(
                  filtros: filtros,
                  accion: puedeEscribir
                      ? BotonPrimario(texto: 'Nuevo turno', onTap: nuevoTurno)
                      : null,
                ),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 380,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(32, 0, 0, 40),
                          child: calendario,
                        ),
                      ),
                      const SizedBox(width: 28),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 4, 32, 14),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Flexible(
                                    child: Text(
                                      _tituloDia(_dia),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: serif(size: 22, weight: 600),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    turnos.isEmpty
                                        ? 'sin turnos'
                                        : '${turnos.length} '
                                            '${turnos.length == 1 ? "turno" : "turnos"}',
                                    style:
                                        sans(size: 13, color: MColors.tMuted),
                                  ),
                                  const Spacer(),
                                  if (_lejosDeHoy) botonHoy,
                                ],
                              ),
                            ),
                            Expanded(child: lista),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          botonHoy,
          fabVista(context, visible: puedeEscribir, onTap: nuevoTurno) ??
              const SizedBox.shrink(),
        ],
      ),
      body: ListaConEncabezado(
        // La cabecera queda FIJA: sin esto, para ver un turno de las 18:00
        // había que perder de vista qué día se estaba mirando.
        encabezado: (_, hayArriba) => AnimatedContainer(
          duration: MMotion.t1,
          decoration: BoxDecoration(
            color: MColors.bg,
            boxShadow: sombraEncabezado(hayArriba),
          ),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      nombreMes(_mes),
                      style: serif(size: 22, weight: 600),
                    ),
                  ),
                  SelectorDeVista(
                    opciones: const ['Semana', 'Mes'],
                    activa: _vista,
                    onElegir: (v) => setState(() => _vista = v),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_vista == 'Semana')
                TiraSemanal(
                  diaElegido: _dia,
                  diasConTurno: diasConTurno,
                  onElegirDia: (d) => setState(() {
                    _dia = d;
                    _mes = DateTime(d.year, d.month, 1);
                  }),
                )
              else
                calendario,
              const SizedBox(height: 12),
              _ResumenDelDia(
                dia: _dia,
                turnos: todos,
                profesionales: profesionalesDelDia,
              ),
              const SizedBox(height: 12),
              filtros,
            ],
          ),
        ),
        lista: TirarParaRefrescar(child: lista),
      ),
    );
  }

  /// "Lunes 21 de septiembre" — el título del panel del día en escritorio.
  static String _tituloDia(DateTime d) {
    const dias = [
      'Domingo',
      'Lunes',
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes',
      'Sábado',
    ];
    return '${dias[d.weekday % 7]} ${d.day} de ${monthName(d.month)}';
  }
}

/// "Martes 22 · 4 turnos · $53.000" con los avatares de quiénes trabajan.
///
/// Es la línea que contesta la pregunta del día sin leer la lista entera, y
/// queda fija arriba mientras los turnos pasan por debajo.
class _ResumenDelDia extends StatelessWidget {
  const _ResumenDelDia({
    required this.dia,
    required this.turnos,
    required this.profesionales,
  });

  final DateTime dia;
  final List<Appointment> turnos;
  final List<String> profesionales;

  @override
  Widget build(BuildContext context) {
    final vivos =
        turnos.where((t) => t.estado != TurnoEstado.cancelled).toList();
    final plata = vivos.fold<num>(0, (a, t) => a + t.precio);
    final n = vivos.length;
    return TarjetaMirame(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
      hijo: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${_tituloCorto(dia)} · '
                  '${n == 0 ? "sin turnos" : "$n ${n == 1 ? "turno" : "turnos"}"}',
                  style: sans(size: 13.5, weight: 600),
                ),
                if (plata > 0) ...[
                  const SizedBox(height: 2),
                  Text(
                    formatMoney(plata),
                    style: serif(size: 20, weight: 600),
                  ),
                ],
              ],
            ),
          ),
          PilaDeAvatares(nombres: profesionales),
        ],
      ),
    );
  }

  static String _tituloCorto(DateTime d) {
    const dias = [
      'Domingo',
      'Lunes',
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes',
      'Sábado',
    ];
    return '${dias[d.weekday % 7]} ${d.day}';
  }
}

/// `.timeline` del original: los turnos se agrupan por HORA, con la hora en
/// una columna angosta a la izquierda y una línea vertical que la separa.
///
/// No es decorativo: agrupar por hora es lo que deja ver de un vistazo si dos
/// turnos caen en la misma franja.
class _Timeline extends StatefulWidget {
  const _Timeline({
    required this.turnos,
    required this.nombrePorId,
    required this.padding,
    required this.esHoy,
    this.nombreProfesional = const {},
  });

  /// El día que se está mirando es hoy: solo entonces tiene sentido la línea
  /// de "ahora" y arrancar el scroll en el próximo turno.
  final bool esHoy;

  final List<Appointment> turnos;
  final Map<String, String> nombrePorId;
  final Map<String, String> nombreProfesional;
  final EdgeInsets padding;

  @override
  State<_Timeline> createState() => _TimelineState();
}

class _TimelineState extends State<_Timeline> {
  final _scroll = ScrollController();

  /// Alto aproximado de una franja horaria. No hace falta que sea exacto: se
  /// usa solo para arrancar cerca del próximo turno, y el usuario ve el resto
  /// con un dedo de scroll.
  static const _altoFranja = 92.0;

  @override
  void initState() {
    super.initState();
    // Abrir la agenda de hoy a las 09:00 cuando son las 17:00 es empezar
    // mirando lo que ya pasó. Se salta al próximo turno en el primer frame.
    WidgetsBinding.instance.addPostFrameCallback((_) => _irAlProximo());
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _irAlProximo() {
    if (!mounted || !_scroll.hasClients || !widget.esHoy) return;
    final ahora = DateTime.now();
    final horas = _horas();
    // La primera franja que todavía no terminó.
    final i = horas.indexWhere((h) => h >= ahora.hour);
    if (i <= 0) return;
    final destino =
        (i * _altoFranja).clamp(0.0, _scroll.position.maxScrollExtent);
    _scroll.jumpTo(destino);
  }

  Map<int, List<Appointment>> _porHora() {
    final m = <int, List<Appointment>>{};
    for (final t in widget.turnos) {
      m.putIfAbsent(t.hora?.hour ?? 9, () => []).add(t);
    }
    return m;
  }

  List<int> _horas() => _porHora().keys.toList()..sort();

  @override
  Widget build(BuildContext context) {
    // `byH` en el original: clave = la hora, sin los minutos.
    final porHora = _porHora();
    final horas = _horas();
    final ahora = DateTime.now();
    final nombrePorId = widget.nombrePorId;

    return ListView.builder(
      controller: _scroll,
      padding: widget.padding,
      // Una fila más: el cierre. Una lista que termina sin decir nada parece
      // cortada por un error de carga.
      itemCount: horas.length + 1,
      itemBuilder: (_, i) {
        if (i == horas.length) {
          return const FinDeLista('No hay más turnos este día');
        }
        final h = horas[i];
        final delHora = porHora[h]!;
        // La franja en curso: la hora de ahora, o la primera que ya pasó si
        // ahora mismo no hay ninguna.
        final esFranjaDeAhora = widget.esHoy && h == ahora.hour;
        // 12 horas con AM/PM, como `${+h%12||12}` del original.
        final h12 = h % 12 == 0 ? 12 : h % 12;
        final ampm = h >= 12 ? 'PM' : 'AM';

        return FadeSlideIn(
          delay: Duration(milliseconds: (i < 8 ? i : 8) * 35),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // `.tl-time { width:38px; text-align:right; 11px t-muted }`
                SizedBox(
                  width: 38,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '$h12',
                          style: sans(
                            size: 11,
                            weight: esFranjaDeAhora ? 700 : 500,
                            color: esFranjaDeAhora
                                ? MColors.brandDark
                                : MColors.tMuted,
                          ),
                        ),
                        Text(
                          ampm,
                          style: sans(
                            size: 9,
                            weight: 500,
                            color: esFranjaDeAhora
                                ? MColors.brand
                                : MColors.tMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // `.tl-row::before` — la línea vertical a 38px del borde. En
                // la franja en curso se pinta en brand: es la única marca de
                // "acá estamos parados" en una lista de horas iguales.
                Container(
                  width: esFranjaDeAhora ? 2 : 1,
                  color: esFranjaDeAhora ? MColors.brand : MColors.bg3,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 0, 2),
                    child: Column(
                      children: [
                        for (final t in delHora)
                          _EventoTimeline(
                            turno: t,
                            nombreCliente: nombrePorId[t.clientId],
                            nombreProfesional:
                                widget.nombreProfesional[t.professionalId],
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// `.tl-ev` — tarjeta del turno, con la **barra lavanda de 3px a la
/// izquierda**, que es lo que le da el aire de agenda.
class _EventoTimeline extends ConsumerWidget {
  const _EventoTimeline({
    required this.turno,
    this.nombreCliente,
    this.nombreProfesional,
  });

  final Appointment turno;
  final String? nombreCliente;
  final String? nombreProfesional;

  /// Cambia el estado sin abrir el formulario.
  ///
  /// `guardarTurno` pide el turno entero porque hace un upsert: se reenvían
  /// los mismos valores y `serviceIds: null` deja los servicios como están
  /// (mandar una lista vacía los borraría).
  Future<void> _cambiarEstado(WidgetRef ref, TurnoEstado nuevo) =>
      ref.read(businessRepoProvider)!.guardarTurno(
            id: turno.id,
            clientId: turno.clientId,
            professionalId: turno.professionalId,
            fecha: turno.fecha,
            hora: (turno.hora ?? const TimeOfDayValue(9, 0)).toString(),
            precio: turno.precio.toDouble(),
            estado: nuevo.name,
            notas: turno.notas,
          );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cancelado = turno.estado == TurnoEstado.cancelled;
    final hecho = turno.estado == TurnoEstado.done;
    final puedeEscribir = ref.watch(puedeProvider(Permiso.escribirAgenda));

    final tarjeta = TarjetaTurno(
      turno: turno,
      nombreCliente: nombreCliente,
      profesional: nombreProfesional,
      onTap: () => _mostrarFormulario(context, ref, turno: turno),
    );

    // Las dos cosas que más se hacen en el día —marcar hecho y cancelar—
    // pedían abrir el formulario, elegir en un desplegable y guardar. Con el
    // deslizamiento son un gesto, y el resto del turno queda igual.
    if (!puedeEscribir) return tarjeta;

    return Dismissible(
      key: ValueKey('turno-${turno.id}'),
      // `confirmDismiss` devolviendo false: la tarjeta vuelve a su lugar. No
      // se saca de la lista porque el turno sigue existiendo, solo cambia de
      // estado — y si el filtro activo ya no lo incluye, desaparece solo.
      confirmDismiss: (dir) async {
        final nuevo = dir == DismissDirection.startToEnd
            ? (hecho ? TurnoEstado.confirmed : TurnoEstado.done)
            : (cancelado ? TurnoEstado.confirmed : TurnoEstado.cancelled);
        await _cambiarEstado(ref, nuevo);
        return false;
      },
      background: _FondoDeslizar(
        alineacion: Alignment.centerLeft,
        color: hecho ? MColors.bg3 : MColors.successBg,
        icono: hecho ? Icons.undo_rounded : Icons.check_rounded,
        texto: hecho ? 'Deshacer' : 'Hecho',
        colorTexto: hecho ? MColors.tSecondary : MColors.successText,
      ),
      secondaryBackground: _FondoDeslizar(
        alineacion: Alignment.centerRight,
        color: cancelado ? MColors.bg3 : MColors.dangerBg,
        icono: cancelado ? Icons.undo_rounded : Icons.close_rounded,
        texto: cancelado ? 'Deshacer' : 'Cancelar',
        colorTexto: cancelado ? MColors.tSecondary : MColors.dangerText,
      ),
      child: tarjeta,
    );
  }
}

/// Lo que se ve detrás de la tarjeta mientras se desliza.
class _FondoDeslizar extends StatelessWidget {
  const _FondoDeslizar({
    required this.alineacion,
    required this.color,
    required this.icono,
    required this.texto,
    required this.colorTexto,
  });

  final Alignment alineacion;
  final Color color;
  final IconData icono;
  final String texto;
  final Color colorTexto;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Container(
          alignment: alineacion,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(MRadius.md),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icono, size: 17, color: colorTexto),
              const SizedBox(width: 7),
              Text(
                texto,
                style: sans(size: 12, weight: 600, color: colorTexto),
              ),
            ],
          ),
        ),
      );
}

Future<void> _mostrarFormulario(
  BuildContext context,
  WidgetRef ref, {
  Appointment? turno,
  DateTime? dia,
}) =>
    showAppSheet<void>(
      context,
      builder: (_) => _FormularioTurno(turno: turno, dia: dia),
    );

class _FormularioTurno extends ConsumerStatefulWidget {
  const _FormularioTurno({this.turno, this.dia});

  final Appointment? turno;
  final DateTime? dia;

  @override
  ConsumerState<_FormularioTurno> createState() => _FormTurnoState();
}

class _FormTurnoState extends ConsumerState<_FormularioTurno> {
  late final TextEditingController _precio;
  late final TextEditingController _notas;
  late DateTime _fecha;
  late TimeOfDay _hora;
  String? _clientId;

  /// Los servicios del turno. Es lo que define cuándo esa clienta tiene que
  /// volver, así que sin esto no hay recordatorio de retoque.
  final _servicios = <String>{};
  bool _guardando = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final t = widget.turno;
    _precio = TextEditingController(
      text: t == null ? '' : t.precio.toStringAsFixed(0),
    );
    _notas = TextEditingController(text: t?.notas ?? '');
    _fecha = t?.fecha ?? widget.dia ?? DateTime.now();
    _hora = t?.hora == null
        ? const TimeOfDay(hour: 10, minute: 0)
        : TimeOfDay(hour: t!.hora!.hour, minute: t.hora!.minute);
    _clientId = t?.clientId;
    if (t != null) {
      _servicios.addAll(
        ref.read(serviciosDeTurnosProvider).value?[t.id] ?? const [],
      );
    }
  }

  @override
  void dispose() {
    _precio.dispose();
    _notas.dispose();
    super.dispose();
  }

  String get _horaTexto => '${_hora.hour.toString().padLeft(2, '0')}:'
      '${_hora.minute.toString().padLeft(2, '0')}';

  Future<void> _guardar() async {
    final repo = ref.read(businessRepoProvider);
    if (repo == null) return;
    final crudo = _precio.text.trim().replaceAll('.', '').replaceAll(',', '.');

    setState(() {
      _guardando = true;
      _error = null;
    });
    final nav = Navigator.of(context);
    try {
      await repo.guardarTurno(
        id: widget.turno?.id,
        clientId: _clientId,
        serviceIds: _servicios.toList(),
        fecha: _fecha,
        hora: _horaTexto,
        precio: double.tryParse(crudo) ?? 0,
        notas: _notas.text.trim().isEmpty ? null : _notas.text.trim(),
      );
      nav.pop();
      // Momento del pedido de permiso: acaba de agendar algo, así que el
      // "te aviso el día anterior" tiene sentido. Pedirlo al arrancar la app
      // se rechaza y después no hay segunda oportunidad.
      if (mounted) await pedirPermisoDeAvisos(context);
    } catch (_) {
      if (mounted) {
        setState(() {
          _guardando = false;
          _error = 'No se pudo guardar en este dispositivo.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final clientes = ref.watch(clientesProvider).value ?? const <db.Client>[];
    final serviciosDisponibles =
        ref.watch(serviciosProvider).value ?? const <db.Service>[];

    return SheetFormulario(
      titulo: widget.turno == null ? 'Nuevo turno' : 'Editar turno',
      error: _error,
      guardando: _guardando,
      onGuardar: _guardar,
      onBorrar: widget.turno == null
          ? null
          : () async {
              final nav = Navigator.of(context);
              await ref
                  .read(businessRepoProvider)
                  ?.borrar('appointments', widget.turno!.id);
              nav.pop();
            },
      campos: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: DropdownButtonFormField<String?>(
            initialValue: _clientId,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: 'Clienta',
              labelStyle: MText.menor,
              filled: true,
              fillColor: MColors.bg2,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(MRadius.md),
                borderSide: const BorderSide(color: MColors.border),
              ),
            ),
            items: [
              const DropdownMenuItem(value: null, child: Text('Sin asignar')),
              for (final c in clientes)
                DropdownMenuItem(value: c.id, child: Text(c.nombre)),
            ],
            onChanged: (v) => setState(() => _clientId = v),
          ),
        ),
        // Los servicios van como chips y no como otro desplegable: un turno
        // suele llevar más de uno, y el precio se arma sumándolos.
        if (serviciosDisponibles.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Servicios', style: MText.menor),
                const SizedBox(height: 7),
                Wrap(
                  spacing: 7,
                  runSpacing: 7,
                  children: [
                    for (final sv in serviciosDisponibles)
                      _ChipServicio(
                        nombre: sv.nombre,
                        elegido: _servicios.contains(sv.id),
                        onTap: () => setState(() {
                          if (!_servicios.remove(sv.id)) _servicios.add(sv.id);
                          // El precio se autocompleta con la suma, pero se
                          // puede pisar a mano: hay descuentos y combos que la
                          // app no conoce.
                          final total = serviciosDisponibles
                              .where((x) => _servicios.contains(x.id))
                              .fold<num>(0, (a, x) => a + x.precio);
                          _precio.text =
                              total == 0 ? '' : total.round().toString();
                        }),
                      ),
                  ],
                ),
              ],
            ),
          ),
        Row(
          children: [
            Expanded(
              child: _BotonCampo(
                etiqueta: 'Fecha',
                valor: formatDateShort(_fecha),
                onTap: () async {
                  final d = await showDatePicker(
                    context: context,
                    initialDate: _fecha,
                    firstDate: DateTime(DateTime.now().year - 2),
                    lastDate: DateTime(DateTime.now().year + 3),
                  );
                  if (d != null) setState(() => _fecha = d);
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _BotonCampo(
                etiqueta: 'Hora',
                valor: _horaTexto,
                onTap: () async {
                  final h = await showTimePicker(
                    context: context,
                    initialTime: _hora,
                  );
                  if (h != null) setState(() => _hora = h);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        CampoTexto(
          controlador: _precio,
          etiqueta: 'Precio',
          prefijo: r'$ ',
          teclado: const TextInputType.numberWithOptions(decimal: true),
        ),
        CampoTexto(controlador: _notas, etiqueta: 'Notas', lineas: 2),
      ],
    );
  }
}

class _BotonCampo extends StatelessWidget {
  const _BotonCampo({
    required this.etiqueta,
    required this.valor,
    required this.onTap,
  });

  final String etiqueta;
  final String valor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: MColors.bg2,
            borderRadius: BorderRadius.circular(MRadius.lg),
            border: Border.all(color: MColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(etiqueta, style: MText.pie),
              const SizedBox(height: 2),
              Text(valor, style: sans(size: 14, weight: 600)),
            ],
          ),
        ),
      );
}

/// Chip de servicio del formulario de turno. Mismo aire que las `.pill` del
/// original, pero en estado elegido/no elegido.
class _ChipServicio extends StatelessWidget {
  const _ChipServicio({
    required this.nombre,
    required this.elegido,
    required this.onTap,
  });

  final String nombre;
  final bool elegido;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
          decoration: BoxDecoration(
            color: elegido ? MColors.brandBg : MColors.bg2,
            border: Border.all(
              color: elegido ? MColors.borderLav : MColors.border,
            ),
            borderRadius: BorderRadius.circular(MRadius.full),
          ),
          child: Text(
            nombre,
            style: sans(
              size: 12,
              weight: elegido ? 600 : 400,
              color: elegido ? MColors.brand : MColors.tSecondary,
            ),
          ),
        ),
      );
}
