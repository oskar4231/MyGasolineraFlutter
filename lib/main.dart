import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Necesario para el modo oscuro
import 'package:my_gasolinera/Inicio/inicio.dart';
import 'package:my_gasolinera/services/theme_service.dart'; // El archivo del servicio

void main() {
  runApp(
    // Envolvemos la app en el Provider para gestionar el estado del tema
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Obtenemos el estado actual del tema (si es oscuro o claro)
    final themeProvider = Provider.of<ThemeProvider>(context);

    // Definimos tus colores base
    const colorNaranja = Color(0xFFFF9350);
    const colorFondoClaro = Color(0xFFFFE2CE);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MyGasolinera',
      
      // --- TEMA CLARO ---
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(seedColor: colorNaranja),
        primaryColor: colorNaranja,
        scaffoldBackgroundColor: colorFondoClaro,
        cardColor: Colors.white, // <--- Importante para las tarjetas en modo claro
        appBarTheme: const AppBarTheme(
          backgroundColor: colorNaranja,
          iconTheme: IconThemeData(color: Colors.black),
        ),
      ),

      // --- TEMA OSCURO ---
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212), // Negro suave
        primaryColor: const Color(0xFF1F1F1F), // Gris oscuro para barras
        cardColor: const Color(0xFF2C2C2C), // <--- ESTO FALTABA: Color gris para las tarjetas
        
        colorScheme: const ColorScheme.dark(
          primary: Colors.white, // Elementos principales blancos
          secondary: colorNaranja, // Mantenemos naranja para detalles
          surface: Color(0xFF1E1E1E),
        ),
        
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1F1F1F),
          iconTheme: IconThemeData(color: Colors.white), // Iconos blancos
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      // Esto cambia el tema automáticamente según el interruptor
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      
      // Tu pantalla inicial (Login o Inicio)
      home: const Inicio(),
    );
  }
}