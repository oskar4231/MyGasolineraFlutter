import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_gasolinera/core/config/api_config.dart';

void main() {
  group('ApiConfig.mapsApiKey', () {
    setUp(() {
      dotenv.loadFromString(envString: 'GOOGLE_MAPS_API_KEY=test_key_123');
    });

    test('returns key from dotenv', () {
      expect(ApiConfig.mapsApiKey, equals('test_key_123'));
    });

    test('returns empty string when key is absent', () {
      dotenv.loadFromString(envString: '', isOptional: true);
      expect(ApiConfig.mapsApiKey, equals(''));
    });
  });
}
