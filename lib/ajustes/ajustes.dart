import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_gasolinera/Inicio/login/login.dart';
import 'dart:typed_data';
import 'package:my_gasolinera/ajustes/facturas/FacturasScreen.dart';
import 'package:my_gasolinera/ajustes/estadisticas/estadisticas.dart';
import 'package:my_gasolinera/ajustes/accesibilidad/accesibilidad.dart';
import 'package:my_gasolinera/services/auth_service.dart';
import 'package:my_gasolinera/services/usuario_service.dart';
import 'package:my_gasolinera/services/perfil_service.dart'; // NUEVO IMPORT

class AjustesScreen extends StatefulWidget {
  const AjustesScreen({super.key});

  @override
  State<AjustesScreen> createState() => _AjustesScreenState();
}

class _AjustesScreenState extends State<AjustesScreen> {
  Uint8List? _profileImageBytes;
  String _telefonoUsuario = "123-456-7890"; // Número por defecto
  String _nombre = "Nombre"; // Nombre por defecto
  String _apellido = "Apellido"; // Apellido por defecto
  String get _emailUsuario {
    return AuthService.getUserEmail() ?? 'usuario@gmail.com';
  }

  final _usuarioService = UsuarioService();
  final _perfilService = PerfilService(); // NUEVO SERVICIO
  bool _eliminandoCuenta = false;
  bool _subiendoFoto = false; // NUEVO: Para mostrar loader al subir foto

  @override
  void initState() {
    super.initState();
    _cargarFotoPerfil(); // NUEVO: Cargar foto al iniciar
  }

  // NUEVO: Cargar foto de perfil desde el servidor
  Future<void> _cargarFotoPerfil() async {
    try {
      final fotoUrl = await _perfilService.obtenerFotoPerfil();
      if (fotoUrl != null && mounted) {
        // Aquí podrías cargar la imagen desde la URL
        // Por ahora, solo la guardamos para mostrar después
        print('📷 Foto de perfil cargada: $fotoUrl');
      }
    } catch (e) {
      print('Error cargando foto de perfil: $e');
    }
  }

  // MODIFICADO: Función para seleccionar imagen desde galería
  Future<void> _pickImageFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _profileImageBytes = bytes;
        _subiendoFoto = true; // Mostrar loader
      });

      // NUEVO: Subir la imagen al servidor
      final exito = await _perfilService.subirFotoPerfil(pickedFile);

      setState(() {
        _subiendoFoto = false; // Ocultar loader
      });

      if (exito && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Foto de perfil actualizada'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Error al subir la foto'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
        // Revertir la imagen si falló la subida
        setState(() {
          _profileImageBytes = null;
        });
      }
    }
  }

  // MODIFICADO: Función para tomar foto con cámara
  Future<void> _pickImageFromCamera() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _profileImageBytes = bytes;
        _subiendoFoto = true; // Mostrar loader
      });

      // NUEVO: Subir la imagen al servidor
      final exito = await _perfilService.subirFotoPerfil(pickedFile);

      setState(() {
        _subiendoFoto = false; // Ocultar loader
      });

      if (exito && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Foto de perfil actualizada'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Error al subir la foto'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
        // Revertir la imagen si falló la subida
        setState(() {
          _profileImageBytes = null;
        });
      }
    }
  }

  // Diálogo para elegir entre cámara o galería
  void _showImagePickerDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cambiar foto de perfil'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Selecciona de dónde quieres tomar la foto:'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _pickImageFromGallery();
              },
              child: const Text('Galería'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _pickImageFromCamera();
              },
              child: const Text('Cámara'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  // Función para mostrar diálogo de edición de nombre
  void _mostrarDialogoEditarNombre() {
    TextEditingController nombreController = TextEditingController();
    TextEditingController apellidoController = TextEditingController();
    TextEditingController telefonoController = TextEditingController();

    nombreController.text = _nombre;
    apellidoController.text = _apellido;
    telefonoController.text = _telefonoUsuario;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFFFE8DA),
          title: const Text(
            'Editar Información',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  border: OutlineInputBorder(),
                  hintText: 'Ingresa tu nombre',
                  labelStyle: TextStyle(color: Colors.black),
                  hintStyle: TextStyle(color: Colors.black54),
                ),
                style: const TextStyle(color: Colors.black),
                maxLength: 25,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: apellidoController,
                decoration: const InputDecoration(
                  labelText: 'Apellido',
                  border: OutlineInputBorder(),
                  hintText: 'Ingresa tu apellido',
                  labelStyle: TextStyle(color: Colors.black),
                  hintStyle: TextStyle(color: Colors.black54),
                ),
                style: const TextStyle(color: Colors.black),
                maxLength: 25,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: telefonoController,
                decoration: const InputDecoration(
                  labelText: 'Teléfono',
                  border: OutlineInputBorder(),
                  hintText: 'Ingresa tu número de teléfono',
                  prefixIcon: Icon(Icons.phone, color: Colors.black),
                  labelStyle: TextStyle(color: Colors.black),
                  hintStyle: TextStyle(color: Colors.black54),
                ),
                style: const TextStyle(color: Colors.black),
                keyboardType: TextInputType.phone,
                maxLength: 15,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.black),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (nombreController.text.trim().isNotEmpty &&
                    telefonoController.text.trim().isNotEmpty) {
                  setState(() {
                    _nombre = nombreController.text.trim();
                    _apellido = apellidoController.text.trim();
                    _telefonoUsuario = telefonoController.text.trim();
                  });
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Información actualizada'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF9350),
              ),
              child: const Text(
                'Guardar',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFF9350),
      appBar: AppBar(
        title: const Text(
          'Ajustes',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: const Color(0xFFFF9350),
        iconTheme: const IconThemeData(color: Colors.black),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _buildAjustesContent(context),
    );
  }

  Widget _buildAjustesContent(BuildContext context) {
    return Container(
      color: const Color(0xFFFF9350),
      child: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSeccionPerfil(),
                  const SizedBox(height: 24),
                  _buildSeccionOpciones(context),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildBotonCerrarSesion(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSeccionPerfil() {
    return Card(
      elevation: 2,
      color: const Color(0xFFFFE8DA),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            GestureDetector(
              onTap: _subiendoFoto
                  ? null
                  : _showImagePickerDialog, // MODIFICADO: Deshabilitar si está subiendo
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.grey,
                    backgroundImage: _profileImageBytes != null
                        ? MemoryImage(_profileImageBytes!) as ImageProvider
                        : null,
                    child: _profileImageBytes == null
                        ? const Icon(Icons.person, color: Colors.black)
                        : null,
                  ),
                  // NUEVO: Mostrar loader mientras sube la foto
                  if (_subiendoFoto)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (!_subiendoFoto) // Solo mostrar icono de cámara si no está subiendo
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.black,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: GestureDetector(
                onTap: _mostrarDialogoEditarNombre,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '$_nombre $_apellido',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.edit, size: 16, color: Colors.black),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.phone, size: 14, color: Colors.black),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            _telefonoUsuario,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _emailUsuario,
                      style: const TextStyle(color: Colors.black, fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeccionOpciones(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Opciones',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 16),
        _OpcionItem(
          icono: Icons.local_gas_station,
          texto: 'Combustible',
          onTap: () {},
        ),
        _OpcionItem(
          icono: Icons.query_stats,
          texto: 'Estadísticas',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const EstadisticasScreen(),
              ),
            );
          },
        ),
        _OpcionItem(
          icono: Icons.receipt,
          texto: 'Gasto/Facturas',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FacturasScreen()),
            );
          },
        ),
        _OpcionItem(
          icono: Icons.accessibility_new,
          texto: 'Accesibilidad',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AccesibilidadScreen(),
              ),
            );
          },
        ),
        _OpcionItem(
          icono: Icons.speed,
          texto: 'Borrar Cuenta',
          onTap: () => _mostrarDialogoBorrarCuenta(),
        ),
      ],
    );
  }

  Widget _buildBotonCerrarSesion(BuildContext context) {
    return Center(
      child: ElevatedButton.icon(
        onPressed: () {
          _mostrarDialogoCerrarSesion(context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
        icon: const Icon(Icons.logout),
        label: const Text('Cerrar sesión'),
      ),
    );
  }

  void _mostrarDialogoCerrarSesion(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cerrar sesión'),
          content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (Route<dynamic> route) => false,
                );
              },
              child: const Text('Cerrar sesión'),
            ),
          ],
        );
      },
    );
  }

  void _mostrarDialogoBorrarCuenta() {
    showDialog(
      context: context,
      barrierDismissible: !_eliminandoCuenta,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Borrar Cuenta'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '¿Estás seguro de que quieres eliminar tu cuenta?\n\n'
                    'Esta acción no se puede deshacer.',
                    style: TextStyle(color: Colors.black87, fontSize: 16),
                  ),
                  if (_eliminandoCuenta) ...[
                    const SizedBox(height: 16),
                    const CircularProgressIndicator(),
                    const SizedBox(height: 8),
                    const Text('Eliminando cuenta...'),
                  ],
                ],
              ),
              actions: [
                if (!_eliminandoCuenta)
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      'Cancelar',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                if (!_eliminandoCuenta)
                  ElevatedButton(
                    onPressed: () async {
                      setDialogState(() => _eliminandoCuenta = true);
                      try {
                        final email = await _usuarioService
                            .obtenerEmailGuardado();

                        print('🔍 DEBUG - Email obtenido en ajustes: "$email"');
                        print('🔍 DEBUG - Longitud del email: ${email.length}');
                        print('🔍 DEBUG - Email está vacío: ${email.isEmpty}');

                        if (email.isEmpty) {
                          throw Exception('No se encontró email del usuario');
                        }

                        print(
                          '🔍 DEBUG - Enviando email al servicio: "$email"',
                        );
                        final exito = await _usuarioService.eliminarCuenta(
                          email,
                        );

                        if (exito) {
                          await _usuarioService.limpiarDatosUsuario();

                          if (mounted) {
                            Navigator.of(context).pop();
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                              (Route<dynamic> route) => false,
                            );
                          }
                        }
                      } catch (e) {
                        setDialogState(() => _eliminandoCuenta = false);
                        if (mounted) {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Error al eliminar cuenta: ${e.toString()}',
                              ),
                              duration: const Duration(seconds: 4),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFFF9350),
                    ),
                    child: const Text(
                      'Eliminar',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}

class _OpcionItem extends StatefulWidget {
  final IconData icono;
  final String texto;
  final bool tieneCheckbox;
  final bool checkboxValue;
  final VoidCallback onTap;

  const _OpcionItem({
    super.key,
    required this.icono,
    required this.texto,
    required this.onTap,
    this.tieneCheckbox = false,
    this.checkboxValue = false,
  });

  @override
  State<_OpcionItem> createState() => __OpcionItemState();
}

class __OpcionItemState extends State<_OpcionItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Container(
        decoration: BoxDecoration(
          color: _isHovered ? Colors.black12 : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: ListTile(
          leading: Icon(widget.icono, color: Colors.black),
          title: Text(
            widget.texto,
            style: const TextStyle(color: Colors.black),
          ),
          trailing: widget.tieneCheckbox
              ? Checkbox(
                  value: widget.checkboxValue,
                  onChanged: (bool? value) {
                    widget.onTap();
                  },
                )
              : null,
          onTap: widget.onTap,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ),
        ),
      ),
    );
  }
}
