/// Comparación de versiones semánticas.
library;

/// Compara dos versiones `x.y.z` **segmento por segmento, como números**.
///
/// Devuelve <0 si [a] es anterior a [b], 0 si son equivalentes, >0 si es
/// posterior.
///
/// Comparar como strings es el bug clásico de este mecanismo: `'1.5.9'` sale
/// mayor que `'1.5.42'` porque `'9' > '4'`. Con eso, la flota deja de recibir
/// actualizaciones a partir de la versión 10 de cualquier segmento y nadie se
/// entera hasta que es tarde.
///
/// Tolera distinta cantidad de segmentos (`1.2` == `1.2.0`), espacios, una `v`
/// al principio y sufijos de pre-release (`1.2.3-beta` se compara como
/// `1.2.3`). Un segmento no numérico cuenta como 0: preferimos no ofrecer una
/// actualización a ofrecer una equivocada.
int cmpVer(String a, String b) {
  final sa = _segmentos(a);
  final sb = _segmentos(b);
  final n = sa.length > sb.length ? sa.length : sb.length;
  for (var i = 0; i < n; i++) {
    final x = i < sa.length ? sa[i] : 0;
    final y = i < sb.length ? sb[i] : 0;
    if (x != y) return x < y ? -1 : 1;
  }
  return 0;
}

List<int> _segmentos(String v) {
  var s = v.trim();
  if (s.startsWith('v') || s.startsWith('V')) s = s.substring(1);
  // El build metadata y el pre-release no participan del orden que nos
  // interesa: `1.2.3+45` y `1.2.3-beta` son, para el updater, `1.2.3`.
  final corte = s.indexOf(RegExp(r'[-+]'));
  if (corte >= 0) s = s.substring(0, corte);
  if (s.isEmpty) return const [0];
  return s.split('.').map((p) => int.tryParse(p.trim()) ?? 0).toList();
}

/// ¿La versión instalada quedó por debajo del piso exigido?
///
/// `minVersion` es el **piso**, no "la última". Separarlos permite publicar
/// una versión y recién exigirla cuando se comprobó que anda.
bool debeActualizar({
  required String instalada,
  required String minVersion,
}) =>
    cmpVer(instalada, minVersion) < 0;

/// ¿Hay una versión más nueva disponible, aunque no sea obligatoria?
bool hayNovedad({
  required String instalada,
  required String latestVersion,
}) =>
    cmpVer(instalada, latestVersion) < 0;
