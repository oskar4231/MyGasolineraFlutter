import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_gasolinera/Implementaciones/auth/data/services/auth_service.dart';
import 'package:my_gasolinera/core/config/api_config.dart';
import 'package:my_gasolinera/core/utils/http_helper.dart';
import 'package:my_gasolinera/core/utils/app_logger.dart';

class AccesibilidadService {
  /// Guarda las configuraciones de accesibilidad en el backend
  Future<bool> guardarConfiguracion({
    required String tamanoFuente,
    required bool altoContraste,
    required bool modoOscuro,
    required String idioma,
    double? tamanoFuentePersonalizado,
  }) async {
    try {
      // Obtener email del usuario
      final email = AuthService.getUserEmail();
      if (email == null || email.isEmpty) {
        throw Exception('Usuario no autenticado');
      }

      // Obtener token si existe
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('authToken') ?? '';

      final url = ApiConfig.accesibilidadUrl;
      AppLogger.debug('Guardando configuración de accesibilidad',
          tag: 'AccesibilidadService');
      AppLogger.debug('URL: $url', tag: 'AccesibilidadService');

      final body = {
        'email': email,
        'tamanoFuente': tamanoFuente,
        'altoContraste': altoContraste,
        'modoOscuro': modoOscuro,
        'idioma': idioma,
        if (tamanoFuentePersonalizado != null)
          'tamanoFuentePersonalizado': tamanoFuentePersonalizado,
      };

      AppLogger.debug('Body: ${jsonEncode(body)}', tag: 'AccesibilidadService');

      final response = await http
          .post(
            Uri.parse(url),
            headers: {
              ...HttpHelper.getLanguageHeaders(),
              ...ApiConfig.headers,
              if (token.isNotEmpty) 'Authorization': 'Bearer $token',
            },
            body: jsonEncode(body),
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () =>
                throw Exception('Timeout al conectar con el servidor'),
          );

      AppLogger.debug('Status code: ${response.statusCode}',
          tag: 'AccesibilidadService');
      AppLogger.debug('Response body: ${response.body}',
          tag: 'AccesibilidadService');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);

        // Guardar localmente también
        await _guardarConfiguracionLocal(
          tamanoFuente: tamanoFuente,
          altoContraste: altoContraste,
          modoOscuro: modoOscuro,
          idioma: idioma,
          tamanoFuentePersonalizado: tamanoFuentePersonalizado,
        );

        return data['success'] == true || response.statusCode == 201;
      } else {
        throw Exception(
          'Error al guardar configuración: ${response.statusCode}',
        );
      }
    } on Exception catch (e) {
      AppLogger.error('Error guardando en backend',
          tag: 'AccesibilidadService', error: e);
      // Fallback: Guardar localmente para que la UX no se rompa
      try {
        await _guardarConfiguracionLocal(
          tamanoFuente: tamanoFuente,
          altoContraste: altoContraste,
          modoOscuro: modoOscuro,
          idioma: idioma,
          tamanoFuentePersonalizado: tamanoFuentePersonalizado,
        );
        AppLogger.info('Configuración guardada localmente (modo offline/error)',
            tag: 'AccesibilidadService');
        return true; // Consideramos éxito parcial para la UI
      } catch (localError) {
        AppLogger.error('Error guardando localmente',
            tag: 'AccesibilidadService', error: localError);
        rethrow;
      }
    }
  }

  /// Obtiene las configuraciones de accesibilidad del backend
  Future<Map<String, dynamic>?> obtenerConfiguracion() async {
    try {
      // Obtener email del usuario
      final email = AuthService.getUserEmail();
      if (email == null || email.isEmpty) {
        throw Exception('Usuario no autenticado');
      }

      // Obtener token si existe
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('authToken') ?? '';

      final url = '${ApiConfig.accesibilidadUrl}/$email';
      AppLogger.debug('Obteniendo configuración de accesibilidad',
          tag: 'AccesibilidadService');
      AppLogger.debug('URL: $url', tag: 'AccesibilidadService');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          ...HttpHelper.getLanguageHeaders(),
          ...ApiConfig.headers,
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Timeout al conectar con el servidor'),
      );

      AppLogger.debug('Status code: ${response.statusCode}',
          tag: 'AccesibilidadService');
      AppLogger.debug('Response body: ${response.body}',
          tag: 'AccesibilidadService');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Guardar localmente para uso offline
        if (data['configuracion'] != null) {
          final config = data['configuracion'];
          await _guardarConfiguracionLocal(
            tamanoFuente: config['tamanoFuente'] ?? 'Mediano',
            altoContraste: config['altoContraste'] ?? false,
            modoOscuro: config['modoOscuro'] ?? false,
            idioma: config['idioma'] ?? 'Español',
            tamanoFuentePersonalizado:
                config['tamanoFuentePersonalizado']?.toDouble(),
          );
        }

        return data['configuracion'];
      } else if (response.statusCode == 404) {
        // No hay configuración guardada, usar valores por defecto
        AppLogger.info(
            'No hay configuración guardada, usando valores por defecto',
            tag: 'AccesibilidadService');
        return null;
      } else {
        throw Exception(
          'Error al obtener configuración: ${response.statusCode}',
        );
      }
    } on Exception catch (e) {
      AppLogger.error('Error obteniendo configuración de accesibilidad',
          tag: 'AccesibilidadService', error: e);
      // Intentar cargar configuración local como fallback
      return await _obtenerConfiguracionLocal();
    }
  }

  /// Guarda la configuración localmente en SharedPreferences
  Future<void> _guardarConfiguracionLocal({
    required String tamanoFuente,
    required bool altoContraste,
    required bool modoOscuro,
    required String idioma,
    double? tamanoFuentePersonalizado,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('accesibilidad_tamanoFuente', tamanoFuente);
    await prefs.setBool('accesibilidad_altoContraste', altoContraste);
    await prefs.setBool('accesibilidad_modoOscuro', modoOscuro);
    await prefs.setString('accesibilidad_idioma', idioma);
    if (tamanoFuentePersonalizado != null) {
      await prefs.setDouble(
        'accesibilidad_tamanoFuentePersonalizado',
        tamanoFuentePersonalizado,
      );
    }
    AppLogger.debug('Configuración guardada localmente',
        tag: 'AccesibilidadService');
  }

  /// Obtiene la configuración local de SharedPreferences
  Future<Map<String, dynamic>?> _obtenerConfiguracionLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final tamanoFuente = prefs.getString('accesibilidad_tamanoFuente');
      if (tamanoFuente == null) {
        return null; // No hay configuración local
      }

      return {
        'tamanoFuente': tamanoFuente,
        'altoContraste': prefs.getBool('accesibilidad_altoContraste') ?? false,
        'modoOscuro': prefs.getBool('accesibilidad_modoOscuro') ?? false,
        'idioma': prefs.getString('accesibilidad_idioma') ?? 'Español',
        'tamanoFuentePersonalizado': prefs.getDouble(
          'accesibilidad_tamanoFuentePersonalizado',
        ),
      };
    } catch (e) {
      AppLogger.error('Error obteniendo configuración local',
          tag: 'AccesibilidadService', error: e);
      return null;
    }
  }

  /// Limpia la configuración local
  Future<void> limpiarConfiguracionLocal() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('accesibilidad_tamanoFuente');
    await prefs.remove('accesibilidad_altoContraste');
    await prefs.remove('accesibilidad_modoOscuro');
    await prefs.remove('accesibilidad_idioma');
    AppLogger.debug('Configuración local limpiada',
        tag: 'AccesibilidadService');
  }
}
