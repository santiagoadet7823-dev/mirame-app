/// Fotos de las prendas: sacar, comprimir, guardar y subir.
///
/// **La compresión no es una optimización, es un requisito.** Una foto de
/// cámara son 3–4 MB. Sin comprimir, el free tier de 1 GB se agota en unas 300
/// fotos y —peor— la vitrina que la clienta abre con datos móviles tarda una
/// eternidad.
///
/// Se guarda en **WebP**, no en JPEG: a 1200 px y calidad 80 la misma foto pasa
/// de ~150 KB a ~50 KB, y la vitrina tiene un techo de un segundo con datos
/// móviles. Es solo Android — este archivo entero usa `dart:io` y no corre en
/// la PWA.
library;

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Bucket de Supabase Storage. Lectura pública: la vitrina la abre gente sin
/// cuenta.
const kBucketProductos = 'productos';

/// Lado mayor de la foto ya comprimida.
///
/// 1200 px es más que suficiente para ver una prenda en un teléfono y para un
/// zoom razonable en la vitrina. Más que eso es peso que nadie mira.
const kLadoMaximo = 1200;
const kCalidad = 80;

/// Saca o elige una foto y la deja comprimida en el teléfono.
///
/// Devuelve la ruta local. **No sube nada**: subir es un paso aparte que puede
/// fallar por falta de señal, y la prenda tiene que quedar cargada igual.
Future<String?> elegirYComprimir({required bool desdeCamara}) async {
  try {
    final x = await ImagePicker().pickImage(
      source: desdeCamara ? ImageSource.camera : ImageSource.gallery,
      // El picker ya reduce al capturar; la compresión de abajo termina el
      // trabajo. Pedirlo acá evita cargar en memoria una imagen de 12 MP.
      maxWidth: kLadoMaximo.toDouble(),
      maxHeight: kLadoMaximo.toDouble(),
      imageQuality: 90,
    );
    if (x == null) return null;

    final dir = await getApplicationDocumentsDirectory();
    final base = '${dir.path}/fotos/${DateTime.now().microsecondsSinceEpoch}';
    await Directory('${dir.path}/fotos').create(recursive: true);

    final comprimida = await FlutterImageCompress.compressAndGetFile(
      x.path,
      '$base.webp',
      quality: kCalidad,
      minWidth: kLadoMaximo,
      minHeight: kLadoMaximo,
      format: CompressFormat.webp,
    );

    // Si la compresión falla (formato raro, poca memoria) se usa el original:
    // una foto pesada es mejor que no poder cargar la prenda.
    //
    // Va con extensión .jpg y no .webp a propósito: el original ES un jpg, y
    // subirlo diciendo que es webp lo dejaría roto en la vitrina.
    if (comprimida == null) {
      final copia = await File(x.path).copy('$base.jpg');
      return copia.path;
    }
    return comprimida.path;
  } catch (e) {
    debugPrint('fotos: no se pudo preparar la imagen ($e)');
    return null;
  }
}

/// Resultado de subir una foto: la URL, o el motivo por el que no se pudo.
///
/// Devolver `null` a secas costó dos días de diagnóstico: un rechazo de
/// permisos y una falta de señal se veían exactamente igual —es decir, no se
/// veían—, porque el error moría en un `debugPrint`. El motivo viaja hasta la
/// pantalla.
typedef ResultadoSubida = ({String? url, String? motivo});

/// Sube una foto ya comprimida y devuelve su URL pública.
///
/// Si no se pudo, `url` viene en null y `motivo` explica por qué. El llamador
/// la deja marcada como pendiente en vez de perder la prenda.
Future<ResultadoSubida> subirFoto({
  required String rutaLocal,
  required String tenantId,
  required String productoId,
}) async {
  try {
    final archivo = File(rutaLocal);
    if (!archivo.existsSync()) {
      return (url: null, motivo: 'el archivo ya no está en el teléfono');
    }

    // La ruta lleva el tenant adelante: es lo que permite borrar todo lo de un
    // salón de una, y lo que evita que dos salones colisionen en un nombre.
    final nombre = rutaLocal.split(Platform.pathSeparator).last;
    final ruta = '$tenantId/$productoId/$nombre';

    // El tipo sale de la extensión y no de una constante: la compresión
    // devuelve webp, pero el camino de respaldo devuelve el jpg original.
    final tipo = nombre.endsWith('.webp') ? 'image/webp' : 'image/jpeg';

    final storage = Supabase.instance.client.storage.from(kBucketProductos);
    await storage.upload(
      ruta,
      archivo,
      fileOptions: FileOptions(
        contentType: tipo,
        // Un año: la ruta lleva un timestamp único, así que el archivo nunca
        // cambia de contenido. Sin esto la vitrina vuelve a bajar las mismas
        // fotos en cada visita.
        cacheControl: '31536000',
        upsert: true,
      ),
    );
    return (url: storage.getPublicUrl(ruta), motivo: null);
  } on StorageException catch (e) {
    debugPrint('fotos: no se pudo subir (${e.statusCode} ${e.message})');
    // 403/401 es la RLS del bucket, no la red. Distinguirlo importa: reintentar
    // no lo arregla nunca, hay que tocar permisos.
    final sinPermiso = e.statusCode == '403' || e.statusCode == '401';
    return (
      url: null,
      motivo: sinPermiso
          ? 'tu usuario no tiene permiso para subir fotos'
          : 'el servidor rechazó la imagen (${e.message})',
    );
  } catch (e) {
    debugPrint('fotos: no se pudo subir ($e)');
    return (url: null, motivo: 'no hay conexión');
  }
}

/// Borra una foto del bucket. Que falle no es grave: un archivo huérfano ocupa
/// lugar, pero perder la operación por eso sí sería un problema.
Future<void> borrarFotoRemota(String url) async {
  try {
    final marca = '/$kBucketProductos/';
    final i = url.indexOf(marca);
    if (i < 0) return;
    final ruta = url.substring(i + marca.length);
    await Supabase.instance.client.storage
        .from(kBucketProductos)
        .remove([ruta]);
  } catch (e) {
    debugPrint('fotos: no se pudo borrar del bucket ($e)');
  }
}
