import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:my_gasolinera/Implementaciones/auth/presentacion/pages/crear.dart';
import 'package:my_gasolinera/Implementaciones/auth/presentacion/pages/login.dart';

class Inicio extends StatelessWidget {
  const Inicio({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // True Apple-inspired color palette
    final bgColor = isDark
        ? const Color(0xFF000000)
        : const Color(0xFFF7F7F5); // Warm neutral background
    final accentColor = isDark
        ? const Color(0xFFE87A3E)
        : const Color(0xFFD36226); // Refined deep/muted orange
    final textColor =
        isDark ? Colors.white : const Color(0xFF1D1D1F); // Apple dark text
    final subtextColor = isDark
        ? const Color(0xFF86868B)
        : const Color(0xFF86868B); // Apple secondary text
    final buttonTextColor = Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // Optional: Grain texture overlay using a CustomPaint or just relying on clean UI
          // Subtle radial glow behind the center icon area (in the top half)
          Positioned(
            top: MediaQuery.of(context).size.height * 0.15,
            left: MediaQuery.of(context).size.width * 0.5 - 150,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    accentColor.withValues(alpha: 0.08),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 1.0],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 1. Top Section: Centered Logo and App Name
                  Padding(
                    padding: const EdgeInsets.only(top: 24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'lib/assets/logo.png',
                          height: 32,
                          width: 32,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'MyGasolinera',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Spacing before hero section
                  const Spacer(flex: 3),

                  // 2. Hero Icon Section (Frosted glass / soft blur surface)
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Glow around the icon
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: accentColor.withValues(alpha: 0.15),
                              blurRadius: 32,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                      ),
                      // Elevated Frosted Glass Surface
                      ClipOval(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                          child: Container(
                            width: 112,
                            height: 112,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isDark
                                  ? Colors.grey.withValues(alpha: 0.1)
                                  : Colors.white.withValues(alpha: 0.6),
                              border: Border.all(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.1)
                                    : Colors.white.withValues(alpha: 0.8),
                                width: 1,
                              ),
                              boxShadow: [
                                if (!isDark)
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.03),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                              ],
                            ),
                            child: Center(
                              child: Icon(
                                Icons
                                    .local_gas_station_outlined, // Refined monoline fuel pump
                                size: 48,
                                color: accentColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 56),

                  // 3. Headline
                  Text(
                    'Encuentra la gasolina\nmás barata',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w700,
                      height: 1.15,
                      letterSpacing: -1.2,
                      color: textColor,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 4. Subheadline
                  Text(
                    'Cerca de ti, en segundos.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                      letterSpacing: -0.5,
                      color: subtextColor,
                    ),
                  ),

                  const Spacer(flex: 4),

                  // 5. Primary button
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          accentColor.withValues(alpha: 0.9),
                          accentColor,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: accentColor.withValues(alpha: 0.25),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
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
                        backgroundColor: Colors.transparent,
                        foregroundColor: buttonTextColor,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Crear cuenta',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.4,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // 6. Secondary action
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
                        foregroundColor: subtextColor,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
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

                  const SizedBox(height: 32),

                  // 7. Very subtle bottom caption
                  Text(
                    'Datos actualizados en tiempo real',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: subtextColor.withValues(alpha: 0.5),
                      letterSpacing: 0.2,
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
