import 'package:flutter/material.dart';
import 'package:my_gasolinera/Implementaciones/estadisticas/presentacion/widgets/gastos_tab.dart';
import 'package:my_gasolinera/Implementaciones/estadisticas/presentacion/widgets/consumo_tab.dart';
import 'package:my_gasolinera/Implementaciones/estadisticas/presentacion/widgets/mantenimiento_tab.dart';
import 'package:my_gasolinera/core/l10n/app_localizations.dart';
import 'package:my_gasolinera/core/widgets/back_button_hover.dart';

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
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isDark = theme.brightness == Brightness.dark;

    // Colores adaptados al patrón de Accesibilidad/Facturas
    final primaryColor = isDark ? const Color(0xFFFF8235) : theme.primaryColor;

    final textColor =
        isDark ? const Color(0xFFEBEBEB) : theme.colorScheme.onSurface;

    final lighterCardColor = isDark
        ? const Color(0xFF3E3E42)
        : Color.lerp(
            theme.cardTheme.color ?? theme.cardColor, Colors.white, 0.25);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Header plano estilo Accesibilidad/Facturas
            Container(
              padding: const EdgeInsets.all(16),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: HoverBackButton(
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  Text(
                    l10n.estadisticas,
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color:
                          isDark ? Colors.white : theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),

            // TabBar adaptado al modo oscuro
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: lighterCardColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withOpacity(0.3)
                        : Colors.grey.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TabBar(
                controller: _tabController,
                indicatorColor: primaryColor,
                indicatorWeight: 3,
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: primaryColor,
                unselectedLabelColor: textColor.withOpacity(0.6),
                dividerColor: Colors.transparent,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 13,
                ),
                tabs: [
                  Tab(text: l10n.gastos, icon: const Icon(Icons.euro)),
                  Tab(
                      text: l10n.consumo,
                      icon: const Icon(Icons.local_gas_station)),
                  Tab(text: l10n.mantenimiento, icon: const Icon(Icons.build)),
                ],
              ),
            ),

            const SizedBox(height: 8),

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
