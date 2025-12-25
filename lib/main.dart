import 'package:flutter/material.dart';
import 'package:my_gasolinera/Inicio/inicio.dart';
import 'package:my_gasolinera/services/config_service.dart';
import 'package:my_gasolinera/services/background_refresh_service.dart';
import 'package:my_gasolinera/importante/switchWebApk.dart';

// Importación condicional según plataforma
import 'package:my_gasolinera/bbdd_intermedia/ParaApk/baseDatosApk.dart'
    if (dart.library.html) 'package:my_gasolinera/bbdd_intermedia/ParaWeb/baseDatosWeb.dart';

// Instancias globales
late AppDatabase database;
late BackgroundRefreshService backgroundRefreshService;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Mostrar modo de plataforma
  print('═══════════════════════════════════════════════════════════');
  print('🔧 MODO PLATAFORMA: ${esAPK ? "📱 APK" : "🌐 WEB"}');
  print('═══════════════════════════════════════════════════════════');

  // Inicializar configuración dinámica del backend
  await ConfigService.initialize();

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
      debugShowCheckedModeBanner: false,
      title: 'MyGasolinera',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const Inicio(),
    );
  }
}
