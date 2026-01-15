import 'package:flutter/material.dart';
import 'package:my_gasolinera/ajustes/estadisticas/gastos_tab.dart';
import 'package:my_gasolinera/ajustes/estadisticas/consumo_tab.dart';
import 'package:my_gasolinera/ajustes/estadisticas/mantenimiento_tab.dart';

class EstadisticasScreen extends StatefulWidget {
  const EstadisticasScreen({super.key});

  @override
  State<EstadisticasScreen> createState() => _EstadisticasScreenState();
}

class _EstadisticasScreenState extends State<EstadisticasScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // --- VARIABLES DE TEMA DINÁMICO ---
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Fondo: Crema en claro, Negro en oscuro
    final scaffoldBg = isDark ? const Color(0xFF121212) : const Color(0xFFFFE2CE);
    
    // AppBar Background: Naranja en claro, Gris oscuro en oscuro
    final appBarBg = isDark ? const Color(0xFF1F1F1F) : const Color(0xFFFF9350);
    
    // Textos e Iconos: Marrón en claro, Blanco en oscuro
    final contentColor = isDark ? Colors.white : const Color(0xFF492714);
    
    // Color de items no seleccionados en el TabBar
    final unselectedColor = isDark ? Colors.white60 : const Color(0xFF492714).withOpacity(0.6);

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        title: Text(
          'Estadísticas',
          style: TextStyle(
            color: contentColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: appBarBg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: contentColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: contentColor,
          labelColor: contentColor,
          unselectedLabelColor: unselectedColor,
          tabs: const [
            Tab(text: 'Gastos', icon: Icon(Icons.euro)),
            Tab(text: 'Consumo', icon: Icon(Icons.local_gas_station)),
            Tab(text: 'Mantenimiento', icon: Icon(Icons.build)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        // CORRECCIÓN AQUÍ: Quitamos 'const' porque los widgets son dinámicos
        children: const [
          GastosTab(),
          ConsumoTab(),
          MantenimientoTab(),
        ],
      ),
    );
  }
}