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
        scaffoldBackgroundColor: colorFondoClaro,
        primaryColor: colorNaranja,
        cardColor: Colors.white,
        colorScheme: const ColorScheme.light(
          primary: colorNaranja,
          onPrimary: Colors.white,
          secondary: colorNaranja,
          onSecondary: Colors.white,
          surface: Colors.white,
          onSurface: Colors.black,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: colorNaranja,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.black),
          bodyMedium: TextStyle(color: Colors.black),
        ),
      ),

      // --- TEMA OSCURO ---
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        primaryColor: const Color(0xFF1F1F1F),
        cardColor: const Color(0xFF2C2C2C),
        colorScheme: const ColorScheme.dark(
          primary: Colors.white,
          onPrimary: Colors.black,
          secondary: colorNaranja,
          onSecondary: Colors.white,
          surface: Color(0xFF1E1E1E),
          onSurface: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1F1F1F),
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white),
        ),
      ),

      // Esto cambia el tema automáticamente según el interruptor
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,

      // Tu pantalla inicial (Login o Inicio)
      home: const Inicio(),
    );
  }
}
