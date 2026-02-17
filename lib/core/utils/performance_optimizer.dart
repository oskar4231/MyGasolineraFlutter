import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

/// Optimizaciones de rendimiento para reducir uso de CPU y RAM
class PerformanceOptimizer {
  /// Debouncer para evitar llamadas excesivas
  static Map<String, DateTime> _lastCallTimes = {};
  static const Duration _defaultDebounce = Duration(milliseconds: 300);

  /// Ejecuta una función solo si ha pasado suficiente tiempo desde la última llamada
  static bool shouldExecute(String key, {Duration? debounce}) {
    final now = DateTime.now();
    final lastCall = _lastCallTimes[key];
    final threshold = debounce ?? _defaultDebounce;

    if (lastCall == null || now.difference(lastCall) > threshold) {
      _lastCallTimes[key] = now;
      return true;
    }
    return false;
  }

  /// Limpia el caché de debounce
  static void clearDebounceCache() {
    _lastCallTimes.clear();
  }

  /// Reduce la frecuencia de setState en listas grandes
  static bool shouldUpdateUI(int itemCount) {
    // Solo actualizar UI si hay cambios significativos
    if (itemCount < 10) return true;
    if (itemCount < 50)
      return shouldExecute('ui_update_medium',
          debounce: const Duration(milliseconds: 500));
    return shouldExecute('ui_update_large',
        debounce: const Duration(milliseconds: 1000));
  }

  /// Libera memoria de imágenes no usadas
  static void clearImageCache() {
    if (!kIsWeb) {
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();
    }
  }

  /// Reduce el tamaño del caché de imágenes
  static void optimizeImageCache() {
    if (!kIsWeb) {
      PaintingBinding.instance.imageCache.maximumSize =
          50; // Reducir de 1000 (default) a 50
      PaintingBinding.instance.imageCache.maximumSizeBytes =
          50 << 20; // 50 MB en lugar de 100 MB
    }
  }
}
