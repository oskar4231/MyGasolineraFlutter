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
      color: Theme.of(context).primaryColor,
      child: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                  color: Theme.of(context).primaryColor),
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
            style: TextStyle(
                fontSize: 16, color: Theme.of(context).colorScheme.onSurface),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _cargarEstadisticas,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
            ),
            child: Text('Reintentar',
                style:
                    TextStyle(color: Theme.of(context).colorScheme.onPrimary)),
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

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    // En modo oscuro, usamos un color naranja brillante para iconos si el primario no resalta suficiente
    final primaryIconColor =
        isDarkMode ? Colors.orangeAccent : Theme.of(context).primaryColor;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 📊 RESUMEN GENERAL
          Text(
            'Resumen General',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),

          // Card: Gasto Total
          EstadisticasWidgets.buildStatCard(
            context: context,
            title: 'Gasto Total',
            value: '€${_formatNumber(resumen['gasto_total'])}',
            subtitle: '${resumen['total_facturas']} repostajes',
            icon: Icons.account_balance_wallet,
            color: primaryIconColor,
          ),
          const SizedBox(height: 12),

          // Card: Mes Actual
          EstadisticasWidgets.buildStatCard(
            context: context,
            title: 'Mes Actual',
            value: '€${_formatNumber(mesActual['gasto'])}',
            subtitle: '${mesActual['facturas']} repostajes',
            icon: Icons.calendar_today,
            color: isDarkMode
                ? Colors.blueAccent
                : Theme.of(context).colorScheme.secondary,
          ),
          const SizedBox(height: 12),

          // Card: Comparativa
          _buildComparativaCard(comparativa),
          const SizedBox(height: 12),

          // Card: Promedio por Factura
          EstadisticasWidgets.buildStatCard(
            context: context,
            title: 'Promedio por Repostaje',
            value: '€${_formatNumber(resumen['promedio_por_factura'])}',
            subtitle:
                'Min: €${_formatNumber(resumen['gasto_minimo'])} - Max: €${_formatNumber(resumen['gasto_maximo'])}',
            icon: Icons.trending_up,
            color: primaryIconColor,
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
    final porcentaje =
        double.tryParse(comparativa['porcentaje_cambio'].toString()) ?? 0;
    final isPositive = porcentaje >= 0;

    return EstadisticasWidgets.buildComparativaCard(
      context: context,
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
      context: context,
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
