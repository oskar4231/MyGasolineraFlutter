import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

/// Utilidad centralizada para logging en la aplicación
/// Reemplaza el uso de print() en producción
class AppLogger {
  static const String _defaultTag = 'MyGasolinera';

  /// Log de nivel DEBUG - solo en modo debug
  static void debug(String message, {String? tag}) {
    if (kDebugMode) {
      developer.log(
        message,
        name: tag ?? _defaultTag,
        level: 500, // DEBUG level
      );
    }
  }

  /// Log de nivel INFO
  static void info(String message, {String? tag}) {
    developer.log(
      message,
      name: tag ?? _defaultTag,
      level: 800, // INFO level
    );
  }

  /// Log de nivel WARNING
  static void warning(String message, {String? tag, Object? error}) {
    developer.log(
      message,
      name: tag ?? _defaultTag,
      level: 900, // WARNING level
      error: error,
    );
  }

  /// Log de nivel ERROR
  static void error(String message,
      {String? tag, Object? error, StackTrace? stackTrace}) {
    developer.log(
      message,
      name: tag ?? _defaultTag,
      level: 1000, // ERROR level
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Log de datos de red/API
  static void network(String message, {String? tag}) {
    if (kDebugMode) {
      developer.log(
        message,
        name: tag ?? '$_defaultTag.Network',
        level: 500,
      );
    }
  }

  /// Log de base de datos
  static void database(String message, {String? tag}) {
    if (kDebugMode) {
      developer.log(
        message,
        name: tag ?? '$_defaultTag.Database',
        level: 500,
      );
    }
  }
}
