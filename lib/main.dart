import 'package:flutter/material.dart';
import 'package:my_gasolinera/Inicio/inicio.dart';
import 'package:my_gasolinera/services/config_service.dart';
import 'package:my_gasolinera/services/background_refresh_service.dart';
import 'package:my_gasolinera/importante/switchWebApk.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:my_gasolinera/bbdd_intermedia/baseDatos.dart';

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

  // 🔥 TEMPORAL: Forzar limpieza de caché de URL para obtener versión fresca
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('backend_url');
  await prefs.remove('last_url_fetch');
  print('🔥 Caché de URL limpiado - obteniendo URL fresca del Gist...');

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

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: rootScaffoldMessengerKey,
      debugShowCheckedModeBanner: false,
      title: 'MyGasolinera',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const Inicio(),
    );
  }
}
