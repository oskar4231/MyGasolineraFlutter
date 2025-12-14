import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_gasolinera/Inicio/login/login.dart';
import 'dart:typed_data';
import 'package:my_gasolinera/ajustes/facturas/FacturasScreen.dart';
import 'package:my_gasolinera/ajustes/estadisticas/estadisticas.dart';
import 'package:my_gasolinera/ajustes/accesibilidad/accesibilidad.dart';
import 'package:my_gasolinera/services/auth_service.dart';
import 'package:my_gasolinera/services/usuario_service.dart';
import 'package:my_gasolinera/services/perfil_service.dart';

class AjustesScreen extends StatefulWidget {
  const AjustesScreen({super.key});

  @override
  State<AjustesScreen> createState() => _AjustesScreenState();
}

class _AjustesScreenState extends State<AjustesScreen> {
  Uint8List? _profileImageBytes;
  String? _profileImageUrl;
  String _nombreUsuario = "Usuario";

  String get _emailUsuario {
    return AuthService.getUserEmail() ?? 'usuario@gmail.com';
  }

  final _usuarioService = UsuarioService();
  final _perfilService = PerfilService();
  bool _eliminandoCuenta = false;
  bool _subiendoFoto = false;

  @override
  void initState() {
    super.initState();
    _cargarFotoPerfil();
    _cargarNombreUsuario();
  }

  Future<void> _cargarNombreUsuario() async {
    try {
      final nombre = await _usuarioService.obtenerNombreUsuario();
      if (mounted) {
        setState(() {
          _nombreUsuario = nombre;
        });
      }
    } catch (e) {
      print('❌ Error cargando nombre de usuario: $e');
      if (mounted) {
        final emailFallback =
            AuthService.getUserEmail()?.split('@')[0] ?? 'Usuario';
        setState(() {
          _nombreUsuario = emailFallback;
        });
      }
    }
  }

  Future<void> _cargarFotoPerfil() async {
    try {
      final fotoData = await _usuarioService.cargarImagenPerfil(_emailUsuario);

      if (fotoData != null && mounted) {
        if (fotoData.startsWith('data:image') || fotoData.contains('base64')) {
          final base64String = fotoData.contains(',')
              ? fotoData.split(',')[1]
              : fotoData;
          final bytes = base64Decode(base64String);
          setState(() {
            _profileImageBytes = bytes;
          });
        } else if (fotoData.startsWith('http')) {
          setState(() {
            _profileImageUrl = fotoData;
          });
        } else {
          try {
            final bytes = base64Decode(fotoData);
            setState(() {
              _profileImageBytes = bytes;
            });
          } catch (e) {
            print('⚠️ No se pudo decodificar la imagen: $e');
          }
        }
      }
    } catch (e) {
      print('Error cargando foto de perfil: $e');
    }
  }

  Future<void> _pickImageFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    await _procesarImagen(pickedFile);
  }

  Future<void> _pickImageFromCamera() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    await _procesarImagen(pickedFile);
  }

  Future<void> _procesarImagen(XFile? pickedFile) async {
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _profileImageBytes = bytes;
        _subiendoFoto = true;
      });

      final exito = await _perfilService.subirFotoPerfil(pickedFile);

      setState(() {
        _subiendoFoto = false;
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
        setState(() {
          _profileImageBytes = null;
        });
      }
    }
  }

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

  @override
  Widget build(BuildContext context) {
    // --- LÓGICA DE COLORES EXACTA ---
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Si es oscuro: Negro Suave (0xFF121212). 
    // Si es claro: TU NARANJA ORIGINAL (0xFFFF9350).
    final backgroundColor = isDark ? const Color(0xFF121212) : const Color(0xFFFF9350);
    
    // Texto blanco en oscuro, negro en claro
    final textColor = isDark ? Colors.white : Colors.black; 

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          'Ajustes',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        backgroundColor: backgroundColor, // Se mantiene el color de fondo
        iconTheme: IconThemeData(color: textColor),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      // Pasamos las variables de color a los widgets hijos
      body: _buildAjustesContent(context, backgroundColor, textColor, isDark),
    );
  }

  Widget _buildAjustesContent(BuildContext context, Color bgColor, Color textColor, bool isDark) {
    return Container(
      color: bgColor, 
      child: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSeccionPerfil(context, isDark, textColor),
                  const SizedBox(height: 24),
                  _buildSeccionOpciones(context, textColor, isDark),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildBotonCerrarSesion(context, isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildSeccionPerfil(BuildContext context, bool isDark, Color textColor) {
    // Tarjeta: Si es oscuro (Gris), Si es claro (TU COLOR CREMA ORIGINAL: 0xFFFFE8DA)
    final cardColor = isDark ? const Color(0xFF2C2C2C) : const Color(0xFFFFE8DA);

    return Card(
      elevation: 2,
      color: cardColor, 
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            // Foto de perfil
            GestureDetector(
              onTap: _subiendoFoto ? null : _showImagePickerDialog,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.grey,
                    backgroundImage: _profileImageBytes != null
                        ? MemoryImage(_profileImageBytes!) as ImageProvider
                        : _profileImageUrl != null
                        ? NetworkImage(_profileImageUrl!) as ImageProvider
                        : null,
                    child: _profileImageBytes == null && _profileImageUrl == null
                        ? Icon(
                            Icons.person,
                            color: isDark ? Colors.white : Colors.black,
                            size: 40,
                          )
                        : null,
                  ),
                  if (_subiendoFoto)
                    Positioned.fill(
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: SizedBox(
                            width: 30,
                            height: 30,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (!_subiendoFoto)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          // Icono cámara: Negro en claro, Naranja en oscuro para resaltar
                          color: isDark ? const Color(0xFFFF9350) : Colors.black, 
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            // Texto nombre
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 24,
                        color: textColor, // Dinámico
                        fontFamily: 'Roboto',
                      ),
                      children: [
                        const TextSpan(
                          text: 'Hola, ',
                          style: TextStyle(fontWeight: FontWeight.normal),
                        ),
                        TextSpan(
                          text: _nombreUsuario,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeccionOpciones(BuildContext context, Color textColor, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Opciones',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 16),
        _OpcionItem(
          icono: Icons.local_gas_station,
          texto: 'Combustible',
          textColor: textColor,
          onTap: () {},
        ),
        _OpcionItem(
          icono: Icons.query_stats,
          texto: 'Estadísticas',
          textColor: textColor,
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
          textColor: textColor,
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
          textColor: textColor,
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
          icono: Icons.delete_outline,
          texto: 'Borrar Cuenta',
          textColor: Colors.redAccent, // Rojo siempre
          onTap: () => _mostrarDialogoBorrarCuenta(),
        ),
      ],
    );
  }

  Widget _buildBotonCerrarSesion(BuildContext context, bool isDark) {
    return Center(
      child: ElevatedButton.icon(
        onPressed: () {
          _mostrarDialogoCerrarSesion(context);
        },
        style: ElevatedButton.styleFrom(
          // Botón Cerrar Sesión: Blanco en oscuro, Negro en claro
          backgroundColor: isDark ? Colors.white : Colors.black, 
          foregroundColor: isDark ? Colors.black : Colors.white,
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
                  Text(
                    '¿Estás seguro de que quieres eliminar tu cuenta?\n\n'
                    'Esta acción no se puede deshacer.',
                    style: TextStyle(
                      // Color de texto del diálogo
                      color: Theme.of(context).textTheme.bodyMedium?.color, 
                      fontSize: 16
                    ),
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
                    child: const Text('Cancelar'),
                  ),
                if (!_eliminandoCuenta)
                  ElevatedButton(
                    onPressed: () async {
                      setDialogState(() => _eliminandoCuenta = true);
                      try {
                        final email = await _usuarioService.obtenerEmailGuardado();
                        if (email.isEmpty) {
                          throw Exception('No se encontró email del usuario');
                        }
                        final exito = await _usuarioService.eliminarCuenta(email);

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
                              content: Text('Error: ${e.toString()}'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Eliminar'),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}

// Widget auxiliar para los items de opciones (Efecto Hover incluido)
class _OpcionItem extends StatefulWidget {
  final IconData icono;
  final String texto;
  final Color textColor;
  final VoidCallback onTap;

  const _OpcionItem({
    required this.icono,
    required this.texto,
    required this.textColor,
    required this.onTap,
  });

  @override
  State<_OpcionItem> createState() => __OpcionItemState();
}

class __OpcionItemState extends State<_OpcionItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    // Ajustar el color de hover según el modo
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hoverColor = isDark ? Colors.white12 : Colors.black12;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Container(
        decoration: BoxDecoration(
          color: _isHovered ? hoverColor : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: ListTile(
          leading: Icon(widget.icono, color: widget.textColor),
          title: Text(
            widget.texto,
            style: TextStyle(color: widget.textColor),
          ),
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