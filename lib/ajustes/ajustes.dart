import 'package:flutter/material.dart';
import 'package:my_gasolinera/widgets/app_bottom_navigation.dart';
import 'package:my_gasolinera/widgets/simple_page_header.dart';
import 'package:my_gasolinera/l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_gasolinera/Inicio/login/login.dart';
import 'dart:typed_data';
import 'package:my_gasolinera/services/auth_service.dart';
import 'package:my_gasolinera/services/usuario_service.dart';
import 'package:my_gasolinera/services/perfil_service.dart';
import 'package:my_gasolinera/services/local_image_service.dart';
import 'dart:convert';
import 'package:my_gasolinera/ajustes/widgets/ajustes_perfil.dart';
import 'package:my_gasolinera/ajustes/widgets/ajustes_conexion.dart';
import 'package:my_gasolinera/ajustes/widgets/ajustes_opciones.dart';

class AjustesScreen extends StatefulWidget {
  const AjustesScreen({super.key});

  @override
  State<AjustesScreen> createState() => _AjustesScreenState();
}

class _AjustesScreenState extends State<AjustesScreen> {
  Uint8List? _profileImageBytes;
  String? _profileImageUrl;
  String _nombreUsuario = "Usuario"; // Nombre que se mostrará

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

  // Cargar el nombre del usuario desde el backend
  Future<void> _cargarNombreUsuario() async {
    try {
      final nombre = await _usuarioService.obtenerNombreUsuario();
      if (mounted) {
        setState(() {
          _nombreUsuario = nombre;
        });
        print('✅ Nombre de usuario cargado: $nombre');
      }
    } catch (e) {
      print('❌ Error cargando nombre de usuario: $e');
      // Fallback al email si falla
      if (mounted) {
        final emailFallback =
            AuthService.getUserEmail()?.split('@')[0] ?? 'Usuario';
        setState(() {
          _nombreUsuario = emailFallback;
        });
      }
    }
  }

  // Cargar foto de perfil (Local > Servidor)
  Future<void> _cargarFotoPerfil() async {
    try {
      // 1. Intentar cargar desde local (intermedia/encriptada)
      print('🔍 Intentando cargar foto de perfil localmente...');
      final localBytes =
          await LocalImageService.getImageBytes('perfil', _emailUsuario);

      if (localBytes != null && mounted) {
        setState(() {
          _profileImageBytes = localBytes;
        });
        print('✅ Foto de perfil cargada desde almacenamiento local encriptado');
        return;
      }

      // 2. Si no hay local, intentar desde servidor
      final fotoData = await _usuarioService.cargarImagenPerfil(_emailUsuario);

      if (fotoData != null && mounted) {
        if (fotoData.startsWith('data:image') || fotoData.contains('base64')) {
          final base64String =
              fotoData.contains(',') ? fotoData.split(',')[1] : fotoData;
          final bytes = base64Decode(base64String);
          setState(() {
            _profileImageBytes = bytes;
          });
          print('📷 Foto de perfil cargada exitosamente (base64)');
        } else if (fotoData.startsWith('http')) {
          print('📷 Cargando foto desde URL: $fotoData');
          setState(() {
            _profileImageUrl = fotoData;
          });
          print('📷 Foto de perfil cargada exitosamente (URL)');
        } else {
          try {
            final bytes = base64Decode(fotoData);
            setState(() {
              _profileImageBytes = bytes;
            });
            print(
              '📷 Foto de perfil cargada exitosamente (base64 sin prefijo)',
            );
          } catch (e) {
            print('⚠️ No se pudo decodificar la imagen: $e');
          }
        }
      }
    } catch (e) {
      print('Error cargando foto de perfil: $e');
    }
  }

  // Función para seleccionar imagen desde galería
  Future<void> _pickImageFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _profileImageBytes = bytes;
        _subiendoFoto = true;
      });

      // CAMBIO: Guardar localmente en lugar de subir
      print('💾 Guardando foto de perfil en local (encriptada)...');
      final path = await LocalImageService.saveImage(
          pickedFile, 'perfil', _emailUsuario);
      final exito = path != null;

      setState(() {
        _subiendoFoto = false;
      });

      if (exito && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Foto de perfil guardada localmente (segura)'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Error al guardar la foto localmente'),
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

  // Función para tomar foto con cámara
  Future<void> _pickImageFromCamera() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _profileImageBytes = bytes;
        _subiendoFoto = true;
      });

      // CAMBIO: Guardar localmente en lugar de subir
      print('💾 Guardando foto de perfil en local (encriptada)...');
      final path = await LocalImageService.saveImage(
          pickedFile, 'perfil', _emailUsuario);
      final exito = path != null;

      setState(() {
        _subiendoFoto = false;
      });

      if (exito && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Foto de perfil guardada localmente (segura)'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Error al guardar la foto localmente'),
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

  // Diálogo para elegir entre cámara o galería
  void _showImagePickerDialog() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.cambiarFotoPerfil),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(l10n.seleccionarFuenteFoto),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _pickImageFromGallery();
              },
              child: Text(l10n.galeria),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _pickImageFromCamera();
              },
              child: Text(l10n.camara),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.cancelar),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Custom Header
            SimplePageHeader(title: l10n.ajustesTitulo),

            // Main Content
            Expanded(
              child: Container(
                color: theme.colorScheme.surface,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AjustesPerfil(
                          profileImageBytes: _profileImageBytes,
                          profileImageUrl: _profileImageUrl,
                          nombreUsuario: _nombreUsuario,
                          isSubmitting: _subiendoFoto,
                          onPickImage: _showImagePickerDialog,
                        ),
                        const SizedBox(height: 24),
                        const AjustesConexion(),
                        const SizedBox(height: 24),
                        AjustesOpciones(
                          onBorrarCuenta: _mostrarDialogoBorrarCuenta,
                        ),
                        const SizedBox(height: 24),
                        _buildBotonCerrarSesion(context),
                        const SizedBox(height: 24), // Extra space for footer
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Custom Footer
            const AppBottomNavigation(currentIndex: 2),
          ],
        ),
      ),
    );
  }

  Widget _buildBotonCerrarSesion(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: ElevatedButton.icon(
        onPressed: () {
          _mostrarDialogoCerrarSesion(context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.onSurface,
          foregroundColor: theme.colorScheme.surface,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
        icon: const Icon(Icons.logout),
        label: Text(AppLocalizations.of(context)!.cerrarSesion),
      ),
    );
  }

  void _mostrarDialogoCerrarSesion(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.cerrarSesion),
          content: Text(AppLocalizations.of(context)!.confirmarCerrarSesion),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(AppLocalizations.of(context)!.cancelar),
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
              child: Text(AppLocalizations.of(context)!.cerrarSesion),
            ),
          ],
        );
      },
    );
  }

  void _mostrarDialogoBorrarCuenta() {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      barrierDismissible: !_eliminandoCuenta,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(AppLocalizations.of(context)!.borrarCuenta),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    AppLocalizations.of(context)!.confirmarBorrarCuenta,
                    style: TextStyle(
                        color: theme.colorScheme.onSurface.withOpacity(0.87),
                        fontSize: 16),
                  ),
                  if (_eliminandoCuenta) ...[
                    const SizedBox(height: 16),
                    const CircularProgressIndicator(),
                    const SizedBox(height: 8),
                    Text(AppLocalizations.of(context)!.eliminandoCuenta),
                  ],
                ],
              ),
              actions: [
                if (!_eliminandoCuenta)
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      AppLocalizations.of(context)!.cancelar,
                      style: TextStyle(color: theme.colorScheme.onSurface),
                    ),
                  ),
                if (!_eliminandoCuenta)
                  ElevatedButton(
                    onPressed: () async {
                      setDialogState(() => _eliminandoCuenta = true);
                      try {
                        final email =
                            await _usuarioService.obtenerEmailGuardado();

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
                                '${AppLocalizations.of(context)!.errorEliminarCuenta}: ${e.toString()}',
                              ),
                              duration: const Duration(seconds: 4),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.eliminar,
                      style: TextStyle(color: theme.colorScheme.onPrimary),
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
  final VoidCallback onTap;

  const _OpcionItem({
    required this.icono,
    required this.texto,
    required this.onTap,
  });

  @override
  State<_OpcionItem> createState() => __OpcionItemState();
}

class __OpcionItemState extends State<_OpcionItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Container(
        decoration: BoxDecoration(
          color: _isHovered
              ? theme.colorScheme.onSurface.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: ListTile(
          leading: Icon(widget.icono, color: theme.colorScheme.onSurface),
          title: Text(
            widget.texto,
            style: TextStyle(color: theme.colorScheme.onSurface),
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
