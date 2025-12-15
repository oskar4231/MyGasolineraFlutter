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
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF492714),
          labelColor: const Color(0xFF492714),
          unselectedLabelColor: const Color(0xFF492714).withOpacity(0.6),
          tabs: const [
            Tab(text: 'Gastos', icon: Icon(Icons.euro)),
            Tab(text: 'Consumo', icon: Icon(Icons.local_gas_station)),
            Tab(text: 'Mantenimiento', icon: Icon(Icons.build)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          GastosTab(),
          ConsumoTab(),
          MantenimientoTab(),
        ],
      ),
    );
  }
}