import 'package:flutter/material.dart';

// Protanopia (Rojo-Verde) - Evitar rojos/verdes, usar azules/amarillos fuertes
ThemeData modoDaltonicoProtanopia() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: const Color(0xFFE6F0FF), // Azul muy claro
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
    ),
    cardTheme: const CardThemeData(
      color: Color(0xFFCCE0FF),
    ),
  );
}

// Deuteranopia (Rojo-Verde) - Similar al Protanopia
ThemeData modoDaltonicoDeuteranopia() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.amber,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: const Color(0xFFFFF8E1), // Amarillo muy claro
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.amber,
      foregroundColor: Colors.black,
    ),
    cardTheme: const CardThemeData(
      color: Color(0xFFFFECB3),
    ),
  );
}

// Tritanopia (Azul-Amarillo) - Usar Rojos/Cian
ThemeData modoDaltonicoTritanopia() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.teal,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: const Color(0xFFE0F2F1), // Cian claro
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.teal,
      foregroundColor: Colors.white,
    ),
    cardTheme: const CardThemeData(
      color: Color(0xFFB2DFDB),
    ),
  );
}

// Achromatopsia (Escala de Grises)
ThemeData modoDaltonicoAchromatopsia() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.light(
      primary: Colors.black,
      secondary: Colors.grey,
      surface: Colors.white,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: Colors.black,
    ),
    scaffoldBackgroundColor: const Color(0xFFE0E0E0),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
    ),
    cardTheme: const CardThemeData(
      color: Colors.white,
    ),
  );
}
