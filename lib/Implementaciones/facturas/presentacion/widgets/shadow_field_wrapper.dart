import 'package:flutter/material.dart';

class ShadowFieldWrapper extends StatefulWidget {
  final Widget child;
  const ShadowFieldWrapper({required this.child, super.key});

  @override
  State<ShadowFieldWrapper> createState() => _ShadowFieldWrapperState();
}

class _ShadowFieldWrapperState extends State<ShadowFieldWrapper> {
  final FocusNode _focusNode = FocusNode();
  bool _hasFocus = false;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (mounted) setState(() => _hasFocus = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Determine background color based on state
    Color backgroundColor = Theme.of(context).cardColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_hasFocus) {
      backgroundColor = isDark ? const Color(0xFF2C2C2C) : Colors.white;
    } else if (_isHovered) {
      // Rounded hover effect color
      backgroundColor = isDark
          ? const Color(0xFF383838)
          : Theme.of(context).cardColor.withOpacity(0.9);

      backgroundColor = Color.alphaBlend(
        Theme.of(context).hoverColor,
        Theme.of(context).cardColor,
      );
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Focus(
        onFocusChange: (value) => setState(() => _hasFocus = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: backgroundColor,
            boxShadow: [
              BoxShadow(
                color: _hasFocus
                    ? Theme.of(context).primaryColor.withOpacity(0.15)
                    : Colors.black.withOpacity(_isHovered ? 0.15 : 0.05),
                blurRadius: _hasFocus ? 12 : (_isHovered ? 8 : 4),
                offset: _hasFocus ? const Offset(0, 4) : const Offset(0, 2),
              ),
            ],
            border: _hasFocus
                ? Border.all(color: Theme.of(context).primaryColor, width: 1.5)
                : Border.all(color: Colors.transparent, width: 1.0),
          ),
          clipBehavior:
              Clip.antiAlias, // Ensures hover color respects rounded corners
          child: widget.child,
        ),
      ),
    );
  }
}
