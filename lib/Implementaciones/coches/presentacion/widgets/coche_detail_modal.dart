import 'package:flutter/material.dart';
import 'package:my_gasolinera/core/l10n/app_localizations.dart';
import 'package:my_gasolinera/Implementaciones/coches/domain/models/coche.dart';
import 'package:my_gasolinera/Implementaciones/coches/presentacion/widgets/brand_logo.dart';

/// Modal que muestra los detalles completos de un [Coche].
///
/// Se puede abrir directamente con [CocheDetailModal.mostrar].
class CocheDetailModal extends StatelessWidget {
  final Coche coche;

  const CocheDetailModal({super.key, required this.coche});

  /// Abre el diálogo de detalles del coche.
  static Future<void> mostrar(BuildContext context, {required Coche coche}) {
    return showDialog(
      context: context,
      builder: (_) => CocheDetailModal(coche: coche),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // ── Colores consistentes con el resto de la app ──────────────────────────
    // accentColor: en oscuro mantenemos el naranja de la marca; en claro
    // usamos theme.colorScheme.primary para respetar todos los temas
    // (protanopia, deuteranopia, tritanopia, achromatopsia…)
    final accentColor =
        isDark ? const Color(0xFFFF8235) : theme.colorScheme.primary;
    final dialogBg = isDark
        ? const Color(0xFF212124)
        : theme.dialogTheme.backgroundColor ?? theme.colorScheme.surface;
    final cardBg = isDark
        ? const Color(0xFF3E3E42)
        : theme.colorScheme.surfaceContainerHighest;
    final textColor =
        isDark ? const Color(0xFFEBEBEB) : theme.colorScheme.onSurface;
    final subtextColor = isDark
        ? const Color(0xFFEBEBEB).withValues(alpha: 0.6)
        : theme.colorScheme.onSurface.withValues(alpha: 0.55);
    final chipBg = accentColor.withValues(alpha: isDark ? 0.15 : 0.2);
    final dividerColor =
        isDark ? const Color(0xFF38383A) : theme.dividerColor;
    final borderColor =
        isDark ? const Color(0xFF38383A) : Colors.transparent;

    return AlertDialog(
      backgroundColor: dialogBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: isDark
            ? BorderSide(color: borderColor, width: 1)
            : BorderSide.none,
      ),
      contentPadding: EdgeInsets.zero,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Cabecera ───────────────────────────────────────────────
              _buildHeader(isDark, accentColor, textColor, subtextColor),

              Divider(color: dividerColor, height: 1),

              // ── Secciones de información ───────────────────────────────
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Combustibles
                    _buildSectionTitle(
                      l10n.tiposCombustibleLabel,
                      Icons.local_gas_station_outlined,
                      accentColor,
                      textColor,
                    ),
                    const SizedBox(height: 10),
                    _buildCombustibles(
                        coche.tiposCombustible, accentColor, textColor, chipBg),
                    const SizedBox(height: 20),

                    // Estadísticas
                    _buildSectionTitle(
                      l10n.estadisticas,
                      Icons.bar_chart_rounded,
                      accentColor,
                      textColor,
                    ),
                    const SizedBox(height: 10),
                    _buildStatsGrid(l10n, isDark, cardBg, textColor, subtextColor, accentColor),

                    // Mantenimiento (solo si hay datos de aceite)
                    if (coche.fechaUltimoCambioAceite != null ||
                        coche.kmUltimoCambioAceite != null) ...[
                      const SizedBox(height: 20),
                      _buildSectionTitle(
                        l10n.mantenimiento,
                        Icons.build_outlined,
                        accentColor,
                        textColor,
                      ),
                      const SizedBox(height: 10),
                      _buildMaintenanceGrid(
                          isDark, cardBg, textColor, subtextColor, accentColor),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          style: ElevatedButton.styleFrom(
            backgroundColor: accentColor,
            foregroundColor: theme.colorScheme.onPrimary,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: Text(
            l10n.cerrar,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ),
      ],
    );
  }

  // ── Cabecera ──────────────────────────────────────────────────────────────
  Widget _buildHeader(
    bool isDark,
    Color accentColor,
    Color textColor,
    Color subtextColor,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Row(
        children: [
          // Logo de marca
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              // Oscuro: gris neutro. Claro: tinte suave del color del tema.
              color: isDark
                  ? const Color(0xFF4A4A50)
                  : accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: BrandLogo(
              brandName: coche.marca,
              size: 38,
              fallbackColor: accentColor,
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
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  coche.modelo,
                  style: TextStyle(
                    fontSize: 16,
                    color: subtextColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Título de sección ─────────────────────────────────────────────────────
  Widget _buildSectionTitle(
      String title, IconData icon, Color accentColor, Color textColor) {
    return Row(
      children: [
        Icon(icon, size: 18, color: accentColor),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: accentColor,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  // ── Chips de combustible ──────────────────────────────────────────────────
  Widget _buildCombustibles(
    List<String> combustibles,
    Color accentColor,
    Color textColor,
    Color chipBg,
  ) {
    if (combustibles.isEmpty) {
      return Text(
        'Sin información',
        style: TextStyle(color: textColor.withValues(alpha: 0.5)),
      );
    }
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: combustibles.map((c) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: chipBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: accentColor, width: 1),
          ),
          child: Text(
            c,
            style: TextStyle(
              fontSize: 13,
              color: textColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Grid de estadísticas ──────────────────────────────────────────────────
  Widget _buildStatsGrid(
    AppLocalizations l10n,
    bool isDark,
    Color cardBg,
    Color textColor,
    Color subtextColor,
    Color accentColor,
  ) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 2.2,
      children: [
        _buildStatCard(
          icon: Icons.speed_outlined,
          label: l10n.kilometrajeInicial,
          value: coche.kilometrajeInicial != null
              ? '${coche.kilometrajeInicial!} km'
              : '—',
          isDark: isDark,
          cardBg: cardBg,
          textColor: textColor,
          subtextColor: subtextColor,
          accentColor: accentColor,
        ),
        _buildStatCard(
          icon: Icons.local_drink_outlined,
          label: l10n.capacidadTanque,
          value: coche.capacidadTanque != null
              ? '${coche.capacidadTanque!.toStringAsFixed(0)} L'
              : '—',
          isDark: isDark,
          cardBg: cardBg,
          textColor: textColor,
          subtextColor: subtextColor,
          accentColor: accentColor,
        ),
        _buildStatCard(
          icon: Icons.show_chart_rounded,
          label: l10n.consumoTeorico,
          value: coche.consumoTeorico != null
              ? '${coche.consumoTeorico!.toStringAsFixed(1)} L/100'
              : '—',
          isDark: isDark,
          cardBg: cardBg,
          textColor: textColor,
          subtextColor: subtextColor,
          accentColor: accentColor,
        ),
        _buildStatCard(
          icon: Icons.refresh_rounded,
          label: 'Cambio aceite',
          value: '${coche.intervaloCambioAceiteKm ~/ 1000}k km · ${coche.intervaloCambioAceiteMeses} m',
          isDark: isDark,
          cardBg: cardBg,
          textColor: textColor,
          subtextColor: subtextColor,
          accentColor: accentColor,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
    required Color cardBg,
    required Color textColor,
    required Color subtextColor,
    required Color accentColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 22, color: accentColor),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 10, color: subtextColor),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Grid de mantenimiento ─────────────────────────────────────────────────
  Widget _buildMaintenanceGrid(
    bool isDark,
    Color cardBg,
    Color textColor,
    Color subtextColor,
    Color accentColor,
  ) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 2.2,
      children: [
        if (coche.kmUltimoCambioAceite != null)
          _buildStatCard(
            icon: Icons.tire_repair_outlined,
            label: 'KM último aceite',
            value: '${coche.kmUltimoCambioAceite!} km',
            isDark: isDark,
            cardBg: cardBg,
            textColor: textColor,
            subtextColor: subtextColor,
            accentColor: accentColor,
          ),
        if (coche.fechaUltimoCambioAceite != null)
          _buildStatCard(
            icon: Icons.calendar_today_outlined,
            label: 'Fecha último aceite',
            value: coche.fechaUltimoCambioAceite!,
            isDark: isDark,
            cardBg: cardBg,
            textColor: textColor,
            subtextColor: subtextColor,
            accentColor: accentColor,
          ),
      ],
    );
  }
}
