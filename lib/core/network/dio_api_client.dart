import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:my_gasolinera/core/config/api_config.dart';
import 'package:my_gasolinera/core/utils/app_logger.dart';

class DioApiClient {
  static final DioApiClient _instance = DioApiClient._internal();
  factory DioApiClient() => _instance;

  late final Dio dio;

  DioApiClient._internal() {
    dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: ApiConfig.headers,
    ));

    // Configurar Cache Interceptor (Memoria en RAM para máxima velocidad)
    final cacheOptions = CacheOptions(
      // Se guarda en RAM. Si la app se cierra, se pierde (ideal para gasolineras que cambian de precio dia a dia).
      store: MemCacheStore(), 
      // Política de cache: Usa la caché primero, si expiró entonces va a la API
      policy: CachePolicy.forceCache,
      // Los datos en RAM vivirán por 5 minutos antes de forzar otra llamada de red = 0% CPU/Red por 5 mins
      maxStale: const Duration(minutes: 5),
      priority: CachePriority.high,
      cipher: null,
      keyBuilder: CacheOptions.defaultCacheKeyBuilder,
      allowPostMethod: false, // Solo cacheamos los GETs
    );

    dio.interceptors.add(DioCacheInterceptor(options: cacheOptions));

    AppLogger.info('DioApiClient inicializado con caché en memoria (5 min)',
        tag: 'DioApiClient');
  }

  /// Helper genérico para hacer un GET y mapear respuesta de forma segura
  Future<Response?> get(String url, {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await dio.get(url, queryParameters: queryParameters);
      return response;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        AppLogger.error('DioApiClient: Timeout al conectar con $url',
            tag: 'DioApiClient', error: e);
      } else {
        AppLogger.error('DioApiClient: Error HTTP ${e.response?.statusCode} en $url',
            tag: 'DioApiClient', error: e);
      }
      return null;
    } catch (e) {
      AppLogger.error('DioApiClient: Excepción genérica GET $url',
            tag: 'DioApiClient', error: e);
      return null;
    }
  }
}
