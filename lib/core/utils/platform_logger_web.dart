import 'package:logger/logger.dart';
import 'package:flutter/foundation.dart';

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
  @override
  void output(OutputEvent event) {
    for (final line in event.lines) {
      try {
        // Fallback simplificado usando debugPrint
        debugPrint(line);
      } catch (_) {
        // Fallback si js no está disponible
        debugPrint(line);
      }
    }
  }
}
