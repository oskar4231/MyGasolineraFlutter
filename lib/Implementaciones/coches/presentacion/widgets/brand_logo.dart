import 'package:flutter/material.dart';

class BrandLogo extends StatelessWidget {
  final String brandName;
  final double size;
  final Color? fallbackColor;

  const BrandLogo({
    super.key,
    required this.brandName,
    this.size = 32,
    this.fallbackColor,
  });

  @override
  Widget build(BuildContext context) {
    // Normalizar el nombre: "Mercedes-Benz" -> "mercedes_benz"
    // Convertir a minúsculas y reemplazar espacios/guiones por guiones bajos
    final normalizedName = brandName
        .toLowerCase()
        .trim()
        .replaceAll(' ', '-')
        .replaceAll('/', '-');

    return Image.asset(
      'assets/images/logos/$normalizedName.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        // Fallback si no existe la imagen
        return Icon(
          Icons.directions_car,
          size: size,
          color: fallbackColor ?? Theme.of(context).colorScheme.onPrimary,
        );
      },
    );
  }
}
