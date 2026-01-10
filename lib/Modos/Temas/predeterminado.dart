import 'package:flutter/material.dart';

ThemeData temaPredeterminado() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFFFF9350), // Naranja original
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: const Color(0xFFFF9350), // Fondo naranja original
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
