import 'package:flutter_test/flutter_test.dart';
import 'package:my_gasolinera/Implementaciones/gasolineras/data/models/gasolinera.dart';

void main() {
  // 📦 Agrupamos tests relacionados con "group"
  group('Gasolinera Model Tests', () {
    
    // 🧪 TEST 1: Parsear precio desde String con coma
    test('_parsePrecio debe convertir String con coma a double', () {
      // Arrange (Preparar): Creamos un JSON simulado
      final json = {
        'IDEESS': '12345',
        'Rótulo': 'Test Station',
        'Dirección': 'Calle Test',
        'Latitud': '40.4168',
        'Longitud (WGS84)': '-3.7038',
        'Horario': 'L-D: 00:00-23:59',
        'Precio Gasolina 95 E5': '1,459', // ⚠️ Coma europea
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

      // Act (Actuar): Ejecutamos el código que queremos probar
      final gasolinera = Gasolinera.fromJson(json);

      // Assert (Verificar): Comprobamos que el resultado es el esperado
      expect(gasolinera.gasolina95, 1.459);
    });

    // 🧪 TEST 2: Parsear precio "N/A" debe devolver 0.0
    test('_parsePrecio debe devolver 0.0 cuando el precio es "N/A"', () {
      final json = {
        'IDEESS': '12345',
        'Rótulo': 'Test Station',
        'Dirección': 'Calle Test',
        'Latitud': '40.4168',
        'Longitud (WGS84)': '-3.7038',
        'Horario': 'L-D: 00:00-23:59',
        'Precio Gasolina 95 E5': 'N/A', // ⚠️ No disponible
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

      expect(gasolinera.gasolina95, 0.0);
    });

    // 🧪 TEST 3: Parsear precio desde número (backend)
    test('_parsePrecio debe manejar números directamente', () {
      final json = {
        'id': '12345',
        'rotulo': 'Test Station',
        'direccion': 'Calle Test',
        'lat': 40.4168, // ⚠️ Número directo (backend)
        'lng': -3.7038,
        'horario': 'L-D: 00:00-23:59',
        'Precio Gasolina 95 E5': 1.459, // ⚠️ Número directo
        'Precio Gasolina 95 E10': 0,
        'Precio Gasolina 98 E5': 0,
        'Precio Gasoleo A': 0,
        'Precio Gasoleo Premium': 0,
        'Precio Gases licuados del petróleo': 0,
        'Precio Biodiesel': 0,
        'Precio Bioetanol': 0,
        'Precio Éster metílico': 0,
        'Precio Hidrogeno': 0,
        'provincia': 'Madrid',
      };

      final gasolinera = Gasolinera.fromJson(json);

      expect(gasolinera.gasolina95, 1.459);
    });

    // 🧪 TEST 4: Verificar que el ID se parsea correctamente
    test('fromJson debe parsear correctamente el ID', () {
      final json = {
        'IDEESS': '12345',
        'Rótulo': 'Test Station',
        'Dirección': 'Calle Test',
        'Latitud': '40.4168',
        'Longitud (WGS84)': '-3.7038',
        'Horario': 'L-D: 00:00-23:59',
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

      expect(gasolinera.id, '12345');
      expect(gasolinera.rotulo, 'Test Station');
    });

    // 🧪 TEST 5: Verificar getter es24Horas
    test('es24Horas debe detectar horario 24h', () {
      final json = {
        'IDEESS': '12345',
        'Rótulo': 'Test Station',
        'Dirección': 'Calle Test',
        'Latitud': '40.4168',
        'Longitud (WGS84)': '-3.7038',
        'Horario': 'L-D: 24H', // ⚠️ 24 horas
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

      expect(gasolinera.es24Horas, true);
    });
  });

  group('Gasolinera Horarios test', () {
    test('estaAbiertaAhora debe devolver true para gasolineras 24h', () {
      // 1️⃣ ARRANGE: Crear una gasolinera con horario 24h
      final json = {
        'IDEESS': '99999',
        'Rótulo': 'Gasolinera 24H',
        'Dirección': 'Calle Test',
        'Latitud': '40.4168',
        'Longitud (WGS84)': '-3.7038',
        'Horario': 'L-D: 24H',  // ⚠️ Esto es lo importante
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
      // 2️⃣ ACT: Crear la gasolinera
      final gasolinera = Gasolinera.fromJson(json);
      // 3️⃣ ASSERT: Verificar que está abierta
      expect(gasolinera.estaAbiertaAhora, true);
    });

    test('estaAbiertaAhora debe devolver false si no hay horario', () {
      final json = {
        'IDEESS': '88888',
        'Rótulo': 'Gasolinera Sin Horario',
        'Dirección': 'Calle Test',
        'Latitud': '40.4168',
        'Longitud (WGS84)': '-3.7038',
        'Horario': '',  // ⚠️ Sin horario
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
      expect(gasolinera.estaAbiertaAhora, false);
    });

    test('es24Horas debe devolver false para horarios normales', () {
    final json = {
        'IDEESS': '77777',
        'Rótulo': 'Gasolinera Normal',
        'Dirección': 'Calle Test',
        'Latitud': '40.4168',
        'Longitud (WGS84)': '-3.7038',
        'Horario': 'L-V: 08:00-20:00',  // ⚠️ NO es 24h
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
    });

    test('fromJson debe manejar campos opcionales faltantes', () {
    // JSON mínimo sin campos opcionales
    final jsonMinimo = {
        'IDEESS': '99999',
        'Latitud': '40.4168',
        'Longitud (WGS84)': '-3.7038',
        // Faltan: Rótulo, Dirección, Horario, Provincia, todos los precios
    };
    // No debe crashear
    final gasolinera = Gasolinera.fromJson(jsonMinimo);
    expect(gasolinera.id, '99999');
    expect(gasolinera.rotulo, 'Sin Rótulo');  // Valor por defecto
    expect(gasolinera.gasolina95, 0.0);  // Precio por defecto
    });
  });



}
