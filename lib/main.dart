import 'package:flutter/material.dart';
import 'package:my_gasolinera/Implementaciones/auth/presentacion/pages/inicio.dart';
import 'package:my_gasolinera/core/config/config_service.dart';
import 'package:my_gasolinera/core/utils/background_refresh_service.dart';
import 'package:my_gasolinera/core/config/importante/switch_web_apk.dart';
import 'package:my_gasolinera/core/theme/Modos/Temas/theme_manager.dart';
import 'package:my_gasolinera/core/utils/app_logger.dart';

import 'package:my_gasolinera/core/database/bbdd_intermedia/base_datos.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:my_gasolinera/core/l10n/app_localizations.dart';
import 'package:my_gasolinera/core/providers/language_provider.dart';
import 'package:my_gasolinera/core/providers/font_size_provider.dart';
import 'package:my_gasolinera/Implementaciones/auth/data/services/auth_service.dart';

// Instancias globales
late AppDatabase database;
late BackgroundRefreshService backgroundRefreshService;
final LanguageProvider languageProvider = LanguageProvider();
final FontSizeProvider fontSizeProvider = FontSizeProvider();

// Global key para mostrar SnackBars desde cualquier lugar
final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Mostrar modo de plataforma
  AppLogger.info('═══════════════════════════════════════════════════════════',
      tag: 'Main');
  AppLogger.info('MODO PLATAFORMA: ${esAPK ? "APK" : "WEB"}', tag: 'Main');
  AppLogger.info('═══════════════════════════════════════════════════════════',
      tag: 'Main');

  // Inicializar configuración dinámica del backend
  await ConfigService.initialize();

  // Inicializar base de datos (APK o Web según configuración)
  database = AppDatabase();
  AppLogger.info(
      'Base de datos inicializada: ${esAPK ? "SQLite nativo" : "IndexedDB"}',
      tag: 'Main');

  // Inicializar servicio de actualización en segundo plano
  backgroundRefreshService = BackgroundRefreshService(database);
  backgroundRefreshService.start();

  // Cargar TEMA
  await ThemeManager().loadInitialTheme();

  // Cargar IDIOMA
  await languageProvider.loadInitialLanguage();

  // Cargar TAMAÑO DE FUENTE
  await fontSizeProvider.loadInitialFontSize();

  // Inicializar Auth
  await AuthService.initialize();

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
            return ListenableBuilder(
              listenable: fontSizeProvider,
              builder: (context, _) {
                return MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaler:
                        TextScaler.linear(fontSizeProvider.textScaleFactor),
                  ),
                  child: MaterialApp(
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
                      Locale('fr'), // Frances
                      Locale('en'), // Inglés
                      Locale('de'), // Alleman
                      Locale('pt'), // Portugues
                      Locale('it'), // Italiano
                      Locale('ca'), // Valenciano
                    ],
                    home: const Inicio(),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
