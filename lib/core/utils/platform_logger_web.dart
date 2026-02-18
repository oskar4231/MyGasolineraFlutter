import 'package:logger/logger.dart';
import 'package:flutter/foundation.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:js' as js;

Future<Logger> initPlatformLogger() async {
  return Logger(
    filter: DevelopmentFilter(),
    printer: _WebPrinter(),
    output: _WebConsoleOutput(),
  );
}

// ─── Printer para Web: formatea el mensaje antes de pasarlo al output ─────────
class _WebPrinter extends LogPrinter {
  static const _emojis = {
    Level.trace: '🌐',
    Level.debug: '🐛',
    Level.info: '💡',
    Level.warning: '⚠️',
    Level.error: '❌',
    Level.fatal: '💀',
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
    Level.trace: 'color: #9E9E9E; font-weight: normal', // Gris
    Level.debug: 'color: #64B5F6; font-weight: bold', // Azul claro
    Level.info: 'color: #81C784; font-weight: bold', // Verde
    Level.warning: 'color: #FFB74D; font-weight: bold', // Naranja
    Level.error: 'color: #E57373; font-weight: bold', // Rojo
    Level.fatal:
        'color: #FF1744; font-weight: bold; font-size: 14px; background: #1a0000', // Rojo intenso
  };

  static const _consoleMethods = {
    Level.trace: 'log',
    Level.debug: 'log',
    Level.info: 'info',
    Level.warning: 'warn',
    Level.error: 'error',
    Level.fatal: 'error',
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
