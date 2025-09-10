import 'package:flutter/material.dart';

/// Common button component (ElevatedButton based)
class CommonButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final ButtonType type;
  final bool isFullWidth;

  const CommonButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.type = ButtonType.primary,
    this.isFullWidth = true,
  });

  const CommonButton.primary({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.isFullWidth = true,
  }) : type = ButtonType.primary;

  const CommonButton.secondary({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.isFullWidth = true,
  }) : type = ButtonType.secondary;

  const CommonButton.success({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.isFullWidth = true,
  }) : type = ButtonType.success;

  const CommonButton.warning({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.isFullWidth = true,
  }) : type = ButtonType.warning;

  const CommonButton.danger({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.isFullWidth = true,
  }) : type = ButtonType.danger;

  const CommonButton.info({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.isFullWidth = true,
  }) : type = ButtonType.info;

  const CommonButton.accent({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.isFullWidth = true,
  }) : type = ButtonType.accent;

  @override
  Widget build(BuildContext context) {
    final buttonStyle = _getButtonStyle();

    final button = icon != null
        ? ElevatedButton.icon(
            onPressed: onPressed,
            icon: Icon(icon, size: 18),
            label: Text(label),
            style: buttonStyle,
          )
        : ElevatedButton(
            onPressed: onPressed,
            style: buttonStyle,
            child: Text(label),
          );

    if (isFullWidth) {
      return SizedBox(width: double.infinity, child: button);
    }

    return button;
  }

  ButtonStyle _getButtonStyle() {
    final colors = _getColors();

    return ElevatedButton.styleFrom(
      backgroundColor: colors.background,
      foregroundColor: colors.foreground,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      minimumSize: const Size(0, 48),
      textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      elevation: 2,
      shadowColor: colors.background.withValues(alpha: 0.3),
    );
  }

  ButtonColors _getColors() {
    switch (type) {
      case ButtonType.primary:
        return const ButtonColors(Colors.blue, Colors.white);
      case ButtonType.secondary:
        return const ButtonColors(Colors.grey, Colors.white);
      case ButtonType.success:
        return const ButtonColors(Colors.green, Colors.white);
      case ButtonType.warning:
        return const ButtonColors(Colors.orange, Colors.white);
      case ButtonType.danger:
        return const ButtonColors(Colors.red, Colors.white);
      case ButtonType.info:
        return const ButtonColors(Colors.teal, Colors.white);
      case ButtonType.accent:
        return const ButtonColors(Colors.indigo, Colors.white);
    }
  }
}

enum ButtonType { primary, secondary, success, warning, danger, info, accent }

class ButtonColors {
  final Color background;
  final Color foreground;

  const ButtonColors(this.background, this.foreground);
}
