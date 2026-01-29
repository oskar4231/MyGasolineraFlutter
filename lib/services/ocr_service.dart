import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OcrService {
  static final OcrService _instance = OcrService._internal();
  factory OcrService() => _instance;
  OcrService._internal();

  final _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  Future<Map<String, dynamic>> scanAndExtract(String imagePath) async {
    try {
      // Validar si es Web primero
      if (kIsWeb) {
        throw Exception(
            'El OCR no es compatible con la versión Web. Por favor utiliza la app en Android o iOS.');
      }

      // Validar si es Escritorio (Desktop)
      // Usamos defaultTargetPlatform en lugar de Platform para evitar errores de compilación en Web
      if (defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.linux ||
          defaultTargetPlatform == TargetPlatform.macOS) {
        throw Exception(
            'El OCR no está soportado en escritorio. Usa un dispositivo móvil.');
      }

      final inputImage = InputImage.fromFilePath(imagePath);
      final RecognizedText recognizedText =
          await _textRecognizer.processImage(inputImage);

      String rawText = recognizedText.text;

      // Normalize text for easier regex processing (keep newlines for context)
      // We might want to iterate blocks/lines for better context

      Map<String, dynamic> data = {
        'fecha': _extractDate(rawText),
        'total': _extractTotal(rawText),
        'litros': _extractLitros(rawText),
        'precio_litro': _extractPrecioLitro(rawText),
        'gasolinera': _extractGasStationName(rawText),
        'raw_text': rawText, // Debugging
      };

      // Derived value check: if we have total and litros but no precio_litro
      if (data['total'] != null &&
          data['litros'] != null &&
          data['precio_litro'] == null) {
        if (data['litros'] > 0) {
          data['precio_litro'] =
              double.parse((data['total'] / data['litros']).toStringAsFixed(3));
        }
      }

      return data;
    } on PlatformException catch (e) {
      if (e.code == 'MissingPluginException') {
        throw Exception(
            'Error de plugin: Si estás en móvil, reinicia la app. En Web/Desktop este plugin no funciona.');
      }
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  String? _extractDate(String text) {
    // Matches: 12/01/2026, 12-01-2026, 12.01.2026
    final dateRegex = RegExp(r'\b(\d{2})[/\.-](\d{2})[/\.-](\d{4})\b');
    final match = dateRegex.firstMatch(text);
    if (match != null) {
      return "${match.group(1)}/${match.group(2)}/${match.group(3)}";
    }

    // Fallback for short year: 12/01/26
    final shortDateRegex = RegExp(r'\b(\d{2})[/\.-](\d{2})[/\.-](\d{2})\b');
    final shortMatch = shortDateRegex.firstMatch(text);
    if (shortMatch != null) {
      return "${shortMatch.group(1)}/${shortMatch.group(2)}/20${shortMatch.group(3)}";
    }

    return null;
  }

  double? _extractTotal(String text) {
    // Look for lines with Total, Importe, Pagar followed by a number
    final lines = text.split('\n');
    final keywords = ['total', 'importe', 'pagar', 'eur', '€'];
    final numberRegex = RegExp(r'(\d+[\.,]\d{2})');

    for (var line in lines) {
      String lowerLine = line.toLowerCase();
      // Check if line has a keyword
      if (keywords.any((k) => lowerLine.contains(k))) {
        final match = numberRegex.firstMatch(line);
        if (match != null) {
          return _normalizeDouble(match.group(1)!);
        }
      }
    }

    // Fallback: Just look for the largest currency-like number at the bottom of the receipt
    // This is risky, but often the total is the biggest number near the end.
    // Let's stick to safe parsing first.
    return null;
  }

  double? _extractLitros(String text) {
    final lines = text.split('\n');
    final keywords = [
      'litros',
      'volumen',
      'cantidad',
      'suministro',
      'lts',
      ' l '
    ];

    // Specific regex for liters which often has 2 or 3 decimals and might be surrounded by L
    final numberRegex = RegExp(r'(\d+[\.,]\d{1,3})');

    for (var line in lines) {
      String lowerLine = line.toLowerCase();
      if (keywords.any((k) => lowerLine.contains(k))) {
        // Avoid confuse with price per liter
        if (lowerLine.contains('€/l') || lowerLine.contains('precio')) continue;

        final match = numberRegex.firstMatch(line);
        if (match != null) {
          return _normalizeDouble(match.group(1)!);
        }
      }
    }
    return null;
  }

  double? _extractPrecioLitro(String text) {
    final lines = text.split('\n');
    final keywords = ['precio', '€/l', 'p.u.', 'pvp'];

    final numberRegex =
        RegExp(r'(\d+[\.,]\d{3})'); // 3 decimals common for gas price

    for (var line in lines) {
      String lowerLine = line.toLowerCase();
      if (keywords.any((k) => lowerLine.contains(k))) {
        final match = numberRegex.firstMatch(line);
        if (match != null) {
          return _normalizeDouble(match.group(1)!);
        }
      }
    }
    return null;
  }

  String? _extractGasStationName(String text) {
    final lines = text.split('\n');
    if (lines.isNotEmpty) {
      // Usually the top line, maybe skip small garbage lines
      for (int i = 0; i < lines.length && i < 5; i++) {
        if (lines[i].trim().length > 3) {
          // Check for known brands to be sure
          String lower = lines[i].toLowerCase();
          if (lower.contains('repsol')) return 'Repsol';
          if (lower.contains('cepsa')) return 'Cepsa';
          if (lower.contains('bp')) return 'BP';
          if (lower.contains('galp')) return 'Galp';
          if (lower.contains('shell')) return 'Shell';

          // If strictly first line looks like a name
          return lines[i].trim();
        }
      }
    }
    return null;
  }

  double _normalizeDouble(String numStr) {
    // Replace comma with dot
    return double.parse(numStr.replaceAll(',', '.'));
  }

  void dispose() {
    _textRecognizer.close();
  }
}
