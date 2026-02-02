import 'package:flutter/material.dart';
import 'package:my_gasolinera/core/theme/Modos/Temas/predeterminado.dart';
import 'package:my_gasolinera/core/theme/Modos/Temas/modo_oscuro.dart';
import 'package:my_gasolinera/core/theme/Modos/Temas/daltonismo.dart';
import 'package:my_gasolinera/main.dart' as main;

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

  /// Carga el tema inicial desde la base de datos
  Future<void> loadInitialTheme() async {
    try {
      _currentThemeId = await main.database.getThemeId();
      notifyListeners();
      print('🎨 Tema inicial cargado: $_currentThemeId');
    } catch (e) {
      print('❌ Error cargando tema inicial: $e');
    }
  }

  void setObjectTheme(int themeId) {
    if (_currentThemeId != themeId) {
      _currentThemeId = themeId;
      notifyListeners();

      // Persistir en la base de datos
      main.database.saveThemeId(themeId);
    }
  }
}
