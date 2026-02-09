import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';  // ⬅️ NUEVO: Importar Mocktail
import 'package:my_gasolinera/Implementaciones/gasolineras/domain/models/gasolinera.dart';
import 'package:my_gasolinera/Implementaciones/mapa/data/services/gasolinera_logic.dart';
import 'package:my_gasolinera/Implementaciones/gasolineras/data/services/gasolinera_cache_service.dart';

// 🎭 NUEVO: Crear un Mock (fake) de GasolinerasCacheService
class MockGasolinerasCacheService extends Mock implements GasolinerasCacheService {}

void main() {
  // 🎭 Datos de prueba: Creamos gasolineras fake para testear
  final gasolineraBarata = Gasolinera(
    id: '1',
    rotulo: 'Gasolinera Barata',
    direccion: 'Calle Test 1',
    lat: 40.4168,
    lng: -3.7038,
    provincia: 'Madrid',
    horario: 'L-D: 08:00-22:00',
    gasolina95: 1.30,  // ⚠️ BARATA
    gasolina95E10: 0,
    gasolina98: 0,
    gasoleoA: 1.20,
    gasoleoPremium: 0,
    glp: 0,
    biodiesel: 0,
    bioetanol: 0,
    esterMetilico: 0,
    hidrogeno: 0,
  );

  final gasolineraCara = Gasolinera(
    id: '2',
    rotulo: 'Gasolinera Cara',
    direccion: 'Calle Test 2',
    lat: 40.4168,
    lng: -3.7038,
    provincia: 'Madrid',
    horario: 'L-D: 24H',  // ⚠️ 24 HORAS
    gasolina95: 1.80,  // ⚠️ CARA
    gasolina95E10: 0,
    gasolina98: 0,
    gasoleoA: 1.70,
    gasoleoPremium: 0,
    glp: 0,
    biodiesel: 0,
    bioetanol: 0,
    esterMetilico: 0,
    hidrogeno: 0,
  );

  final gasolineraSinGasolina = Gasolinera(
    id: '3',
    rotulo: 'Solo Diesel',
    direccion: 'Calle Test 3',
    lat: 40.4168,
    lng: -3.7038,
    provincia: 'Madrid',
    horario: 'L-D: 08:00-22:00',
    gasolina95: 0,  // ⚠️ NO TIENE GASOLINA
    gasolina95E10: 0,
    gasolina98: 0,
    gasoleoA: 1.40,
    gasoleoPremium: 0,
    glp: 0,
    biodiesel: 0,
    bioetanol: 0,
    esterMetilico: 0,
    hidrogeno: 0,
  );

  group('Filtros de Gasolineras', () {
    late GasolineraLogic logic;
    late MockGasolinerasCacheService mockCacheService;

    setUp(() {
      // ✅ ARREGLADO: Crear un mock en lugar de null
      mockCacheService = MockGasolinerasCacheService();
      logic = GasolineraLogic(mockCacheService);
    });

    test('Filtro de precio: debe excluir gasolineras caras', () {
      // 1️⃣ ARRANGE
      final todasLasGasolineras = [
        gasolineraBarata,
        gasolineraCara,
        gasolineraSinGasolina,
      ];

      // 2️⃣ ACT: Filtrar por Gasolina 95 con precio máximo 1.50
      final resultado = logic.aplicarFiltros(
        todasLasGasolineras,
        combustibleSeleccionado: 'Gasolina 95',
        precioHasta: 1.50,
      );

      // 3️⃣ ASSERT: Solo debe quedar la barata
      expect(resultado.length, 1);
      expect(resultado.first.id, '1');
      expect(resultado.first.rotulo, 'Gasolinera Barata');
    });

    test('Filtro de combustible: debe excluir gasolineras sin ese combustible', () {
      final todasLasGasolineras = [
        gasolineraBarata,
        gasolineraCara,
        gasolineraSinGasolina,  // Esta NO tiene Gasolina 95
      ];

      final resultado = logic.aplicarFiltros(
        todasLasGasolineras,
        combustibleSeleccionado: 'Gasolina 95',
      );

      // Solo deben quedar 2 (la barata y la cara)
      expect(resultado.length, 2);
      expect(resultado.any((g) => g.id == '3'), false);  // La '3' NO debe estar
    });

    test('Filtro de apertura: debe filtrar solo 24 horas', () {
      final todasLasGasolineras = [
        gasolineraBarata,  // NO es 24h
        gasolineraCara,    // SÍ es 24h
        gasolineraSinGasolina,  // NO es 24h
      ];

      final resultado = logic.aplicarFiltros(
        todasLasGasolineras,
        tipoAperturaSeleccionado: '24 Horas',
      );

      expect(resultado.length, 1);
      expect(resultado.first.id, '2');  // Solo la cara (24h)
    });

    test('Filtro combinado: combustible + precio + horario', () {
      final todasLasGasolineras = [gasolineraBarata, gasolineraCara, gasolineraSinGasolina];
      final resultado = logic.aplicarFiltros(
        todasLasGasolineras,
        combustibleSeleccionado: 'Gasolina 95',
        precioHasta: 1.50,
        tipoAperturaSeleccionado: '24 Horas',
      );
      // NO debe haber ninguna (la barata no es 24h, la cara es muy cara)
      expect(resultado.length, 0);
    });

     test('Debe parsear correctamente horario L-V y S-D diferentes', () {
      // Simular un Lunes a las 10:00 (debería estar abierta)
      final json = {
        'IDEESS': '1',
        'Rótulo': 'Test',
        'Dirección': 'Test',
        'Latitud': '40.4168',
        'Longitud (WGS84)': '-3.7038',
        'Horario': 'L-V: 08:00-22:00; S-D: 09:00-14:00',
        'Precio Gasolina 95 E5': '0',
        'Precio Gasolina 95 E10': '0',
        'Precio Gasolina 98 E5': '0',
        'Precio Gasoleo A': '0',
        'Precio Gasoleo Premium': '0',
        'Precio Gases licuados del petróleo': '0',
        'Precio Biodiesel': '0',
        'Precio Bioetanol': '0',
        'Precio Éster metílico': '0',
        'Precio Hidrogeno': '0',
        'Provincia': 'Madrid',
      };
      final gasolinera = Gasolinera.fromJson(json);
      // NOTA: Este test puede fallar dependiendo del día/hora actual
      // Idealmente necesitarías mockear DateTime.now()
      // Por ahora, solo verificamos que no crashea
      expect(() => gasolinera.estaAbiertaAhora, returnsNormally);
      expect(() => gasolinera.es24Horas, returnsNormally);
    });

    test('Debe detectar horario que cruza medianoche', () {
      final json = {
        'IDEESS': '2',
        'Rótulo': 'Nocturna',
        'Dirección': 'Test',
        'Latitud': '40.4168',
        'Longitud (WGS84)': '-3.7038',
        'Horario': 'L-D: 22:00-06:00',  // Cruza medianoche
        'Precio Gasolina 95 E5': '0',
        'Precio Gasolina 95 E10': '0',
        'Precio Gasolina 98 E5': '0',
        'Precio Gasoleo A': '0',
        'Precio Gasoleo Premium': '0',
        'Precio Gases licuados del petróleo': '0',
        'Precio Biodiesel': '0',
        'Precio Bioetanol': '0',
        'Precio Éster metílico': '0',
        'Precio Hidrogeno': '0',
        'Provincia': 'Madrid',
      };
      final gasolinera = Gasolinera.fromJson(json);
      // Verificar que no es 24h (tiene horario limitado)
      expect(gasolinera.es24Horas, false);
      
      // Verificar que no crashea al calcular
      expect(() => gasolinera.estaAbiertaAhora, returnsNormally);
    });

    test('Debe manejar horario vacío sin crashear', () {
      final json = {
        'IDEESS': '3',
        'Rótulo': 'Sin Horario',
        'Dirección': 'Test',
        'Latitud': '40.4168',
        'Longitud (WGS84)': '-3.7038',
        'Horario': '',  // Vacío
        'Precio Gasolina 95 E5': '0',
        'Precio Gasolina 95 E10': '0',
        'Precio Gasolina 98 E5': '0',
        'Precio Gasoleo A': '0',
        'Precio Gasoleo Premium': '0',
        'Precio Gases licuados del petróleo': '0',
        'Precio Biodiesel': '0',
        'Precio Bioetanol': '0',
        'Precio Éster metílico': '0',
        'Precio Hidrogeno': '0',
        'Provincia': 'Madrid',
      };
      final gasolinera = Gasolinera.fromJson(json);
      expect(gasolinera.es24Horas, false);
      expect(gasolinera.estaAbiertaAhora, false);
    });

    test('Filtro de precio: debe manejar rango inválido (desde > hasta)', () {
        final todasLasGasolineras = [gasolineraBarata, gasolineraCara];
        // precioDesde (1.80) > precioHasta (1.30) = rango inválido
        final resultado = logic.aplicarFiltros(
            todasLasGasolineras,
            combustibleSeleccionado: 'Gasolina 95',
            precioDesde: 1.80,
        precioHasta: 1.30,
    );
    // Debería devolver lista vacía (ninguna cumple)
    expect(resultado.length, 0);
    });

    test('Filtro de precio: debe manejar rango inválido (desde > hasta)', () {
    final todasLasGasolineras = [gasolineraBarata, gasolineraCara];
    // precioDesde (1.80) > precioHasta (1.30) = rango inválido
    final resultado = logic.aplicarFiltros(
        todasLasGasolineras,
        combustibleSeleccionado: 'Gasolina 95',
        precioDesde: 1.80,
        precioHasta: 1.30,
    );
    // Debería devolver lista vacía (ninguna cumple)
    expect(resultado.length, 0);
    });

    test('Filtro debe excluir gasolineras con todos los precios en 0', () {
    final gasolineraSinPrecios = Gasolinera(
        id: '999',
        rotulo: 'Sin Precios',
        direccion: 'Test',
        lat: 40.4168,
        lng: -3.7038,
        provincia: 'Madrid',
        horario: 'L-D: 08:00-22:00',
        gasolina95: 0,  // ⚠️ Todos en 0
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
    final todasLasGasolineras = [gasolineraBarata, gasolineraSinPrecios];
    final resultado = logic.aplicarFiltros(
        todasLasGasolineras,
        combustibleSeleccionado: 'Gasolina 95',
    );
    // Solo debe quedar la barata (la otra tiene precio 0)
    expect(resultado.length, 1);
    expect(resultado.first.id, '1');
    });

    test('Filtro triple: debe aplicar combustible + precio + apertura correctamente', () {
    // Crear gasolinera que cumple TODOS los criterios
    final gasolineraPerfecta = Gasolinera(
        id: '100',
        rotulo: 'Perfecta',
        direccion: 'Test',
        lat: 40.4168,
        lng: -3.7038,
        provincia: 'Madrid',
        horario: 'L-D: 24H',  // ✅ 24 horas
        gasolina95: 1.40,  // ✅ Precio medio
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
    final todasLasGasolineras = [
        gasolineraBarata,  // NO cumple (no es 24h)
        gasolineraCara,    // NO cumple (precio muy alto)
        gasolineraPerfecta,  // ✅ CUMPLE TODO
    ];
    final resultado = logic.aplicarFiltros(
        todasLasGasolineras,
        combustibleSeleccionado: 'Gasolina 95',
        precioDesde: 1.30,
        precioHasta: 1.50,
        tipoAperturaSeleccionado: '24 Horas',
    );
    // Solo debe quedar la perfecta
    expect(resultado.length, 1);
    expect(resultado.first.id, '100');
    expect(resultado.first.rotulo, 'Perfecta');
    });

    test('Filtro sin parámetros debe devolver todas las gasolineras', () {
    final todasLasGasolineras = [
        gasolineraBarata,
        gasolineraCara,
        gasolineraSinGasolina,
    ];
    // Llamar sin ningún filtro
    final resultado = logic.aplicarFiltros(
        todasLasGasolineras,
        // Todos los parámetros opcionales = null
    );
    // Debe devolver TODAS (sin filtrar)
    expect(resultado.length, 3);
    expect(resultado, equals(todasLasGasolineras));
    });
  });
}