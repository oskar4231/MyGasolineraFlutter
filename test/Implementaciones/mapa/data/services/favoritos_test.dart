import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_gasolinera/Implementaciones/mapa/data/services/gasolinera_logic.dart';
import 'package:my_gasolinera/Implementaciones/gasolineras/data/services/gasolinera_cache_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockGasolinerasCacheService extends Mock implements GasolinerasCacheService {}
void main() {
  // IMPORTANTE: Necesitas inicializar SharedPreferences para tests
  TestWidgetsFlutterBinding.ensureInitialized();
  group('Gestión de Favoritos', () {
    late GasolineraLogic logic;
    late MockGasolinerasCacheService mockCacheService;
    setUp(() async {
      // Limpiar SharedPreferences antes de cada test
      SharedPreferences.setMockInitialValues({});
      
      mockCacheService = MockGasolinerasCacheService();
      logic = GasolineraLogic(mockCacheService);
      
      // Cargar favoritos vacíos
      await logic.cargarFavoritos();
    });
    test('Debe añadir un favorito correctamente', () async {
      // Inicialmente vacío
      expect(logic.favoritosIds, isEmpty);
      // Añadir favorito
      await logic.toggleFavorito('gasolinera_123');
      // Verificar que se añadió
      expect(logic.favoritosIds, contains('gasolinera_123'));
      expect(logic.favoritosIds.length, 1);
    });
    test('Debe eliminar un favorito existente', () async {
      // Añadir primero
      await logic.toggleFavorito('gasolinera_123');
      expect(logic.favoritosIds, contains('gasolinera_123'));
      // Eliminar (toggle de nuevo)
      await logic.toggleFavorito('gasolinera_123');
      // Verificar que se eliminó
      expect(logic.favoritosIds, isNot(contains('gasolinera_123')));
      expect(logic.favoritosIds, isEmpty);
    });
    test('Debe manejar múltiples favoritos', () async {
      await logic.toggleFavorito('gas_1');
      await logic.toggleFavorito('gas_2');
      await logic.toggleFavorito('gas_3');
      expect(logic.favoritosIds.length, 3);
      expect(logic.favoritosIds, containsAll(['gas_1', 'gas_2', 'gas_3']));
    });

    test('Debe persistir favoritos entre instancias de GasolineraLogic', () async {
    // Primera instancia: añadir favorito
    await logic.toggleFavorito('gas_persistente');
    expect(logic.favoritosIds, contains('gas_persistente'));
    // Crear NUEVA instancia (simula reinicio de app)
    final nuevaInstancia = GasolineraLogic(mockCacheService);
    await nuevaInstancia.cargarFavoritos();
    // Verificar que el favorito persiste
    expect(nuevaInstancia.favoritosIds, contains('gas_persistente'));
    });

    test('Debe manejar toggle de favorito inexistente sin error', () async {
    // Lista inicialmente vacía
    expect(logic.favoritosIds, isEmpty);
    // Intentar eliminar (toggle) un favorito que no existe
    await logic.toggleFavorito('gas_inexistente');
    // Debería añadirlo (porque no existía)
    expect(logic.favoritosIds, contains('gas_inexistente'));
    expect(logic.favoritosIds.length, 1);
    });
  });
}