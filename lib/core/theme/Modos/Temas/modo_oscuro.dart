import 'package:flutter/material.dart';

class ModoOscuroAccesibilidad {
  // Colores extraídos directamente de tu imagen de referencia
  static const Color fondoPrincipal = Color(0xFF151517); // Gris casi negro
  static const Color fondoTarjeta =
      Color(0xFF212124); // Gris elevado para tarjetas
  static const Color colorBorde = Color(0xFF38383A); // Gris sutil para bordes
  static const Color colorAcento = Color(0xFFFF8235); // Tu naranja vibrante
  static const Color textoPrimario =
      Color(0xFFEBEBEB); // Blanco roto / gris clarito
  static const Color textoInactivo =
      Color(0xFF9E9E9E); // Gris medio para botones inactivos
  static const Color textoSobreNaranja =
      Color(0xFF151517); // Oscuro para legibilidad
}

ThemeData modoOscuro() {
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: ModoOscuroAccesibilidad.fondoPrincipal,
    colorScheme: ColorScheme.fromSeed(
      seedColor: ModoOscuroAccesibilidad.colorAcento,
      brightness: Brightness.dark,
      primary: ModoOscuroAccesibilidad.colorAcento,
      onPrimary: ModoOscuroAccesibilidad
          .textoSobreNaranja, // ¡Clave! Texto oscuro sobre naranja
      surface: ModoOscuroAccesibilidad.fondoTarjeta,
      onSurface: ModoOscuroAccesibilidad.textoPrimario,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: ModoOscuroAccesibilidad.fondoPrincipal,
      foregroundColor: ModoOscuroAccesibilidad.colorAcento,
      elevation: 0, // Plano, sin sombra para un look moderno
      iconTheme: IconThemeData(color: ModoOscuroAccesibilidad.colorAcento),
      titleTextStyle: TextStyle(
        color: ModoOscuroAccesibilidad.colorAcento,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    cardTheme: const CardThemeData(
      color: ModoOscuroAccesibilidad.fondoTarjeta,
      elevation: 0, // En modo oscuro puro se usa el borde, no la sombra
      shape: RoundedRectangleBorder(
        side: BorderSide(color: ModoOscuroAccesibilidad.colorBorde, width: 1),
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: ModoOscuroAccesibilidad.colorAcento,
        foregroundColor:
            ModoOscuroAccesibilidad.textoSobreNaranja, // Texto oscuro
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
              25), // Bordes más redondeados como en tu botón "Guardar"
        ),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: ModoOscuroAccesibilidad.textoPrimario,
      ),
    ),
  );
}
