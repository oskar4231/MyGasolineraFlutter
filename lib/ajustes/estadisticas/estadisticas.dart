import 'package:flutter/material.dart';
import 'package:my_gasolinera/services/estadisticas_service.dart';

class EstadisticasScreen extends StatefulWidget {
  const EstadisticasScreen({super.key});

  @override
  State<EstadisticasScreen> createState() => _EstadisticasScreenState();
}

class _EstadisticasScreenState extends State<EstadisticasScreen> {
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
    return Scaffold(
      backgroundColor: const Color(0xFFFFE2CE),
      appBar: AppBar(
        title: const Text(
          'Estadísticas',
          style: TextStyle(
            color: Color(0xFF492714),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFFFF9350),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF492714)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF492714)),
            onPressed: _cargarEstadisticas,
          ),
        ],
      ),
      body: _isLoading
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
          _buildStatCard(
            title: 'Gasto Total',
            value: '€${_formatNumber(resumen['gasto_total'])}',
            subtitle: '${resumen['total_facturas']} repostajes',
            icon: Icons.account_balance_wallet,
            color: const Color(0xFFFF9350),
          ),
          const SizedBox(height: 12),

          // Card: Mes Actual
          _buildStatCard(
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
          _buildStatCard(
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
          const Text(
            'Gráficas',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF492714),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                '📊 Gráficas próximamente...',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF492714),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparativaCard(Map<String, dynamic> comparativa) {
    final mesActual = comparativa['mes_actual'];
    final mesAnterior = comparativa['mes_anterior'];
    final porcentaje = double.tryParse(comparativa['porcentaje_cambio'].toString()) ?? 0;
    final isPositive = porcentaje >= 0;

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
                  color: const Color(0xFFFF9350).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.compare_arrows,
                  color: Color(0xFFFF9350),
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  'Comparativa Mensual',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF492714),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Mes Actual',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    '€${_formatNumber(mesActual)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF492714),
                    ),
                  ),
                ],
              ),
              Icon(
                isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                color: isPositive ? Colors.red : Colors.green,
                size: 32,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Mes Anterior',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    '€${_formatNumber(mesAnterior)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF492714),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isPositive
                  ? Colors.red.withOpacity(0.1)
                  : Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isPositive ? Icons.trending_up : Icons.trending_down,
                  color: isPositive ? Colors.red : Colors.green,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '${isPositive ? '+' : ''}${porcentaje.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isPositive ? Colors.red : Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProyeccionCard(Map<String, dynamic> proyeccion) {
    final gastoActual = proyeccion['gasto_actual'];
    final diasTranscurridos = proyeccion['dias_transcurridos'];
    final diasTotales = proyeccion['dias_totales_mes'];
    final proyeccionFin = proyeccion['proyeccion_fin_mes'];
    final progreso = diasTranscurridos / diasTotales;

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
                  color: const Color(0xFFFF9350).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.insights,
                  color: Color(0xFFFF9350),
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  'Proyección Fin de Mes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF492714),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Gasto Actual',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    '€${_formatNumber(gastoActual)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF492714),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Proyección',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    '€${_formatNumber(proyeccionFin)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF9350),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Día $diasTranscurridos de $diasTotales',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    '${(progreso * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF492714),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progreso,
                  backgroundColor: Colors.grey[300],
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFFFF9350),
                  ),
                  minHeight: 8,
                ),
              ),
            ],
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
