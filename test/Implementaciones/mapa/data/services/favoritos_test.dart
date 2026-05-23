import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_gasolinera/Implementaciones/mapa/data/services/gasolinera_logic.dart';
import 'package:my_gasolinera/Implementaciones/gasolineras/data/services/gasolinera_cache_service.dart';
import 'package:my_gasolinera/Implementaciones/gasolineras/domain/models/gasolinera.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockGasolinerasCacheService extends Mock implements GasolinerasCacheService {}

Gasolinera _makeGasolinera(String id) => Gasolinera(
      id: id,
      rotulo: 'Test',
      direccion: 'Test',
      lat: 40.0,
      lng: -3.0,
      horario: '',
      gasolina95: 0,
      gasolina95E10: 0,
      gasolina98: 0,
      gasoleoA: 0,
      gasoleoPremium: 0,
      glp: 0,
      biodiesel: 0,
      bioetanol: 0,
      esterMetilico: 0,
      hidrogeno: 0,
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('Gestión de Favoritos', () {
    late GasolineraLogic logic;
    late MockGasolinerasCacheService mockCacheService;
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      mockCacheService = MockGasolinerasCacheService();
      logic = GasolineraLogic(mockCacheService);
      await logic.cargarFavoritos();
    });
    test('Debe añadir un favorito correctamente', () async {
      expect(logic.favoritosIds, isEmpty);
      await logic.toggleFavorito(_makeGasolinera('gasolinera_123'));
      expect(logic.favoritosIds, contains('gasolinera_123'));
      expect(logic.favoritosIds.length, 1);
    });
    test('Debe eliminar un favorito existente', () async {
      await logic.toggleFavorito(_makeGasolinera('gasolinera_123'));
      expect(logic.favoritosIds, contains('gasolinera_123'));
      await logic.toggleFavorito(_makeGasolinera('gasolinera_123'));
      expect(logic.favoritosIds, isNot(contains('gasolinera_123')));
      expect(logic.favoritosIds, isEmpty);
    });
    test('Debe manejar múltiples favoritos', () async {
      await logic.toggleFavorito(_makeGasolinera('gas_1'));
      await logic.toggleFavorito(_makeGasolinera('gas_2'));
      await logic.toggleFavorito(_makeGasolinera('gas_3'));
      expect(logic.favoritosIds.length, 3);
      expect(logic.favoritosIds, containsAll(['gas_1', 'gas_2', 'gas_3']));
    });

    test('Debe persistir favoritos entre instancias de GasolineraLogic', () async {
      await logic.toggleFavorito(_makeGasolinera('gas_persistente'));
      expect(logic.favoritosIds, contains('gas_persistente'));
      final nuevaInstancia = GasolineraLogic(mockCacheService);
      await nuevaInstancia.cargarFavoritos();
      expect(nuevaInstancia.favoritosIds, contains('gas_persistente'));
    });

    test('Debe manejar toggle de favorito inexistente sin error', () async {
      expect(logic.favoritosIds, isEmpty);
      await logic.toggleFavorito(_makeGasolinera('gas_inexistente'));
      expect(logic.favoritosIds, contains('gas_inexistente'));
      expect(logic.favoritosIds.length, 1);
    });
  });
}
