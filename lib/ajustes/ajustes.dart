import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:my_gasolinera/l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_gasolinera/Inicio/login/login.dart';
import 'dart:typed_data';
import 'package:my_gasolinera/ajustes/facturas/FacturasScreen.dart';
import 'package:my_gasolinera/ajustes/estadisticas/estadisticas.dart';
import 'package:my_gasolinera/ajustes/accesibilidad/accesibilidad.dart';
import 'package:my_gasolinera/ajustes/idiomas/idiomas_screen.dart';
import 'package:my_gasolinera/services/auth_service.dart';
import 'package:my_gasolinera/services/usuario_service.dart';
import 'package:my_gasolinera/services/perfil_service.dart';
import 'package:my_gasolinera/services/config_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_gasolinera/services/local_image_service.dart';

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

  // Variables para la sección de conexión y mapa
  bool _actualizandoUrl = false;
  DateTime? _lastUrlUpdate;
  double _radiusKm = 25.0; // Valor por defecto

  @override
  void initState() {
    super.initState();
    _cargarFotoPerfil();
    _cargarNombreUsuario();
    _cargarDatosConexion();
  }

  Future<void> _cargarDatosConexion() async {
    final lastTime = await ConfigService.getLastFetchTime();
    final prefs = await SharedPreferences.getInstance();
    final savedRadius = prefs.getDouble('radius_km') ?? 25.0;

    if (mounted) {
      setState(() {
        _lastUrlUpdate = lastTime;
        _radiusKm = savedRadius;
      });
    }
  }

  Future<void> _guardarRadio(double valor) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('radius_km', valor);
    setState(() {
      _radiusKm = valor;
    });
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
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.ajustesTitulo,
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onPrimary,
          ),
        ),
        backgroundColor: theme.colorScheme.primary,
        iconTheme: IconThemeData(color: theme.colorScheme.onPrimary),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _buildAjustesContent(context),
    );
  }

  Widget _buildAjustesContent(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: theme.colorScheme.surface,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSeccionPerfil(),
                    const SizedBox(height: 24),
                    _buildSeccionConexion(context),
                    const SizedBox(height: 24),
                    _buildSeccionOpciones(context),
                  ],
                ),
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
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      color: theme.colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            // Foto de perfil más grande con indicador de carga
            GestureDetector(
              onTap: _subiendoFoto ? null : _showImagePickerDialog,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 40, // Aumentado de 24 a 40
                    backgroundColor: Colors.grey,
                    backgroundImage: _profileImageBytes != null
                        ? MemoryImage(_profileImageBytes!) as ImageProvider
                        : _profileImageUrl != null
                            ? NetworkImage(_profileImageUrl!) as ImageProvider
                            : null,
                    child:
                        _profileImageBytes == null && _profileImageUrl == null
                            ? Icon(
                                Icons.person,
                                color: theme.colorScheme.onSurface,
                                size: 40,
                              )
                            : null,
                  ),
                  // Loader mientras sube la foto
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
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  // Icono de cámara
                  if (!_subiendoFoto)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.camera_alt,
                          size: 16,
                          color: theme.colorScheme.onPrimary,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            // Texto "Hola, [nombre]"
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 24,
                        color: theme.colorScheme.onSurface,
                        fontFamily: 'Roboto',
                      ),
                      children: [
                        TextSpan(
                          text: AppLocalizations.of(context)!.holaUsuario,
                          style: const TextStyle(fontWeight: FontWeight.normal),
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

  Widget _buildSeccionConexion(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.conexionMapa,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 1,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // 1. Botón Actualizar Servidor
                Row(
                  children: [
                    Icon(Icons.sync, color: theme.colorScheme.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.servidorBackend,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _lastUrlUpdate != null
                                ? 'Act: ${_lastUrlUpdate!.hour.toString().padLeft(2, '0')}:${_lastUrlUpdate!.minute.toString().padLeft(2, '0')}'
                                : 'Sin actualizar',
                            style: TextStyle(
                              fontSize: 12,
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      // ... (button logic unchanged)
                      onPressed: _actualizandoUrl
                          ? null
                          : () async {
                              setState(() => _actualizandoUrl = true);
                              try {
                                await ConfigService.forceRefresh();
                                final lastTime =
                                    await ConfigService.getLastFetchTime();
                                if (mounted) {
                                  setState(() {
                                    _lastUrlUpdate = lastTime;
                                    _actualizandoUrl = false;
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('✅ URL actualizada'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (mounted) {
                                  setState(() => _actualizandoUrl = false);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('❌ Error: $e')),
                                  );
                                }
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primaryContainer,
                        foregroundColor: theme.colorScheme.primary,
                        elevation: 0,
                      ),
                      child: _actualizandoUrl
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    theme.colorScheme.primary),
                              ),
                            )
                          : Text(AppLocalizations.of(context)!.actualizar),
                    ),
                  ],
                ),

                const Divider(height: 24),

                // 2. Slider Radio
                Row(
                  children: [
                    Icon(Icons.radar, color: theme.colorScheme.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                AppLocalizations.of(context)!.radioBusqueda,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${_radiusKm.toInt()} km',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                          Slider(
                            value: _radiusKm,
                            min: 5,
                            max: 100,
                            divisions: 19,
                            activeColor: theme.colorScheme.primary,
                            label: '${_radiusKm.toInt()} km',
                            onChanged: (value) {
                              setState(() {
                                _radiusKm = value;
                              });
                            },
                            onChangeEnd: (value) {
                              _guardarRadio(value);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSeccionOpciones(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.opciones,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        _OpcionItem(
          icono: Icons.language,
          texto: l10n.idiomas,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const IdiomasScreen(),
              ),
            );
          },
        ),
        _OpcionItem(
          icono: Icons.query_stats,
          texto: l10n.estadisticas,
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
          texto: l10n.gastosFacturas,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FacturasScreen()),
            );
          },
        ),
        _OpcionItem(
          icono: Icons.accessibility_new,
          texto: l10n.accesibilidad,
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
          texto: l10n.borrarCuenta,
          onTap: () => _mostrarDialogoBorrarCuenta(),
        ),
      ],
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
