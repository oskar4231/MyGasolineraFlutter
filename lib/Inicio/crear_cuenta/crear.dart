import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const Crear());
}

class Crear extends StatelessWidget {
  const Crear({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crear Cuenta MyGasolinera',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: const CrearScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class CrearScreen extends StatefulWidget {
  const CrearScreen({super.key});

  @override
  State<CrearScreen> createState() => _CrearScreenState();
}

class _CrearScreenState extends State<CrearScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nombreController = TextEditingController(); // Nuevo campo
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nombreController.dispose();
    super.dispose();
  }

  // Función para registrar usuario en el backend
  Future<void> _registrarUsuario() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final response = await http.post(
          Uri.parse('http://localhost:3000/register'), //Chrome
          // Uri.parse('http://10.0.2.2:3000/register'), // Android emulator
          // Uri.parse('http://localhost:3000/register'), // iOS simulator
          headers: {
            'Content-Type': 'application/json',
          },
          body: json.encode({
            'email': _emailController.text.trim(),
            'password': _passwordController.text,
            'nombre': _nombreController.text.trim(),
          }),
        );

        final responseData = json.decode(response.body);

        if (response.statusCode == 201) {
          // Registro exitoso
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(responseData['message']),
              backgroundColor: Colors.green,
            ),
          );
          
          // Opcional: Navegar a login o home
          print('Usuario registrado: ${responseData['user']['email']}');
          print('Token: ${responseData['token']}');
          
          // Limpiar formulario
          _formKey.currentState!.reset();
          
        } else {
          // Error del servidor
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(responseData['message'] ?? 'Error desconocido'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (error) {
        // Error de conexión
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error de conexión: $error'),
            backgroundColor: Colors.red,
          ),
        );
        print('Error de conexión: $error');
      } finally {
        setState(() {
          _isLoading = false;
        });
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
          icon: const Icon(Icons.arrow_back, color: Color(0xFF492714)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 20),

                    Container(
                      margin: const EdgeInsets.only(bottom: 30.0),
                      child: const Text(
                        'MyGasolinera',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF492714),
                        ),
                      ),
                    ),

                    Container(
                      margin: const EdgeInsets.only(bottom: 30.0),
                      child: Image.asset(
                        'lib/assets/logo.png',
                        height: 100,
                        width: 100,
                        fit: BoxFit.contain,
                      ),
                    ),

                    // Campo de nombre (NUEVO)
                    TextFormField(
                      controller: _nombreController,
                      decoration: InputDecoration(
                        hintText: 'Nombre completo',
                        hintStyle: const TextStyle(
                          color: Color(0xFF492714),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFFFD4B8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 15,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa tu nombre';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),

                    // Campo de email
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        hintText: 'e-mail',
                        hintStyle: const TextStyle(
                          color: Color(0xFF492714),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFFFD4B8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 15,
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa tu email';
                        }
                        if (!value.contains('@')) {
                          return 'Ingresa un email válido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    
                    // Campo de contraseña
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        hintText: 'contraseña',
                        hintStyle: const TextStyle(
                          color: Color(0xFF492714),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFFFD4B8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 15,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Color(0xFF492714),
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
                        if (value.length < 6) {
                          return 'La contraseña debe tener al menos 6 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    
                    // Campo de confirmar contraseña
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      decoration: InputDecoration(
                        hintText: 'confirmar contraseña',
                        hintStyle: const TextStyle(
                          color: Color(0xFF492714),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFFFD4B8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 15,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Color(0xFF492714),
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword = !_obscureConfirmPassword;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor confirma tu contraseña';
                        }
                        if (value != _passwordController.text) {
                          return 'Las contraseñas no coinciden';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 30),
                    
                    // Botón de crear
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _registrarUsuario,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF9955),
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
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
                            : const Text(
                                'Crear Cuenta',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF492714),
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}