import 'package:flutter/material.dart';

import '../theme/finora_theme.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.label,
    this.controller,
    this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.onSubmitted,
    this.onChanged,
    this.autofillHints,
    this.maxLines = 1,
    this.helperText,
    this.enabled = true,
  });

  final String label;
  final String? hint;
  final TextEditingController? controller;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;
  final Iterable<String>? autofillHints;
  final int maxLines;
  final String? helperText;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    const borderRadius = BorderRadius.all(Radius.circular(12));
    final enabledBorder = OutlineInputBorder(
      borderRadius: borderRadius,
      borderSide: const BorderSide(color: FinoraColors.outline, width: 1.2),
    );
    final focusedBorder = OutlineInputBorder(
      borderRadius: borderRadius,
      borderSide: const BorderSide(
        color: FinoraColors.brandPrimary,
        width: 1.6,
      ),
    );
    final errorBorder = OutlineInputBorder(
      borderRadius: borderRadius,
      borderSide: const BorderSide(color: FinoraColors.negative, width: 1.4),
    );
    final disabledBorder = OutlineInputBorder(
      borderRadius: borderRadius,
      borderSide: const BorderSide(
        color: FinoraColors.outline,
        width: 1.0,
      ).copyWith(color: FinoraColors.outline.withValues(alpha: 0.5)),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0E1726),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          validator: validator,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          onFieldSubmitted: onSubmitted,
          onChanged: onChanged,
          autofillHints: autofillHints,
          maxLines: obscureText ? 1 : maxLines,
          enabled: enabled,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: FinoraColors.surfaceAlt,
            prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
            suffixIcon: suffixIcon,
            helperText: helperText,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            border: enabledBorder,
            enabledBorder: enabledBorder,
            focusedBorder: focusedBorder,
            errorBorder: errorBorder,
            focusedErrorBorder: focusedBorder,
            disabledBorder: disabledBorder,
          ),
        ),
      ],
    );
  }
}
