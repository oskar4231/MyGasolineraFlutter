import 'package:flutter/material.dart';
import 'package:my_gasolinera/Implementaciones/facturas/presentacion/pages/crear_factura_screen.dart';
import 'package:my_gasolinera/Implementaciones/gasolineras/domain/models/gasolinera.dart';
import 'package:url_launcher/url_launcher.dart';

/// Bottom sheet con la información de una gasolinera.
/// Recibe callbacks para no depender de ningún estado externo.
class GasolineraBottomSheet extends StatelessWidget {
  final Gasolinera gasolinera;
  final bool esFavorita;
  final Future<void> Function() onToggleFavorito;

  const GasolineraBottomSheet({
    super.key,
    required this.gasolinera,
    required this.esFavorita,
    required this.onToggleFavorito,
  });

  /// Abre Google Maps con dirección para navegar a la gasolinera
  Future<void> _abrirGoogleMaps(double lat, double lng) async {
    final Uri mapsWebUri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving',
    );
    try {
      await launchUrl(mapsWebUri, mode: LaunchMode.externalApplication);
    } catch (e) {
      await launchUrl(mapsWebUri, mode: LaunchMode.platformDefault);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final primaryColor =
        isDark ? const Color(0xFFFF8235) : theme.colorScheme.primary;
    final cardColor = isDark
        ? const Color(0xFF212124)
        : (theme.cardTheme.color ?? theme.cardColor);
    final lighterCardColor = isDark
        ? const Color(0xFF2A2A2E)
        : Color.lerp(cardColor, Colors.white, 0.3);
    final borderColor = isDark ? Colors.white10 : Colors.grey.withOpacity(0.18);
    final textPrimary =
        isDark ? const Color(0xFFEBEBEB) : theme.colorScheme.onSurface;
    final textSecondary = isDark
        ? const Color(0xFF9E9E9E)
        : theme.colorScheme.onSurface.withOpacity(0.6);

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Handle ──────────────────────────────────────────────────────
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: borderColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // ── Cabecera: nombre + botón favorito ────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  gasolinera.rotulo,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () async {
                  await onToggleFavorito();
                  if (context.mounted) Navigator.pop(context);
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    esFavorita ? Icons.star_rounded : Icons.star_border_rounded,
                    color: esFavorita ? primaryColor : textSecondary,
                    size: 26,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // ── Dirección ────────────────────────────────────────────────────
          Row(
            children: [
              Icon(Icons.location_on_outlined, size: 15, color: textSecondary),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  gasolinera.direccion,
                  style: TextStyle(fontSize: 14, color: textSecondary),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ── Precios en card ──────────────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              color: lighterCardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Column(
                children: [
                  if (gasolinera.gasolina95 > 0) ...[
                    _PrecioRow(
                      icon: Icons.local_gas_station,
                      nombre: 'Gasolina 95',
                      precio: gasolinera.gasolina95,
                      iconColor: Colors.green,
                      primaryColor: primaryColor,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                    Divider(height: 1, color: borderColor),
                  ],
                  if (gasolinera.gasoleoA > 0) ...[
                    _PrecioRow(
                      icon: Icons.directions_car,
                      nombre: 'Diesel',
                      precio: gasolinera.gasoleoA,
                      iconColor: Colors.blueGrey,
                      primaryColor: primaryColor,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                    Divider(height: 1, color: borderColor),
                  ],
                  if (gasolinera.gasolina98 > 0) ...[
                    _PrecioRow(
                      icon: Icons.local_gas_station,
                      nombre: 'Gasolina 98',
                      precio: gasolinera.gasolina98,
                      iconColor: Colors.blue,
                      primaryColor: primaryColor,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                    Divider(height: 1, color: borderColor),
                  ],
                  if (gasolinera.glp > 0)
                    _PrecioRow(
                      icon: Icons.local_fire_department,
                      nombre: 'GLP',
                      precio: gasolinera.glp,
                      iconColor: Colors.orange,
                      primaryColor: primaryColor,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ── Botón Favorito ───────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                await onToggleFavorito();
                if (context.mounted) {
                  // Pequeño delay para asegurar que el evento de clic se consuma en Flutter antes de cerrar
                  await Future.delayed(const Duration(milliseconds: 150));
                  if (context.mounted) Navigator.pop(context);
                }
              },
              icon: Icon(
                esFavorita ? Icons.star_rounded : Icons.star_border_rounded,
                size: 20,
              ),
              label: Text(
                esFavorita ? 'Eliminar de favoritos' : 'Añadir a favoritos',
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    esFavorita ? theme.colorScheme.error : primaryColor,
                foregroundColor:
                    esFavorita ? Colors.white : theme.colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // ── Fila: Repostaje + Cómo llegar ────────────────────────────────
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    // Pequeño delay antes de cerrar para evitar pass-through
                    await Future.delayed(const Duration(milliseconds: 150));
                    if (context.mounted) Navigator.pop(context);

                    if (context.mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CrearFacturaScreen(
                            prefilledGasolineraName: gasolinera.rotulo,
                          ),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.flash_on, size: 18),
                  label: const Text(
                    'Repostaje',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: theme.colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () =>
                      _abrirGoogleMaps(gasolinera.lat, gasolinera.lng),
                  icon: Icon(Icons.directions, size: 18, color: primaryColor),
                  label: Text(
                    'Cómo llegar',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: primaryColor,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: primaryColor, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Widget privado para cada fila de precio ─────────────────────────────────
class _PrecioRow extends StatelessWidget {
  final IconData icon;
  final String nombre;
  final double precio;
  final Color iconColor;
  final Color primaryColor;
  final Color textPrimary;
  final Color textSecondary;

  const _PrecioRow({
    required this.icon,
    required this.nombre,
    required this.precio,
    required this.iconColor,
    required this.primaryColor,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              nombre,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: textPrimary,
              ),
            ),
          ),
          Text(
            '${precio.toStringAsFixed(3)} €',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
