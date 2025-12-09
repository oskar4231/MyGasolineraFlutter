import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_gasolinera/ajustes/ajustes.dart';
import 'dart:convert';
import 'package:my_gasolinera/services/auth_service.dart';

// Modelo para representar un coche
class Coche {
  final int? idCoche; // ID del coche en la base de datos
  final String marca;
  final String modelo;
  final List<String> tiposCombustible;

  Coche({
    this.idCoche,
    required this.marca,
    required this.modelo,
    required this.tiposCombustible,
  });

  // Factory para crear un Coche desde JSON del backend
  factory Coche.fromJson(Map<String, dynamic> json) {
    // El backend envía combustible como string, lo convertimos a lista
    List<String> combustibles = [];
    if (json['combustible'] != null) {
      combustibles = json['combustible']
          .toString()
          .split(', ')
          .map((e) => e.trim())
          .toList();
    }

    return Coche(
      idCoche: json['id_coche'],
      marca: json['marca'] ?? '',
      modelo: json['modelo'] ?? '',
      tiposCombustible: combustibles,
    );
  }
}

class CochesScreen extends StatefulWidget {
  const CochesScreen({super.key});

  @override
  State<CochesScreen> createState() => _CochesScreenState();
}

class _CochesScreenState extends State<CochesScreen> {
  final _formKey = GlobalKey<FormState>();
  final _marcaController = TextEditingController();
  final _modeloController = TextEditingController();

  // Lista de coches guardados
  final List<Coche> _coches = [];

  // Estado de carga
  bool _isLoading = false;

  // Tipos de combustible disponibles en España
  final Map<String, bool> _tiposCombustible = {
    'Gasolina 95': false,
    'Gasolina 98': false,
    'Diésel': false,
    'Diésel Premium': false,
    'GLP (Autogas)': false,
    'Híbrido': false,
  };

  @override
  void initState() {
    super.initState();
    _cargarCoches(); // Cargar coches al iniciar la pantalla
  }

  // Función para cargar los coches del usuario desde el backend
  Future<void> _cargarCoches() async {
    final token = AuthService.getToken();

    if (token == null || token.isEmpty) {
      print('No hay token, usuario no autenticado');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final url = Uri.parse('http://localhost:3000/coches');

      print('Cargando coches desde: $url');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Respuesta status: ${response.statusCode}');
      print('Respuesta body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> cochesJson = json.decode(response.body);

        setState(() {
          _coches.clear();
          _coches.addAll(
            cochesJson.map((json) => Coche.fromJson(json)).toList(),
          );
        });

        print('✅ ${_coches.length} coches cargados');
      } else {
        print('Error al cargar coches: ${response.statusCode}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error al cargar los coches'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (error) {
      print('Error de conexión al cargar coches: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error de conexión: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _crearCoche(
    String marca,
    String modelo,
    List<String> tiposCombustible,
  ) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Use http://10.0.2.2:3000/insertCar for Android Emulator
      // Use http://localhost:3000/insertCar for iOS Simulator or Web
      final url = Uri.parse('http://localhost:3000/insertCar');

      // Convertir el array de combustibles a un string separado por comas
      final combustibleString = tiposCombustible.join(', ');

      print('Intentando crear coche en: $url');
      print('Marca: $marca');
      print('Modelo: $modelo');
      print('Combustible: $combustibleString');

      // TODO: Obtener el token del almacenamiento local (SharedPreferences)
      // Por ahora, necesitas iniciar sesión primero para obtener el token
      final token =
          AuthService.getToken() ?? ''; // Obtener el token guardado del login

      if (token.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Debes iniciar sesión primero para añadir coches'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
            ),
          );
        }
        return;
      }

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization':
              'Bearer $token', // Token JWT requerido por el backend
        },
        body: json.encode({
          'marca': marca,
          'modelo': modelo,
          'combustible': combustibleString,
        }),
      );

      print('Respuesta status: ${response.statusCode}');
      print('Respuesta body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);

        // Creación exitosa
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Coche creado exitosamente: $marca $modelo'),
              backgroundColor: Colors.green,
            ),
          );

          // Recargar la lista de coches desde el backend
          await _cargarCoches();
        }
      } else {
        // Creación fallida (400, 401, 409, 500)
        final responseData = json.decode(response.body);
        if (mounted) {
          String errorMessage =
              responseData['message'] ?? 'Error al crear el coche';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
          );
        }
      }
    } catch (error) {
      print('Error de conexión: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error de conexión. Asegúrate de que el servidor esté corriendo. ($error)',
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _marcaController.dispose();
    _modeloController.dispose();
    super.dispose();
  }

  void _mostrarModalFormulario() {
    // Resetear el formulario
    _marcaController.clear();
    _modeloController.clear();
    _tiposCombustible.updateAll((key, value) => false);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text(
                'Añadir Coche',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Campo Marca
                      TextFormField(
                        controller: _marcaController,
                        decoration: const InputDecoration(
                          labelText: 'Marca',
                          hintText: 'Ej: Toyota, BMW, Seat...',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.directions_car),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa la marca';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // Campo Modelo
                      TextFormField(
                        controller: _modeloController,
                        decoration: const InputDecoration(
                          labelText: 'Modelo',
                          hintText: 'Ej: Corolla, Serie 3, León...',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.car_crash),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa el modelo';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Tipo de Combustible
                      const Text(
                        'Tipo de Combustible:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Checkboxes para tipos de combustible
                      ..._tiposCombustible.keys.map((tipo) {
                        return CheckboxListTile(
                          title: Text(tipo),
                          value: _tiposCombustible[tipo],
                          onChanged: (bool? value) {
                            setDialogState(() {
                              _tiposCombustible[tipo] = value ?? false;
                            });
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                          dense: true,
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () async {
                          if (_formKey.currentState!.validate()) {
                            // Verificar que al menos un tipo de combustible esté seleccionado
                            bool alMenosUnoCombustible = _tiposCombustible
                                .values
                                .any((v) => v);

                            if (!alMenosUnoCombustible) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Selecciona al menos un tipo de combustible',
                                  ),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                              return;
                            }

                            // Obtener los combustibles seleccionados
                            List<String> combustiblesSeleccionados =
                                _tiposCombustible.entries
                                    .where((entry) => entry.value)
                                    .map((entry) => entry.key)
                                    .toList();

                            // Cerrar el modal primero
                            Navigator.of(context).pop();

                            // Llamar a la función para crear el coche en el backend
                            await _crearCoche(
                              _marcaController.text,
                              _modeloController.text,
                              combustiblesSeleccionados,
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF9350),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Función para eliminar un coche del backend
  Future<void> _eliminarCoche(int index) async {
    final coche = _coches[index];

    // Verificar que el coche tenga ID
    if (coche.idCoche == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: El coche no tiene ID'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // Confirmar eliminación
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text(
          '¿Estás seguro de que quieres eliminar ${coche.marca} ${coche.modelo}?',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.black),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFFF9350)),
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    final token = AuthService.getToken();

    if (token == null || token.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Debes iniciar sesión para eliminar coches'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final url = Uri.parse('http://localhost:3000/coches/${coche.idCoche}');

      print('Eliminando coche: ${coche.idCoche}');

      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Respuesta status: ${response.statusCode}');
      print('Respuesta body: ${response.body}');

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Coche eliminado: ${coche.marca} ${coche.modelo}'),
              backgroundColor: Colors.green,
            ),
          );

          // Recargar la lista de coches desde el backend
          await _cargarCoches();
        }
      } else {
        final responseData = json.decode(response.body);
        if (mounted) {
          String errorMessage =
              responseData['message'] ?? 'Error al eliminar el coche';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
          );
        }
      }
    } catch (error) {
      print('Error al eliminar coche: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error de conexión: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFE2CE),
      body: SafeArea(
        child: Column(
          children: [
            // Header con título "Coches"
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFFF9350),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Coches',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF492714),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Botón "+" que ocupa todo el ancho
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _mostrarModalFormulario,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFB380),
                        foregroundColor: const Color(0xFF492714),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add, size: 28),
                          SizedBox(width: 8),
                          Text(
                            'Añadir Coche',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Lista de coches
            Expanded(
              child: _coches.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.directions_car_outlined,
                            size: 80,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No hay coches añadidos',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Pulsa el botón "Añadir Coche" para empezar',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _coches.length,
                      itemBuilder: (context, index) {
                        final coche = _coches[index];
                        return Card(
                          elevation: 4,
                          margin: const EdgeInsets.only(bottom: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFFFFFF), Color(0xFFFFF5EE)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFF9350),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.directions_car,
                                          color: Colors.white,
                                          size: 32,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              coche.marca,
                                              style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF492714),
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              coche.modelo,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () => _eliminarCoche(index),
                                        icon: const Icon(
                                          Icons.delete_outline,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  const Divider(),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Tipos de combustible:',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF492714),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: coche.tiposCombustible.map((
                                      combustible,
                                    ) {
                                      return Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(
                                            0xFFFF9350,
                                          ).withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          border: Border.all(
                                            color: const Color(0xFFFF9350),
                                            width: 1,
                                          ),
                                        ),
                                        child: Text(
                                          combustible,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF492714),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),

            // Barra de navegación inferior
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: const BoxDecoration(
                color: Color(0xFFFF9350),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Botón coche (ya estamos en esta pantalla)
                  IconButton(
                    onPressed: () {
                      // Ya estamos en la pantalla de coches
                    },
                    icon: const Icon(
                      Icons.directions_car,
                      size: 40,
                      color: Color(0xFF492714),
                    ),
                  ),

                  // Botón pin (volver a home)
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.pin_drop, size: 40),
                  ),

                  // Botón ajustes
                  IconButton(
                    onPressed: () {
                      // Navegar a ajustes si existe
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const AjustesScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.settings, size: 40),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
