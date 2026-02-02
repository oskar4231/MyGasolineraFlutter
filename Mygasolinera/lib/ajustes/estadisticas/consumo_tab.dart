import 'package:flutter/material.dart';
import 'package:my_gasolinera/services/estadisticas_avanzadas_service.dart';

import 'package:my_gasolinera/l10n/app_localizations.dart';

class ConsumoTab extends StatefulWidget {
  const ConsumoTab({super.key});

  @override
  State<ConsumoTab> createState() => _ConsumoTabState();
}

class _ConsumoTabState extends State<ConsumoTab> {
  late Future<Map<String, dynamic>> _costoKmData;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _costoKmData = _cargarCostoPorKm();
  }

  Future<Map<String, dynamic>> _cargarCostoPorKm() async {
    try {
      return await EstadisticasAvanzadasService.obtenerCostoPorKm();
    } catch (e) {
      print('Error cargando costo por km: $e');
      return {'costos_por_coche': [], 'total_coches': 0};
    }
  }

  Future<void> _recargar() async {
    setState(() {
      _isLoading = true;
    });
    await _cargarCostoPorKm();
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _recargar,
      color: Theme.of(context).primaryColor,
      child: FutureBuilder<Map<String, dynamic>>(
        future: _costoKmData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting ||
              _isLoading) {
            return Center(
                child: CircularProgressIndicator(
                    color: Theme.of(context).primaryColor));
          }

          if (snapshot.hasError) {
            return _buildError(snapshot.error.toString());
          }

          final data =
              snapshot.data ?? {'costos_por_coche': [], 'total_coches': 0};
          final costosPorCoche = data['costos_por_coche'] as List<dynamic>;
          final totalCoches = data['total_coches'] as int;

          if (totalCoches == 0) {
            return _buildEmptyState();
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título principal
                Text(
                  AppLocalizations.of(context)!.costoKilometro,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context)!.analisisVehiculoSubtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 16),

                // Resumen general
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).primaryColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text(
                            AppLocalizations.of(context)!.totalCoches,
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.6),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$totalCoches',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            AppLocalizations.of(context)!.facturasTotales,
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.6),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_calcularTotalFacturas(costosPorCoche)}',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Lista de coches
                Text(
                  AppLocalizations.of(context)!.analisisVehiculo,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),

                ...costosPorCoche.map((cocheData) {
                  final coche = cocheData as Map<String, dynamic>;
                  return _buildCocheCard(coche);
                }),

                // Información adicional
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).shadowColor.withOpacity(0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info, color: Colors.blue, size: 24),
                          SizedBox(width: 12),
                          Text(
                            AppLocalizations.of(context)!.queEsCostoKm,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Text(
                        AppLocalizations.of(context)!.explainCostoKm,
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.6),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCocheCard(Map<String, dynamic> coche) {
    final costoProm =
        double.tryParse(coche['costo_promedio_por_km']?.toString() ?? '0') ?? 0;
    final costoMin =
        double.tryParse(coche['costo_minimo_por_km']?.toString() ?? '0') ?? 0;
    final costoMax =
        double.tryParse(coche['costo_maximo_por_km']?.toString() ?? '0') ?? 0;
    final kmTotales = int.tryParse(coche['km_totales']?.toString() ?? '0') ?? 0;
    final gastoTotal =
        double.tryParse(coche['gasto_total']?.toString() ?? '0') ?? 0;
    final numFacturas =
        int.tryParse(coche['num_facturas']?.toString() ?? '0') ?? 0;
    final numFacturasValidas =
        int.tryParse(coche['num_facturas_validas']?.toString() ?? '0') ?? 0;

    // Determinar color basado en el costo (más barato = mejor)
    Color getCostoColor(double costo) {
      if (costo < 0.08) return Theme.of(context).primaryColor;
      if (costo < 0.12) return Colors.orange;
      return Theme.of(context).colorScheme.error;
    }

    final costoColor = getCostoColor(costoProm);

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryIconColor =
        isDarkMode ? Colors.orangeAccent : Theme.of(context).primaryColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encabezado con marca y modelo
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: primaryIconColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.directions_car,
                    color: primaryIconColor,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${coche['marca']} ${coche['modelo']}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.local_gas_station,
                            color: Colors.grey.shade600,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$numFacturasValidas/$numFacturas ${AppLocalizations.of(context)!.recargasValidas}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Costo promedio (destacado)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: costoColor.withOpacity(0.1),
              border: Border.symmetric(
                horizontal: BorderSide(
                  color: Colors.grey.shade200,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context)!.costoPromedioKm,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: costoColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '€${_formatNumber(costoProm)}/km',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Estadísticas detalladas
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.estadisticasDetalladas,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),

                // Rango de costos
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.costoMinimo,
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.6),
                          ),
                        ),
                        Text(
                          '€${_formatNumber(costoMin)}/km',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Container(
                          width: 100,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: (costoMin * 1000).round(),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: ((costoMax - costoMin) * 1000).round(),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          AppLocalizations.of(context)!.rangoMinMax,
                          style: TextStyle(
                            fontSize: 10,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.costoMaximo,
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.6),
                          ),
                        ),
                        Text(
                          '€${_formatNumber(costoMax)}/km',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Totales
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      icon: Icons.car_crash,
                      label: AppLocalizations.of(context)!.kilometraje,
                      value: '$kmTotales km',
                      color: Color(0xFFFF9350),
                    ),
                    _buildStatItem(
                      icon: Icons.euro,
                      label: AppLocalizations.of(context)!.gastoTotal,
                      value: '€${_formatNumber(gastoTotal)}',
                      color: const Color(0xFFFF9350),
                    ),
                    _buildStatItem(
                      icon: Icons.attach_money,
                      label: AppLocalizations.of(context)!.costo100km,
                      value: '€${_formatNumber(costoProm * 100)}',
                      color: Color(0xFFFF9350),
                    ),
                  ],
                ),

                // Eficiencia relativa
                if (costoProm > 0) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _getEficienciaColor(costoProm).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _getEficienciaColor(costoProm).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _getEficienciaIcon(costoProm),
                          color: _getEficienciaColor(costoProm),
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _getEficienciaMensaje(costoProm),
                            style: TextStyle(
                              fontSize: 14,
                              color: _getEficienciaColor(costoProm),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildError(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 80, color: Colors.red),
          const SizedBox(height: 20),
          Text(
            '${AppLocalizations.of(context)!.error}: $error',
            style: TextStyle(
                fontSize: 16, color: Theme.of(context).colorScheme.onSurface),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _recargar,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
            ),
            child: Text(AppLocalizations.of(context)!.reintentar,
                style:
                    TextStyle(color: Theme.of(context).colorScheme.onPrimary)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.directions_car_outlined,
              size: 80, color: Colors.grey),
          const SizedBox(height: 20),
          Text(
            AppLocalizations.of(context)!.noDatosConsumo,
            style: TextStyle(
                fontSize: 16, color: Theme.of(context).colorScheme.onSurface),
          ),
          const SizedBox(height: 10),
          Text(
            AppLocalizations.of(context)!.agregaFacturasConsumo,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _recargar,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
            ),
            child: Text(AppLocalizations.of(context)!.reintentar,
                style:
                    TextStyle(color: Theme.of(context).colorScheme.onPrimary)),
          ),
        ],
      ),
    );
  }

  // Helper methods
  int _calcularTotalFacturas(List<dynamic> costosPorCoche) {
    int total = 0;
    for (final coche in costosPorCoche) {
      total += int.tryParse(coche['num_facturas']?.toString() ?? '0') ?? 0;
    }
    return total;
  }

  Color _getEficienciaColor(double costoPorKm) {
    if (costoPorKm < 0.08) return Colors.green;
    if (costoPorKm < 0.12) return Colors.orange;
    return Colors.red;
  }

  IconData _getEficienciaIcon(double costoPorKm) {
    if (costoPorKm < 0.08) return Icons.emoji_events;
    if (costoPorKm < 0.12) return Icons.check_circle;
    return Icons.warning;
  }

  String _getEficienciaMensaje(double costoPorKm) {
    if (costoPorKm < 0.08) {
      return AppLocalizations.of(context)!.excelenteEficiencia;
    }
    if (costoPorKm < 0.12) {
      return AppLocalizations.of(context)!.eficienciaNormal;
    }
    return AppLocalizations.of(context)!.eficienciaBaja;
  }

  String _formatNumber(dynamic number) {
    if (number == null) return '0.00';
    final value = double.tryParse(number.toString()) ?? 0;
    return value.toStringAsFixed(2);
  }
}
