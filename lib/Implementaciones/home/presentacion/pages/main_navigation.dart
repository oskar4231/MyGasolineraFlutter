import 'package:flutter/material.dart';
import 'package:my_gasolinera/Implementaciones/home/presentacion/pages/layouthome.dart';
import 'package:my_gasolinera/Implementaciones/coches/presentacion/pages/coches.dart';
import 'package:my_gasolinera/Implementaciones/ajustes/presentacion/pages/ajustes.dart';

// Global keys to access state
final GlobalKey<LayouthomeState> layoutHomeKey = GlobalKey<LayouthomeState>();

class MainNavigationScreen extends StatefulWidget {
  final int initialIndex;
  const MainNavigationScreen({super.key, this.initialIndex = 0});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onNavigationChanged(int index) {
    if (_currentIndex != index) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  void _onToggleMapList() {
    if (_currentIndex != 0) {
      _onNavigationChanged(0);
    } else {
      layoutHomeKey.currentState?.toggleMapList();
      setState(() {}); // refresh generic bottom bar boolean
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isMapMode = true;
    if (_currentIndex == 0 && layoutHomeKey.currentState != null) {
      isMapMode = layoutHomeKey.currentState!.isMapMode;
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = isDark ? const Color(0xFFFF8235) : theme.colorScheme.primary;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          Layouthome(key: layoutHomeKey),
          const CochesScreen(),
          const AjustesScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: accentColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Botón de Coches (index 1)
              IconButton(
                onPressed: () => _onNavigationChanged(1),
                icon: Icon(
                  Icons.directions_car,
                  size: 40,
                  color: _currentIndex == 1
                      ? (isDark ? Colors.black : theme.colorScheme.onPrimary)
                      : (isDark ? Colors.black.withValues(alpha: 0.5) : theme.colorScheme.onPrimary.withValues(alpha: 0.5)),
                ),
              ),

              // Botón de Toggle con ambos iconos (index 0)
              InkWell(
                onTap: _onToggleMapList,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedOpacity(
                        opacity: (_currentIndex == 0 && isMapMode) ? 1.0 : 0.4,
                        duration: const Duration(milliseconds: 300),
                        child: Icon(
                          Icons.pin_drop,
                          size: 40,
                          color: _currentIndex == 0
                              ? (isDark ? Colors.black : theme.colorScheme.onPrimary)
                              : (isDark ? Colors.black.withValues(alpha: 0.5) : theme.colorScheme.onPrimary.withValues(alpha: 0.5)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      AnimatedOpacity(
                        opacity: (_currentIndex == 0 && !isMapMode) ? 1.0 : 0.4,
                        duration: const Duration(milliseconds: 300),
                        child: Icon(
                          Icons.list,
                          size: 40,
                          color: _currentIndex == 0
                              ? (isDark ? Colors.black : theme.colorScheme.onPrimary)
                              : (isDark ? Colors.black.withValues(alpha: 0.5) : theme.colorScheme.onPrimary.withValues(alpha: 0.5)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Botón de Ajustes (index 2)
              IconButton(
                onPressed: () => _onNavigationChanged(2),
                icon: Icon(
                  Icons.settings,
                  size: 40,
                  color: _currentIndex == 2
                      ? (isDark ? Colors.black : theme.colorScheme.onPrimary)
                      : (isDark ? Colors.black.withValues(alpha: 0.5) : theme.colorScheme.onPrimary.withValues(alpha: 0.5)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
