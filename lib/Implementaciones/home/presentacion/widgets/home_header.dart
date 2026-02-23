import 'package:flutter/material.dart';

class HomeHeader extends StatelessWidget {
  final VoidCallback onFavoritosPressed;
  final VoidCallback onPriceFilterPressed;
  final VoidCallback onOpenDrawer;

  const HomeHeader({
    super.key,
    required this.onFavoritosPressed,
    required this.onPriceFilterPressed,
    required this.onOpenDrawer,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {}, // Captura eventos para que no lleguen al mapa
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Botón de Favoritos (Estrella)
            IconButton(
              icon: Icon(Icons.stars,
                  size: 40, color: theme.colorScheme.onPrimary),
              onPressed: onFavoritosPressed,
            ),

            // Botón de filtro de precio (Euro + Flecha)
            IconButton(
              icon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.arrow_upward_rounded,
                      size: 26, color: theme.colorScheme.onPrimary),
                  const SizedBox(width: 2),
                  Icon(Icons.euro_symbol_rounded,
                      size: 32, color: theme.colorScheme.onPrimary),
                ],
              ),
              onPressed: onPriceFilterPressed,
            ),

            // Botón para abrir el drawer de filtros (+)
            IconButton(
              icon: Icon(Icons.tune_rounded,
                  size: 36, color: theme.colorScheme.onPrimary),
              onPressed: onOpenDrawer,
            ),
          ],
        ),
      ),
    );
  }
}
