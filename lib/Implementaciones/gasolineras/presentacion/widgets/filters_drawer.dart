import 'package:flutter/material.dart';
import 'package:my_gasolinera/core/l10n/app_localizations.dart';

class FiltersDrawer extends StatelessWidget {
  final VoidCallback onPriceFilterPressed;
  final VoidCallback onFuelFilterPressed;
  final VoidCallback onOpeningFilterPressed;

  const FiltersDrawer({
    super.key,
    required this.onPriceFilterPressed,
    required this.onFuelFilterPressed,
    required this.onOpeningFilterPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          SizedBox(
            height: 60,
            child: DrawerHeader(
              decoration: BoxDecoration(color: theme.colorScheme.primary),
              margin: EdgeInsets.zero,
              padding: const EdgeInsets.all(16),
              child: Text(
                l10n.filtros,
                style:
                    TextStyle(fontSize: 20, color: theme.colorScheme.onPrimary),
              ),
            ),
          ),
          ListTile(
            title: Text(l10n.precio,
                style: TextStyle(color: theme.colorScheme.onSurface)),
            onTap: () {
              Navigator.of(context).pop();
              onPriceFilterPressed();
            },
          ),
          ListTile(
            title: Text(l10n.combustible,
                style: TextStyle(color: theme.colorScheme.onSurface)),
            onTap: () {
              Navigator.of(context).pop();
              onFuelFilterPressed();
            },
          ),
          ListTile(
            title: Text(l10n.apertura,
                style: TextStyle(color: theme.colorScheme.onSurface)),
            onTap: () {
              Navigator.of(context).pop();
              onOpeningFilterPressed();
            },
          ),
        ],
      ),
    );
  }
}
