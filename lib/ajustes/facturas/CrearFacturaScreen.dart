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
        });
      }
    } catch (e) {
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al tomar foto: $e')),
      );
    }
  }

  void _mostrarOpcionesImagen() {
    // Colores dinámicos para el modal
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF2C2C2C) : const Color(0xFFFFE8DA);
    final textColor = isDark ? Colors.white : const Color(0xFF492714);

    showModalBottomSheet(
      context: context,
      backgroundColor: bgColor,
      builder: (context) => Wrap(
        children: [
          ListTile(
            leading: Icon(Icons.photo_library, color: textColor),
            title: Text('Galería', style: TextStyle(color: textColor)),
            onTap: () {
              Navigator.pop(context);
              _seleccionarImagen();
            },
          ),
          ListTile(
            leading: Icon(Icons.camera_alt, color: textColor),
            title: Text('Cámara', style: TextStyle(color: textColor)),
            onTap: () {
              Navigator.pop(context);
              _tomarFoto();
            },
          ),
        ],
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al crear factura: $e')),
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

  // Widget auxiliar para crear TextFields consistentes con el tema
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    VoidCallback? onTap,
    String? Function(String?)? validator,
    String? hintText,
    int maxLines = 1,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Colores del Input
    final fillColor = isDark ? const Color(0xFF2C2C2C) : const Color(0xFFFFCFB0);
    final textColor = isDark ? Colors.white : Colors.black;
    final labelColor = isDark ? Colors.white70 : const Color(0xFF492714);
    final hintColor = isDark ? Colors.white38 : const Color(0x99492714);

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      onTap: onTap,
      maxLines: maxLines,
      style: TextStyle(color: textColor),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: labelColor),
        hintText: hintText,
        hintStyle: TextStyle(color: hintColor),
        filled: true,
        fillColor: fillColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      validator: validator,
    );
  }

  @override
  Widget build(BuildContext context) {
    // --- VARIABLES DE TEMA ---
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = isDark ? const Color(0xFF121212) : const Color(0xFFFFE8DA);
    final headerColor = isDark ? Colors.white : const Color(0xFF492714);
    
    // Colores de inputs (para los dropdowns y contenedores manuales)
    final inputFillColor = isDark ? const Color(0xFF2C2C2C) : const Color(0xFFFFCFB0);
    final inputTextColor = isDark ? Colors.white : const Color(0xFF492714);

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        title: Text(
          'Nueva Factura',
          style: TextStyle(
            color: headerColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: headerColor),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextField(
                    controller: _tituloController,
                    label: 'Título',
                    validator: (value) => (value == null || value.isEmpty) ? 'Por favor ingresa un título' : null,
                  ),
                  const SizedBox(height: 16),

                  _buildTextField(
                    controller: _costoController,
                    label: 'Coste Total (€)',
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Por favor ingresa el coste total';
                      if (double.tryParse(value) == null) return 'Por favor ingresa un número válido';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _fechaController,
                          label: 'Fecha',
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
                      Expanded(
                        child: _buildTextField(
                          controller: _horaController,
                          label: 'Hora',
                          readOnly: true,
                          onTap: () async {
                            final TimeOfDay? picked = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                            );
                            if (picked != null) {
                              _horaController.text = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Text(
                    'Información del Repostaje',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: headerColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Divider(color: headerColor, thickness: 1),
                  const SizedBox(height: 16),

                  // Dropdown Coche
                  DropdownButtonFormField<int>(
                    initialValue: _cocheSeleccionado,
                    decoration: InputDecoration(
                      labelText: 'Coche',
                      labelStyle: TextStyle(color: isDark ? Colors.white70 : const Color(0xFF492714)),
                      filled: true,
                      fillColor: inputFillColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    items: _coches.map((coche) {
                      return DropdownMenuItem<int>(
                        value: coche['id_coche'],
                        child: Text(
                          '${coche['marca']} ${coche['modelo']}',
                          style: TextStyle(color: inputTextColor),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => _cocheSeleccionado = value),
                    dropdownColor: inputFillColor,
                    borderRadius: BorderRadius.circular(10),
                    icon: Icon(Icons.arrow_drop_down, color: inputTextColor),
                  ),
                  const SizedBox(height: 16),

                  _buildTextField(
                    controller: _litrosController,
                    label: 'Litros Repostados',
                    hintText: 'Ej: 45.5',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),

                  _buildTextField(
                    controller: _precioLitroController,
                    label: 'Precio por Litro (€)',
                    hintText: 'Ej: 1.459',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),

                  _buildTextField(
                    controller: _kilometrajeController,
                    label: 'Kilometraje Actual',
                    hintText: 'Ej: 45230',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),

                  // Dropdown Combustible
                  ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: 300, maxWidth: 400),
                    child: DropdownButtonFormField<String>(
                      initialValue: _tipoCombustibleSeleccionado,
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: 'Tipo de Combustible',
                        labelStyle: TextStyle(color: isDark ? Colors.white70 : const Color(0xFF492714)),
                        filled: true,
                        fillColor: inputFillColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      items: _tiposCombustible.map((tipo) {
                        return DropdownMenuItem<String>(
                          value: tipo,
                          child: Text(
                            tipo,
                            style: TextStyle(color: inputTextColor),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) => setState(() => _tipoCombustibleSeleccionado = value),
                      dropdownColor: inputFillColor,
                      borderRadius: BorderRadius.circular(10),
                      icon: Icon(Icons.arrow_drop_down, color: inputTextColor),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Text(
                    'Imagen de Factura',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: headerColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Divider(color: headerColor, thickness: 1),
                  const SizedBox(height: 16),

                  // Botón Imagen
                  Container(
                    width: double.infinity,
                    height: 120,
                    decoration: BoxDecoration(
                      color: inputFillColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: _imagenFactura == null
                        ? TextButton(
                            onPressed: _mostrarOpcionesImagen,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_photo_alternate, size: 40, color: inputTextColor),
                                const SizedBox(height: 8),
                                Text(
                                  'Agregar Imagen de Factura',
                                  style: TextStyle(color: inputTextColor, fontSize: 14),
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
                                      child: CircularProgressIndicator(color: Color(0xFFFF9350)),
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
                                    icon: const Icon(Icons.close, color: Colors.white, size: 20),
                                    onPressed: () => setState(() => _imagenFactura = null),
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ),
                  const SizedBox(height: 16),

                  _buildTextField(
                    controller: _descripcionController,
                    label: 'Descripción (Opcional)',
                    maxLines: 4,
                  ),
                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _guardarFactura,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF9350), // Botón Naranja siempre (Brand color)
                        foregroundColor: const Color(0xFF492714),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF492714)),
                              ),
                            )
                          : const Text(
                              'Guardar Factura',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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