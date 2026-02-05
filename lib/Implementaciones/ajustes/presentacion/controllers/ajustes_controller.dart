import 'dart:convert';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:my_gasolinera/Implementaciones/ajustes/data/services/perfil_service.dart';
import 'package:my_gasolinera/Implementaciones/auth/data/services/auth_service.dart';
import 'package:my_gasolinera/Implementaciones/auth/data/services/usuario_service.dart';
import 'package:my_gasolinera/core/config/config_service.dart';
import 'package:my_gasolinera/core/utils/app_logger.dart';
import 'package:my_gasolinera/core/utils/local_image_service.dart';
import 'package:my_gasolinera/Implementaciones/auth/presentacion/pages/login.dart'; // For navigation in delete
import 'package:flutter/material.dart'; // For BuildContext and SnackBar

class AjustesController {
  final UsuarioService _usuarioService = UsuarioService();
  final PerfilService _perfilService = PerfilService();

  String get emailUsuario => AuthService.getUserEmail() ?? 'usuario@gmail.com';

  Future<String> cargarNombreUsuario() async {
    try {
      final nombre = await _usuarioService.obtenerNombreUsuario();
      AppLogger.info('Nombre de usuario cargado: $nombre',
          tag: 'AjustesScreen');
      return nombre;
    } catch (e) {
      AppLogger.error('Error cargando nombre de usuario',
          tag: 'AjustesScreen', error: e);
      return AuthService.getUserEmail()?.split('@')[0] ?? 'Usuario';
    }
  }

  Future<Uint8List?> cargarFotoPerfilLocal() async {
    try {
      final localBytes =
          await LocalImageService.getImageBytes('perfil', emailUsuario);
      if (localBytes != null) {
        AppLogger.info('Foto de perfil cargada desde almacenamiento local',
            tag: 'AjustesScreen');
      }
      return localBytes;
    } catch (e) {
      AppLogger.error('Error cargando foto local',
          tag: 'AjustesScreen', error: e);
      return null;
    }
  }

  Future<dynamic> cargarFotoPerfilRemota() async {
    try {
      final fotoData = await _usuarioService.cargarImagenPerfil(emailUsuario);
      if (fotoData == null) return null;

      if (fotoData.startsWith('data:image') || fotoData.contains('base64')) {
        final base64String =
            fotoData.contains(',') ? fotoData.split(',')[1] : fotoData;
        return base64Decode(base64String);
      } else if (fotoData.startsWith('http')) {
        return fotoData; // Return URL string
      } else {
        return base64Decode(fotoData);
      }
    } catch (e) {
      AppLogger.error('Error cargando foto remota',
          tag: 'AjustesScreen', error: e);
      return null;
    }
  }

  Future<bool> subirFotoPerfil(XFile file) async {
    AppLogger.info('Subiendo foto de perfil...', tag: 'AjustesScreen');
    final exito = await _perfilService.subirFotoPerfil(file);
    if (exito) {
      await LocalImageService.saveImage(file, 'perfil', emailUsuario);
    }
    return exito;
  }

  Future<void> actualzarUrlBackend(BuildContext context) async {
    try {
      await ConfigService.forceRefresh();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('✅ URL actualizada'), backgroundColor: Colors.green),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error: $e')),
      );
      rethrow;
    }
  }

  Future<void> eliminarCuenta(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    try {
      if (emailUsuario.isEmpty) throw Exception('No email found');

      final exito = await _usuarioService.eliminarCuenta(emailUsuario);

      if (exito) {
        await _usuarioService.limpiarDatosUsuario();
        navigator.pop(); // Close dialog
        navigator.pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      navigator.pop(); // Close dialog if open?
      // Actually the dialog calls this, so if we pop here we close the dialog.
      messenger.showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }
}
