import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';

// Widgets & Controllers
import 'package:my_gasolinera/Implementaciones/ajustes/presentacion/widgets/ajustes_header.dart';
import 'package:my_gasolinera/Implementaciones/ajustes/presentacion/widgets/ajustes_footer.dart';
import 'package:my_gasolinera/Implementaciones/ajustes/presentacion/widgets/profile_section.dart';
import 'package:my_gasolinera/Implementaciones/ajustes/presentacion/widgets/options_menu.dart';
import 'package:my_gasolinera/Implementaciones/ajustes/presentacion/widgets/logout_button.dart';
import 'package:my_gasolinera/Implementaciones/ajustes/presentacion/widgets/ajustes_dialogs.dart';
import 'package:my_gasolinera/Implementaciones/ajustes/presentacion/controllers/ajustes_controller.dart';

class AjustesScreen extends StatefulWidget {
  const AjustesScreen({super.key});

  @override
  State<AjustesScreen> createState() => _AjustesScreenState();
}

class _AjustesScreenState extends State<AjustesScreen> {
  final _controller = AjustesController();

  // State
  Uint8List? _profileImageBytes;
  String? _profileImageUrl;
  String _nombreUsuario = "Usuario";
  bool _subiendoFoto = false;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    _cargarNombre();
    _cargarFoto();
  }

  Future<void> _cargarNombre() async {
    final nombre = await _controller.cargarNombreUsuario();
    if (mounted) setState(() => _nombreUsuario = nombre);
  }

  Future<void> _cargarFoto() async {
    // 1. Local
    final local = await _controller.cargarFotoPerfilLocal();
    if (local != null && mounted) {
      return setState(() => _profileImageBytes = local);
    }
    // 2. Remote
    final remote = await _controller.cargarFotoPerfilRemota();
    if (mounted && remote != null) {
      if (remote is Uint8List) {
        setState(() => _profileImageBytes = remote);
      } else if (remote is String) {
        setState(() => _profileImageUrl = remote);
      }
    }
  }

  Future<void> _handleImagePick(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
        source: source, maxWidth: 1024, maxHeight: 1024, imageQuality: 85);

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _profileImageBytes = bytes;
        _subiendoFoto = true;
      });

      final exito = await _controller.subirFotoPerfil(pickedFile);

      if (mounted) {
        setState(() => _subiendoFoto = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(exito ? '✅ Foto actualizada' : '❌ Error al subir'),
            backgroundColor: exito ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            const AjustesHeader(),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ProfileSection(
                        profileImageBytes: _profileImageBytes,
                        profileImageUrl: _profileImageUrl,
                        subiendoFoto: _subiendoFoto,
                        nombreUsuario: _nombreUsuario,
                        onPickImage: () => AjustesDialogs.showImagePickerDialog(
                          context,
                          onGallery: () =>
                              _handleImagePick(ImageSource.gallery),
                          onCamera: () => _handleImagePick(ImageSource.camera),
                        ),
                      ),
                      OptionsMenu(
                        onDeleteAccount: () =>
                            AjustesDialogs.showDeleteAccountDialog(
                          context,
                          onDelete: _controller.eliminarCuenta,
                        ),
                      ),
                      const SizedBox(height: 24),
                      LogoutButton(
                        onLogout: () =>
                            AjustesDialogs.showLogoutDialog(context),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
            const AjustesFooter(),
          ],
        ),
      ),
    );
  }
}
