import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:my_gasolinera/Implementaciones/auth/presentacion/pages/crear.dart';
import 'package:my_gasolinera/Implementaciones/auth/presentacion/pages/login.dart';

class Inicio extends StatefulWidget {
  const Inicio({super.key});

  @override
  State<Inicio> createState() => _InicioState();
}

class _InicioState extends State<Inicio> with TickerProviderStateMixin {
  late AnimationController _iconController;
  late AnimationController _contentController;

  late Animation<double> _iconScale;
  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;
  late Animation<double> _textFade;
  late Animation<Offset> _textSlide;
  late Animation<double> _bottomFade;
  late Animation<Offset> _bottomSlide;

  @override
  void initState() {
    super.initState();

    _iconController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _iconScale = CurvedAnimation(
      parent: _iconController,
      curve: Curves.easeOutBack,
    );

    // Header (logo + nombre) — aparece primero
    _headerFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );
    _headerSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _contentController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOutCubic),
    ));

    // Headline + subtext + pills
    _textFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: const Interval(0.2, 0.7, curve: Curves.easeOut),
      ),
    );
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _contentController,
      curve: const Interval(0.2, 0.7, curve: Curves.easeOutCubic),
    ));

    // Bottom CTA section
    _bottomFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
      ),
    );
    _bottomSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _contentController,
      curve: const Interval(0.4, 1.0, curve: Curves.easeOutCubic),
    ));

    _iconController.forward();
    _contentController.forward();
  }

  @override
  void dispose() {
    _iconController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF000000) : const Color(0xFFF5F5F0);
    final accentColor =
        isDark ? const Color(0xFFE87A3E) : const Color(0xFFD36226);
    final textColor = isDark ? Colors.white : const Color(0xFF1D1D1F);
    final subtextColor = const Color(0xFF86868B);

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // Ambient glow
          Positioned(
            top: MediaQuery.of(context).size.height * 0.12,
            left: MediaQuery.of(context).size.width * 0.5 - 160,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    accentColor.withValues(alpha: 0.09),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                children: [
                  // ── Header: logo + nombre ──
                  Padding(
                    padding: const EdgeInsets.only(top: 24.0),
                    child: FadeTransition(
                      opacity: _headerFade,
                      child: SlideTransition(
                        position: _headerSlide,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/images/logo-mygasolinera.png',
                              width: 50,
                              height: 50,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'MyGasolinera',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.5,
                                color: textColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // ── Hero ──
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icono con frosted glass
                        ScaleTransition(
                          scale: _iconScale,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Superficie frosted glass con Sombra exterior (Glow)
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    // Sombra base oscura suave
                                    BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.06),
                                      blurRadius: 32,
                                      offset: const Offset(0, 8),
                                    ),
                                    // Glow naranja vibrante alrededor del borde
                                    BoxShadow(
                                      color: accentColor.withValues(alpha: 0.6),
                                      blurRadius: 24,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(24),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(
                                        sigmaX: 20, sigmaY: 20),
                                    child: Container(
                                      width: 100,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(24),
                                        color: isDark
                                            ? Colors.grey
                                                .withValues(alpha: 0.12)
                                            : Colors.white
                                                .withValues(alpha: 0.72),
                                        border: Border.all(
                                          color: isDark
                                              ? Colors.white
                                                  .withValues(alpha: 0.1)
                                              : Colors.white
                                                  .withValues(alpha: 0.9),
                                          width: 1,
                                        ),
                                        // Las sombras se han movido al Container exterior para que no se corten
                                      ),
                                      child: Center(
                                        child: Image.asset(
                                          'assets/images/logo-mygasolinera.png',
                                          width: 96,
                                          height: 96,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 40),

                        // Headline + subtext + pills con animación
                        FadeTransition(
                          opacity: _textFade,
                          child: SlideTransition(
                            position: _textSlide,
                            child: Column(
                              children: [
                                // Headline
                                Text(
                                  'Encuentra la gasolina\nmás barata',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 34,
                                    fontWeight: FontWeight.w700,
                                    height: 1.12,
                                    letterSpacing: -1.2,
                                    color: textColor,
                                  ),
                                ),

                                const SizedBox(height: 12),

                                // Subheadline
                                Text(
                                  'Cerca de ti, en segundos.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w300,
                                    letterSpacing: -0.3,
                                    color: subtextColor,
                                  ),
                                ),

                                const SizedBox(height: 28),

                                // Feature Pills
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _FeaturePill(
                                      icon: Icons.location_on,
                                      label: 'Cerca de ti',
                                      accentColor: accentColor,
                                      isDark: isDark,
                                    ),
                                    const SizedBox(width: 8),
                                    _FeaturePill(
                                      icon: Icons.trending_down,
                                      label: 'Mejor precio',
                                      accentColor: accentColor,
                                      isDark: isDark,
                                    ),
                                    const SizedBox(width: 8),
                                    _FeaturePill(
                                      icon: Icons.bolt,
                                      label: 'Tiempo real',
                                      accentColor: accentColor,
                                      isDark: isDark,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Bottom CTA ──
                  FadeTransition(
                    opacity: _bottomFade,
                    child: SlideTransition(
                      position: _bottomSlide,
                      child: Column(
                        children: [
                          // Social proof
                          Text(
                            'Más de 10.000 gasolineras en España',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: subtextColor,
                              letterSpacing: -0.1,
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Botón primario — Apple: color plano, radius 14
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const CrearScreen(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: accentColor,
                                foregroundColor: Colors.white,
                                shadowColor:
                                    accentColor.withValues(alpha: 0.22),
                                elevation: 4,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 18),
                                shape: RoundedRectangleBorder(
                                  // Apple usa 14, no pill
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: const Text(
                                'Crear cuenta',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: -0.4,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Divisor "o"
                          Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.1)
                                      : Colors.black.withValues(alpha: 0.08),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  'o',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: subtextColor,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.1)
                                      : Colors.black.withValues(alpha: 0.08),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Botón secundario — Apple: sin borde, fondo sutil
                          SizedBox(
                            width: double.infinity,
                            child: TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const LoginScreen(),
                                  ),
                                );
                              },
                              style: TextButton.styleFrom(
                                backgroundColor: isDark
                                    ? Colors.white.withValues(alpha: 0.06)
                                    : Colors.black.withValues(alpha: 0.04),
                                foregroundColor: textColor,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 18),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: const Text(
                                'Iniciar sesión',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: -0.4,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Caption
                          Text(
                            'Datos actualizados en tiempo real',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: subtextColor.withValues(alpha: 0.5),
                              letterSpacing: 0.1,
                            ),
                          ),

                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Feature Pill ──
class _FeaturePill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color accentColor;
  final bool isDark;

  const _FeaturePill({
    required this.icon,
    required this.label,
    required this.accentColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: accentColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.7)
                  : Colors.black.withValues(alpha: 0.75),
            ),
          ),
        ],
      ),
    );
  }
}
