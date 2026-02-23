import 'package:flutter/material.dart';
import 'package:my_gasolinera/core/l10n/app_localizations.dart';

import 'package:my_gasolinera/main.dart' as app;

class FiltersDrawer extends StatefulWidget {
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
  State<FiltersDrawer> createState() => _FiltersDrawerState();
}

class _FiltersDrawerState extends State<FiltersDrawer>
    with SingleTickerProviderStateMixin {
  late AnimationController _blinkController;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.3).animate(
      CurvedAnimation(parent: _blinkController, curve: Curves.easeInOut),
    );

    // Solo parpadear si no hay combustible seleccionado
    if (app.filterProvider.tipoCombustibleSeleccionado == null) {
      _blinkController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _blinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final fuelSelected = app.filterProvider.tipoCombustibleSeleccionado != null;

    // Detener animación si ya hay algo seleccionado
    if (fuelSelected && _blinkController.isAnimating) {
      _blinkController.stop();
      _blinkController.value = 0; // Opacidad completa (begin: 1.0)
    } else if (!fuelSelected && !_blinkController.isAnimating) {
      _blinkController.repeat(reverse: true);
    }

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
              child: Row(
                children: [
                  Icon(Icons.filter_list, color: theme.colorScheme.onPrimary),
                  const SizedBox(width: 12),
                  Text(
                    l10n.filtros,
                    style: TextStyle(
                        fontSize: 20, color: theme.colorScheme.onPrimary),
                  ),
                ],
              ),
            ),
          ),
          FadeTransition(
            opacity: !fuelSelected
                ? _opacityAnimation
                : const AlwaysStoppedAnimation(1.0),
            child: ListTile(
              leading: Icon(Icons.local_gas_station,
                  color: !fuelSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface),
              title: Text(l10n.combustible,
                  style: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontWeight:
                          !fuelSelected ? FontWeight.bold : FontWeight.normal)),
              onTap: () {
                Navigator.of(context).pop();
                widget.onFuelFilterPressed();
              },
            ),
          ),
          ListTile(
            leading: Icon(Icons.euro,
                color:
                    fuelSelected ? theme.colorScheme.onSurface : Colors.grey),
            enabled: fuelSelected,
            title: Text(l10n.precio,
                style: TextStyle(
                    color: fuelSelected
                        ? theme.colorScheme.onSurface
                        : Colors.grey)),
            subtitle: !fuelSelected
                ? Text(
                    "Seleccione combustible primero",
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  )
                : null,
            onTap: () {
              Navigator.of(context).pop();
              widget.onPriceFilterPressed();
            },
          ),
          ListTile(
            leading:
                Icon(Icons.access_time, color: theme.colorScheme.onSurface),
            title: Text(l10n.apertura,
                style: TextStyle(color: theme.colorScheme.onSurface)),
            onTap: () {
              Navigator.of(context).pop();
              widget.onOpeningFilterPressed();
            },
          ),
          const Divider(),
          ListTile(
            leading: Icon(
              Icons.delete_outline,
              color: (fuelSelected ||
                      app.filterProvider.precioDesde != null ||
                      app.filterProvider.precioHasta != null ||
                      app.filterProvider.tipoAperturaSeleccionado != null)
                  ? Colors.redAccent
                  : theme.dividerColor,
            ),
            title: Text(
              'Limpiar filtros',
              style: TextStyle(
                color: (fuelSelected ||
                        app.filterProvider.precioDesde != null ||
                        app.filterProvider.precioHasta != null ||
                        app.filterProvider.tipoAperturaSeleccionado != null)
                    ? Colors.redAccent
                    : theme.disabledColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: (fuelSelected ||
                    app.filterProvider.precioDesde != null ||
                    app.filterProvider.precioHasta != null ||
                    app.filterProvider.tipoAperturaSeleccionado != null)
                ? () {
                    app.filterProvider.clearFilters();
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Filtros eliminados'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  }
                : null,
          ),
        ],
      ),
    );
  }
}
