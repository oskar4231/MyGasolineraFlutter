import 'package:flutter/material.dart';
import 'package:my_gasolinera/Inicio/inicio.dart';
import 'package:my_gasolinera/services/config_service.dart';
import 'package:my_gasolinera/services/background_refresh_service.dart';
import 'package:my_gasolinera/importante/switchWebApk.dart';
import 'package:my_gasolinera/Modos/Temas/theme_manager.dart';

import 'package:my_gasolinera/bbdd_intermedia/baseDatos.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:my_gasolinera/l10n/app_localizations.dart';
import 'package:my_gasolinera/providers/language_provider.dart';

// Instancias globales
late AppDatabase database;
late BackgroundRefreshService backgroundRefreshService;
final LanguageProvider languageProvider = LanguageProvider();

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

  // Inicializar base de datos (APK o Web según configuración)
  database = AppDatabase();
  print(
      '✅ Base de datos inicializada: ${esAPK ? "SQLite nativo" : "IndexedDB"}');

  // Inicializar servicio de actualización en segundo plano
  backgroundRefreshService = BackgroundRefreshService(database);
  backgroundRefreshService.start();

  // Cargar TEMA
  await ThemeManager().loadInitialTheme();

  // Cargar IDIOMA
  await languageProvider.loadInitialLanguage();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeManager(),
      builder: (context, _) {
        return ListenableBuilder(
          listenable: languageProvider,
          builder: (context, _) {
            return MaterialApp(
              scaffoldMessengerKey: rootScaffoldMessengerKey,
              debugShowCheckedModeBanner: false,
              title: 'MyGasolinera',
              theme: ThemeManager().currentTheme,
              locale: languageProvider.currentLocale,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [
                Locale('es'), // Español
                Locale('en'), // Inglés
              ],
              home: const Inicio(),
            );
          },
        );
      },
    );
  }
}
