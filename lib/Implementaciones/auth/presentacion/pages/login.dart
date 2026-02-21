import 'dart:ui';
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
import 'package:my_gasolinera/core/utils/app_logger.dart';
import 'package:my_gasolinera/core/widgets/back_button_hover.dart';

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

        AppLogger.debug('Intentando login en: $url', tag: 'LoginScreen');
        AppLogger.debug('Email: ${_emailController.text.trim()}',
            tag: 'LoginScreen');

        final response = await http.post(
          url,
          headers: HttpHelper.mergeHeaders(ApiConfig.headers),
          body: json.encode({
            'email': _emailController.text.trim(),
            'password': _passwordController.text,
          }),
        );

        AppLogger.debug('Respuesta status: ${response.statusCode}',
            tag: 'LoginScreen');
        AppLogger.debug('Respuesta body: ${response.body}', tag: 'LoginScreen');

        final responseData = json.decode(response.body);

        if (response.statusCode == 200) {
          // Login exitoso
          if (mounted) {
            // Guardar el token del usuario
            final token = responseData['token'];
            if (token != null) {
              await AuthService.saveToken(token, _emailController.text.trim());
              AppLogger.info('Token guardado exitosamente', tag: 'LoginScreen');
            }

            if (mounted) {
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
        AppLogger.error('Error de conexión', tag: 'LoginScreen', error: error);
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentColor =
        isDark ? const Color(0xFFE87A3E) : const Color(0xFFD36226);
    final cardColor = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final bgColor = isDark
        ? const Color(0xFF000000)
        : const Color(0xFFF7F7F5); // Premium neutral Apple tint

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header con botón de retroceso premium
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  HoverBackButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const Inicio()),
                      );
                    },
                  ),
                  const SizedBox(width: 16),
                  Text(
                    AppLocalizations.of(context)!.volver,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),

            // Contenido principal
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 450),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: isDark
                                  ? Colors.black.withValues(alpha: 0.3)
                                  : Colors.black
                                      .withValues(alpha: 0.04), // Apple shadow
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(32),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                'assets/images/logo-mygasolinera.png',
                                width: 96,
                                height: 96,
                                fit: BoxFit.contain,
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'MyGasolinera',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w900,
                                  color: theme.colorScheme.onSurface,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 40),

                              // Campo de email
                              TextFormField(
                                controller: _emailController,
                                focusNode: _emailFocus,
                                textInputAction: TextInputAction.next,
                                onFieldSubmitted: (_) =>
                                    _handleFieldSubmit('email'),
                                decoration: InputDecoration(
                                  hintText: AppLocalizations.of(context)!.email,
                                  hintStyle: TextStyle(
                                      color: theme.colorScheme.onSurface
                                          .withValues(alpha: 0.5)),
                                  filled: true,
                                  fillColor: isDark
                                      ? theme.colorScheme.onSurface
                                          .withValues(alpha: 0.05)
                                      : theme.colorScheme.primary
                                          .withValues(alpha: 0.05),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide.none,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(
                                      color: accentColor.withValues(alpha: 0.5),
                                      width: 2,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 20,
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return AppLocalizations.of(context)!
                                        .ingresaEmail;
                                  }
                                  if (value.contains('@')) {
                                    final emailRegex = RegExp(
                                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                    );
                                    if (!emailRegex.hasMatch(value)) {
                                      return AppLocalizations.of(context)!
                                          .emailValido;
                                    }
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              // Campo de contraseña
                              TextFormField(
                                controller: _passwordController,
                                focusNode: _passwordFocus,
                                textInputAction: TextInputAction.done,
                                onFieldSubmitted: (_) =>
                                    _handleFieldSubmit('password'),
                                obscureText: _obscurePassword,
                                decoration: InputDecoration(
                                  hintText:
                                      AppLocalizations.of(context)!.password,
                                  hintStyle: TextStyle(
                                      color: theme.colorScheme.onSurface
                                          .withValues(alpha: 0.5)),
                                  filled: true,
                                  fillColor: isDark
                                      ? theme.colorScheme.onSurface
                                          .withValues(alpha: 0.05)
                                      : theme.colorScheme.primary
                                          .withValues(alpha: 0.05),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide.none,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(
                                      color: accentColor.withValues(alpha: 0.5),
                                      width: 2,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 20,
                                  ),
                                  suffixIcon: Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: IconButton(
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                        color: theme.colorScheme.onSurface
                                            .withValues(alpha: 0.6),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscurePassword = !_obscurePassword;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return AppLocalizations.of(context)!
                                        .ingresaPassword;
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              // Checkbox "Recuérdame" y olvido de contraseña
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: Checkbox(
                                          value: _rememberMe,
                                          onChanged: (bool? value) {
                                            setState(() {
                                              _rememberMe = value ?? false;
                                            });
                                          },
                                          activeColor: accentColor,
                                          checkColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        AppLocalizations.of(context)!
                                            .recordarme,
                                        style: TextStyle(
                                            color: theme.colorScheme.onSurface,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 32),

                              // Botón Iniciar sesión (Premium)
                              SizedBox(
                                width: double.infinity,
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        accentColor.withValues(alpha: 0.9),
                                        accentColor,
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      if (!isDark)
                                        BoxShadow(
                                          color: accentColor.withValues(
                                              alpha: 0.25),
                                          blurRadius: 12,
                                          offset: const Offset(0, 6),
                                        ),
                                    ],
                                  ),
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : _login,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 20),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: _isLoading
                                        ? const SizedBox(
                                            height: 24,
                                            width: 24,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 3,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                            ),
                                          )
                                        : Text(
                                            AppLocalizations.of(context)!
                                                .iniciarSesion,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Enlace "¿Has olvidado la contraseña?"
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const RecuperarPassword(),
                                    ),
                                  );
                                },
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                ),
                                child: Text(
                                  AppLocalizations.of(context)!.olvidoPassword,
                                  style: TextStyle(
                                    color: accentColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
