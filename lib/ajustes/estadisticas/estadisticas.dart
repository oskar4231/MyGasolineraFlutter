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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, // Tema
      appBar: AppBar(
        title: Text(
          'Estadísticas',
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: Theme.of(context).appBarTheme.iconTheme?.color),
          onPressed: () => Navigator.of(context).pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Theme.of(context)
              .colorScheme
              .onPrimary, // Indicador visible sobre primario
          labelColor: Theme.of(context).colorScheme.onPrimary,
          unselectedLabelColor:
              Theme.of(context).colorScheme.onPrimary.withOpacity(0.6),
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
