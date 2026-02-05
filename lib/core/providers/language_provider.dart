import 'package:flutter/material.dart';
import 'package:my_gasolinera/Implementaciones/ajustes/data/services/accesibilidad_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_gasolinera/core/utils/app_logger.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _currentLocale = const Locale('es');
  String _languageCode = 'es'; // Código para HTTP header

  Locale get currentLocale => _currentLocale;
  String get languageCode => _languageCode;

  // Mapa de nombres de idioma a códigos ISO
  static const Map<String, String> _languageCodes = {
    'Español': 'es',
    'English': 'en',
    'Français': 'fr',
    'Deutsch': 'de',
    'Português': 'pt',
    'Italiano': 'it',
    'Valenciano': 'ca',
    'Valencià': 'ca', // Variante valenciana
    'Català': 'ca', // Variante catalana
  };

  /// Cambia el idioma por nombre (ej: "English", "Español")
  Future<void> changeLanguage(String idiomaNombre) async {
    String code = 'es'; // Default

    // Buscar coincidencia exacta o parcial
    if (_languageCodes.containsKey(idiomaNombre)) {
      code = _languageCodes[idiomaNombre]!;
    } else {
      // Intentar buscar variantes (ej. English (US))
      for (var key in _languageCodes.keys) {
        if (idiomaNombre.startsWith(key)) {
          code = _languageCodes[key]!;
          break;
        }
      }
    }

    _languageCode = code;
    _currentLocale = Locale(code);

    // Persistir en SharedPreferences
    await _saveLanguagePreference(code);

    notifyListeners();
  }

  /// Establece locale directamente por código (ej: "es", "en")
  Future<void> setLocale(Locale locale) async {
    _currentLocale = locale;
    _languageCode = locale.languageCode;

    // Persistir en SharedPreferences
    await _saveLanguagePreference(_languageCode);

    notifyListeners();
  }

  /// Carga el idioma inicial desde SharedPreferences o AccesibilidadService
  Future<void> loadInitialLanguage() async {
    try {
      // Intentar cargar desde SharedPreferences primero
      final prefs = await SharedPreferences.getInstance();
      final savedLanguage = prefs.getString('app_language');

      if (savedLanguage != null && savedLanguage.isNotEmpty) {
        // Usar idioma guardado localmente
        _languageCode = savedLanguage;
        _currentLocale = Locale(savedLanguage);
        AppLogger.info('Idioma cargado desde SharedPreferences: $savedLanguage',
            tag: 'LanguageProvider');
      } else {
        // Intentar cargar desde AccesibilidadService (backend)
        final config = await AccesibilidadService().obtenerConfiguracion();
        if (config != null && config['idioma'] != null) {
          await changeLanguage(config['idioma']);
          AppLogger.info('Idioma cargado desde backend: ${config['idioma']}',
              tag: 'LanguageProvider');
        } else {
          // Valor por defecto
          await _saveLanguagePreference('es');
          AppLogger.info('Idioma por defecto: es', tag: 'LanguageProvider');
        }
      }

      notifyListeners();
    } catch (e) {
      AppLogger.warning('Error cargando idioma inicial',
          tag: 'LanguageProvider', error: e);
      // Continuar con español por defecto
      _languageCode = 'es';
      _currentLocale = const Locale('es');
    }
  }

  /// Guarda la preferencia de idioma en SharedPreferences
  Future<void> _saveLanguagePreference(String languageCode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('app_language', languageCode);
      AppLogger.debug('Idioma guardado en SharedPreferences: $languageCode',
          tag: 'LanguageProvider');
    } catch (e) {
      AppLogger.error('Error guardando idioma en SharedPreferences',
          tag: 'LanguageProvider', error: e);
    }
  }
}
