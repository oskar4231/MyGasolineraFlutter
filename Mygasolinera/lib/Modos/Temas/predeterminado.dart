import 'package:flutter/material.dart';

ThemeData temaPredeterminado() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFFFF9350), // Naranja original
      brightness: Brightness.light,
      primary: const Color(0xFFFF9350),
      onPrimary:
          const Color(0xFF492714), // Marrón oscuro para texto sobre naranja
      surface:
          const Color(0xFFFFE8DA), // Color crema para fondo de cards/sheets
      onSurface: const Color(0xFF492714), // Marrón oscuro para texto general
    ),
    scaffoldBackgroundColor: const Color(
        0xFFFFE8DA), // Fondo crema general (cambiado de naranja a crema para coincidir con Inicio)
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFFF9350),
      foregroundColor: Colors.black,
      iconTheme: IconThemeData(color: Colors.black),
      titleTextStyle: TextStyle(
        color: Colors.black,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFFFFE8DA), // Color crema de las cards
      elevation: 2,
    ),
    // Definimos colores semánticos extra si es necesario
    extensions: const <ThemeExtension<dynamic>>[],
  );
}
