import 'package:flutter/material.dart';
import 'package:my_gasolinera/Inicio/login/nueva_password.dart';
import 'package:my_gasolinera/services/auth_service.dart';

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
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleForgotPassword() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);

    try {
      final response = await AuthService.forgotPassword(
        _emailController.text.trim(),
      );

      if (!mounted) return;

      if (response['status'] == 'success') {
        // Mostrar mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Se ha enviado un código a tu correo'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );

        // Navegar a la pantalla de nueva contraseña pasando el email
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                NuevaPasswordScreen(email: _emailController.text.trim()),
          ),
        );
      } else {
        // Mostrar mensaje de error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response['message'] ?? 'Error al solicitar recuperación',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Colores usados en los campos
  @override
  Widget build(BuildContext context) {
    final bgColor = const Color(0xFFFFE8DA);
    final cardColor = const Color(0xFFFFCFB0);
    final accent = const Color(0xFFFF9350);

    final maxWidth =
        MediaQuery.of(context).size.width * 0.95; // Aumentado de 0.85 a 0.95
    final cardWidth = maxWidth > 520.0
        ? 520.0
        : maxWidth; // Aumentado de 420 a 520

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('Recuperar contraseña'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF492714)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24), // Aumentado de 20 a 24
          child: Container(
            width: cardWidth,
            padding: const EdgeInsets.symmetric(
              horizontal: 32,
              vertical: 36,
            ), // Aumentado de 24,28 a 32,36
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16), // Aumentado de 12 a 16
              boxShadow: [
                BoxShadow(
                  color: Color.fromRGBO(
                    0,
                    0,
                    0,
                    0.15,
                  ), // Aumentado de 0.12 a 0.15
                  blurRadius: 16, // Aumentado de 12 a 16
                  offset: const Offset(0, 8), // Aumentado de 6 a 8
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 12), // Aumentado de 8 a 12
                  const Text(
                    'MyGasolinera',
                    style: TextStyle(
                      fontSize: 28, // Aumentado de 22 a 28
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF492714),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16.0,
                    ), // Aumentado de 12 a 16
                    child: Column(
                      children: [
                        Image.asset(
                          'lib/assets/logo.png',
                          width: 150, // Aumentado de 120 a 150
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 16), // Aumentado de 12 a 16
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Recuperar contraseña',
                    style: TextStyle(
                      fontSize: 24, // Aumentado de 20 a 24
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF492714),
                    ),
                  ),
                  const SizedBox(height: 24), // Aumentado de 18 a 24
                  // Campo de correo electrónico más grande
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(
                      fontSize: 16,
                    ), // Añadido tamaño de fuente
                    enabled: !_isLoading,
                    // Añadir el manejador de teclas
                    onFieldSubmitted: (value) => _handleForgotPassword(),
                    decoration: InputDecoration(
                      labelText: 'e-mail',
                      labelStyle: const TextStyle(color: Color(0xFF492714)),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 16,
                      ), // Aumentado
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          10,
                        ), // Aumentado de 8 a 10
                        borderSide: const BorderSide(color: Color(0xFF492714)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Color(0xFF492714),
                          width: 2,
                        ),
                      ),
                    ),
                    validator: (value) {
                      // Comprueba que el campo del correo no esté vacio
                      if (value == null || value.isEmpty)
                        return 'Introduce un correo';
                      if (!value.contains('@'))
                        return 'Introduce un correo válido';
                      return null;
                    },
                  ),
                  const SizedBox(height: 24), // Aumentado de 20 a 24
                  // Botón más grande
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleForgotPassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accent,
                        foregroundColor: const Color(0xFF492714),
                        padding: const EdgeInsets.symmetric(
                          vertical: 18,
                        ), // Aumentado de 14 a 18
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 16,
                        ), // Añadido tamaño de fuente
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFF492714),
                                ),
                              ),
                            )
                          : const Text('Solicitar recuperación'),
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
