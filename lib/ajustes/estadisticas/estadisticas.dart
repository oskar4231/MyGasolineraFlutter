import 'package:flutter/material.dart';
import 'package:my_gasolinera/ajustes/estadisticas/gastos_tab.dart';
import 'package:my_gasolinera/ajustes/estadisticas/consumo_tab.dart';
import 'package:my_gasolinera/ajustes/estadisticas/mantenimiento_tab.dart';
import 'package:my_gasolinera/l10n/app_localizations.dart';

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
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Custom Header with TabBar
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 16, left: 16, right: 16, bottom: 8),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back,
                              color: theme.colorScheme.onPrimary),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          l10n.estadisticas,
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TabBar(
                    controller: _tabController,
                    indicatorColor: theme.colorScheme.onPrimary,
                    indicatorWeight: 3,
                    labelColor: theme.colorScheme.onPrimary,
                    unselectedLabelColor:
                        theme.colorScheme.onPrimary.withValues(alpha: 0.6),
                    dividerColor: Colors.transparent, // Remove default divider
                    tabs: [
                      Tab(text: l10n.gastos, icon: const Icon(Icons.euro)),
                      Tab(
                          text: l10n.consumo,
                          icon: const Icon(Icons.local_gas_station)),
                      Tab(
                          text: l10n.mantenimiento,
                          icon: const Icon(Icons.build)),
                    ],
                  ),
                  const SizedBox(height: 8), // Padding bottom of header
                ],
              ),
            ),

            // Tab View
            Expanded(
              child: Container(
                color: theme.colorScheme.surface,
                child: TabBarView(
                  controller: _tabController,
                  children: const [
                    GastosTab(),
                    ConsumoTab(),
                    MantenimientoTab(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
