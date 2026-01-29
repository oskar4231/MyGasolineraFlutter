import 'package:my_gasolinera/main.dart';

/// Helper para agregar headers comunes a todas las peticiones HTTP
class HttpHelper {
  /// Retorna headers con Accept-Language basado en la preferencia del usuario
  ///
  /// Incluye:
  /// - Accept-Language: código del idioma actual (es/en)
  ///
  /// Ejemplo de uso:
  /// ```dart
  /// final response = await http.post(
  ///   Uri.parse(url),
  ///   headers: {
  ///     ...HttpHelper.getLanguageHeaders(),
  ///     'Content-Type': 'application/json',
  ///   },
  ///   body: jsonEncode(data),
  /// );
  /// ```
  static Map<String, String> getLanguageHeaders() {
    return {
      'Accept-Language': languageProvider.languageCode,
    };
  }

  /// Retorna headers completos incluyendo Content-Type y Accept-Language
  ///
  /// Útil para peticiones POST/PUT con JSON
  static Map<String, String> getJsonHeaders() {
    return {
      'Content-Type': 'application/json',
      'Accept-Language': languageProvider.languageCode,
    };
  }

  /// Combina headers personalizados con los headers de idioma
  ///
  /// Ejemplo:
  /// ```dart
  /// final headers = HttpHelper.mergeHeaders({
  ///   'Authorization': 'Bearer token123',
  ///   'Custom-Header': 'value',
  /// });
  /// ```
  static Map<String, String> mergeHeaders(Map<String, String> customHeaders) {
    return {
      ...getLanguageHeaders(),
      ...customHeaders,
    };
  }
}
