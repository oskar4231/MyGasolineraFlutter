import 'package:flutter/material.dart';
import 'package:my_gasolinera/l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context)!;

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
            Text(
              "MyGasolinera",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.all(8),
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
                  Center(
                    child: ToggleButtons(
                      isSelected: [showMap, !showMap],
                      onPressed: (index) {
                        onToggleChanged(index == 0);
                      },
                      borderRadius: BorderRadius.circular(8),
                      selectedColor: theme.colorScheme.onPrimary,
                      color: theme.colorScheme.onPrimary.withValues(alpha: 0.7),
                      fillColor:
                          theme.colorScheme.onPrimary.withValues(alpha: 0.2),
                      constraints: const BoxConstraints(
                        minHeight: 32,
                        minWidth: 85,
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Text(
                            l10n.mapa,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Text(
                            l10n.lista,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
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
