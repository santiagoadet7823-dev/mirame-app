// El punto de entrada existe y se puede armar.
//
// Este archivo existe por un accidente concreto: `lib/main.dart` quedó en **0
// bytes** por un script de edición que abrió el archivo para escritura antes de
// leerlo, y nadie se enteró. `flutter analyze` no dice nada —un archivo Dart
// vacío es válido— y los 392 tests seguían en verde porque **ninguno importaba
// el punto de entrada**. Lo único que fallaba era el build, que en local nadie
// corre y en CI habría tirado la PWA abajo con un "Undefined name 'main'".
//
// Alcanza con importarlo y tocar sus nombres: si `main.dart` vuelve a perder su
// contenido, esto no compila.
import 'package:flutter_test/flutter_test.dart';
import 'package:mirame/main.dart' as app;

void main() {
  test('el punto de entrada expone main y la app', () {
    expect(app.main, isA<Function>());
    expect(const app.MirameApp(), isNotNull);
  });
}
