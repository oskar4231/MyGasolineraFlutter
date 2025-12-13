
import 'package:flutter/material.dart';
import 'package:my_gasolinera/ajustes/ajustes.dart';
import 'package:my_gasolinera/services/coche_service.dart';

// Modelo para representar un coche (MANTENIDO EN EL MISMO ARCHIVO)
class Coche {
  final int? idCoche;
  final String marca;
  final String modelo;
  final List<String> tiposCombustible;
  final int? kilometrajeInicial;
  final double? capacidadTanque;
  final double? consumoTeorico;
  final String? fechaUltimoCambioAceite;
  final int? kmUltimoCambioAceite;
  final int intervaloCambioAceiteKm;
  final int intervaloCambioAceiteMeses;

  Coche({
    this.idCoche,
    required this.marca,
    required this.modelo,
    required this.tiposCombustible,
    this.kilometrajeInicial,
    this.capacidadTanque,
    this.consumoTeorico,
    this.fechaUltimoCambioAceite,
    this.kmUltimoCambioAceite,
    this.intervaloCambioAceiteKm = 15000,
    this.intervaloCambioAceiteMeses = 12,
  });

  // Factory para crear un Coche desde JSON del backend
  factory Coche.fromJson(Map<String, dynamic> json) {
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
      kilometrajeInicial: json['kilometraje_inicial'] != null ? int.tryParse(json['kilometraje_inicial'].toString()) : null,
      capacidadTanque: json['capacidad_tanque'] != null ? double.tryParse(json['capacidad_tanque'].toString()) : null,
      consumoTeorico: json['consumo_teorico'] != null ? double.tryParse(json['consumo_teorico'].toString()) : null,
      fechaUltimoCambioAceite: json['fecha_ultimo_cambio_aceite'],
      kmUltimoCambioAceite: json['km_ultimo_cambio_aceite'] != null ? int.tryParse(json['km_ultimo_cambio_aceite'].toString()) : null,
      intervaloCambioAceiteKm: json['intervalo_cambio_aceite_km'] != null ? int.tryParse(json['intervalo_cambio_aceite_km'].toString()) ?? 15000 : 15000,
      intervaloCambioAceiteMeses: json['intervalo_cambio_aceite_meses'] != null ? int.tryParse(json['intervalo_cambio_aceite_meses'].toString()) ?? 12 : 12,
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
  final _kilometrajeInicialController = TextEditingController();
  final _capacidadTanqueController = TextEditingController();
  final _consumoTeoricoController = TextEditingController();
  final _fechaUltimoCambioAceiteController = TextEditingController(); // NUEVO
  final _kmUltimoCambioAceiteController = TextEditingController();
  final _intervaloKmController = TextEditingController(text: '15000');
  final _intervaloMesesController = TextEditingController(text: '12');

  final List<Coche> _coches = [];
  bool _isLoading = false;

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
    _cargarCoches();
  }

  // Función para cargar los coches usando el servicio
  Future<void> _cargarCoches() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final cochesJson = await CocheService.obtenerCoches();

       final List<Map<String, dynamic>> cochesList = List<Map<String, dynamic>>.from(cochesJson);

      setState(() {
        _coches.clear();
        _coches.addAll(
        cochesList.map((json) => Coche.fromJson(json)).toList(),
      );
      });
      print('✅ ${_coches.length} coches cargados');
    } catch (error) {
      print('Error al cargar coches: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar los coches: $error'),
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

  // Función para crear un coche usando el servicio
  Future<void> _crearCoche() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Obtener los combustibles seleccionados
      final combustiblesSeleccionados = _tiposCombustible.entries
          .where((entry) => entry.value)
          .map((entry) => entry.key)
          .toList();

      await CocheService.crearCoche(
        marca: _marcaController.text,
        modelo: _modeloController.text,
        tiposCombustible: combustiblesSeleccionados,
        kilometrajeInicial: _kilometrajeInicialController.text.isNotEmpty
          ? int.tryParse(_kilometrajeInicialController.text)
          : null,
      capacidadTanque: _capacidadTanqueController.text.isNotEmpty
          ? double.tryParse(_capacidadTanqueController.text)
          : null,
      consumoTeorico: _consumoTeoricoController.text.isNotEmpty
          ? double.tryParse(_consumoTeoricoController.text)
          : null,
      fechaUltimoCambioAceite: _fechaUltimoCambioAceiteController.text.isNotEmpty
          ? _fechaUltimoCambioAceiteController.text
          : null,
      kmUltimoCambioAceite: _kmUltimoCambioAceiteController.text.isNotEmpty
          ? int.tryParse(_kmUltimoCambioAceiteController.text)
          : null,
      intervaloCambioAceiteKm: int.tryParse(_intervaloKmController.text) ?? 15000,
      intervaloCambioAceiteMeses: int.tryParse(_intervaloMesesController.text) ?? 12,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Coche creado exitosamente: ${_marcaController.text} ${_modeloController.text}'),
            backgroundColor: Colors.green,
          ),
        );

        await _cargarCoches();
      }
    } catch (error) {
      print('Error al crear coche: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al crear coche: $error'),
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
  void dispose() {
    _marcaController.dispose();
    _modeloController.dispose();
    _kilometrajeInicialController.dispose();
    _capacidadTanqueController.dispose();
    _consumoTeoricoController.dispose();
    _fechaUltimoCambioAceiteController.dispose();
    _kmUltimoCambioAceiteController.dispose();
    _intervaloKmController.text='15000';
    _intervaloMesesController.text='12';
    super.dispose();
  }

  void _mostrarModalFormulario() {
    _marcaController.clear();
    _modeloController.clear();
    _tiposCombustible.updateAll((key, value) => false);
    _kilometrajeInicialController.clear();
    _capacidadTanqueController.clear();
    _consumoTeoricoController.clear();
    _fechaUltimoCambioAceiteController.clear();
    _kmUltimoCambioAceiteController.clear();
    _intervaloKmController.text='15000';
    _intervaloMesesController.text='12';

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

                      const Text(
                        'Tipo de Combustible:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),

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

                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _kilometrajeInicialController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Kilometraje Inicial',
                          hintText: 'Ej: 50000',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _capacidadTanqueController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Capacidad del Tanque (L)',
                          hintText: 'Ej: 50',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _consumoTeoricoController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Consumo Teórico (L/100km)',
                          hintText: 'Ej: 5.5',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _intervaloKmController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Intervalo de Kilometros',
                          hintText: 'Ej: 15000',
                          border: OutlineInputBorder(),   
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _intervaloMesesController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Intervalo de Meses',
                          hintText: 'Ej: 12',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () async {
                          if (_formKey.currentState!.validate()) {
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

                            Navigator.of(context).pop();
                            await _crearCoche();
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

  // Función para eliminar un coche usando el servicio
  Future<void> _eliminarCoche(int index) async {
    final coche = _coches[index];

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

    setState(() {
      _isLoading = true;
    });

    try {
      await CocheService.eliminarCoche(coche.idCoche!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Coche eliminado: ${coche.marca} ${coche.modelo}'),
            backgroundColor: Colors.green,
          ),
        );

        await _cargarCoches();
      }
    } catch (error) {
      print('Error al eliminar coche: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar coche: $error'),
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
                                              if (coche.kilometrajeInicial != null)
                                                Text(
                                                  'Kilometraje: ${coche.kilometrajeInicial} km',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              if (coche.capacidadTanque != null)
                                                Text(
                                                  'Tanque: ${coche.capacidadTanque}L',
                                                  style: const TextStyle(
                                                    fontSize: 12,
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
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.directions_car,
                      size: 40,
                      color: Color(0xFF492714),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.pin_drop, size: 40),
                  ),
                  IconButton(
                    onPressed: () {
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