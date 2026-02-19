import 'package:flutter/material.dart';

class HomeHeader extends StatelessWidget {
  final bool showMap;
  final ValueChanged<bool> onToggleChanged;
  final VoidCallback onFavoritosPressed;
  final VoidCallback onPriceFilterPressed;
  final VoidCallback onOpenDrawer;

  const HomeHeader({
    super.key,
    required this.showMap,
    required this.onToggleChanged,
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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Botón de Favoritos (Estrella)
                IconButton(
                  icon: Icon(Icons.stars,
                      size: 40, color: theme.colorScheme.onPrimary),
                  onPressed: onFavoritosPressed,
                ),

                // Botón de filtro de precio (flecha arriba)
                IconButton(
                  icon: Icon(Icons.arrow_upward,
                      size: 40, color: theme.colorScheme.onPrimary),
                  onPressed: onPriceFilterPressed,
                ),

                // Botón para abrir el drawer de filtros (+)
                IconButton(
                  icon: Icon(Icons.add,
                      size: 40, color: theme.colorScheme.onPrimary),
                  onPressed: onOpenDrawer,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
