import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

Future<Logger> createLogger() async {
  LogOutput? fileOutput;
  Directory? logsDirectory;

  try {
    final directory = await getApplicationDocumentsDirectory();
    logsDirectory = Directory('${directory.path}/logs');
    if (!await logsDirectory.exists()) {
      await logsDirectory.create(recursive: true);
    }
    fileOutput = _CustomFileOutput(logsDirectory);
  } catch (e) {
    debugPrint('Error inicializando logs en disco: $e');
  }

  return Logger(
    filter: DevelopmentFilter(),
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 80,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
    output: MultiOutput([
      ConsoleOutput(),
      if (fileOutput != null) fileOutput,
    ]),
  );
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
      final cleanLine = line.replaceAll(RegExp(r'\x1B\[[0-?]*[ -/]*[@-~]'), '');
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
      case Level.debug:
        return 'debug_logs.txt';
      case Level.info:
        return 'info_logs.txt';
      case Level.warning:
        return 'warning_logs.txt';
      case Level.error:
        return 'error_logs.txt';
      case Level.fatal:
        return 'fatal_logs.txt';
      case Level.trace:
        return 'network_logs.txt';
      default:
        return 'app_logs.txt';
    }
  }
}
