import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:my_gasolinera/core/l10n/app_localizations.dart';
import 'package:my_gasolinera/core/theme/Modos/Temas/predeterminado.dart';

class ProfileSection extends StatefulWidget {
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
  State<ProfileSection> createState() => _ProfileSectionState();
}

class _ProfileSectionState extends State<ProfileSection> {
  bool _imageError = false;
  String? _lastFailedUrl;

  @override
  void didUpdateWidget(ProfileSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.profileImageUrl != oldWidget.profileImageUrl ||
        widget.profileImageBytes != oldWidget.profileImageBytes) {
      _imageError = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark
        ? const Color(0xFF212124)
        : (theme.cardTheme.color ?? theme.cardColor);
    final lighterCardColor = isDark
        ? const Color(0xFF3E3E42)
        : Color.lerp(cardColor, Colors.white, 0.25);
    final primaryColor = isDark ? const Color(0xFFFF8235) : theme.primaryColor;
    final textColor =
        isDark ? const Color(0xFFEBEBEB) : theme.colorScheme.onSurface;

    return Container(
      decoration: BoxDecoration(
        color: lighterCardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : const Color(0x1A2D1509),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            // Foto de perfil más grande con indicador de carga
            GestureDetector(
              onTap: widget.subiendoFoto ? null : widget.onPickImage,
              child: Stack(
                children: [
                  ClipOval(
                    child: Container(
                      width: 80,
                      height: 80,
                      color: const Color(0xFFFFD5BC), // secondaryContainer
                      child: widget.profileImageBytes != null
                          ? Image.memory(
                              widget.profileImageBytes!,
                              fit: BoxFit.cover,
                            )
                          : (widget.profileImageUrl != null && !_imageError)
                              ? Image.network(
                                  widget.profileImageUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    if (widget.profileImageUrl !=
                                        _lastFailedUrl) {
                                      _lastFailedUrl = widget.profileImageUrl;
                                      WidgetsBinding.instance
                                          .addPostFrameCallback((_) {
                                        if (mounted) {
                                          setState(() {
                                            _imageError = true;
                                          });
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  'Error: No se ha podido encontrar la foto de perfil'),
                                              backgroundColor: MyGasolineraColors.warning,
                                              behavior:
                                                  SnackBarBehavior.floating,
                                            ),
                                          );
                                        }
                                      });
                                    }
                                    return Icon(
                                      Icons.person,
                                      color: textColor,
                                      size: 40,
                                    );
                                  },
                                )
                              : Icon(
                                  Icons.person,
                                  color: textColor,
                                  size: 40,
                                ),
                    ),
                  ),
                  // Loader mientras sube la foto
                  if (widget.subiendoFoto)
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
                  if (!widget.subiendoFoto)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.camera_alt,
                          size: 16,
                          color: isDark
                              ? Colors.black
                              : theme.colorScheme.onPrimary,
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
                        color: textColor,
                        fontFamily: 'Roboto',
                      ),
                      children: [
                        TextSpan(
                          text: AppLocalizations.of(context)!.holaUsuario,
                          style: const TextStyle(fontWeight: FontWeight.normal),
                        ),
                        TextSpan(
                          text: widget.nombreUsuario,
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
