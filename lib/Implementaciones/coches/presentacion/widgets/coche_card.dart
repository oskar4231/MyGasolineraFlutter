import 'package:flutter/material.dart';
import 'package:my_gasolinera/core/l10n/app_localizations.dart';
import 'package:my_gasolinera/Implementaciones/coches/domain/models/coche.dart';
import 'package:my_gasolinera/Implementaciones/coches/presentacion/widgets/brand_logo.dart';

class CocheCard extends StatelessWidget {
  final Coche coche;
  final VoidCallback onDelete;

  const CocheCard({
    super.key,
    required this.coche,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardColor = isDark
        ? const Color(0xFF3E3E42)
        : (theme.cardTheme.color ?? theme.cardColor);
    final textColor =
        isDark ? const Color(0xFFEBEBEB) : theme.colorScheme.onSurface;
    final subtextColor = isDark
        ? const Color(0xFFEBEBEB).withValues(alpha: 0.6)
        : theme.colorScheme.onSurface.withValues(alpha: 0.5);
    final accentColor = isDark ? const Color(0xFFFF8235) : theme.primaryColor;
    final chipBg = isDark
        ? accentColor.withValues(alpha: 0.15)
        : accentColor.withValues(alpha: 0.2);
    final dividerColor = isDark ? const Color(0xFF38383A) : theme.dividerColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.grey.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF4A4A50) : accentColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: BrandLogo(
                    brandName: coche.marca,
                    size: 32,
                    fallbackColor: isDark ? accentColor : Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        coche.marca,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        coche.modelo,
                        style: TextStyle(
                          fontSize: 16,
                          color: textColor.withValues(alpha: 0.7),
                        ),
                      ),
                      if (coche.kilometrajeInicial != null)
                        Text(
                          l10n.kilometrajeItem(coche.kilometrajeInicial!),
                          style: TextStyle(
                            fontSize: 12,
                            color: subtextColor,
                          ),
                        ),
                      if (coche.capacidadTanque != null)
                        Text(
                          l10n.tanqueItem(coche.capacidadTanque!),
                          style: TextStyle(
                            fontSize: 12,
                            color: subtextColor,
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: Icon(
                    Icons.delete_outline,
                    color: isDark ? Colors.redAccent : theme.colorScheme.error,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Divider(color: dividerColor, height: 1),
            const SizedBox(height: 12),
            Text(
              l10n.tiposCombustibleLabel,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: coche.tiposCombustible.map((combustible) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: chipBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: accentColor,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    combustible,
                    style: TextStyle(
                      fontSize: 12,
                      color: textColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
