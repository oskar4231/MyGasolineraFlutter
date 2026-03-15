import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

/// Manejador global de errores no capturados.
/// Muestra una pantalla de error con detalles del crash en lugar de cerrar la app.
class CrashHandler {
  /// Guarda el log del crash en un archivo en el dispositivo
  static Future<String> saveCrashLog(String error, String stackTrace) async {
    try {
      final dir = await getExternalStorageDirectory() ??
          await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now()
          .toIso8601String()
          .replaceAll(':', '-')
          .replaceAll('.', '-');
      final file = File('${dir.path}/crash_$timestamp.txt');
      await file.writeAsString(
        '=== MyGasolinera Crash Log ===\n'
        'Fecha: ${DateTime.now()}\n\n'
        'ERROR:\n$error\n\n'
        'STACK TRACE:\n$stackTrace\n',
      );
      return file.path;
    } catch (_) {
      return 'No se pudo guardar el log';
    }
  }

  /// Pantalla de error estilo "Windows Error" que se muestra al crashear
  static Widget buildCrashScreen(
    FlutterErrorDetails details, {
    String? logPath,
  }) {
    if (kReleaseMode) {
      final String shortError = details.exception.toString().split('\n').first;
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: const Color(0xFF1E1E2E),
        ),
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, color: Color(0xFFE53935), size: 64),
                  const SizedBox(height: 16),
                  const Text(
                    'Error xd00003',
                    style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Ha ocurrido un problema inesperado.',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A2A3E),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFFF6B6B).withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      shortError,
                      style: const TextStyle(color: Color(0xFFFF6B6B), fontSize: 13, fontFamily: 'monospace'),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final error = details.exception.toString();
    final stack = details.stack?.toString() ?? 'No stack trace disponible';
    final shortStack =
        stack.length > 600 ? '${stack.substring(0, 600)}...' : stack;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFF1E1E2E),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header estilo Windows Error
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE53935),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.white, size: 32),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'MyGasolinera ha encontrado un problema',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'La aplicación no pudo continuar. Revisa los detalles.',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Error message
                _buildSection('ERROR', error, const Color(0xFFFF6B6B)),
                const SizedBox(height: 12),
                // Stack trace
                _buildSection(
                    'STACK TRACE', shortStack, const Color(0xFFFFD93D)),
                const SizedBox(height: 12),
                // Log path
                if (logPath != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A2A3E),
                      borderRadius: BorderRadius.circular(8),
                      border:
                          Border.all(color: const Color(0xFF6BCB77), width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '📁 LOG GUARDADO EN:',
                          style: TextStyle(
                            color: Color(0xFF6BCB77),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          logPath,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget _buildSection(String title, String content, Color titleColor) {
    return Expanded(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A3E),
          borderRadius: BorderRadius.circular(8),
          border:
              Border.all(color: titleColor.withValues(alpha: 0.4), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: titleColor,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  content,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
