import 'dart:io' show Directory, File, FileMode;
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

// ignore: avoid_web_libraries_in_flutter
import 'dart:js' as js;

class AppLogger {
  static const String _defaultTag = 'MyGasolinera';
  static Logger? _logger;
  static Directory? _logsDirectory;

  static Future<void> init() async {
    LogOutput? fileOutput;

    if (!kIsWeb) {
      try {
        final directory = await getApplicationDocumentsDirectory();
        _logsDirectory = Directory('${directory.path}/logs');
        if (!await _logsDirectory!.exists()) {
          await _logsDirectory!.create(recursive: true);
        }
        fileOutput = _CustomFileOutput(_logsDirectory!);
      } catch (e) {
        debugPrint('Error inicializando logs en disco: $e');
      }
    }

    _logger = Logger(
      filter: DevelopmentFilter(),
      printer: kIsWeb
          ? _WebPrinter()
          : PrettyPrinter(
              methodCount: 2,
              errorMethodCount: 8,
              lineLength: 80,
              colors: true,
              printEmojis: true,
              printTime: true,
            ),
      output: kIsWeb
          ? _WebConsoleOutput()
          : MultiOutput([
              ConsoleOutput(),
              if (fileOutput != null) fileOutput,
            ]),
    );
  }

  // --- Métodos de conveniencia ---
  static void debug(String message, {String? tag}) =>
      _logger?.d('[${tag ?? _defaultTag}] $message');
  static void info(String message, {String? tag}) =>
      _logger?.i('[${tag ?? _defaultTag}] $message');
  static void warning(String message, {String? tag, Object? error}) =>
      _logger?.w('[${tag ?? _defaultTag}] $message', error: error);
  static void error(String message,
          {String? tag, Object? error, StackTrace? stackTrace}) =>
      _logger?.e('[${tag ?? _defaultTag}] $message',
          error: error, stackTrace: stackTrace);
  static void network(String message, {String? tag}) =>
      _logger?.t('[${tag ?? _defaultTag}] [NETWORK] $message');
  static void database(String message, {String? tag}) =>
      _logger?.d('[${tag ?? _defaultTag}] [DATABASE] $message');
  static void fatal(String message,
          {String? tag, Object? error, StackTrace? stackTrace}) =>
      _logger?.f('[${tag ?? _defaultTag}] $message',
          error: error, stackTrace: stackTrace);
}

// ─── Printer para Web: formatea el mensaje antes de pasarlo al output ─────────
class _WebPrinter extends LogPrinter {
  static const _emojis = {
    Level.trace:   '🌐',
    Level.debug:   '🐛',
    Level.info:    '💡',
    Level.warning: '⚠️',
    Level.error:   '❌',
    Level.fatal:   '💀',
  };

  @override
  List<String> log(LogEvent event) {
    final emoji = _emojis[event.level] ?? '📋';
    final time = DateTime.now().toIso8601String().substring(11, 23);
    final msg = event.message;
    final err = event.error != null ? '\n  Error: ${event.error}' : '';
    return ['$emoji [$time] $msg$err'];
  }
}

// ─── Output para Web: usa console.log con estilos CSS por nivel ───────────────
class _WebConsoleOutput extends LogOutput {
  // Estilos CSS por nivel
  static const _styles = {
    Level.trace:   'color: #9E9E9E; font-weight: normal',   // Gris
    Level.debug:   'color: #64B5F6; font-weight: bold',     // Azul claro
    Level.info:    'color: #81C784; font-weight: bold',     // Verde
    Level.warning: 'color: #FFB74D; font-weight: bold',     // Naranja
    Level.error:   'color: #E57373; font-weight: bold',     // Rojo
    Level.fatal:   'color: #FF1744; font-weight: bold; font-size: 14px; background: #1a0000', // Rojo intenso
  };

  static const _consoleMethods = {
    Level.trace:   'log',
    Level.debug:   'log',
    Level.info:    'info',
    Level.warning: 'warn',
    Level.error:   'error',
    Level.fatal:   'error',
  };

  @override
  void output(OutputEvent event) {
    final style = _styles[event.level] ?? 'color: inherit';
    final method = _consoleMethods[event.level] ?? 'log';

    for (final line in event.lines) {
      try {
        js.context.callMethod(method, ['%c$line', style]);
      } catch (_) {
        // Fallback si js no está disponible
        debugPrint(line);
      }
    }
  }
}

// ─── Output para móvil/desktop: escribe en archivos .txt ──────────────────────
class _CustomFileOutput extends LogOutput {
  final Directory logsDirectory;
  _CustomFileOutput(this.logsDirectory);

  @override
  void output(OutputEvent event) {
    if (kIsWeb) return;

    final timestamp = DateTime.now().toIso8601String();
    for (var line in event.lines) {
      final cleanLine =
          line.replaceAll(RegExp(r'\x1B\[[0-?]*[ -/]*[@-~]'), '');
      final logEntry = '[$timestamp] $cleanLine\n';

      try {
        final fileName = _getFileName(event.level);
        File('${logsDirectory.path}/$fileName')
            .writeAsStringSync(logEntry, mode: FileMode.append, flush: true);
        File('${logsDirectory.path}/app_logs.txt')
            .writeAsStringSync(logEntry, mode: FileMode.append, flush: true);
      } catch (e) {
        debugPrint('Error escribiendo log en archivo: $e');
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