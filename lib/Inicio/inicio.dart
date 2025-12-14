import 'package:flutter/material.dart';
import 'package:my_gasolinera/Inicio/crear_cuenta/crear.dart';
import 'login/login.dart';

class Inicio extends StatelessWidget {
  const Inicio({super.key});

  @override
  Widget build(BuildContext context) {
    // --- LÓGICA DE COLORES DINÁMICOS ---
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Colores de Fondo
    final scaffoldBg = isDark ? const Color(0xFF121212) : const Color(0xFFFFE8DA);
    
    // Colores de Texto
    final titleColor = isDark ? Colors.white : const Color(0xFF492714);

    // Botón 1: Iniciar Sesión
    // Dark: Fondo Blanco, Texto Negro (Alto contraste)
    // Light: Tu Naranja original, Texto Marrón
    final btn1Bg = isDark ? Colors.white : const Color(0xFFFF9350);
    final btn1Fg = isDark ? Colors.black : const Color(0xFF492714);
    final btn1Border = isDark ? Colors.white : const Color(0xFF492714);

    // Botón 2: Crear Cuenta
    // Dark: Fondo Gris Oscuro, Texto Blanco
    // Light: Tu Melocotón original, Texto Marrón
    final btn2Bg = isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFFCFB0);
    final btn2Fg = isDark ? Colors.white : const Color(0xFF492714);
    final btn2Border = const Color(0xFFFF9350); // Mantenemos borde naranja en ambos para identidad

    return Scaffold(
      backgroundColor: scaffoldBg, // Dinámico
      body: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 40),

                  // Logo y texto en fila - GRANDES Y CENTRADOS
                  Container(
                    padding: const EdgeInsets.fromLTRB(30, 80, 30, 30),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          'lib/assets/logo.png',
                          height: 120,
                          width: 120,
                          // Si tu logo es negro transparente, necesitamos invertirlo en dark mode
                          // Si es una imagen colorida, quita esta línea de 'color'
                          // color: isDark ? Colors.white : null, 
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'MyGasolinera',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: titleColor, // Dinámico
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Botón Iniciar Sesión
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: btn1Bg, // Dinámico
                        foregroundColor: btn1Fg, // Dinámico
                        padding: const EdgeInsets.symmetric(vertical: 30),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                          side: BorderSide(
                            color: btn1Border, // Dinámico
                            width: 2.0,
                          ),
                        ),
                        elevation: 0,
                        textStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      child: const Text('Iniciar Sesión'),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // Botón Crear Cuenta
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const CrearScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: btn2Bg, // Dinámico
                        foregroundColor: btn2Fg, // Dinámico
                        padding: const EdgeInsets.symmetric(vertical: 30),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                          side: BorderSide(
                            color: btn2Border, // Siempre Naranja
                            width: 2.0,
                          ),
                        ),
                        elevation: 0,
                        textStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      child: const Text('Crear Cuenta'),
                    ),
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}