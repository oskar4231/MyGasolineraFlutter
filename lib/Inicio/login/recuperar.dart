import 'package:flutter/material.dart';
import 'package:my_gasolinera/Inicio/login/nueva_password.dart';

// Pantalla para solicitar la recuperacion de la contraseña
// Muestra un formulario con un campo de correo y un boton de envío 
class RecuperarPassword extends StatefulWidget {
  const RecuperarPassword({super.key});

  @override
  State<RecuperarPassword> createState() => _RecuperarPasswordState();
}

class _RecuperarPasswordState extends State<RecuperarPassword> {
  final _formKey = GlobalKey<FormState>();
  // COntrolador del campo para el boton de envio
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

// Colores usados en los campos
  @override
  Widget build(BuildContext context) {
    final bgColor = const Color(0xFFFFE8DA);
    final cardColor = const Color(0xFFFFCFB0);
    final accent = const Color(0xFFFF9350);

    final maxWidth = MediaQuery.of(context).size.width * 0.85;
    final cardWidth = maxWidth > 420 ? 420.0 : maxWidth;

// Estructura principal 
    return Scaffold(
      backgroundColor: bgColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Container(
            width: cardWidth,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.12),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                )
              ],
            ),
            // Formulario con validacion para el email
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 8),
                  const Text(
                    'MyGasolinera',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF492714),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: Column(
                      children: [
                        // Logo
                        Image.asset(
                          'lib/assets/logo.png',
                          width: 120,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Recuperar contraseña',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF492714),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Etiqueta del campo correo
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Correo electrónico',
                      style: TextStyle(color: Color(0xFF492714)),
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    validator: (value) {
                      // Comprueba que el campo del correo no esté vacio
                      if (value == null || value.isEmpty) return 'Introduce un correo';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          // Aquí puede ir la llamada al backend para solicitar recuperación
                          // Se elimina el SnackBar solicitado; simplemente volvemos atrás
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const NuevaPasswordScreen(),
                            ),
                );
                        }
                      },
                      // Etiqueta del campo de la solicitud de recuperación
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accent,
                        foregroundColor: const Color(0xFF492714),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Solicitar recuperación'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}