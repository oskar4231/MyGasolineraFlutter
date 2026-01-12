import 'dart:async';
import 'dart:typed_data';
import 'package:drift/drift.dart' as drift;
import 'package:image_picker/image_picker.dart';
import 'package:my_gasolinera/main.dart';
import 'package:my_gasolinera/bbdd_intermedia/baseDatos.dart';

class LocalImageService {
  static const int _xorKey = 157; // Clave simple para "encriptar"

  /// Guarda una imagen localmente en la base de datos (Drift) encriptada
  /// Compatible con Web y Nativo (sin usar dart:io/FileSystem)
  static Future<String?> saveImage(
      XFile imageFile, String type, String relatedId) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final encryptedBytes = _encryptBytes(bytes);

      // Usar un "path" virtual para referencia
      final fileName =
          '${relatedId}_${DateTime.now().millisecondsSinceEpoch}.you';

      // Guardar en DB
      // NOTA: Como modificamos la tabla para incluir 'content', debemos pasar los bytes aquí.
      // Drift genera el companion con el campo 'content'.

      // Verificamos si ya existe para actualizar o insertar nuevo (aunque insertLocalImage hace insert siempre)
      // Para simplificar, insertamos uno nuevo.

      await database.insertLocalImage(LocalImagesTableCompanion(
        imageType: drift.Value(type),
        relatedId: drift.Value(relatedId),
        localPath: drift.Value(fileName),
        content: drift.Value(encryptedBytes), // Guardamos BLOB
        createdAt: drift.Value(DateTime.now()),
      ));

      print('🔐 Imagen guardada en BD encriptada ($type / $relatedId)');
      return fileName;
    } catch (e) {
      // ignore: avoid_print
      print('❌ Error guardando imagen local: $e');
      return null;
    }
  }

  /// Lee una imagen encriptada desde la BD y devuelve los bytes desencriptados
  static Future<Uint8List?> getImageBytes(String type, String relatedId) async {
    try {
      // Buscar en BD
      print('🔍 Buscando imagen local (type: $type, id: $relatedId)...');
      final record = await database.getLocalImage(type, relatedId);

      if (record == null) {
        print(
            '⚠️ No se encontró registro en BD local para: $type / $relatedId');
        return null;
      }

      print(
          '✅ Registro encontrado. ID: ${record.id}, ContentSize: ${record.content.length} bytes');

      // Si tenemos contenido en blob (nueva versión)
      // Drift devuelve Uint8List para BlobColumn
      return _encryptBytes(record.content); // XOR es simétrico

      // Fallback para versión antigua (si existiera lógica de archivo, pero la hemos eliminado para compatibilidad Web)
      // Si la columna content está vacía, no podemos recuperar la imagen en Web si dependía de FileSystem.
      return null;
    } catch (e) {
      // ignore: avoid_print
      print('Error leyendo imagen local: $e');
      return null;
    }
  }

  static Uint8List _encryptBytes(Uint8List bytes) {
    final result = Uint8List(bytes.length);
    for (int i = 0; i < bytes.length; i++) {
      result[i] = bytes[i] ^ _xorKey;
    }
    return result;
  }
}
