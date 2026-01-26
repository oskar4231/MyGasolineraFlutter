import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_gasolinera/principal/gasolineras/gasolinera.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_gasolinera/l10n/app_localizations.dart';

class GasolineraItem extends StatefulWidget {
  final Gasolinera gasolinera;
  final VoidCallback onRemoved; // Callback for when removed from favorites

  const GasolineraItem({
    super.key,
    required this.gasolinera,
    required this.onRemoved,
  });

  @override
  State<GasolineraItem> createState() => _GasolineraItemState();
}

class _GasolineraItemState extends State<GasolineraItem> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final formatter = NumberFormat.currency(
      locale: 'es_ES',
      symbol: '€',
      decimalDigits: 3,
    );

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [Colors.white, const Color(0xFFFFF5EE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF492714).withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF9350),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.local_gas_station_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.gasolinera.rotulo,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF492714),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.gasolinera.direccion,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    // Eliminar de favoritos (logic moved here or uses callback)
                    // We handle the storage update here or in parent?
                    // Better to handle storage here to be self-contained for the "action",
                    // but parent list needs to update.

                    final prefs = await SharedPreferences.getInstance();
                    final idsFavoritos =
                        prefs.getStringList('favoritas_ids') ?? [];
                    idsFavoritos.remove(widget.gasolinera.id);
                    await prefs.setStringList('favoritas_ids', idsFavoritos);

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '${widget.gasolinera.rotulo} ${l10n.eliminadoDeFavoritos}',
                          ),
                          backgroundColor: Colors.red,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                      // Notify parent to remove from list
                      widget.onRemoved();
                    }
                  },
                  icon: const Icon(
                    Icons.star_rounded,
                    color: Color(0xFFFF9350),
                    size: 32,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFFFFF0E6),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _buildPreciosPremium(widget.gasolinera, formatter),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPreciosPremium(Gasolinera g, NumberFormat formatter) {
    final preciosWidgets = <Widget>[];

    // Helper para crear widgets de precio
    Widget buildPrice(String label, double price, Color color) {
      return Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${price.toStringAsFixed(3)}€',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      );
    }

    if (g.gasolina95 > 0) {
      preciosWidgets.add(
        buildPrice('G95', g.gasolina95, const Color(0xFF00A650)),
      );
    }

    if (g.gasoleoA > 0) {
      preciosWidgets.add(
        buildPrice('Diesel', g.gasoleoA, const Color(0xFF000000)),
      );
    }

    if (g.gasolina98 > 0 && preciosWidgets.length < 3) {
      preciosWidgets.add(
        buildPrice('G98', g.gasolina98, const Color(0xFF008030)),
      );
    }

    // Si solo hay uno o dos, añadir GLP o Premium si existen para llenar visualmente
    if (preciosWidgets.length < 3 && g.glp > 0) {
      preciosWidgets.add(buildPrice('GLP', g.glp, const Color(0xFFFF5722)));
    }

    return preciosWidgets;
  }
}
