import 'package:flutter/material.dart';

class HoverBackButton extends StatefulWidget {
  final VoidCallback onPressed;

  const HoverBackButton({
    required this.onPressed,
    super.key,
  });

  @override
  State<HoverBackButton> createState() => _HoverBackButtonState();
}

class _HoverBackButtonState extends State<HoverBackButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // 1. Color Base (El gris oscuro del botón)
    final cardColor = isDark
        ? const Color(0xFF212124)
        : (theme.cardTheme.color ?? theme.cardColor);

    final lighterCardColor = isDark
        ? const Color(0xFF2C2C2F)
        : Color.lerp(cardColor, Colors.white, 0.25)!;

    // 2. Definimos el color naranja
    const orangeColor = Color(0xFFFF8235);

    // 3. Calculamos el color final para el Hover
    // En lugar de usar solo el naranja transparente, usamos una mezcla (alphaBlend).
    // Esto pone una capa de naranja al 5% (0.05) SOBRE el color gris base.
    // Así el botón nunca se vuelve transparente.
    final hoverColor = Color.alphaBlend(
      orangeColor.withOpacity(0.1), // Opacidad muy baja para que sea sutil
      lighterCardColor,
    );

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            // Aquí está el cambio clave: alternamos entre el gris y el gris teñido de naranja
            color: _isHovered ? hoverColor : lighterCardColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Icon(
              Icons.arrow_back,
              size: 28,
              color: orangeColor, // Flecha naranja siempre
            ),
          ),
        ),
      ),
    );
  }
}
