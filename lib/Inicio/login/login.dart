import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:my_gasolinera/Inicio/inicio.dart';
import 'package:my_gasolinera/Inicio/login/recuperar.dart';
import 'package:my_gasolinera/principal/layouthome.dart';
import 'package:my_gasolinera/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Use http://10.0.2.2:3000/login for Android Emulator
        // Use http://localhost:3000/login for iOS Simulator or Web
        final url = Uri.parse('http://localhost:3000/login'); 
        
        print('Intentando login en: $url');
        print('Email: ${_emailController.text.trim()}');

        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'email': _emailController.text.trim(),
            'password': _passwordController.text,
          }),
        );

        print('Respuesta status: ${response.statusCode}');
        print('Respuesta body: ${response.body}');

        final responseData = json.decode(response.body);

        if (response.statusCode == 200) {
          // Login exitoso
          if (mounted) {
            // Guardar el token del usuario
            final token = responseData['token'];
            if (token != null) {
              AuthService.saveToken(token, _emailController.text.trim());
              print('✅ Token guardado exitosamente');
            }
            
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Login exitoso'),
                backgroundColor: Colors.green,
              ),
            );
            
            // Navegar al mapa
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const Layouthome(),
              ),
            );
          }
        } else {
          // Login fallido (400, 401, 500)
          if (mounted) {
            String errorMessage = responseData['message'] ?? 'Error al iniciar sesión';
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(errorMessage),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (error) {
        print('Error de conexión: $error');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error de conexión. Asegúrate de que el servidor esté corriendo. ($error)'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFE8DA),
      appBar: AppBar(
        title: const Text('Volver'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Color(0xFF492714),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const Inicio(),
              ),
            );
          },
        ),
      ),
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo
                      Image.asset(
                        'assets/images/logo-mygasolinera.png',
                        width: 200,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 20),
                      // Título
                      const Text(
                        'MyGasolinera',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF492714),
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Campo de email
                      SizedBox(
                        width: 1000,
                        child: TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Email o Usuario',
                            labelStyle: const TextStyle(color: Color(0xFF492714)),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Color(0xFF492714)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Color(0xFF492714), width: 2),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingresa tu email o usuario';
                            }
                            if (value.contains('@')) {
                                final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                                if (!emailRegex.hasMatch(value)) {
                                    return 'Ingresa un email válido';
                                }
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Campo de contraseña
                      SizedBox(
                        width: 1000,
                        child: TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'contraseña',
                            labelStyle: const TextStyle(color: Color(0xFF492714)),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Color(0xFF492714)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Color(0xFF492714), width: 2),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: const Color(0xFF492714),
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingresa tu contraseña';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 15),

                      // Checkbox "Recuérdame"
                      SizedBox(
                        width: 1000,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Checkbox(
                              value: _rememberMe,
                              onChanged: (bool? value) {
                                setState(() {
                                  _rememberMe = value ?? false;
                                });
                              },
                              activeColor: const Color(0xFFFF9350),
                              checkColor: const Color(0xFF492714),
                            ),
                            const Text(
                              'Recuérdame',
                              style: TextStyle(
                                color: Color(0xFF492714),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Botón Iniciar sesión
                      ElevatedButton(
                        onPressed: _isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF9350),
                          foregroundColor: const Color(0xFF492714),
                          padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                          side: const BorderSide(
                              color: Color(0xFF492714),
                              width: 2.0
                          ),
                          textStyle: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF492714)),
                          ),
                        )
                            : const Text('Iniciar sesión'),
                      ),
                      const SizedBox(height: 15),

                      // Enlace "¿Has olvidado la contraseña?"
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const RecuperarPassword(),
                            ),
                          );
                        },
                        child: const Text(
                          '¿Has olvidado la contraseña?',
                          style: TextStyle(
                            color: Color(0xFF492714),
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}