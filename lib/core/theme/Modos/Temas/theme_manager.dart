import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_gasolinera/core/theme/Modos/Temas/predeterminado.dart';
import 'package:my_gasolinera/core/theme/Modos/Temas/modo_oscuro.dart';
import 'package:my_gasolinera/core/theme/Modos/Temas/daltonismo.dart';
import 'package:my_gasolinera/core/utils/app_logger.dart';

class ThemeManager extends ChangeNotifier {
  static final ThemeManager _instance = ThemeManager._internal();
  factory ThemeManager() => _instance;
  ThemeManager._internal();

  int _currentThemeId = 0;

  int get currentThemeId => _currentThemeId;

  ThemeData get currentTheme {
    switch (_currentThemeId) {
      case 0:
        return temaPredeterminado();
      case 1:
        return modoOscuro();
      case 2:
        return modoDaltonicoProtanopia();
      case 3:
        return modoDaltonicoDeuteranopia();
      case 4:
        return modoDaltonicoTritanopia();
      case 5:
        return modoDaltonicoAchromatopsia();
      default:
        return temaPredeterminado();
    }
  }

  /// Carga el tema inicial desde la base de datos (SharedPreferences)
  Future<void> loadInitialTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _currentThemeId = prefs.getInt('theme_id') ?? 0;
      notifyListeners();
      AppLogger.info('Tema inicial cargado: $_currentThemeId',
          tag: 'ThemeManager');
    } catch (e) {
      AppLogger.error('Error cargando tema inicial',
          tag: 'ThemeManager', error: e);
    }
  }

  void setObjectTheme(int themeId) async {
    if (_currentThemeId != themeId) {
      _currentThemeId = themeId;
      notifyListeners();

      // Persistir en la base de datos (SharedPreferences)
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('theme_id', themeId);
    }
  }
}
