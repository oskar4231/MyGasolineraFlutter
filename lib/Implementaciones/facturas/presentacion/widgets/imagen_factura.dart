import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'package:my_gasolinera/core/l10n/app_localizations.dart';
import 'shadow_field_wrapper.dart';

class ImagenFactura extends StatelessWidget {
  final XFile? imagen;
  final VoidCallback onAgregarImagen;
  final VoidCallback onEliminarImagen;

  const ImagenFactura({
    required this.imagen,
    required this.onAgregarImagen,
    required this.onEliminarImagen,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          AppLocalizations.of(context)!.imagenFactura,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Divider(
          color: Theme.of(context).colorScheme.onSurface,
          thickness: 1,
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: onAgregarImagen,
          child: ShadowFieldWrapper(
            child: SizedBox(
              height: 200,
              width: double.infinity,
              child: imagen == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_photo_alternate,
                          size: 40,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          AppLocalizations.of(context)!.agregarImagen,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    )
                  : Stack(
                      children: [
                        FutureBuilder(
                          future: imagen!.readAsBytes(),
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
                              child: CircularProgressIndicator(
                                color: Color(0xFFFF9350),
                              ),
                            );
                          },
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
                              icon: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 20,
                              ),
                              onPressed: onEliminarImagen,
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
