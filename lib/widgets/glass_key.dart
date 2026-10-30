import 'dart:ui';

import 'package:flutter/material.dart';

/// Glass buttons respond to both desktop mouse hover and mobile touch presses.
enum GlassKeyKind { number, utility, operator, equal, destructive }

class GlassKey extends StatefulWidget {
  const GlassKey({
    super.key,
    required this.label,
    required this.onPressed,
    required this.dark,
    this.kind = GlassKeyKind.number,
    this.icon,
  });

  final String label;
  final VoidCallback onPressed;
  final bool dark;
  final GlassKeyKind kind;
  final IconData? icon;

  @override
  State<GlassKey> createState() => _GlassKeyState();
}

class _GlassKeyState extends State<GlassKey> {
  bool _hover = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final isEqual = widget.kind == GlassKeyKind.equal;
    final isOperator = widget.kind == GlassKeyKind.operator;
    final isDanger = widget.kind == GlassKeyKind.destructive;
    final isUtility = widget.kind == GlassKeyKind.utility;
    final isDark = widget.dark;

    final accent = isEqual
        ? const Color(0xFF7CE8FF)
        : isDanger
            ? const Color(0xFFFFA1B1)
            : isOperator
                ? const Color(0xFFAAA0FF)
                : isDark
                    ? const Color(0xFFE9F5FF)
                    : const Color(0xFF202A4F);
    final foreground = isEqual
        ? const Color(0xFF09112C)
        : isDark
            ? (isDanger ? const Color(0xFFFFC1CF) : accent)
            : (isDanger ? const Color(0xFF9A2842) : accent);

    final normalAlpha = isDark ? 0.105 : 0.66;
    final gradient = isEqual
        ? const [Color(0xFF86EEFF), Color(0xFF849EFF)]
        : isOperator
            ? [
                const Color(0xFF8970E8).withValues(alpha: isDark ? 0.35 : 0.18),
                const Color(0xFF91C8FF).withValues(alpha: isDark ? 0.19 : 0.32),
              ]
            : [
                Colors.white.withValues(alpha: _hover ? normalAlpha + 0.13 : normalAlpha),
                Colors.white.withValues(alpha: isDark ? 0.055 : 0.28),
              ];

    return Semantics(
      button: true,
      label: _semanticName(widget.label),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() {
          _hover = false;
          _pressed = false;
        }),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (_) => setState(() => _pressed = true),
          onTapCancel: () => setState(() => _pressed = false),
          onTapUp: (_) => setState(() => _pressed = false),
          onTap: widget.onPressed,
          child: AnimatedScale(
            scale: _pressed ? 0.955 : (_hover ? 1.025 : 1),
            duration: const Duration(milliseconds: 145),
            curve: Curves.easeOutCubic,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 185),
              curve: Curves.easeOut,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(19),
                boxShadow: [
                  if (_hover || isEqual)
                    BoxShadow(
                      color: accent.withValues(alpha: _hover ? 0.22 : 0.17),
                      blurRadius: _hover ? 27 : 20,
                      spreadRadius: -4,
                      offset: const Offset(0, 8),
                    ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(19),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 13, sigmaY: 13),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 185),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: gradient,
                      ),
                      borderRadius: BorderRadius.circular(19),
                      border: Border.all(
                        color: isEqual
                            ? Colors.white.withValues(alpha: 0.65)
                            : (_hover
                                ? accent.withValues(alpha: 0.64)
                                : Colors.white.withValues(
                                    alpha: isDark ? 0.20 : 0.95,
                                  )),
                        width: _hover ? 1.5 : 1.0,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: widget.icon != null
                        ? Icon(widget.icon, size: 25, color: foreground)
                        : Text(
                            widget.label,
                            style: TextStyle(
                              color: foreground,
                              fontSize: isEqual ? 29 : (isUtility || isDanger ? 21 : 25),
                              fontWeight: isEqual || isOperator
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                              height: 1,
                              letterSpacing: 0.1,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _semanticName(String key) {
    switch (key) {
      case 'AC': return 'Clear all';
      case '⌫': return 'Backspace';
      case '±': return 'Change sign';
      case '%': return 'Percent';
      case '÷': return 'Divide';
      case '×': return 'Multiply';
      case '=': return 'Equals';
      default: return key;
    }
  }
}
