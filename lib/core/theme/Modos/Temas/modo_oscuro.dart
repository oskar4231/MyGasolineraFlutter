import 'package:flutter/material.dart';

ThemeData modoOscuro() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFFFF9350),
      brightness: Brightness.dark,
      primary: const Color(0xFFFF9350), // Intacto
      onPrimary:
          const Color(0xFFFFE8DA), // Crema para texto sobre botones naranjas
      surface: const Color(0xFF241A14), // Espresso
      onSurface: const Color(0xFFFFE8DA), // Crema original del modo claro
    ),
    scaffoldBackgroundColor: const Color(0xFF140F0B), // Choco-Negro
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF140F0B), // Oscuro
      foregroundColor: Color(0xFFFF9350), // Naranja
      iconTheme: IconThemeData(color: Color(0xFFFF9350)), // Naranja
      titleTextStyle: TextStyle(
        color: Color(0xFFFF9350), // Naranja
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    cardTheme: const CardThemeData(
      color: Color(0xFF241A14), // Espresso
      elevation: 2,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFFF9350), // Naranja
        foregroundColor: const Color(0xFFFFE8DA), // Texto en crema
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: const Color(0xFFFFE8DA), // Iconos en crema
      ),
    ),
  );
}
