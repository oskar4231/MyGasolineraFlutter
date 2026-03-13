import 'package:flutter/material.dart';
import 'package:my_gasolinera/core/l10n/app_localizations.dart';

import 'package:my_gasolinera/main.dart' as app;

class FiltersDialog extends StatefulWidget {
  final VoidCallback onPriceFilterPressed;
  final VoidCallback onFuelFilterPressed;
  final VoidCallback onOpeningFilterPressed;

  const FiltersDialog({
    super.key,
    required this.onPriceFilterPressed,
    required this.onFuelFilterPressed,
    required this.onOpeningFilterPressed,
  });

  @override
  State<FiltersDialog> createState() => _FiltersDialogState();

  static Future<void> show(
    BuildContext context, {
    required VoidCallback onPriceFilterPressed,
    required VoidCallback onFuelFilterPressed,
    required VoidCallback onOpeningFilterPressed,
  }) {
    return showDialog(
      context: context,
      builder: (context) => FiltersDialog(
        onPriceFilterPressed: onPriceFilterPressed,
        onFuelFilterPressed: onFuelFilterPressed,
        onOpeningFilterPressed: onOpeningFilterPressed,
      ),
    );
  }
}

class _FiltersDialogState extends State<FiltersDialog>
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
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final fuelSelected = app.filterProvider.tipoCombustibleSeleccionado != null;

    // Detener animación si ya hay algo seleccionado
    if (fuelSelected && _blinkController.isAnimating) {
      _blinkController.stop();
      _blinkController.value = 0; // Opacidad completa (begin: 1.0)
    } else if (!fuelSelected && !_blinkController.isAnimating) {
      _blinkController.repeat(reverse: true);
    }

    final dialogBg =
        isDark ? const Color(0xFF212124) : theme.colorScheme.surface;
    final headerBg = isDark ? dialogBg : theme.colorScheme.primary;
    final headerText = isDark ? Colors.white : theme.colorScheme.onPrimary;
    final textColor =
        isDark ? const Color(0xFFEBEBEB) : theme.colorScheme.onSurface;
    final accentColor =
        isDark ? const Color(0xFFFF8235) : theme.colorScheme.primary;
    final dividerColor = isDark ? const Color(0xFF38383A) : theme.dividerColor;

    return Dialog(
      backgroundColor: dialogBg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            decoration: BoxDecoration(
              color: headerBg,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.filtros,
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: headerText,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: headerText),
                  onPressed: () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Precio
          _buildFilterTile(
            icon: Icons.attach_money_rounded,
            title: l10n.precio,
            textColor: fuelSelected ? textColor : Colors.grey,
            accentColor: fuelSelected ? accentColor : Colors.grey,
            dividerColor: dividerColor,
            onTap: fuelSelected
                ? () {
                    widget.onPriceFilterPressed();
                  }
                : () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Seleccione combustible primero")),
                    );
                  },
          ),

          Divider(height: 1, color: dividerColor, indent: 56),

          // Combustible (con efecto de Fade si no hay seleccionado)
          FadeTransition(
            opacity: !fuelSelected
                ? _opacityAnimation
                : const AlwaysStoppedAnimation(1.0),
            child: _buildFilterTile(
              icon: Icons.local_gas_station_rounded,
              title: l10n.combustible,
              textColor: textColor,
              accentColor:
                  !fuelSelected ? theme.colorScheme.primary : accentColor,
              dividerColor: dividerColor,
              onTap: () {
                widget.onFuelFilterPressed();
              },
            ),
          ),

          Divider(height: 1, color: dividerColor, indent: 56),

          // Apertura
          _buildFilterTile(
            icon: Icons.access_time_rounded,
            title: l10n.apertura,
            textColor: textColor,
            accentColor: accentColor,
            dividerColor: dividerColor,
            onTap: () {
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
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildFilterTile({
    required IconData icon,
    required String title,
    required Color textColor,
    required Color accentColor,
    required Color dividerColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Icon(icon, color: accentColor, size: 24),
      title: Text(
        title,
        style: TextStyle(
          color: textColor,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: textColor.withValues(alpha: 0.5),
      ),
      onTap: onTap,
      hoverColor: accentColor.withValues(alpha: 0.1),
      splashColor: accentColor.withValues(alpha: 0.15),
    );
  }
}
