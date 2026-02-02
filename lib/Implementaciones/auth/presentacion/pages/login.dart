import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:my_gasolinera/Implementaciones/auth/presentacion/pages/inicio.dart';
import 'package:my_gasolinera/Implementaciones/auth/presentacion/pages/recuperar.dart';
import 'package:my_gasolinera/Implementaciones/home/presentacion/pages/layouthome.dart';
import 'package:my_gasolinera/Implementaciones/auth/data/services/auth_service.dart';
import 'package:my_gasolinera/core/config/api_config.dart';
import 'package:my_gasolinera/core/utils/http_helper.dart';
import 'package:my_gasolinera/core/l10n/app_localizations.dart';

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

  // Focus nodes para manejar el foco entre campos
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Use http://10.0.2.2:3000/login for Android Emulator
        // Use https://unsubscribe-doom-onion-submitting.trycloudflare.com/login for iOS Simulator or Web
        final url = Uri.parse(ApiConfig.loginUrl);

        print('Intentando login en: $url');
        print('Email: ${_emailController.text.trim()}');

        final response = await http.post(
          url,
          headers: HttpHelper.mergeHeaders(ApiConfig.headers),
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
              await AuthService.saveToken(token, _emailController.text.trim());
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
              MaterialPageRoute(builder: (context) => const Layouthome()),
            );
          }
        } else {
          // Login fallido (400, 401, 500)
          if (mounted) {
            String errorMessage =
                responseData['message'] ?? 'Error al iniciar sesión';
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
              content: Text(
                'Error de conexión. Asegúrate de que el servidor esté corriendo. ($error)',
              ),
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

  // Función para manejar la acción "Siguiente" o "Enter"
  void _handleFieldSubmit(String value) {
    switch (value) {
      case 'email':
        FocusScope.of(context).requestFocus(_passwordFocus);
        break;
      case 'password':
        _login(); // Al último campo, ejecutar el login
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.volver),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: Theme.of(context).colorScheme.onSurface),
          onPressed: () {
            // MODIFICACIÓN AQUÍ: Navegar a Inicio en lugar de pop
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const Inicio()),
            );
          },
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
                      child: Text(
                        'MyGasolinera',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
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

                    // Campo de email
                    TextFormField(
                      controller: _emailController,
                      focusNode: _emailFocus,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) => _handleFieldSubmit('email'),
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!.email,
                        hintStyle: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.6)),
                        filled: true,
                        fillColor: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.15),
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
                          return AppLocalizations.of(context)!.ingresaEmail;
                        }
                        if (value.contains('@')) {
                          final emailRegex = RegExp(
                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                          );
                          if (!emailRegex.hasMatch(value)) {
                            return AppLocalizations.of(context)!.emailValido;
                          }
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),

                    // Campo de contraseña
                    TextFormField(
                      controller: _passwordController,
                      focusNode: _passwordFocus,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _handleFieldSubmit('password'),
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!.password,
                        hintStyle: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.6)),
                        filled: true,
                        fillColor: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.15),
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
                            color: Theme.of(context).colorScheme.onSurface,
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
                          return AppLocalizations.of(context)!.ingresaPassword;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),

                    // Checkbox "Recuérdame"
                    Row(
                      children: [
                        Checkbox(
                          value: _rememberMe,
                          onChanged: (bool? value) {
                            setState(() {
                              _rememberMe = value ?? false;
                            });
                          },
                          activeColor: Theme.of(context).colorScheme.primary,
                          checkColor: Theme.of(context).colorScheme.onPrimary,
                        ),
                        Text(
                          AppLocalizations.of(context)!.recordarme,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    // Botón Iniciar sesión
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Theme.of(context).colorScheme.onPrimary,
                                  ),
                                ),
                              )
                            : Text(
                                AppLocalizations.of(context)!.iniciarSesion,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                ),
                              ),
                      ),
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
                      child: Text(
                        AppLocalizations.of(context)!.olvidoPassword,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          decoration: TextDecoration.underline,
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
