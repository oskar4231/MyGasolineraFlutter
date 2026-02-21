import 'package:flutter/material.dart';
import 'package:my_gasolinera/Implementaciones/auth/presentacion/pages/inicio.dart';
import 'package:my_gasolinera/Implementaciones/auth/presentacion/pages/login.dart';
import 'package:my_gasolinera/Implementaciones/auth/data/services/auth_service.dart';
import 'package:my_gasolinera/Implementaciones/auth/presentacion/widgets/password_requirements.dart';
import 'package:my_gasolinera/core/l10n/app_localizations.dart';
import 'package:my_gasolinera/core/utils/app_logger.dart';
import 'package:my_gasolinera/core/widgets/back_button_hover.dart';

class CrearScreen extends StatefulWidget {
  const CrearScreen({super.key});

  @override
  State<CrearScreen> createState() => _CrearScreenState();
}

class _CrearScreenState extends State<CrearScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _nombreFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmPasswordFocus = FocusNode();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _showPasswordRequirements = false;

  @override
  void initState() {
    super.initState();
    _passwordFocus.addListener(() {
      setState(() {
        _showPasswordRequirements = _passwordFocus.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nombreFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    super.dispose();
  }

  bool _isPasswordValid() {
    final password = _passwordController.text;
    final hasMinLength = password.length >= 8;
    final hasNumber = password.contains(RegExp(r'[0-9]'));
    final hasSpecialChar = password.contains(RegExp(r'[#$?¿]'));
    final hasUppercase = password.contains(RegExp(r'[A-Z]'));

    return hasMinLength && hasNumber && hasSpecialChar && hasUppercase;
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      if (!_isPasswordValid()) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.passwordRequisitos),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        final responseData = await AuthService.register(
          _nombreController.text.trim(),
          _emailController.text.trim(),
          _passwordController.text,
        );

        if (!mounted) return;

        if (responseData['status'] == 'success' ||
            responseData['message'] == 'Usuario registrado con éxito') {
          // Registro exitoso, ir al login
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.registroExitoso),
              backgroundColor: Colors.green,
            ),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        } else {
          // Error controlado por el backend
          String errorMessage =
              responseData['message'] ?? 'Error al registrar usuario';
          AppLogger.error('Error de registro: $errorMessage',
              tag: 'CrearScreen');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        if (!mounted) return;
        AppLogger.error('Error general de registro',
            tag: 'CrearScreen', error: e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Error de conexión o problema inesperado.'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  void _handleFieldSubmit(String field) {
    switch (field) {
      case 'nombre':
        FocusScope.of(context).requestFocus(_emailFocus);
        break;
      case 'email':
        FocusScope.of(context).requestFocus(_passwordFocus);
        break;
      case 'password':
        FocusScope.of(context).requestFocus(_confirmPasswordFocus);
        break;
      case 'confirm_password':
        _register();
        break;
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hintText,
    required BuildContext context,
    required String fieldName,
    required Color accentColor,
    required ThemeData theme,
    required bool isDark,
    bool isPassword = false,
    bool? obscureText,
    VoidCallback? onToggleVisibility,
    TextInputAction textInputAction = TextInputAction.next,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      textInputAction: textInputAction,
      onFieldSubmitted: (_) => _handleFieldSubmit(fieldName),
      obscureText: isPassword ? (obscureText ?? true) : false,
      onChanged: isPassword && fieldName == 'password'
          ? (_) => setState(() {}) // Para actualizar los requisitos
          : null,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
        filled: true,
        fillColor: isDark
            ? theme.colorScheme.onSurface.withValues(alpha: 0.05)
            : theme.colorScheme.primary.withValues(alpha: 0.05),
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
        suffixIcon: isPassword
            ? Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: IconButton(
                  icon: Icon(
                    obscureText ?? true
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  onPressed: onToggleVisibility,
                ),
              )
            : null,
      ),
      validator: validator,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentColor =
        isDark ? const Color(0xFFE87A3E) : const Color(0xFFD36226);
    final cardColor = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final bgColor = isDark ? const Color(0xFF000000) : const Color(0xFFF7F7F5);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header con botón de retroceso premium
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: HoverBackButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Inicio()),
                        );
                      },
                    ),
                  ),
                  Text(
                    AppLocalizations.of(context)!.volver,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
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
                              Text(
                                AppLocalizations.of(context)!.crearCuenta,
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w900,
                                  color: theme.colorScheme.onSurface,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Únete a MyGasolinera gratis',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: theme.colorScheme.onSurface
                                      .withValues(alpha: 0.6),
                                ),
                              ),
                              const SizedBox(height: 32),

                              _buildTextField(
                                controller: _nombreController,
                                focusNode: _nombreFocus,
                                hintText:
                                    AppLocalizations.of(context)!.fullName,
                                context: context,
                                fieldName: 'nombre',
                                accentColor: accentColor,
                                theme: theme,
                                isDark: isDark,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return AppLocalizations.of(context)!
                                        .ingresaNombre;
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              _buildTextField(
                                controller: _emailController,
                                focusNode: _emailFocus,
                                hintText: AppLocalizations.of(context)!.email,
                                context: context,
                                fieldName: 'email',
                                accentColor: accentColor,
                                theme: theme,
                                isDark: isDark,
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

                              _buildTextField(
                                controller: _passwordController,
                                focusNode: _passwordFocus,
                                hintText:
                                    AppLocalizations.of(context)!.password,
                                context: context,
                                fieldName: 'password',
                                isPassword: true,
                                obscureText: _obscurePassword,
                                onToggleVisibility: () => setState(
                                    () => _obscurePassword = !_obscurePassword),
                                accentColor: accentColor,
                                theme: theme,
                                isDark: isDark,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return AppLocalizations.of(context)!
                                        .ingresaPassword;
                                  }
                                  if (!_isPasswordValid()) {
                                    return AppLocalizations.of(context)!
                                        .passwordRequisitos;
                                  }
                                  return null;
                                },
                              ),

                              PasswordRequirements(
                                password: _passwordController.text,
                                isVisible: _showPasswordRequirements,
                                primaryColor: accentColor,
                              ),
                              const SizedBox(height: 16),

                              _buildTextField(
                                controller: _confirmPasswordController,
                                focusNode: _confirmPasswordFocus,
                                hintText: AppLocalizations.of(context)!
                                    .confirmPassword,
                                context: context,
                                fieldName: 'confirm_password',
                                isPassword: true,
                                obscureText: _obscureConfirmPassword,
                                onToggleVisibility: () => setState(() =>
                                    _obscureConfirmPassword =
                                        !_obscureConfirmPassword),
                                textInputAction: TextInputAction.done,
                                accentColor: accentColor,
                                theme: theme,
                                isDark: isDark,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return AppLocalizations.of(context)!
                                        .confirmaPassword;
                                  }
                                  if (value != _passwordController.text) {
                                    return AppLocalizations.of(context)!
                                        .passwordsNoCoinciden;
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 32),

                              // Botón Crear Cuenta (Premium)
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
                                    onPressed: _isLoading ? null : _register,
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
                                                .crearCuenta,
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
                              const SizedBox(height: 16),
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
