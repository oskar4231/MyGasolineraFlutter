import 'package:flutter/material.dart';

ThemeData modoOscuro() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFFFF9350), // Mantenemos semilla pero en oscuro
      brightness: Brightness.dark,
      primary: const Color(0xFFFF9350),
      onPrimary: Colors.black, // Texto negro sobre naranja
      surface: const Color(0xFF1E1E1E), // Gris oscuro para superficies
      onSurface: Colors.white, // Blanco para texto general
    ),
    scaffoldBackgroundColor: const Color(0xFF121212),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E1E1E),
      foregroundColor: Colors.white,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    cardTheme: const CardThemeData(
      color: Color(0xFF2C2C2C),
      elevation: 2,
    ),
  );
}
