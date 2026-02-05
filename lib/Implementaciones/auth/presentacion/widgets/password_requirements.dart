import 'package:flutter/material.dart';

class PasswordRequirements extends StatelessWidget {
  final String password;
  final bool isVisible;
  final Color? primaryColor;
  final Color successColor;
  final Color errorColor;
  final Color? backgroundColor;

  const PasswordRequirements({
    super.key,
    required this.password,
    required this.isVisible,
    this.primaryColor,
    this.successColor = Colors.green,
    this.errorColor = Colors.red,
    this.backgroundColor,
  });

  // Validaciones
  bool get hasMinLength => password.length >= 8;
  bool get hasNumber => password.contains(RegExp(r'[0-9]'));
  bool get hasSpecialChar =>
      password.contains(RegExp(r'[!@#<>?":_`~;[\]\\|=+)(*&^%0-9-.,ñÑ]'));
  bool get hasUppercase => password.contains(RegExp(r'[A-Z]'));

  // Validación de todos los requisitos
  bool get isAllValid =>
      hasMinLength && hasNumber && hasSpecialChar && hasUppercase;

  @override
  Widget build(BuildContext context) {
    final effectivePrimaryColor =
        primaryColor ?? Theme.of(context).colorScheme.onSurface;
    final effectiveBackgroundColor =
        backgroundColor ?? Theme.of(context).colorScheme.surface;

    return AnimatedSize(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      child: AnimatedOpacity(
        opacity: isVisible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 400),
        child: isVisible
            ? Container(
                margin: const EdgeInsets.only(top: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: effectiveBackgroundColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Requisitos de contraseña:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: effectivePrimaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildRequirementItem('Al menos 8 caracteres', hasMinLength,
                        effectivePrimaryColor),
                    _buildRequirementItem('Al menos un número (0-9)', hasNumber,
                        effectivePrimaryColor),
                    _buildRequirementItem(
                        'Al menos un carácter especial (., #, ñ, ...)',
                        hasSpecialChar,
                        effectivePrimaryColor),
                    _buildRequirementItem('Al menos una mayúscula (A-Z)',
                        hasUppercase, effectivePrimaryColor),
                  ],
                ),
              )
            : SizedBox.shrink(),
      ),
    );
  }

  Widget _buildRequirementItem(
      String text, bool isMet, Color effectivePrimaryColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isMet
                  ? successColor.withValues(alpha: 0.1)
                  : errorColor.withValues(alpha: 0.1),
              border: Border.all(
                color: isMet ? successColor : errorColor,
                width: 2,
              ),
            ),
            child: Center(
              child: Icon(
                isMet ? Icons.check : Icons.close,
                size: 12,
                color: effectivePrimaryColor,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: effectivePrimaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
