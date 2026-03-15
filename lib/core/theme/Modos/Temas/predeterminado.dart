import 'package:flutter/material.dart';

ThemeData temaPredeterminado() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFFFF9350),
      brightness: Brightness.light,

      // — Principal —
      primary: const Color(0xFFFF9350),
      onPrimary:
          const Color(0xFF2D1509), // Marrón muy oscuro (reemplaza negro puro)
      primaryContainer:
          const Color(0xFFFFC285), // Naranja claro para containers
      onPrimaryContainer: const Color(0xFF2D1509),

      // — Secundario (naranja oscuro) —
      secondary: const Color(0xFFE07030),
      onSecondary: const Color(0xFFFFFFFF),
      secondaryContainer: const Color(0xFFFFD5BC),
      onSecondaryContainer: const Color(0xFF2D1509),

      // — Superficie con jerarquía —
      surface: const Color(0xFFFFE8DA), // Cards nivel 1
      onSurface: const Color(0xFF2D1509), // Texto primario
      surfaceContainerLow: const Color(0xFFFFF8F2), // Scaffold (fondo)
      surfaceContainerHigh: const Color(0xFFFFD5BC), // Elevated / Bottom sheets
      onSurfaceVariant: const Color(0xFF7A4020), // Texto secundario/muted

      // — Semánticos —
      error: const Color(0xFFD63B1F),
      onError: const Color(0xFFFFFFFF),
      errorContainer: const Color(0xFFFFDAD4),
      onErrorContainer: const Color(0xFF5C1308),

      // — Outline —
      outline: const Color(0xFFC08060), // Borders/dividers cálidos
      outlineVariant: const Color(0xFFFFD5BC), // Borders sutiles
    ),

    scaffoldBackgroundColor:
        const Color(0xFFFFF8F2), // Surface 0 — fondo más limpio

    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFFF9350),
      foregroundColor:
          Color(0xFF2D1509), // Marrón oscuro — eliminamos el negro puro
      iconTheme: IconThemeData(color: Color(0xFF2D1509)),
      titleTextStyle: TextStyle(
        color: Color(0xFF2D1509),
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),

    cardTheme: const CardThemeData(
      color: Color(0xFFFFE8DA), // Surface 1
      elevation: 0, // Sin sombra — el borde diferencia la card del fondo
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        side: BorderSide(
            color: Color(0x1A2D1509), width: 0.5), // Borde sutil cálido
      ),
    ),

    navigationBarTheme: const NavigationBarThemeData(
      backgroundColor: Color(0xFFFF9350),
      indicatorColor: Color(0xFFFFD5BC),
      iconTheme: WidgetStatePropertyAll(
        IconThemeData(color: Color(0xFF2D1509)),
      ),
      labelTextStyle: WidgetStatePropertyAll(
        TextStyle(
          color: Color(0xFF2D1509),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFFFF9350),
      selectedItemColor: Color(0xFF2D1509),
      unselectedItemColor: Color(0xFF7A4020),
    ),

    textTheme: const TextTheme(
      titleLarge:
          TextStyle(color: Color(0xFF2D1509), fontWeight: FontWeight.w600),
      titleMedium:
          TextStyle(color: Color(0xFF2D1509), fontWeight: FontWeight.w500),
      bodyLarge: TextStyle(color: Color(0xFF2D1509)),
      bodyMedium: TextStyle(color: Color(0xFF7A4020)), // Texto secundario
      bodySmall: TextStyle(color: Color(0xFFC08060)), // Texto disabled/hints
      labelLarge:
          TextStyle(color: Color(0xFF2D1509), fontWeight: FontWeight.w500),
    ),

    extensions: const <ThemeExtension<dynamic>>[],
  );
}

// — Colores semánticos de conveniencia —
// Úsalos en la app con MyGasolineraColors.success, etc.
abstract final class MyGasolineraColors {
  // Principales
  static const primary = Color(0xFFFF9350);
  static const onPrimary = Color(0xFF2D1509);
  static const primaryContainer = Color(0xFFFFC285);
  static const onPrimaryContainer = Color(0xFF2D1509);

  // Secundarios
  static const secondary = Color(0xFFE07030);
  static const onSecondary = Color(0xFFFFFFFF);
  static const secondaryContainer = Color(0xFFFFD5BC);
  static const onSecondaryContainer = Color(0xFF2D1509);

  // Textos y estados
  static const textPrimary = Color(0xFF2D1509);
  static const textSecondary = Color(0xFF7A4020);
  static const textDisabled = Color(0xFFC08060);

  // Semánticos
  static const success = Color(0xFF3D7A52);
  static const onSuccess = Color(0xFFFFFFFF);
  static const successContainer = Color(0xFFB7F0CE);

  static const warning = Color(0xFFF0A500);
  static const onWarning = Color(0xFF2D1509);
  static const warningContainer = Color(0xFFFFEAB0);

  static const error = Color(0xFFD63B1F);
  static const onError = Color(0xFFFFFFFF);
  static const errorContainer = Color(0xFFFFDAD4);

  // Bordes
  static const outline = Color(0xFFC08060);
  static const outlineVariant = Color(0xFFFFD5BC);
}
