/// Formato y helpers de presentación, portados del `index.html`.
///
/// Estos son los que más se notan si cambian: la dueña lee estos números todos
/// los días y cualquier diferencia de formato se percibe como un error.
library;

/// Formato de moneda. Puerto de:
///
/// ```js
/// const fc = n => '$' + Number(n||0).toLocaleString('es-AR');
/// ```
///
/// `es-AR` usa el punto como separador de miles y no muestra decimales para
/// enteros. Se implementa a mano en vez de con `intl` para que `domain/` no
/// tenga dependencias y los tests corran sin inicializar locales.
///
/// Los decimales se redondean, igual que `toLocaleString` sin opciones, que
/// muestra hasta 3 decimales pero en la práctica siempre recibe enteros.
String formatMoney(num? n) {
  final v = n ?? 0;
  final entero = v.round().abs();
  final signo = v.round() < 0 ? '-' : '';
  return '$signo\$${_miles(entero)}';
}

/// Agrupa de a 3 dígitos con punto: `284500` → `'284.500'`.
String _miles(int n) {
  final s = n.toString();
  if (s.length <= 3) return s;
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
    buf.write(s[i]);
  }
  return buf.toString();
}

/// Iniciales para el avatar. Puerto de:
///
/// ```js
/// const ini = n => (n||'?').split(' ').slice(0,2).map(w=>w[0]||'').join('').toUpperCase() || '?';
/// ```
///
/// Toma la primera letra de las dos primeras palabras.
String initials(String? name) {
  final base = (name == null || name.isEmpty) ? '?' : name;
  final palabras = base.split(' ').take(2);
  final out = palabras.map((w) => w.isEmpty ? '' : w[0]).join().toUpperCase();
  return out.isEmpty ? '?' : out;
}

/// Índice de color de avatar, de 0 a 5. Puerto de:
///
/// ```js
/// const avc = s => {
///   const g = ['av-a','av-b','av-c','av-d','av-e','av-f'];
///   let h = 0;
///   for (const c of (s||'A')) h = (h*31 + c.charCodeAt(0)) % g.length;
///   return g[h];
/// };
/// ```
///
/// El módulo se acumula **en cada iteración**, no al final. Reproducir ese
/// detalle es obligatorio: si se calcula el hash completo y recién ahí se toma
/// el módulo, el resultado es distinto y todas las clientas cambian de color
/// respecto de la app que la dueña ya conoce.
///
/// Itera sobre unidades UTF-16 (`codeUnits`), igual que `charCodeAt` en JS, no
/// sobre runes: con nombres acentuados el resultado coincide con el original.
int avatarIndex(String? name) {
  final s = (name == null || name.isEmpty) ? 'A' : name;
  var h = 0;
  for (final c in s.codeUnits) {
    h = (h * 31 + c) % 6;
  }
  return h;
}

/// Etiqueta de fecha corta en es-AR: `'lun, 3 mar'`.
///
/// El original parsea `'YYYY-MM-DD' + 'T12:00:00'` — al mediodía, justamente
/// para que ningún corrimiento de zona horaria mueva el día.
const _diasCortos = ['dom', 'lun', 'mar', 'mié', 'jue', 'vie', 'sáb'];
const _mesesCortos = [
  'ene',
  'feb',
  'mar',
  'abr',
  'may',
  'jun',
  'jul',
  'ago',
  'sep',
  'oct',
  'nov',
  'dic',
];

String formatDateShort(DateTime d) {
  final dia = _diasCortos[d.weekday % 7];
  final mes = _mesesCortos[d.month - 1];
  return '$dia, ${d.day} $mes';
}

const _mesesLargos = [
  'enero',
  'febrero',
  'marzo',
  'abril',
  'mayo',
  'junio',
  'julio',
  'agosto',
  'septiembre',
  'octubre',
  'noviembre',
  'diciembre',
];

String monthName(int month) => _mesesLargos[month - 1];

/// Saludo del dashboard según la hora. Puerto literal de `renderDash`:
/// `<12` mañana, `<18` tarde, si no noche.
String greeting(DateTime now) {
  if (now.hour < 12) return 'Buenos días ✨';
  if (now.hour < 18) return 'Buenas tardes 🌸';
  return 'Buenas noches 🌙';
}

/// `Agosto 2026`. Lo usan el selector de mes de Caja y el de liquidaciones.
///
/// Vive acá y no en una vista porque lo necesitan dos pantallas distintas, y
/// que una importe a la otra las ataría sin razon.
String nombreMes(DateTime d) => '${monthName(d.month)} ${d.year}';
