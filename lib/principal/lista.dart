import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_gasolinera/principal/gasolineras/gasolinera.dart';

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
    final currencyFormatter = NumberFormat.currency(locale: 'es_ES', symbol: '€', decimalDigits: 3);

    if (gasolineras.isEmpty) {
      return const Center(child: Text('No hay gasolineras disponibles'));
    }

    return ListView.separated(
      itemCount: gasolineras.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final g = gasolineras[index];
        final p95 = g.gasolina95 > 0 ? currencyFormatter.format(g.gasolina95) : 'N/A';
        final pd = g.gasoleoA > 0 ? currencyFormatter.format(g.gasoleoA) : 'N/A';

        return ListTile(
          title: Text(g.rotulo),
          subtitle: Text('G95: $p95 — Diésel: $pd'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            onItemTap?.call();
          },
        );
      },
    );
  }
}