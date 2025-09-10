import 'package:flutter/material.dart';

/// Common input field component with consistent styling
class CommonInputField extends StatelessWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconTap;
  final bool isRequired;
  final bool enabled;
  final bool isDense;
  final TextInputType? keyboardType;
  final String? errorText;
  final int? maxLines;
  final Function(String)? onChanged;
  final EdgeInsetsGeometry? contentPadding;

  const CommonInputField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconTap,
    this.isRequired = false,
    this.enabled = true,
    this.isDense = true,
    this.keyboardType,
    this.errorText,
    this.maxLines = 1,
    this.onChanged,
    this.contentPadding,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      maxLines: maxLines,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: isRequired && labelText != null ? '$labelText *' : labelText,
        hintText: hintText,
        border: const OutlineInputBorder(),
        isDense: isDense,
        errorText: errorText,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        suffixIcon: suffixIcon != null
            ? IconButton(icon: Icon(suffixIcon), onPressed: onSuffixIconTap)
            : null,
        contentPadding:
            contentPadding ??
            const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }
}

/// Common dropdown field component with consistent styling
class CommonDropdownField<T> extends StatelessWidget {
  final T? value;
  final String? labelText;
  final String? hintText;
  final List<DropdownMenuItem<T>> items;
  final Function(T?)? onChanged;
  final bool enabled;
  final bool isDense;
  final String? errorText;

  const CommonDropdownField({
    super.key,
    this.value,
    this.labelText,
    this.hintText,
    required this.items,
    this.onChanged,
    this.enabled = true,
    this.isDense = true,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      items: items,
      onChanged: enabled ? onChanged : null,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        border: const OutlineInputBorder(),
        isDense: isDense,
        errorText: errorText,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }
}

/// Common input decorator for read-only displays
class CommonInputDecorator extends StatelessWidget {
  final Widget child;
  final String? labelText;
  final bool isDense;
  final EdgeInsetsGeometry? contentPadding;

  const CommonInputDecorator({
    super.key,
    required this.child,
    this.labelText,
    this.isDense = true,
    this.contentPadding,
  });

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: labelText,
        border: const OutlineInputBorder(),
        isDense: isDense,
        contentPadding:
            contentPadding ??
            const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      child: child,
    );
  }
}
