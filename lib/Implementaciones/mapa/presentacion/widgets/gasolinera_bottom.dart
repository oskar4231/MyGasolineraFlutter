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
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Cabecera: nombre + botón favorito ──────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  gasolinera.rotulo,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: () async {
                  await onToggleFavorito();
                  if (context.mounted) Navigator.pop(context);
                },
                icon: Icon(
                  esFavorita ? Icons.star : Icons.star_border,
                  color: esFavorita ? Colors.amber : Colors.grey,
                  size: 32,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ── Dirección ──────────────────────────────────────────────────
          Text(
            gasolinera.direccion,
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),

          const SizedBox(height: 20),

          // ── Precios ────────────────────────────────────────────────────
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (gasolinera.gasolina95 > 0)
                _PrecioItem(
                  nombre: 'Gasolina 95',
                  precio: gasolinera.gasolina95,
                  icon: Icons.local_gas_station,
                  color: Colors.green,
                ),
              if (gasolinera.gasoleoA > 0)
                _PrecioItem(
                  nombre: 'Diesel',
                  precio: gasolinera.gasoleoA,
                  icon: Icons.directions_car,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              if (gasolinera.gasolina98 > 0)
                _PrecioItem(
                  nombre: 'Gasolina 98',
                  precio: gasolinera.gasolina98,
                  icon: Icons.local_gas_station,
                  color: Colors.blue,
                ),
              if (gasolinera.glp > 0)
                _PrecioItem(
                  nombre: 'GLP',
                  precio: gasolinera.glp,
                  icon: Icons.local_fire_department,
                  color: Colors.orange,
                ),
            ],
          ),

          const SizedBox(height: 24),

          // ── Botón Favorito ─────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                await onToggleFavorito();
                if (context.mounted) Navigator.pop(context);
              },
              icon: Icon(
                esFavorita ? Icons.star : Icons.star_border,
                color: Colors.white,
              ),
              label: Text(
                esFavorita ? 'Eliminar de favoritos' : 'Añadir a favoritos',
                style: const TextStyle(fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: esFavorita
                    ? Theme.of(context).colorScheme.error
                    : Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ── Botón Repostaje Rápido ─────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CrearFacturaScreen(
                      prefilledGasolineraName: gasolinera.rotulo,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.flash_on, color: Colors.white),
              label: const Text(
                'Repostaje Rápido',
                style: TextStyle(fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF9350),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ── Botón Cómo Llegar ──────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _abrirGoogleMaps(gasolinera.lat, gasolinera.lng),
              icon: Icon(
                Icons.directions,
                color: Theme.of(context).colorScheme.primary,
              ),
              label: Text(
                'Cómo llegar',
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Widget privado para cada fila de precio ────────────────────────────────────
class _PrecioItem extends StatelessWidget {
  final String nombre;
  final double precio;
  final IconData icon;
  final Color color;

  const _PrecioItem({
    required this.nombre,
    required this.precio,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 8),
          Text(
            '$nombre: ',
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const Spacer(),
          Text(
            '${precio.toStringAsFixed(3)}€',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
