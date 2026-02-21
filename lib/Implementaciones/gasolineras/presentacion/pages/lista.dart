import 'package:flutter/material.dart';
import 'package:my_gasolinera/Implementaciones/gasolineras/domain/models/gasolinera.dart';

class GasolineraListWidget extends StatelessWidget {
  final List<Gasolinera> gasolineras;
  final VoidCallback? onItemTap;
  const GasolineraListWidget({
    super.key,
    required this.gasolineras,
    this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    if (gasolineras.isEmpty) {
      return const Center(child: Text('No hay gasolineras disponibles'));
    }

    final gasolinerasLimitadas = gasolineras.take(50).toList();

    return ListView.separated(
      itemCount: gasolinerasLimitadas.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final g = gasolinerasLimitadas[index];

        return ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          title: Text(
            g.rotulo,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Row(
              children: [
                if (g.gasolina95 > 0) ...[
                  _smallPriceIndicator(
                      '95', g.gasolina95, const Color(0xFF2ECC71)),
                  const SizedBox(width: 12),
                ],
                if (g.gasoleoA > 0)
                  _smallPriceIndicator(
                      'Diesel', g.gasoleoA, const Color(0xFF34495E)),
              ],
            ),
          ),
          trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
          onTap: () {
            onItemTap?.call();
          },
        );
      },
    );
  }

  Widget _smallPriceIndicator(String label, double price, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          '$label: ',
          style: const TextStyle(
              fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500),
        ),
        Text(
          '${price.toStringAsFixed(3)}€',
          style: TextStyle(
              fontSize: 13, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }
}
