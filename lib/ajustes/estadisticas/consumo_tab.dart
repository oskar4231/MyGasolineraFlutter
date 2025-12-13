import 'package:flutter/material.dart';
import 'package:my_gasolinera/services/estadisticas_avanzadas_service.dart';
import 'package:my_gasolinera/ajustes/estadisticas/widgets/estadisticas_widgets.dart';

class ConsumoTab extends StatefulWidget {
  const ConsumoTab({super.key});

  @override
  State<ConsumoTab> createState() => _ConsumoTabState();
}

class _ConsumoTabState extends State<ConsumoTab> {
  late Future<Map<String, dynamic>> _consumoData;

  @override
  void initState() {
    super.initState();
    _consumoData = _cargarConsumo();
  }

  Future<Map<String, dynamic>> _cargarConsumo() async {
    try {
      return await EstadisticasAvanzadasService.obtenerConsumoReal();
    } catch (e) {
      // Si hay error, devolver mapa vacío
      print('Error cargando consumo: $e');
      return {};
    }
  }

  Future<void> _recargar() async {
    setState(() {
      _consumoData = _cargarConsumo();
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _recargar,
      color: const Color(0xFFFF9350),
      child: FutureBuilder<Map<String, dynamic>>(
        future: _consumoData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFFF9350)));
          }
          
          if (snapshot.hasError) {
            return _buildError(snapshot.error.toString());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState();
          }

          final data = snapshot.data!;
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Análisis de Consumo',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF492714),
                  ),
                ),
                const SizedBox(height: 12),

                if (data.containsKey('consumo_promedio'))
                  EstadisticasWidgets.buildStatCard(
                    title: 'Consumo Promedio',
                    value: '${_formatNumber(data['consumo_promedio'])} L/100km',
                    subtitle: 'Eficiencia promedio de tu vehículo',
                    icon: Icons.speed,
                    color: Color(0xFFFF9350),
                  ),
                const SizedBox(height: 12),

                if (data.containsKey('costo_por_km'))
                  EstadisticasWidgets.buildStatCard(
                    title: 'Costo por Kilómetro',
                    value: '€${_formatNumber(data['costo_por_km'])}/km',
                    subtitle: 'Incluye combustible y mantenimiento',
                    icon: Icons.attach_money,
                    color: Colors.green,
                  ),
                const SizedBox(height: 12),

                if (data.containsKey('mejor_eficiencia'))
                  _buildMejorEficienciaCard(data['mejor_eficiencia']),
                const SizedBox(height: 12),

                if (data.containsKey('peor_eficiencia'))
                  _buildPeorEficienciaCard(data['peor_eficiencia']),
                const SizedBox(height: 12),

                if (data.containsKey('ultimo_consumo'))
                  _buildUltimoConsumoCard(data['ultimo_consumo']),
                const SizedBox(height: 12),

                // Información adicional
                if (data.containsKey('consejos'))
                  _buildConsejosCard(data['consejos']),
              ],
            ),
          );
        },
      ),
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
            'Error: $error',
            style: const TextStyle(fontSize: 16, color: Color(0xFF492714)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _recargar,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF9350),
            ),
            child: const Text('Reintentar'),
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
          const Icon(Icons.local_gas_station, size: 80, color: Colors.grey),
          const SizedBox(height: 20),
          const Text(
            'No hay datos de consumo disponibles',
            style: TextStyle(fontSize: 16, color: Color(0xFF492714)),
          ),
          const SizedBox(height: 10),
          const Text(
            'Agrega facturas con kilometraje para calcular consumo',
            style: TextStyle(fontSize: 14, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _recargar,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF9350),
            ),
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildMejorEficienciaCard(Map<String, dynamic> data) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.emoji_events, color: Colors.green, size: 32),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  'Mejor Eficiencia',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF492714),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${_formatNumber(data['valor'])} L/100km',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          if (data.containsKey('fecha'))
            Text(
              'Fecha: ${data['fecha']}',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          if (data.containsKey('coche'))
            Text(
              'Vehículo: ${data['coche']}',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
        ],
      ),
    );
  }

  Widget _buildPeorEficienciaCard(Map<String, dynamic> data) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.warning, color: Colors.red, size: 32),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  'Peor Eficiencia',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF492714),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${_formatNumber(data['valor'])} L/100km',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          if (data.containsKey('fecha'))
            Text(
              'Fecha: ${data['fecha']}',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          if (data.containsKey('coche'))
            Text(
              'Vehículo: ${data['coche']}',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
        ],
      ),
    );
  }

  Widget _buildUltimoConsumoCard(Map<String, dynamic> data) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.history, color: Colors.blue, size: 32),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  'Último Consumo',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF492714),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${_formatNumber(data['valor'])} L/100km',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF492714),
            ),
          ),
          if (data.containsKey('fecha'))
            Text(
              'Última recarga: ${data['fecha']}',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
        ],
      ),
    );
  }

  Widget _buildConsejosCard(List<dynamic> consejos) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.lightbulb, color: Colors.amber, size: 32),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  'Consejos para Ahorrar',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF492714),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: consejos.map((consejo) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        consejo.toString(),
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  String _formatNumber(dynamic number) {
    if (number == null) return '0.00';
    final value = double.tryParse(number.toString()) ?? 0;
    return value.toStringAsFixed(2);
  }
}