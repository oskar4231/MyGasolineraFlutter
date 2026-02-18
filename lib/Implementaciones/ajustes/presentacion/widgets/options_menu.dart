import 'package:flutter/material.dart';
import 'package:my_gasolinera/core/l10n/app_localizations.dart';
import 'package:my_gasolinera/Implementaciones/ajustes/presentacion/pages/idiomas_screen.dart';
import 'package:my_gasolinera/Implementaciones/estadisticas/presentacion/pages/estadisticas.dart';
import 'package:my_gasolinera/Implementaciones/facturas/presentacion/pages/facturas_screen.dart';
import 'package:my_gasolinera/Implementaciones/ajustes/presentacion/pages/accesibilidad_screen.dart';

class OptionsMenu extends StatelessWidget {
  final VoidCallback onDeleteAccount;

  const OptionsMenu({
    super.key,
    required this.onDeleteAccount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isDark = theme.brightness == Brightness.dark;

    final cardColor = isDark
        ? const Color(0xFF212124)
        : (theme.cardTheme.color ?? theme.cardColor);
    final lighterCardColor = isDark
        ? const Color(0xFF3E3E42)
        : Color.lerp(cardColor, Colors.white, 0.25);
    final borderColor = isDark ? Colors.white10 : Colors.grey.withOpacity(0.2);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.opciones,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: lighterCardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withOpacity(0.3)
                    : Colors.grey.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Column(
              children: [
                _OptionItem(
                  icono: Icons.language,
                  texto: l10n.idiomas,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const IdiomasScreen()),
                    );
                  },
                ),
                Divider(height: 1, color: borderColor),
                _OptionItem(
                  icono: Icons.query_stats,
                  texto: l10n.estadisticas,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EstadisticasScreen(),
                      ),
                    );
                  },
                ),
                Divider(height: 1, color: borderColor),
                _OptionItem(
                  icono: Icons.receipt,
                  texto: l10n.gastosFacturas,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const FacturasScreen()),
                    );
                  },
                ),
                Divider(height: 1, color: borderColor),
                _OptionItem(
                  icono: Icons.accessibility_new,
                  texto: l10n.accesibilidad,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AccesibilidadScreen(),
                      ),
                    );
                  },
                ),
                Divider(height: 1, color: borderColor),
                _OptionItem(
                  icono: Icons.delete_outline,
                  texto: l10n.borrarCuenta,
                  onTap: onDeleteAccount,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _OptionItem extends StatelessWidget {
  final IconData icono;
  final String texto;
  final VoidCallback onTap;

  const _OptionItem({
    required this.icono,
    required this.texto,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final primaryColor = isDark ? const Color(0xFFFF8235) : theme.primaryColor;
    final textColor =
        isDark ? const Color(0xFFEBEBEB) : theme.colorScheme.onSurface;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        hoverColor: primaryColor.withOpacity(0.1),
        splashColor: primaryColor.withOpacity(0.2),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icono, color: primaryColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  texto,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: textColor.withOpacity(0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
