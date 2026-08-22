import 'package:flutter/material.dart';
import '../theme/finora_theme.dart';

class FinoraDropdown<T> extends StatelessWidget {
  const FinoraDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.icon,
    this.hint,
    this.options,
    this.items,
    this.optionLabel,
    this.prefixIcon,
  }) : assert(
         options != null || items != null,
         'Provide either options (with optional optionLabel) or prebuilt items.',
       );

  final String label;
  final T? value;
  final ValueChanged<T?> onChanged;
  final IconData? icon;
  final String? hint;
  final List<T>? options;
  final List<DropdownMenuItem<T>>? items;
  final String Function(T)? optionLabel;
  final IconData? prefixIcon;

  @override
  Widget build(BuildContext context) {
    final resolvedItems =
        items ??
        (options!
            .map(
              (o) => DropdownMenuItem<T>(
                value: o,
                child: Text(
                  optionLabel == null ? '$o' : optionLabel!(o),
                  style: FinoraTextStyles.body.copyWith(
                    color: FinoraColors.textPrimary,
                  ),
                ),
              ),
            )
            .toList());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: FinoraTextStyles.label),
        const SizedBox(height: FinoraSpacing.xs),
        Container(
          decoration: BoxDecoration(
            color: FinoraColors.surfaceAlt,
            borderRadius: BorderRadius.circular(FinoraRadii.md),
            border: Border.all(color: FinoraColors.outline, width: 1.2),
          ),
          padding: const EdgeInsets.symmetric(horizontal: FinoraSpacing.md),
          child: Row(
            children: [
              if (prefixIcon != null) ...[
                Icon(prefixIcon, size: 20, color: FinoraColors.brandPrimary),
                const SizedBox(width: FinoraSpacing.sm),
              ],
              if (icon != null && prefixIcon == null) ...[
                Icon(icon, size: 20, color: FinoraColors.brandPrimary),
                const SizedBox(width: FinoraSpacing.sm),
              ],
              Expanded(
                child: DropdownButton<T>(
                  value: value,
                  items: resolvedItems,
                  onChanged: onChanged,
                  isExpanded: true,
                  underline: const SizedBox.shrink(),
                  borderRadius: BorderRadius.circular(FinoraRadii.md),
                  hint: hint == null
                      ? null
                      : Text(
                          hint!,
                          style: FinoraTextStyles.body.copyWith(
                            color: FinoraColors.textMuted,
                          ),
                        ),
                  style: FinoraTextStyles.body.copyWith(
                    color: FinoraColors.textPrimary,
                  ),
                  icon: const Icon(
                    Icons.expand_more_rounded,
                    color: FinoraColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
