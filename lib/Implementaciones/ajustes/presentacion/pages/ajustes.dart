import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:my_gasolinera/core/l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_gasolinera/Implementaciones/auth/presentacion/pages/login.dart';
import 'dart:typed_data';
import 'package:my_gasolinera/Implementaciones/facturas/presentacion/pages/facturas_screen.dart';
import 'package:my_gasolinera/Implementaciones/estadisticas/presentacion/pages/estadisticas.dart';
import 'package:my_gasolinera/Implementaciones/ajustes/presentacion/pages/accesibilidad.dart';
import 'package:my_gasolinera/Implementaciones/ajustes/presentacion/pages/idiomas_screen.dart';
import 'package:my_gasolinera/Implementaciones/auth/data/services/auth_service.dart';
import 'package:my_gasolinera/Implementaciones/auth/data/services/usuario_service.dart';
import 'package:my_gasolinera/Implementaciones/ajustes/data/services/perfil_service.dart';
import 'package:my_gasolinera/core/config/config_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_gasolinera/core/utils/local_image_service.dart';
import 'package:my_gasolinera/Implementaciones/coches/presentacion/pages/coches.dart';
import 'package:my_gasolinera/Implementaciones/home/presentacion/pages/layouthome.dart';
import 'package:my_gasolinera/core/utils/app_logger.dart';

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
        AppLogger.info('Nombre de usuario cargado: $nombre',
            tag: 'AjustesScreen');
      }
    } catch (e) {
      AppLogger.error('Error cargando nombre de usuario',
          tag: 'AjustesScreen', error: e);
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
      AppLogger.debug('Intentando cargar foto de perfil localmente...',
          tag: 'AjustesScreen');
      final localBytes = await LocalImageService.getImageBytes(
        'perfil',
        _emailUsuario,
      );

      if (localBytes != null && mounted) {
        setState(() {
          _profileImageBytes = localBytes;
        });
        AppLogger.info(
            'Foto de perfil cargada desde almacenamiento local encriptado',
            tag: 'AjustesScreen');
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
          AppLogger.info('Foto de perfil cargada exitosamente (base64)',
              tag: 'AjustesScreen');
        } else if (fotoData.startsWith('http')) {
          AppLogger.info('Cargando foto desde URL: $fotoData',
              tag: 'AjustesScreen');
          setState(() {
            _profileImageUrl = fotoData;
          });
          AppLogger.info('Foto de perfil cargada exitosamente (URL)',
              tag: 'AjustesScreen');
        } else {
          try {
            final bytes = base64Decode(fotoData);
            setState(() {
              _profileImageBytes = bytes;
            });
            AppLogger.info(
              'Foto de perfil cargada exitosamente (base64 sin prefijo)',
              tag: 'AjustesScreen',
            );
          } catch (e) {
            AppLogger.warning('No se pudo decodificar la imagen',
                tag: 'AjustesScreen', error: e);
          }
        }
      }
    } catch (e) {
      AppLogger.error('Error cargando foto de perfil',
          tag: 'AjustesScreen', error: e);
    }
  }

  // Función para seleccionar imagen desde galería
  Future<void> _pickImageFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _profileImageBytes = bytes;
        _subiendoFoto = true;
      });

      // Intentar subir al servidor primero
      AppLogger.info('Subiendo foto de perfil al servidor...',
          tag: 'AjustesScreen');
      final subidaExitosa = await _perfilService.subirFotoPerfil(pickedFile);

      if (subidaExitosa) {
        // Si sube bien, actualizamos la caché local
        AppLogger.info('Guardando copia local (cache)...',
            tag: 'AjustesScreen');
        await LocalImageService.saveImage(pickedFile, 'perfil', _emailUsuario);
      }

      setState(() {
        _subiendoFoto = false;
      });

      if (subidaExitosa && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Foto de perfil subida y guardada'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Error al subir la foto al servidor'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
        // Si falla la subida, revertimos la vista previa (opcional, o dejamos la local)
        // setState(() { _profileImageBytes = null; });
      }
    }
  }

  // Función para tomar foto con cámara
  Future<void> _pickImageFromCamera() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _profileImageBytes = bytes;
        _subiendoFoto = true;
      });

      // Intentar subir al servidor primero
      AppLogger.info('Subiendo foto de perfil al servidor...',
          tag: 'AjustesScreen');
      final subidaExitosa = await _perfilService.subirFotoPerfil(pickedFile);

      if (subidaExitosa) {
        // Si sube bien, actualizamos la caché local
        AppLogger.info('Guardando copia local (cache)...',
            tag: 'AjustesScreen');
        await LocalImageService.saveImage(pickedFile, 'perfil', _emailUsuario);
      }

      setState(() {
        _subiendoFoto = false;
      });

      if (subidaExitosa && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Foto de perfil subida y guardada'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Error al subir la foto al servidor'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
        // Si falla la subida, revertimos la vista previa
        // setState(() { _profileImageBytes = null; });
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
              children: <Widget>[Text(l10n.seleccionarFuenteFoto)],
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
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: theme.colorScheme.onPrimary,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.ajustesTitulo,
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onPrimary,
                    ),
                  ),
                ],
              ),
            ),

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
                        _buildSeccionPerfil(),
                        const SizedBox(height: 24),
                        _buildSeccionConexion(context),
                        const SizedBox(height: 24),
                        _buildSeccionOpciones(context),
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const CochesScreen(),
                        ),
                      );
                    },
                    icon: Icon(
                      Icons.directions_car,
                      size: 40,
                      color: theme.colorScheme.onPrimary
                          .withValues(alpha: 0.5), // No seleccionado - apagado
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const Layouthome(),
                        ),
                      );
                    },
                    icon: Icon(
                      Icons.pin_drop,
                      size: 40,
                      color: theme.colorScheme.onPrimary
                          .withValues(alpha: 0.5), // No seleccionado - apagado
                    ),
                  ),
                  IconButton(
                    onPressed: null, // Ya estamos en Ajustes
                    icon: Icon(
                      Icons.settings,
                      size: 40,
                      color:
                          theme.colorScheme.onPrimary, // Seleccionado - claro
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
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
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.6,
                              ),
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
                              final messenger = ScaffoldMessenger.of(context);
                              try {
                                await ConfigService.forceRefresh();
                                final lastTime =
                                    await ConfigService.getLastFetchTime();

                                if (mounted) {
                                  setState(() {
                                    _lastUrlUpdate = lastTime;
                                    _actualizandoUrl = false;
                                  });
                                }

                                messenger.showSnackBar(
                                  const SnackBar(
                                    content: Text('✅ URL actualizada'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              } catch (e) {
                                if (mounted) {
                                  setState(() => _actualizandoUrl = false);
                                  messenger.showSnackBar(
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
                                  theme.colorScheme.primary,
                                ),
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
              MaterialPageRoute(builder: (context) => const IdiomasScreen()),
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
                      color:
                          theme.colorScheme.onSurface.withValues(alpha: 0.87),
                      fontSize: 16,
                    ),
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
                  ElevatedButton(
                    onPressed: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      final navigator = Navigator.of(context);
                      final localizations = AppLocalizations.of(context)!;

                      setDialogState(() => _eliminandoCuenta = true);
                      try {
                        final email = AuthService.getUserEmail() ?? '';

                        AppLogger.debug('Email obtenido en ajustes: "$email"',
                            tag: 'AjustesScreen');

                        if (email.isEmpty) {
                          throw Exception('No se encontró email del usuario');
                        }

                        final exito = await _usuarioService.eliminarCuenta(
                          email,
                        );

                        if (exito) {
                          await _usuarioService.limpiarDatosUsuario();

                          navigator.pop();
                          navigator.pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                            (Route<dynamic> route) => false,
                          );
                        }
                      } catch (e) {
                        setDialogState(() => _eliminandoCuenta = false);
                        if (mounted) {
                          navigator.pop();
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text(
                                '${localizations.errorEliminarCuenta}: ${e.toString()}',
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
