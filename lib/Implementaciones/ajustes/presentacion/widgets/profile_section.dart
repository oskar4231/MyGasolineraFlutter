import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:my_gasolinera/core/l10n/app_localizations.dart';

class ProfileSection extends StatelessWidget {
  final Uint8List? profileImageBytes;
  final String? profileImageUrl;
  final bool subiendoFoto;
  final String nombreUsuario;
  final VoidCallback onPickImage;

  const ProfileSection({
    super.key,
    this.profileImageBytes,
    this.profileImageUrl,
    required this.subiendoFoto,
    required this.nombreUsuario,
    required this.onPickImage,
  });

  @override
  Widget build(BuildContext context) {
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
              onTap: subiendoFoto ? null : onPickImage,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.grey,
                    backgroundImage: profileImageBytes != null
                        ? MemoryImage(profileImageBytes!) as ImageProvider
                        : profileImageUrl != null
                            ? NetworkImage(profileImageUrl!) as ImageProvider
                            : null,
                    child: profileImageBytes == null && profileImageUrl == null
                        ? Icon(
                            Icons.person,
                            color: theme.colorScheme.onSurface,
                            size: 40,
                          )
                        : null,
                  ),
                  // Loader mientras sube la foto
                  if (subiendoFoto)
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
                  if (!subiendoFoto)
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
                          text: nombreUsuario,
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
}
