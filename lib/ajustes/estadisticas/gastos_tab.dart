import 'package:flutter/material.dart';
import 'package:my_gasolinera/services/estadisticas_service.dart';
import 'package:my_gasolinera/ajustes/estadisticas/widgets/estadisticas_widgets.dart';

class GastosTab extends StatefulWidget {
  const GastosTab({super.key});

  @override
  State<GastosTab> createState() => _GastosTabState();
}

class _GastosTabState extends State<GastosTab> {
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic>? _estadisticas;

  @override
  void initState() {
    super.initState();
    _cargarEstadisticas();
  }

  Future<void> _cargarEstadisticas() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await EstadisticasService.obtenerTodasEstadisticas();
      
      if (mounted) {
        setState(() {
          _estadisticas = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error al cargar estadísticas: $e';
          _isLoading = false;
        });
      }
      print('Error cargando estadísticas: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _cargarEstadisticas,
      color: const Color(0xFFFF9350),
      child: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFFF9350)),
            )
          : _errorMessage != null
              ? _buildError()
              : _buildEstadisticas(),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 80, color: Colors.red),
          const SizedBox(height: 20),
          Text(
            _errorMessage!,
            style: const TextStyle(fontSize: 16, color: Color(0xFF492714)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _cargarEstadisticas,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF9350),
            ),
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildEstadisticas() {
    if (_estadisticas == null) {
      return const Center(child: Text('No hay datos disponibles'));
    }

    final resumen = _estadisticas!['resumen'];
    final mesActual = _estadisticas!['mesActual'];
    final comparativa = _estadisticas!['comparativa'];
    final proyeccion = _estadisticas!['proyeccion'];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 📊 RESUMEN GENERAL
          const Text(
            'Resumen General',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF492714),
            ),
          ),
          const SizedBox(height: 12),
          
          // Card: Gasto Total
          EstadisticasWidgets.buildStatCard(
            title: 'Gasto Total',
            value: '€${_formatNumber(resumen['gasto_total'])}',
            subtitle: '${resumen['total_facturas']} repostajes',
            icon: Icons.account_balance_wallet,
            color: const Color(0xFFFF9350),
          ),
          const SizedBox(height: 12),

          // Card: Mes Actual
          EstadisticasWidgets.buildStatCard(
            title: 'Mes Actual',
            value: '€${_formatNumber(mesActual['gasto'])}',
            subtitle: '${mesActual['facturas']} repostajes',
            icon: Icons.calendar_today,
            color: const Color(0xFFF57C00),
          ),
          const SizedBox(height: 12),

          // Card: Comparativa
          _buildComparativaCard(comparativa),
          const SizedBox(height: 12),

          // Card: Promedio por Factura
          EstadisticasWidgets.buildStatCard(
            title: 'Promedio por Repostaje',
            value: '€${_formatNumber(resumen['promedio_por_factura'])}',
            subtitle: 'Min: €${_formatNumber(resumen['gasto_minimo'])} - Max: €${_formatNumber(resumen['gasto_maximo'])}',
            icon: Icons.trending_up,
            color: const Color(0xFFFF9350),
          ),
          const SizedBox(height: 12),

          // Card: Proyección
          _buildProyeccionCard(proyeccion),
          const SizedBox(height: 24),

          // 📈 GRÁFICAS (Próximamente)
          
          
        ],
      ),
    );
  }

  Widget _buildComparativaCard(Map<String, dynamic> comparativa) {
    final mesActual = comparativa['mes_actual'];
    final mesAnterior = comparativa['mes_anterior'];
    final porcentaje = double.tryParse(comparativa['porcentaje_cambio'].toString()) ?? 0;
    final isPositive = porcentaje >= 0;

    return EstadisticasWidgets.buildComparativaCard(
      mesActual: mesActual,
      mesAnterior: mesAnterior,
      porcentaje: porcentaje,
      isPositive: isPositive,
    );
  }

  Widget _buildProyeccionCard(Map<String, dynamic> proyeccion) {
    final gastoActual = proyeccion['gasto_actual'];
    final diasTranscurridos = proyeccion['dias_transcurridos'];
    final diasTotales = proyeccion['dias_totales_mes'];
    final proyeccionFin = proyeccion['proyeccion_fin_mes'];

    return EstadisticasWidgets.buildProyeccionCard(
      gastoActual: gastoActual,
      diasTranscurridos: diasTranscurridos,
      diasTotales: diasTotales,
      proyeccionFin: proyeccionFin,
    );
  }

  String _formatNumber(dynamic number) {
    if (number == null) return '0.00';
    final value = double.tryParse(number.toString()) ?? 0;
    return value.toStringAsFixed(2);
  }
}