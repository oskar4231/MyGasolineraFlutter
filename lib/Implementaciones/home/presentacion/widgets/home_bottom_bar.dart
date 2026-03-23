import 'package:flutter/material.dart';

class HomeBottomBar extends StatelessWidget {
  final VoidCallback onCochesPressed;
  final VoidCallback onMapListTogglePressed;
  final VoidCallback onAjustesPressed;
  final bool isMapMode;

  const HomeBottomBar({
    super.key,
    required this.onCochesPressed,
    required this.onMapListTogglePressed,
    required this.onAjustesPressed,
    this.isMapMode = true,
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
                    .withValues(alpha: 0.5)),
          ),

          // Botón de Toggle con ambos iconos
          InkWell(
            onTap: onMapListTogglePressed,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedOpacity(
                    opacity: isMapMode ? 1.0 : 0.3,
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      Icons.pin_drop,
                      size: 40,
                      color: theme.colorScheme.onPrimary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedOpacity(
                    opacity: !isMapMode ? 1.0 : 0.3,
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      Icons.list,
                      size: 40,
                      color: theme.colorScheme.onPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Botón de Ajustes
          IconButton(
            onPressed: onAjustesPressed,
            icon: Icon(Icons.settings,
                size: 40,
                color: theme.colorScheme.onPrimary
                    .withValues(alpha: 0.5)),
          ),
        ],
      ),
    );
  }
}
