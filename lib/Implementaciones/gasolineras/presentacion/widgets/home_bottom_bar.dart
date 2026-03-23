import 'package:flutter/material.dart';

class HomeBottomBar extends StatelessWidget {
  final VoidCallback onCochesPressed;
  final VoidCallback onAjustesPressed;

  const HomeBottomBar({
    super.key,
    required this.onCochesPressed,
    required this.onAjustesPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final barColor = isDark ? const Color(0xFFFF8235) : const Color(0xFFFF8200);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: barColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Botón de Coches
          IconButton(
            onPressed: onCochesPressed,
            icon: Icon(Icons.directions_car,
                size: 40,
                color: theme.colorScheme.onPrimary
                    .withValues(alpha: 0.5)), // No seleccionado - apagado
          ),

          // Botón de Ubicación (Pin) - Seleccionado
          IconButton(
            onPressed: null, // Ya estamos en Mapa
            icon: Icon(Icons.pin_drop,
                size: 40,
                color: theme.colorScheme.onPrimary), // Seleccionado - claro
          ),

          // Botón de Ajustes
          IconButton(
            onPressed: onAjustesPressed,
            icon: Icon(Icons.settings,
                size: 40,
                color: theme.colorScheme.onPrimary
                    .withValues(alpha: 0.5)), // No seleccionado - apagado
          ),
        ],
      ),
    );
  }
}
