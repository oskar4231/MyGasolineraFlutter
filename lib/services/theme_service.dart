import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  // Variable privada para guardar el estado
  bool _isDarkMode = false;

  // Getter para que otras clases puedan leer el estado
  bool get isDarkMode => _isDarkMode;

  // Constructor: Carga el tema guardado al iniciar la app
  ThemeProvider() {
    _loadTheme();
  }

  // Cargar tema desde el almacenamiento local
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    // Si no existe el valor, por defecto es false (modo claro)
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    notifyListeners(); // Avisa a la app que el valor ha cambiado
  }

  // Cambiar el tema y guardarlo
  Future<void> toggleTheme(bool isOn) async {
    _isDarkMode = isOn;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isOn);
    notifyListeners(); // Avisa a toda la app para repintar los colores
  }
}