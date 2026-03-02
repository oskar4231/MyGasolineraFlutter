import 'package:flutter/material.dart';
import 'package:my_gasolinera/Implementaciones/auth/presentacion/pages/inicio.dart';
import 'package:my_gasolinera/core/config/config_service.dart';
import 'package:my_gasolinera/core/utils/background_refresh_service.dart';
import 'package:flutter/foundation.dart';
import 'package:my_gasolinera/core/theme/Modos/Temas/theme_manager.dart';
import 'package:my_gasolinera/core/utils/app_logger.dart';

// New Architecture Imports
import 'package:my_gasolinera/core/database/isar_service.dart';
import 'package:my_gasolinera/core/sync/sync_manager.dart';

import 'package:my_gasolinera/Implementaciones/gasolineras/data/services/gasolinera_cache_service.dart';

import 'package:my_gasolinera/core/l10n/app_localizations.dart';
import 'package:my_gasolinera/core/providers/language_provider.dart';
import 'package:my_gasolinera/core/providers/font_size_provider.dart';
import 'package:my_gasolinera/core/providers/filter_provider.dart';
import 'package:my_gasolinera/Implementaciones/auth/data/services/auth_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Instancias globales Isar / Sync
late IsarService isarService;
late SyncManager syncManager;
late GasolinerasCacheService gasolineraCacheService;
late BackgroundRefreshService backgroundRefreshService;

final LanguageProvider languageProvider = LanguageProvider();
final FontSizeProvider fontSizeProvider = FontSizeProvider();
final FilterProvider filterProvider = FilterProvider();

// Global key para mostrar SnackBars desde cualquier lugar
final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Cargar variables de entorno
  await dotenv.load(fileName: ".env");

  final isAPK = !kIsWeb;

  // Mostrar modo de plataforma
  AppLogger.info('═══════════════════════════════════════════════════════════',
      tag: 'Main');
  AppLogger.info('MODO PLATAFORMA: ${isAPK ? "APK/Nativo" : "WEB"}',
      tag: 'Main');
  AppLogger.info('═══════════════════════════════════════════════════════════',
      tag: 'Main');

  // Inicializar configuración dinámica del backend
  await ConfigService.initialize();

  // 1. Inicializar base de datos local (Isar)
  isarService = IsarService();
  await isarService.db; // Esperar a que abra la DB

  AppLogger.info('Base de datos local Isar inicializada', tag: 'Main');

  // 2. Inicializar servicios dependientes
  gasolineraCacheService = GasolinerasCacheService(isarService);
  syncManager = SyncManager(isarService: isarService);

  // 3. Inicializar servicio de background refresh
  backgroundRefreshService = BackgroundRefreshService(syncManager);
  backgroundRefreshService.start();

  // 4. Lanzar sincronización en background en el arranque (si está logueado)
  syncManager.startBackgroundSync();

  // Cargar TEMA
  await ThemeManager().loadInitialTheme();

  // Cargar IDIOMA
  await languageProvider.loadInitialLanguage();

  // Cargar TAMAÑO DE FUENTE
  await fontSizeProvider.loadInitialFontSize();

  // Cargar FILTROS
  await filterProvider.loadInitialFilters();

  // Inicializar Auth
  await AuthService.initialize();

  // Inicializar Logger
  await AppLogger.init();

  // ✅ Optimizaciones de rendimiento para APK (reducir RAM/CPU)
  if (isAPK) {
    PaintingBinding.instance.imageCache.maximumSize = 50;
    PaintingBinding.instance.imageCache.maximumSizeBytes = 50 << 20;

    AppLogger.info('Optimizaciones de rendimiento APK aplicadas', tag: 'Main');
  }

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
                    localizationsDelegates:
                        AppLocalizations.localizationsDelegates,
                    supportedLocales: AppLocalizations.supportedLocales,
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
