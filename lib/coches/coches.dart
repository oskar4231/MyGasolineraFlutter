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
  final _fechaUltimoCambioAceiteController = TextEditingController();
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

  Future<void> _crearCoche() async {
    setState(() {
      _isLoading = true;
    });

    try {
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
            content: Text('Coche creado exitosamente: ${_marcaController.text} ${_modeloController.text}'),
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

    // --- VARIABLES DE TEMA PARA DIALOGO ---
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dialogBg = isDark ? const Color(0xFF2C2C2C) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final hintColor = isDark ? Colors.white38 : Colors.black38;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: dialogBg,
              title: Text(
                'Añadir Coche',
                style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
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
                        style: TextStyle(color: textColor),
                        decoration: InputDecoration(
                          labelText: 'Marca',
                          labelStyle: TextStyle(color: textColor.withOpacity(0.7)),
                          hintText: 'Ej: Toyota, BMW, Seat...',
                          hintStyle: TextStyle(color: hintColor),
                          border: const OutlineInputBorder(),
                          prefixIcon: Icon(Icons.directions_car, color: textColor),
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
                        style: TextStyle(color: textColor),
                        decoration: InputDecoration(
                          labelText: 'Modelo',
                          labelStyle: TextStyle(color: textColor.withOpacity(0.7)),
                          hintText: 'Ej: Corolla, Serie 3, León...',
                          hintStyle: TextStyle(color: hintColor),
                          border: const OutlineInputBorder(),
                          prefixIcon: Icon(Icons.car_crash, color: textColor),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa el modelo';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      Text(
                        'Tipo de Combustible:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 8),

                      ..._tiposCombustible.keys.map((tipo) {
                        return CheckboxListTile(
                          title: Text(tipo, style: TextStyle(color: textColor)),
                          value: _tiposCombustible[tipo],
                          activeColor: const Color(0xFFFF9350),
                          checkColor: Colors.white,
                          side: BorderSide(color: textColor.withOpacity(0.6)),
                          onChanged: (bool? value) {
                            setDialogState(() {
                              _tiposCombustible[tipo] = value ?? false;
                            });
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                          dense: true,
                        );
                      }),

                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _kilometrajeInicialController,
                        keyboardType: TextInputType.number,
                        style: TextStyle(color: textColor),
                        decoration: InputDecoration(
                          labelText: 'Kilometraje Inicial',
                          labelStyle: TextStyle(color: textColor.withOpacity(0.7)),
                          hintText: 'Ej: 50000',
                          hintStyle: TextStyle(color: hintColor),
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _capacidadTanqueController,
                        keyboardType: TextInputType.number,
                        style: TextStyle(color: textColor),
                        decoration: InputDecoration(
                          labelText: 'Capacidad del Tanque (L)',
                          labelStyle: TextStyle(color: textColor.withOpacity(0.7)),
                          hintText: 'Ej: 50',
                          hintStyle: TextStyle(color: hintColor),
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _consumoTeoricoController,
                        keyboardType: TextInputType.number,
                        style: TextStyle(color: textColor),
                        decoration: InputDecoration(
                          labelText: 'Consumo Teórico (L/100km)',
                          labelStyle: TextStyle(color: textColor.withOpacity(0.7)),
                          hintText: 'Ej: 5.5',
                          hintStyle: TextStyle(color: hintColor),
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cancelar', style: TextStyle(color: textColor)),
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
                    foregroundColor: Colors.white,
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

    // Variables de tema para el diálogo de eliminación
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dialogBg = isDark ? const Color(0xFF2C2C2C) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: dialogBg,
        title: Text('Confirmar eliminación', style: TextStyle(color: textColor)),
        content: Text(
          '¿Estás seguro de que quieres eliminar ${coche.marca} ${coche.modelo}?',
          style: TextStyle(fontSize: 16, color: textColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancelar',
              style: TextStyle(color: textColor),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF9350)),
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Colors.white),
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
    // --- LÓGICA DE COLORES DINÁMICOS ---
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Background: Crema en claro, Negro en oscuro
    final scaffoldBg = isDark ? const Color(0xFF121212) : const Color(0xFFFFE2CE);
    
    // Header/Footer Background: Naranja en claro, Gris oscuro en oscuro
    final barBg = isDark ? const Color(0xFF1F1F1F) : const Color(0xFFFF9350);
    
    // Textos principales: Marrón en claro, Blanco en oscuro
    final titleColor = isDark ? Colors.white : const Color(0xFF492714);
    
    // Botón "Añadir Coche": Melocotón en claro, Gris medio en oscuro
    final btnAddBg = isDark ? const Color(0xFF333333) : const Color(0xFFFFB380);
    final btnAddFg = isDark ? Colors.white : const Color(0xFF492714);

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: barBg,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Coches',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _mostrarModalFormulario,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: btnAddBg,
                        foregroundColor: btnAddFg,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                      ),
                      child: const Row(
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

            // LISTA DE COCHES
            Expanded(
              child: _coches.isEmpty
                  ? const Center(
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
                        
                        // Configuración de la tarjeta según el modo
                        final cardDecoration = isDark
                            ? BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: const Color(0xFF2C2C2C), // Gris en oscuro
                              )
                            : BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFFFFFFF), Color(0xFFFFF5EE)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              );
                        
                        final cardTextColor = isDark ? Colors.white : const Color(0xFF492714);
                        final cardSubtextColor = isDark ? Colors.white70 : Colors.grey;

                        return Card(
                          elevation: 4,
                          margin: const EdgeInsets.only(bottom: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          // En dark mode el color lo pone el container, en light el container tiene gradiente
                          color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
                          child: Container(
                            decoration: cardDecoration,
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
                                          color: const Color(0xFFFF9350), // Mantenemos acento naranja
                                          borderRadius: BorderRadius.circular(12),
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
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: cardTextColor,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              coche.modelo,
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: cardSubtextColor,
                                              ),
                                            ),
                                            if (coche.kilometrajeInicial != null)
                                              Text(
                                                'Kilometraje: ${coche.kilometrajeInicial} km',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: cardSubtextColor,
                                                ),
                                              ),
                                            if (coche.capacidadTanque != null)
                                              Text(
                                                'Tanque: ${coche.capacidadTanque}L',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: cardSubtextColor,
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
                                  Divider(color: isDark ? Colors.white24 : Colors.grey[300]),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Tipos de combustible:',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: cardTextColor,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: coche.tiposCombustible.map((combustible) {
                                      return Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFF9350).withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(
                                            color: const Color(0xFFFF9350),
                                            width: 1,
                                          ),
                                        ),
                                        child: Text(
                                          combustible,
                                          style: TextStyle(
                                            fontSize: 12,
                                            // En los tags, siempre mantenemos el marrón para que contraste con el naranja
                                            // O si prefieres blanco en dark mode:
                                            color: isDark ? Colors.white : const Color(0xFF492714),
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

            // FOOTER (Barra de navegación)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: barBg,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.directions_car,
                      size: 40,
                      color: isDark ? Colors.white : const Color(0xFF492714),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.pin_drop, size: 40, color: isDark ? Colors.white : Colors.black),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const AjustesScreen(),
                        ),
                      );
                    },
                    icon: Icon(Icons.settings, size: 40, color: isDark ? Colors.white : Colors.black),
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