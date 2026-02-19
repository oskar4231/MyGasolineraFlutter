import 'package:logger/logger.dart';

import 'logger_implementation_io.dart'
    if (dart.library.js) 'logger_implementation_web.dart';

class AppLogger {
  static const String _defaultTag = 'MyGasolinera';
  static Logger? _logger;

  static Future<void> init() async {
    _logger = await createLogger();
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
