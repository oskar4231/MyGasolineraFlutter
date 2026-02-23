import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:my_gasolinera/Implementaciones/auth/presentacion/pages/nueva_password.dart';
import 'package:my_gasolinera/Implementaciones/auth/data/services/auth_service.dart';
import 'package:my_gasolinera/core/l10n/app_localizations.dart';
import 'package:my_gasolinera/core/widgets/back_button_hover.dart';
import 'package:my_gasolinera/core/widgets/premium_gradient_button.dart'; // Added import

// Pantalla para solicitar la recuperacion de la contraseña
// Muestra un formulario con un campo de correo y un boton de envío
class RecuperarPassword extends StatefulWidget {
  const RecuperarPassword({super.key});

  @override
  State<RecuperarPassword> createState() => _RecuperarPasswordState();
}

class _RecuperarPasswordState extends State<RecuperarPassword> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _forgotPassword() async {
    // Renamed from _handleForgotPassword
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
          SnackBar(
            content: Text(AppLocalizations.of(context)!.codigoEnviado),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
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
                                  ? Colors.black.withOpacity(
                                      0.3) // Corrected from withValues
                                  : Colors.black.withOpacity(
                                      0.04), // Apple shadow // Corrected from withValues
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
                                AppLocalizations.of(context)!.recuperarPassword,
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
                                AppLocalizations.of(context)!
                                    .ingresaTuEmail, // A description
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(
                                          0.6), // Corrected from withValues
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 32),

                              // Campo de correo electrónico premium
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                enabled: !_isLoading,
                                onFieldSubmitted: (value) =>
                                    _forgotPassword(), // Renamed method
                                decoration: InputDecoration(
                                  hintText: AppLocalizations.of(context)!.email,
                                  hintStyle: TextStyle(
                                      color: theme.colorScheme.onSurface
                                          .withOpacity(
                                              0.5)), // Corrected from withValues
                                  filled: true,
                                  fillColor: isDark
                                      ? theme.colorScheme.onSurface.withOpacity(
                                          0.05) // Corrected from withValues
                                      : theme.colorScheme.primary.withOpacity(
                                          0.05), // Corrected from withValues
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide.none,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(
                                      color: accentColor.withOpacity(
                                          0.5), // Corrected from withValues
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
                                        .ingresaTuEmail;
                                  }
                                  if (!value.contains('@')) {
                                    return AppLocalizations.of(context)!
                                        .emailValido;
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 32),

                              // Botón Enviar Código (Premium)
                              PremiumGradientButton(
                                onPressed: _forgotPassword, // Renamed method
                                isLoading: _isLoading,
                                text: AppLocalizations.of(context)!
                                    .enviarCodigo, // Use localization
                                accentColor: accentColor,
                                isDark: isDark,
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
