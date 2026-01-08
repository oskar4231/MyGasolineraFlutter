import 'package:flutter/material.dart';
import 'package:my_gasolinera/Inicio/inicio.dart';
<<<<<<< HEAD
import 'package:my_gasolinera/services/config_service.dart';
import 'package:my_gasolinera/services/background_refresh_service.dart';
import 'package:my_gasolinera/importante/switchWebApk.dart';

import 'package:my_gasolinera/bbdd_intermedia/baseDatos.dart';
import 'package:my_gasolinera/browser_console_helper.dart';

// Instancias globales
late AppDatabase database;
late BackgroundRefreshService backgroundRefreshService;

// Global key para mostrar SnackBars desde cualquier lugar
final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Mostrar modo de plataforma
  print('═══════════════════════════════════════════════════════════');

  print('🔧 MODO PLATAFORMA: ${esAPK ? "📱 APK" : "🌐 WEB"}');
  print('═══════════════════════════════════════════════════════════');

  // Inicializar configuración dinámica del backend
  await ConfigService.initialize();

  // Configurar callback de cambio de URL
  ConfigService.onUrlChanged = () {
    rootScaffoldMessengerKey.currentState?.showSnackBar(
      const SnackBar(
        content: Text('🔄 Conexión actualizada automáticamente'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 4),
      ),
    );
  };

  // Inicializar base de datos (APK o Web según configuración)
  database = AppDatabase();
  print(
      '✅ Base de datos inicializada: ${esAPK ? "SQLite nativo" : "IndexedDB"}');

  // Inicializar servicio de actualización en segundo plano
  backgroundRefreshService = BackgroundRefreshService(database);
  backgroundRefreshService.start();

  // Configurar listener para comandos de consola del navegador
  setupBrowserConsoleListeners();

=======

void main() {
>>>>>>> origin/main
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
<<<<<<< HEAD
      scaffoldMessengerKey: rootScaffoldMessengerKey,
=======
>>>>>>> origin/main
      debugShowCheckedModeBanner: false,
      title: 'MyGasolinera',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const Inicio(),
    );
  }
}
