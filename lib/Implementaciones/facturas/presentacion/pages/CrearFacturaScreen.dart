import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_gasolinera/core/l10n/app_localizations.dart';
import 'package:my_gasolinera/Implementaciones/facturas/presentacion/controllers/crear_factura_controller.dart';
import 'package:my_gasolinera/Implementaciones/facturas/presentacion/widgets/factura_header.dart';
import 'package:my_gasolinera/Implementaciones/facturas/presentacion/widgets/factura_form.dart';
import 'package:my_gasolinera/Implementaciones/facturas/presentacion/widgets/info_repostaje.dart';
import 'package:my_gasolinera/Implementaciones/facturas/presentacion/widgets/imagen_factura.dart';

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

  late CrearFacturaController _controller;

  String? _tipoCombustibleSeleccionado;
  int? _cocheSeleccionado;
  List<Map<String, dynamic>> _coches = [];

  XFile? _imagenFactura;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = CrearFacturaController();
    _inicializar();
  }

  Future<void> _inicializar() async {
    final now = DateTime.now();
    _fechaController.text = _controller.formatDate(now);
    _horaController.text = _controller.formatTime(now);
    await _cargarCoches();
  }

  Future<void> _cargarCoches() async {
    try {
      final coches = await _controller.cargarCoches();
      if (mounted) {
        setState(() {
          _coches = coches;
          print('✅ ${_coches.length} coches cargados');
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

  void _mostrarOpcionesEscaneo() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.photo_library,
                  color: Theme.of(context).colorScheme.onSurface),
              title: Text('Galería',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface)),
              onTap: () {
                Navigator.pop(context);
                _procesarEscaneo(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: Icon(Icons.camera_alt,
                  color: Theme.of(context).colorScheme.onSurface),
              title: Text('Cámara',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface)),
              onTap: () {
                Navigator.pop(context);
                _procesarEscaneo(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarOpcionesImagen() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.photo_library,
                  color: Theme.of(context).colorScheme.onSurface),
              title: Text(AppLocalizations.of(context)!.galeria,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface)),
              onTap: () {
                Navigator.pop(context);
                _seleccionarImagen();
              },
            ),
            ListTile(
              leading: Icon(Icons.camera_alt,
                  color: Theme.of(context).colorScheme.onSurface),
              title: Text(AppLocalizations.of(context)!.camara,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface)),
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

  Future<void> _seleccionarImagen() async {
    try {
      final image = await _controller.seleccionarImagenGaleria();
      if (image != null && mounted) {
        setState(() => _imagenFactura = image);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  '${AppLocalizations.of(context)!.errorSeleccionarImagen}: $e')),
        );
      }
    }
  }

  Future<void> _tomarFoto() async {
    try {
      final image = await _controller.tomarFoto();
      if (image != null && mounted) {
        setState(() => _imagenFactura = image);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  '${AppLocalizations.of(context)!.errorSeleccionarImagen}: $e')),
        );
      }
    }
  }

  Future<void> _procesarEscaneo(ImageSource source) async {
    try {
      final image = source == ImageSource.gallery
          ? await _controller.seleccionarImagenGaleria()
          : await _controller.tomarFoto();

      if (image == null) return;

      setState(() {
        _isLoading = true;
        _imagenFactura = image;
      });

      final data = await _controller.procesarEscaneo(image.path);

      setState(() {
        if (data['fecha'] != null) _fechaController.text = data['fecha'];
        if (data['total'] != null) {
          _costoController.text = data['total'].toString();
        }
        if (data['litros'] != null) {
          _litrosController.text = data['litros'].toString();
        }
        if (data['precio_litro'] != null) {
          _precioLitroController.text = data['precio_litro'].toString();
        }
        if (data['gasolinera'] != null && _tituloController.text.isEmpty) {
          _tituloController.text = "Repostaje ${data['gasolinera']}";
        } else if (_tituloController.text.isEmpty) {
          _tituloController.text = "Repostaje Escaneado";
        }
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Datos escaneados.')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al escanear: $e')),
        );
      }
    }
  }

  Future<void> _guardarFactura() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        await _controller.guardarFactura(
          titulo: _tituloController.text,
          coste: double.parse(_costoController.text),
          fecha: _fechaController.text,
          hora: _horaController.text,
          descripcion: _descripcionController.text,
          imagen: _imagenFactura,
          litrosRepostados: _litrosController.text.isNotEmpty
              ? double.parse(_litrosController.text)
              : null,
          precioPorLitro: _precioLitroController.text.isNotEmpty
              ? double.parse(_precioLitroController.text)
              : null,
          kilometrajeActual: _kilometrajeController.text.isNotEmpty
              ? int.parse(_kilometrajeController.text)
              : null,
          tipoCombustible: _tipoCombustibleSeleccionado,
          idCoche: _cocheSeleccionado,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text(AppLocalizations.of(context)!.facturaCreadaExito)),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    '${AppLocalizations.of(context)!.errorCrearFactura}: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
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
    _litrosController.dispose();
    _precioLitroController.dispose();
    _kilometrajeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                const FacturaHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _mostrarOpcionesEscaneo,
                            icon: const Icon(Icons.document_scanner),
                            label: Text(AppLocalizations.of(context)!
                                .escanearFacturaAutocompletar),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              foregroundColor:
                                  Theme.of(context).colorScheme.onPrimary,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        FacturaForm(
                          formKey: _formKey,
                          tituloController: _tituloController,
                          costoController: _costoController,
                          fechaController: _fechaController,
                          horaController: _horaController,
                          descripcionController: _descripcionController,
                          onFechaChanged: (date) {
                            setState(() {
                              _fechaController.text =
                                  _controller.formatDate(date);
                            });
                          },
                          onHoraChanged: (time) {
                            setState(() {
                              _horaController.text =
                                  '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
                            });
                          },
                        ),
                        const SizedBox(height: 24),
                        InfoRepostaje(
                          litrosController: _litrosController,
                          precioLitroController: _precioLitroController,
                          kilometrajeController: _kilometrajeController,
                          tipoCombustibleSeleccionado:
                              _tipoCombustibleSeleccionado,
                          coches: _coches,
                          cocheSeleccionado: _cocheSeleccionado,
                          onCocheChanged: (value) {
                            setState(() => _cocheSeleccionado = value);
                          },
                          onTipoCombustibleChanged: (value) {
                            setState(
                                () => _tipoCombustibleSeleccionado = value);
                          },
                        ),
                        const SizedBox(height: 24),
                        ImagenFactura(
                          imagen: _imagenFactura,
                          onAgregarImagen: _mostrarOpcionesImagen,
                          onEliminarImagen: () {
                            setState(() => _imagenFactura = null);
                          },
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _guardarFactura,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Theme.of(context).primaryColor,
                              foregroundColor:
                                  Theme.of(context).colorScheme.onPrimary,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 4,
                            ),
                            child: _isLoading
                                ? SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 3,
                                      valueColor:
                                          AlwaysStoppedAnimation<Color>(
                                        Theme.of(context)
                                            .colorScheme
                                            .onPrimary,
                                      ),
                                    ),
                                  )
                                : Text(
                                    AppLocalizations.of(context)!
                                        .guardarFactura,
                                    style: const TextStyle(
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
              ],
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