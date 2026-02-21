import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:my_gasolinera/Implementaciones/auth/presentacion/pages/login.dart';
import 'package:my_gasolinera/Implementaciones/auth/data/services/auth_service.dart';
import 'package:my_gasolinera/Implementaciones/auth/presentacion/widgets/password_requirements.dart';
import 'package:my_gasolinera/core/l10n/app_localizations.dart';
import 'package:my_gasolinera/core/widgets/back_button_hover.dart';

class NuevaPasswordScreen extends StatefulWidget {
  final String email;

  const NuevaPasswordScreen({super.key, required this.email});

  @override
  State<NuevaPasswordScreen> createState() => _NuevaPasswordScreenState();
}

class _NuevaPasswordScreenState extends State<NuevaPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tokenController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _passwordFocus = FocusNode();

  bool _isLoading = false;
  bool _showPasswordRequirements = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    // Escuchar cambios del foco en el campo de contraseña
    _passwordFocus.addListener(() {
      setState(() {
        _showPasswordRequirements = _passwordFocus.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _tokenController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _passwordFocus.dispose();
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

  Future<void> _handleChangePassword() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (!_isPasswordValid()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.passwordRequisitos),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Primero verificar el token
      final verifyResponse = await AuthService.verifyToken(
        _tokenController.text.trim(),
      );

      if (!mounted) return;

      if (verifyResponse['status'] != 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              verifyResponse['message'] ??
                  AppLocalizations.of(context)!.codigoInvalido,
            ),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isLoading = false);
        return;
      }

      // Si el token es válido, cambiar la contraseña
      final resetResponse = await AuthService.resetPassword(
        _tokenController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;

      if (resetResponse['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.passwordActualizada),
            backgroundColor: Colors.green,
          ),
        );

        // Navegar al login
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              resetResponse['message'] ?? 'Error al cambiar contraseña',
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
                    onPressed: () => Navigator.of(context).pop(),
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
                              const SizedBox(height: 32),

                              Text(
                                AppLocalizations.of(context)!.nuevaPassword,
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                  color: theme.colorScheme.onSurface,
                                  letterSpacing: -0.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),

                              Text(
                                'Código enviado a: ${widget.email}',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: theme.colorScheme.onSurface
                                      .withValues(alpha: 0.6),
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 32),

                              // Campo para el código de 6 dígitos
                              TextFormField(
                                controller: _tokenController,
                                keyboardType: TextInputType.number,
                                maxLength: 6,
                                style: TextStyle(
                                  fontSize: 20,
                                  letterSpacing: 8,
                                  color: theme.colorScheme.onSurface,
                                ),
                                textAlign: TextAlign.center,
                                enabled: !_isLoading,
                                decoration: InputDecoration(
                                  hintText: '000000',
                                  hintStyle: TextStyle(
                                      letterSpacing: 8,
                                      color: theme.colorScheme.onSurface
                                          .withValues(alpha: 0.3)),
                                  labelText: AppLocalizations.of(context)!
                                      .ingresarCodigo,
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
                                  counterText: '',
                                ),
                                onFieldSubmitted: (_) =>
                                    FocusScope.of(context).nextFocus(),
                                validator: (v) {
                                  if (v == null || v.isEmpty) {
                                    return AppLocalizations.of(context)!
                                        .ingresaTuCodigo;
                                  }
                                  if (v.length != 6) {
                                    return 'El código debe tener 6 dígitos';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              // Nueva contraseña
                              TextFormField(
                                controller: _passwordController,
                                focusNode: _passwordFocus,
                                obscureText: _obscurePassword,
                                enabled: !_isLoading,
                                onChanged: (_) => setState(() {}),
                                decoration: InputDecoration(
                                  hintText: AppLocalizations.of(context)!
                                      .nuevaPassword,
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
                                onFieldSubmitted: (_) =>
                                    FocusScope.of(context).nextFocus(),
                                validator: (v) {
                                  if (v == null || v.isEmpty) {
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

                              // Confirmar contraseña
                              TextFormField(
                                controller: _confirmController,
                                obscureText: _obscureConfirmPassword,
                                enabled: !_isLoading,
                                decoration: InputDecoration(
                                  hintText: AppLocalizations.of(context)!
                                      .confirmPassword,
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
                                        _obscureConfirmPassword
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                        color: theme.colorScheme.onSurface
                                            .withValues(alpha: 0.6),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscureConfirmPassword =
                                              !_obscureConfirmPassword;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                                onFieldSubmitted: (_) =>
                                    _handleChangePassword(),
                                validator: (v) {
                                  if (v == null || v.isEmpty) {
                                    return AppLocalizations.of(context)!
                                        .confirmaPassword;
                                  }
                                  if (v != _passwordController.text) {
                                    return AppLocalizations.of(context)!
                                        .passwordsNoCoinciden;
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 32),

                              // Botón Guardar (Premium)
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
                                    onPressed: _isLoading
                                        ? null
                                        : _handleChangePassword,
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
                                                .guardar,
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
