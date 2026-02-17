import 'dart:io' show Directory, File, FileMode; // Importación selectiva
import 'package:flutter/foundation.dart'; // Para kIsWeb
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

class AppLogger {
  static const String _defaultTag = 'MyGasolinera';
  static Logger? _logger;
  
  // Quitamos 'late' para evitar errores de inicialización en Web
  static Directory? _logsDirectory;

  static Future<void> init() async {
    LogOutput? fileOutput;

    // 1. Verificamos si NO es Web para configurar archivos
    if (!kIsWeb) {
      try {
        final directory = await getApplicationDocumentsDirectory();
        _logsDirectory = Directory('${directory.path}/logs');
        
        if (!await _logsDirectory!.exists()) {
          await _logsDirectory!.create(recursive: true);
        }
        
        fileOutput = _CustomFileOutput(_logsDirectory!);
      } catch (e) {
        debugPrint("Error inicializando logs en disco: $e");
      }
    }

    // 2. Inicializamos el logger
    _logger = Logger(
      filter: DevelopmentFilter(), 
      printer: PrettyPrinter(
        methodCount: 2,
        errorMethodCount: 8,
        lineLength: 80,
        colors: !kIsWeb, // Desactivar colores ANSI en web si dan problemas
        printEmojis: true,
        printTime: true,
      ),
      output: MultiOutput([
        ConsoleOutput(),
        if (fileOutput != null) fileOutput, // Solo se añade en móvil/desktop
      ]),
    );
  }

  // --- Métodos de conveniencia ---
  static void debug(String message, {String? tag}) => _logger?.d('[${tag ?? _defaultTag}] $message');
  static void info(String message, {String? tag}) => _logger?.i('[${tag ?? _defaultTag}] $message');
  static void warning(String message, {String? tag, Object? error}) => _logger?.w('[${tag ?? _defaultTag}] $message', error: error);
  static void error(String message, {String? tag, Object? error, StackTrace? stackTrace}) =>  _logger?.e('[${tag ?? _defaultTag}] $message', error: error, stackTrace: stackTrace);
  static void network(String message, {String? tag}) => _logger?.t('[${tag ?? _defaultTag}] [NETWORK] $message');
  static void database(String message, {String? tag}) => _logger?.d('[${tag ?? _defaultTag}] [DATABASE] $message');
}

/// Implementación que solo se ejecuta fuera de la Web
class _CustomFileOutput extends LogOutput {
  final Directory logsDirectory;
  _CustomFileOutput(this.logsDirectory);

  @override
  void output(OutputEvent event) {
    // Si por algún motivo se llamara en Web, salimos
    if (kIsWeb) return;

    final timestamp = DateTime.now().toIso8601String();
    
    for (var line in event.lines) {
      // Limpiar códigos de color para el archivo .txt
      final cleanLine = line.replaceAll(RegExp(r'\x1B\[[0-?]*[ -/]*[@-~]'), '');
      final logEntry = '[$timestamp] $cleanLine\n';
      
      try {
        // Archivo específico por nivel
        final fileName = _getFileName(event.level);
        final file = File('${logsDirectory.path}/$fileName');
        file.writeAsStringSync(logEntry, mode: FileMode.append, flush: true);
        
        // Archivo general
        final generalFile = File('${logsDirectory.path}/app_logs.txt');
        generalFile.writeAsStringSync(logEntry, mode: FileMode.append, flush: true);
      } catch (e) {
        debugPrint("Error escribiendo log en archivo: $e");
      }
    }
  }

  String _getFileName(Level level) {
    switch (level) {
      case Level.debug:   return 'debug_logs.txt';
      case Level.info:    return 'info_logs.txt';
      case Level.warning: return 'warning_logs.txt';
      case Level.error:   return 'error_logs.txt';
      case Level.fatal:   return 'fatal_logs.txt';
      case Level.trace:   return 'network_logs.txt';
      default:            return 'app_logs.txt';
    }
  }
}