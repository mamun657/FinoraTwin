import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/finora_theme.dart';

class FinoraAmountField extends StatelessWidget {
  const FinoraAmountField({
    super.key,
    required this.controller,
    required this.currencySymbol,
    this.label = 'Amount',
    this.hint,
    this.prefixIcon = Icons.payments_rounded,
    this.onChanged,
    this.autofocus = false,
    this.helper,
    this.validator,
    this.textInputAction,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String currencySymbol;
  final String label;
  final String? hint;
  final IconData prefixIcon;
  final ValueChanged<String>? onChanged;
  final bool autofocus;
  final String? helper;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(FinoraRadii.md);

    final field = Container(
      decoration: BoxDecoration(
        color: FinoraColors.surfaceAlt,
        borderRadius: borderRadius,
        border: Border.all(color: FinoraColors.outline, width: 1.2),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: FinoraSpacing.md),
            child: Icon(prefixIcon, size: 22, color: FinoraColors.brandPrimary),
          ),
          Container(width: 1.2, height: 28, color: FinoraColors.outline),
          const SizedBox(width: FinoraSpacing.sm),
          Text(
            currencySymbol,
            style: FinoraTextStyles.h2.copyWith(
              color: FinoraColors.brandPrimary,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: TextFormField(
              controller: controller,
              autofocus: autofocus,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              textInputAction: textInputAction,
              onFieldSubmitted: onSubmitted,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              style: FinoraTextStyles.h2,
              validator: validator,
              decoration: InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: FinoraSpacing.md,
                ),
                hintText: hint ?? '0.00',
                hintStyle: FinoraTextStyles.h2.copyWith(
                  color: FinoraColors.textMuted,
                ),
              ),
              onChanged: onChanged,
            ),
          ),
          const SizedBox(width: FinoraSpacing.md),
        ],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: FinoraTextStyles.label),
        const SizedBox(height: FinoraSpacing.xs),
        field,
        if (helper != null) ...[
          const SizedBox(height: FinoraSpacing.xs),
          Text(helper!, style: FinoraTextStyles.caption),
        ],
      ],
    );
  }
}
