import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'package:my_gasolinera/services/factura_service.dart';
import 'package:my_gasolinera/services/coche_service.dart';


class CrearFacturaScreen extends StatefulWidget {
  const CrearFacturaScreen({super.key});

  @override
  State<CrearFacturaScreen> createState() => _CrearFacturaScreenState();
}

class _CrearFacturaScreenState extends State<CrearFacturaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _costoController = TextEditingController();
  final _fechaController = TextEditingController();
  final _horaController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _litrosController = TextEditingController();
  final _precioLitroController = TextEditingController();
  final _kilometrajeController = TextEditingController();

  String? _tipoCombustibleSeleccionado;
  int? _cocheSeleccionado;
  List<Map<String, dynamic>> _coches = [];
  
  final List<String> _tiposCombustible = [
    'Gasolina 95',
    'Gasolina 98',
    'Diésel',
    'Diésel Premium',
    'GLP (Autogas)',
  ];

  XFile? _imagenFactura;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Establecer fecha y hora actual por defecto
    final now = DateTime.now();
    _fechaController.text = _formatDate(now);
    _horaController.text = _formatTime(now);

    _cargarCoches();
  }

  Future<void> _cargarCoches() async {
    try {
      final coches = await CocheService.obtenerCoches();
      if (mounted) {
        setState(() {
          _coches = coches.cast<Map<String, dynamic>>();
          print('✅ ${_coches.length} coches cargados en el formulario');
        });
      }
    } catch (e) {
      print('❌ Error cargando coches: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar coches: $e')),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _seleccionarImagen() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _imagenFactura = image;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al seleccionar imagen: $e')),
      );
    }
  }

  void _tomarFoto() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        setState(() {
          _imagenFactura = image;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al tomar foto: $e')));
    }
  }

  void _mostrarOpcionesImagen() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        color: const Color(0xFFFFE8DA),
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(
                Icons.photo_library,
                color: Color(0xFF492714),
              ),
              title: const Text(
                'Galería',
                style: TextStyle(color: Color(0xFF492714)),
              ),
              onTap: () {
                Navigator.pop(context);
                _seleccionarImagen();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFF492714)),
              title: const Text(
                'Cámara',
                style: TextStyle(color: Color(0xFF492714)),
              ),
              onTap: () {
                Navigator.pop(context);
                _tomarFoto();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _guardarFactura() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        await FacturaService.crearFactura(
          titulo: _tituloController.text,
          coste: double.parse(_costoController.text),
          fecha: _fechaController.text,
          hora: _horaController.text,
          descripcion: _descripcionController.text,
          imagenFile: _imagenFactura,
          litrosRepostados: _litrosController.text.isNotEmpty ? double.parse(_litrosController.text) : null,
          precioPorLitro: _precioLitroController.text.isNotEmpty ? double.parse(_precioLitroController.text) : null,
          kilometrajeActual: _kilometrajeController.text.isNotEmpty ? int.parse(_kilometrajeController.text) : null,
          tipoCombustible: _tipoCombustibleSeleccionado,
          idCoche: _cocheSeleccionado,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Factura creada correctamente')),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error al crear factura: $e')));
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _costoController.dispose();
    _fechaController.dispose();
    _horaController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFE8DA),
      appBar: AppBar(
        title: const Text(
          'Nueva Factura',
          style: TextStyle(
            color: Color(0xFF492714),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF492714)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Campo Título
                  TextFormField(
                    controller: _tituloController,
                    decoration: InputDecoration(
                      labelText: 'Título',
                      labelStyle: const TextStyle(color: Color(0xFF492714)),
                      filled: true,
                      fillColor: const Color(0xFFFFCFB0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa un título';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Campo Coste Total
                  TextFormField(
                    controller: _costoController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Coste Total (€)',
                      labelStyle: const TextStyle(color: Color(0xFF492714)),
                      filled: true,
                      fillColor: const Color(0xFFFFCFB0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa el coste total';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Por favor ingresa un número válido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Campos Fecha y Hora en fila
                  Row(
                    children: [
                      // Campo Fecha
                      Expanded(
                        child: TextFormField(
                          controller: _fechaController,
                          decoration: InputDecoration(
                            labelText: 'Fecha',
                            labelStyle: const TextStyle(
                              color: Color(0xFF492714),
                            ),
                            filled: true,
                            fillColor: const Color(0xFFFFCFB0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          readOnly: true,
                          onTap: () async {
                            final DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              _fechaController.text = _formatDate(picked);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Campo Hora
                      Expanded(
                        child: TextFormField(
                          controller: _horaController,
                          decoration: InputDecoration(
                            labelText: 'Hora',
                            labelStyle: const TextStyle(
                              color: Color(0xFF492714),
                            ),
                            filled: true,
                            fillColor: const Color(0xFFFFCFB0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          readOnly: true,
                          onTap: () async {
                            final TimeOfDay? picked = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                            );
                            if (picked != null) {
                              _horaController.text =
                                  '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // NUEVA SECCIÓN: Información del Repostaje
                  const Text(
                    'Información del Repostaje',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF492714),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Divider(color: Color(0xFF492714), thickness: 1),
                  const SizedBox(height: 16),

                  // Dropdown Coche
                  DropdownButtonFormField<int>(
                    value: _cocheSeleccionado,
                    decoration: InputDecoration(
                      labelText: 'Coche',
                      labelStyle: const TextStyle(color: Color(0xFF492714)),
                      filled: true,
                      fillColor: const Color(0xFFFFCFB0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    items: _coches.map((coche) {
                      return DropdownMenuItem<int>(
                        value: coche['id_coche'],
                        child: Text(
                          '${coche['marca']} ${coche['modelo']}',
                          style: const TextStyle(color: Color(0xFF492714)),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _cocheSeleccionado = value);
                    },
                    dropdownColor: const Color(0xFFFFCFB0),
                    borderRadius: BorderRadius.circular(10),
                    icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF492714)),
                  ),
                  const SizedBox(height: 16),

                  // Campo Litros Repostados
                  TextFormField(
                    controller: _litrosController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Litros Repostados',
                      hintText: 'Ej: 45.5',
                      labelStyle: const TextStyle(color: Color(0xFF492714)),
                      hintStyle: const TextStyle(color: Color(0x99492714)),
                      filled: true,
                      fillColor: const Color(0xFFFFCFB0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Campo Precio por Litro
                  TextFormField(
                    controller: _precioLitroController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Precio por Litro (€)',
                      hintText: 'Ej: 1.459',
                      labelStyle: const TextStyle(color: Color(0xFF492714)),
                      hintStyle: const TextStyle(color: Color(0x99492714)),
                      filled: true,
                      fillColor: const Color(0xFFFFCFB0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Campo Kilometraje Actual
                  TextFormField(
                    controller: _kilometrajeController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Kilometraje Actual',
                      hintText: 'Ej: 45230',
                      labelStyle: const TextStyle(color: Color(0xFF492714)),
                      hintStyle: const TextStyle(color: Color(0x99492714)),
                      filled: true,
                      fillColor: const Color(0xFFFFCFB0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  ConstrainedBox(
                    constraints: const BoxConstraints(
                      minWidth: 300,  // Ancho mínimo
                      maxWidth: 400,  // Ancho máximo
                    ),
                  // Dropdown Tipo de Combustible 
                  child:DropdownButtonFormField<String>(
                    value: _tipoCombustibleSeleccionado,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: 'Tipo de Combustible',
                      labelStyle: const TextStyle(color: Color(0xFF492714)),
                      filled: true,
                      fillColor: const Color(0xFFFFCFB0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    items: _tiposCombustible.map((tipo) {
                      return DropdownMenuItem<String>(
                        value: tipo,
                        child: Text(
                          tipo,
                          style: const TextStyle(color: Color(0xFF492714)),
                          
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _tipoCombustibleSeleccionado = value);
                    },
                    dropdownColor: const Color(0xFFFFCFB0),
                    borderRadius: BorderRadius.circular(10),
                    icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF492714)),
                  ),
                  ),
                  const SizedBox(height: 16),

                  // NUEVA SECCIÓN: Imagen de Factura
                  const Text(
                    'Imagen de Factura',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF492714),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Divider(color: Color(0xFF492714), thickness: 1),
                  const SizedBox(height: 16),

                  // Botón para agregar imagen
                  Container(
                    width: double.infinity,
                    height: 120,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFCFB0),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: _imagenFactura == null
                        ? TextButton(
                            onPressed: _mostrarOpcionesImagen,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(
                                  Icons.add_photo_alternate,
                                  size: 40,
                                  color: Color(0xFF492714),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Agregar Imagen de Factura',
                                  style: TextStyle(
                                    color: Color(0xFF492714),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: FutureBuilder(
                                  future: _imagenFactura!.readAsBytes(),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData) {
                                      return Image.memory(
                                        snapshot.data as Uint8List,
                                        width: double.infinity,
                                        height: double.infinity,
                                        fit: BoxFit.cover,
                                      );
                                    }
                                    return const Center(
                                      child: CircularProgressIndicator(
                                        color: Color(0xFFFF9350),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.black54,
                                  ),
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _imagenFactura = null;
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ),
                  const SizedBox(height: 16),

                  // Campo Descripción
                  TextFormField(
                    controller: _descripcionController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: 'Descripción (Opcional)',
                      labelStyle: const TextStyle(color: Color(0xFF492714)),
                      filled: true,
                      fillColor: const Color(0xFFFFCFB0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Botón Guardar
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _guardarFactura,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF9350),
                        foregroundColor: const Color(0xFF492714),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                        shadowColor: const Color(0xFF492714).withOpacity(0.3),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFF492714),
                                ),
                              ),
                            )
                          : const Text(
                              'Guardar Factura',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(color: Color(0xFFFF9350)),
              ),
            ),
        ],
      ),
    );
  }
}