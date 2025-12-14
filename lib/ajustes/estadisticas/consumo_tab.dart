import 'package:flutter/material.dart';
import 'package:my_gasolinera/services/estadisticas_avanzadas_service.dart';

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
    // Detectar tema oscuro
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final loadingColor = isDark ? Colors.white : const Color(0xFFFF9350);
    final titleColor = isDark ? Colors.white : const Color(0xFF492714);
    final subTitleColor = isDark ? Colors.grey[400] : const Color(0xFF492714).withOpacity(0.7);

    return RefreshIndicator(
      onRefresh: _recargar,
      color: loadingColor,
      child: FutureBuilder<Map<String, dynamic>>(
        future: _costoKmData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting || _isLoading) {
            return Center(child: CircularProgressIndicator(color: loadingColor));
          }
          
          if (snapshot.hasError) {
            return _buildError(snapshot.error.toString(), isDark);
          }

          final data = snapshot.data ?? {'costos_por_coche': [], 'total_coches': 0};
          final costosPorCoche = data['costos_por_coche'] as List<dynamic>;
          final totalCoches = data['total_coches'] as int;
          
          if (totalCoches == 0) {
            return _buildEmptyState(isDark);
          }
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Costo por Kilómetro',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: titleColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Análisis detallado por vehículo',
                  style: TextStyle(
                    fontSize: 14,
                    color: subTitleColor,
                  ),
                ),
                const SizedBox(height: 16),

                // Resumen general
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFFFF9350).withOpacity(0.15) : const Color(0xFFFF9350).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFFF9350).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text(
                            'Total Coches',
                            style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[400] : Colors.grey),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$totalCoches',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : const Color(0xFF492714),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            'Facturas Totales',
                            style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[400] : Colors.grey),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_calcularTotalFacturas(costosPorCoche)}',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : const Color(0xFF492714),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                Text(
                  'Análisis por Vehículo',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: titleColor,
                  ),
                ),
                const SizedBox(height: 12),
                
                ...costosPorCoche.map((cocheData) {
                  final coche = cocheData as Map<String, dynamic>;
                  return _buildCocheCard(coche, isDark);
                }).toList(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCocheCard(Map<String, dynamic> coche, bool isDark) {
    final costoProm = double.tryParse(coche['costo_promedio_por_km']?.toString() ?? '0') ?? 0;
    final kmTotales = int.tryParse(coche['km_totales']?.toString() ?? '0') ?? 0;
    final gastoTotal = double.tryParse(coche['gasto_total']?.toString() ?? '0') ?? 0;
    
    // Colores dinámicos
    final cardColor = isDark ? const Color(0xFF2C2C2C) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF492714);
    final subTextColor = isDark ? Colors.grey[400] : Colors.grey.shade600;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${coche['marca']} ${coche['modelo']}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Coste/KM', style: TextStyle(fontSize: 12, color: subTextColor)),
                  Text('€${_formatNumber(costoProm)}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFFFF9350))),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total Gasto', style: TextStyle(fontSize: 12, color: subTextColor)),
                  Text('€${_formatNumber(gastoTotal)}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('KM Totales', style: TextStyle(fontSize: 12, color: subTextColor)),
                  Text('$kmTotales km', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildError(String error, bool isDark) {
    return Center(
      child: Text('Error: $error', style: TextStyle(color: isDark ? Colors.white : Colors.black)),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Text('No hay datos', style: TextStyle(color: isDark ? Colors.white : Colors.black)),
    );
  }

  int _calcularTotalFacturas(List<dynamic> costosPorCoche) {
    int total = 0;
    for (final coche in costosPorCoche) {
      total += int.tryParse(coche['num_facturas']?.toString() ?? '0') ?? 0;
    }
    return total;
  }

  String _formatNumber(dynamic number) {
    if (number == null) return '0.00';
    final value = double.tryParse(number.toString()) ?? 0;
    return value.toStringAsFixed(2);
  }
}