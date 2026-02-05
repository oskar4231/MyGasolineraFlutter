import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_gasolinera/Implementaciones/ajustes/data/services/accesibilidad_service.dart';
import 'package:my_gasolinera/core/utils/app_logger.dart';

class FontSizeProvider extends ChangeNotifier {
  double _textScaleFactor = 1.0;
  String _currentSizePreset = 'Mediano';
  double _customFontSize = 16.0;

  double get textScaleFactor => _textScaleFactor;
  String get currentSizePreset => _currentSizePreset;
  double get customFontSize => _customFontSize;

  /// Convierte el preset de tamaño a un factor de escala
  static double _presetToScaleFactor(String preset) {
    switch (preset) {
      case 'Pequeño':
        return 0.75;
      case 'Mediano':
        return 1.0;
      case 'Grande':
        return 1.25;
      default:
        return 1.0;
    }
  }

  /// Convierte un tamaño personalizado a factor de escala (base 16px)
  static double _customSizeToScaleFactor(double size) {
    return size / 16.0;
  }

  /// Cambia el tamaño de fuente por preset
  Future<void> changeFontSizeByPreset(String preset) async {
    _currentSizePreset = preset;

    if (preset == 'Personalizada') {
      _textScaleFactor = _customSizeToScaleFactor(_customFontSize);
    } else {
      _textScaleFactor = _presetToScaleFactor(preset);
    }

    await _savePreference('preset', preset);
    notifyListeners();
  }

  /// Cambia el tamaño de fuente personalizado
  Future<void> changeFontSizeCustom(double size) async {
    _customFontSize = size;
    _currentSizePreset = 'Personalizada';
    _textScaleFactor = _customSizeToScaleFactor(size);

    await _savePreference('preset', 'Personalizada');
    await _savePreference('customSize', size.toString());
    notifyListeners();
  }

  /// Carga la configuración inicial
  Future<void> loadInitialFontSize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedPreset = prefs.getString('font_size_preset');
      final savedCustomSize = prefs.getString('font_size_custom');

      if (savedPreset != null) {
        _currentSizePreset = savedPreset;

        if (savedPreset == 'Personalizada' && savedCustomSize != null) {
          _customFontSize = double.tryParse(savedCustomSize) ?? 16.0;
          _textScaleFactor = _customSizeToScaleFactor(_customFontSize);
        } else {
          _textScaleFactor = _presetToScaleFactor(savedPreset);
        }

        AppLogger.info(
            'Tamaño de fuente cargado: $_currentSizePreset (factor: $_textScaleFactor)',
            tag: 'FontSizeProvider');
      } else {
        // Intentar cargar desde AccesibilidadService
        final config = await AccesibilidadService().obtenerConfiguracion();
        if (config != null && config['tamanoFuente'] != null) {
          await changeFontSizeByPreset(config['tamanoFuente']);

          if (config['tamanoFuente'] == 'Personalizada' &&
              config['tamanoFuentePersonalizado'] != null) {
            await changeFontSizeCustom(
                config['tamanoFuentePersonalizado'].toDouble());
          }

          AppLogger.info('Tamaño de fuente cargado desde backend',
              tag: 'FontSizeProvider');
        }
      }

      notifyListeners();
    } catch (e) {
      AppLogger.warning('Error cargando tamaño de fuente',
          tag: 'FontSizeProvider', error: e);
      // Continuar con valores por defecto
      _textScaleFactor = 1.0;
      _currentSizePreset = 'Mediano';
    }
  }

  /// Guarda la preferencia en SharedPreferences
  Future<void> _savePreference(String key, String value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('font_size_$key', value);
      AppLogger.debug('Tamaño de fuente guardado: $key = $value',
          tag: 'FontSizeProvider');
    } catch (e) {
      AppLogger.error('Error guardando tamaño de fuente',
          tag: 'FontSizeProvider', error: e);
    }
  }
}
