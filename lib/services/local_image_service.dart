import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:drift/drift.dart' as drift;
import 'package:flutter/foundation.dart' show kIsWeb; // Add this import
import 'package:image_picker/image_picker.dart';
import 'package:my_gasolinera/main.dart';
import 'package:my_gasolinera/bbdd_intermedia/baseDatos.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class LocalImageService {
  static const int _xorKey = 157; // Clave simple para "encriptar"

  /// Guarda una imagen localmente en el SISTEMA DE ARCHIVOS y registra la referencia en la BD.
  /// Los datos binarios ya NO se guardan en la BD para optimizar RAM y rendimiento (Solo APK).
  /// EN WEB: Se guardan en la BD (IndexedDB) porque no hay FileSystem persistente directo.
  static Future<String?> saveImage(
      XFile imageFile, String type, String relatedId) async {
    // Normalizar ID
    final normalizedId = relatedId.trim();
    try {
      final bytes = await imageFile.readAsBytes();
      final encryptedBytes = _encryptBytes(bytes);

      String fileName = '';

      // LOGICA NATIVA (APK/iOS): Guardar en FileSystem
      if (!kIsWeb) {
        // Usar un nombre de archivo único
        fileName = '${relatedId}_${DateTime.now().millisecondsSinceEpoch}.you';

        // Obtener directorio de documentos de la app
        final directory = await getApplicationDocumentsDirectory();
        final filePath = p.join(directory.path, fileName);

        // Escribir bytes encriptados al archivo
        final file = File(filePath);
        await file.writeAsBytes(encryptedBytes);

        print('📁 (Nativo) Imagen guardada en Archivo: $filePath');
      } else {
        print('🌐 (Web) Guardando imagen directamente en IndexedDB (BLOB)');
        fileName = 'web_blob_${DateTime.now().millisecondsSinceEpoch}';
      }

      // Guardar referencia en DB
      // En Web guardamos el contenido (BLOB)
      // En Nativo guardamos contenido VACIO para ahorrar espacio
      await database.insertLocalImage(LocalImagesTableCompanion(
        imageType: drift.Value(type),
        relatedId: drift.Value(normalizedId),
        localPath: drift.Value(fileName), // Guardamos solo el nombre
        content: drift.Value(kIsWeb
            ? encryptedBytes
            : Uint8List(0)), // Web: Full Blob, Nativo: Empty
        createdAt: drift.Value(DateTime.now()),
      ));

      print('🔐 Referencia guardada en BD ($type / $relatedId)');
      return fileName;
    } catch (e) {
      // ignore: avoid_print
      print('❌ Error guardando imagen local: $e');
      return null;
    }
  }

  /// Lee una imagen y devuelve el ARCHIVO desencriptado temporalmente o bytes.
  /// Para optimización, intentamos devolver bytes y dejar que ResizeImage haga el trabajo,
  /// o si usamos FileImage, necesitamos un archivo desencriptado.
  ///
  /// Estrategia optimizada de memoria:
  /// Leemos el archivo encriptado -> Desencriptamos en RAM -> Widget usa ResizeImage
  static Future<Uint8List?> getImageBytes(String type, String relatedId) async {
    // Normalizar ID para evitar errores de espacios
    final normalizedId = relatedId.trim();
    try {
      final record = await database.getLocalImage(type, normalizedId);

      if (record == null) {
        return null;
      }

      // 1. WEB: Cargar directamente del BLOB
      if (kIsWeb) {
        if (record.content.isNotEmpty) {
          return _encryptBytes(record.content); // Desencriptar
        }
        return null;
      }

      // 2. NATIVO: Intentar cargar desde File System
      if (record.localPath != null && record.localPath!.isNotEmpty) {
        final directory = await getApplicationDocumentsDirectory();
        final filePath = p.join(directory.path, record.localPath!);
        final file = File(filePath);

        if (await file.exists()) {
          final encryptedBytes = await file.readAsBytes();
          return _encryptBytes(encryptedBytes); // Desencriptar
        }
      }

      // 3. Fallback Nativo (Migración): Cargar desde BD si existe
      if (record.content.isNotEmpty) {
        print('⚠️ Migrando imagen legacy a FileSystem: $relatedId');
        // Migramos 'al vuelo' para limpiar la DB poco a poco
        final decryptedBytes = _encryptBytes(record.content);
        await _migrateSingleImage(record, record.content);
        return decryptedBytes;
      }

      return null;
    } catch (e) {
      print('Error leyendo imagen local: $e');
      return null;
    }
  }

  /// Migración interna: Mueve BLOB de DB a Archivo y limpia la columna BLOB
  static Future<void> _migrateSingleImage(
      dynamic record, Uint8List encryptedContent) async {
    if (kIsWeb) return; // No migrar en web

    try {
      final directory = await getApplicationDocumentsDirectory();
      // Si no tiene path, generamos uno
      String fileName = record.localPath;
      if (fileName.isEmpty) {
        fileName =
            '${record.relatedId}_${DateTime.now().millisecondsSinceEpoch}.you';
      }

      final filePath = p.join(directory.path, fileName);
      final file = File(filePath);

      // Guardar en disco
      await file.writeAsBytes(encryptedContent);

      // Actualizar DB (Pendiente de implementación robusta de update)
    } catch (e) {
      print('Error migrando imagen: $e');
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
