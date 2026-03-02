import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:my_gasolinera/core/utils/app_logger.dart';

class LocalImageService {
  static const int _xorKey = 157; // Clave simple para "encriptar"

  /// Guarda una imagen localmente en el SISTEMA DE ARCHIVOS.
  static Future<String?> saveImage(
      XFile imageFile, String type, String relatedId) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final encryptedBytes = _encryptBytes(bytes);

      String fileName = '';

      if (!kIsWeb) {
        fileName = '${relatedId}_${DateTime.now().millisecondsSinceEpoch}.you';
        final directory = await getApplicationDocumentsDirectory();
        final filePath = p.join(directory.path, fileName);
        final file = File(filePath);
        await file.writeAsBytes(encryptedBytes);

        AppLogger.info('(Nativo) Imagen guardada en Archivo: $filePath');
      } else {
        AppLogger.info(
            '(Web) Guardando imagen directamente en IndexedDB (no implementado)');
        fileName = 'web_blob_${DateTime.now().millisecondsSinceEpoch}';
      }

      return fileName;
    } catch (e) {
      AppLogger.error('Error guardando imagen local',
          tag: 'LocalImageService', error: e);
      return null;
    }
  }

  /// Guarda una imagen localmente desde bytes crudos.
  static Future<String?> saveImageBytes(
      Uint8List bytes, String type, String relatedId) async {
    try {
      final encryptedBytes = _encryptBytes(bytes);
      String fileName = '';

      if (!kIsWeb) {
        fileName = '${relatedId}_${DateTime.now().millisecondsSinceEpoch}.you';
        final directory = await getApplicationDocumentsDirectory();
        final filePath = p.join(directory.path, fileName);
        final file = File(filePath);
        await file.writeAsBytes(encryptedBytes);
      } else {
        fileName = 'web_blob_${DateTime.now().millisecondsSinceEpoch}';
      }

      return fileName;
    } catch (e) {
      AppLogger.error('Error guardando imagen por bytes',
          tag: 'LocalImageService', error: e);
      return null;
    }
  }

  /// Lee una imagen y devuelve los bytes desencriptados.
  static Future<Uint8List?> getImageBytes(String type, String relatedId,
      {String? fileName}) async {
    if (fileName == null || fileName.isEmpty) return null;

    try {
      if (kIsWeb) {
        return null; // Logic required for web
      }

      final directory = await getApplicationDocumentsDirectory();
      final filePath = p.join(directory.path, fileName);
      final file = File(filePath);

      if (await file.exists()) {
        final encryptedBytes = await file.readAsBytes();
        return _encryptBytes(encryptedBytes); // Desencriptar
      }

      return null;
    } catch (e) {
      AppLogger.error('Error leyendo imagen local',
          tag: 'LocalImageService', error: e);
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
