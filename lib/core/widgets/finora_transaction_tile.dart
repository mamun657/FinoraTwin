import 'package:flutter/material.dart';
import '../theme/finora_theme.dart';

class FinoraTransactionTile extends StatelessWidget {
  const FinoraTransactionTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.amount,
    this.amountPrefix = '',
    this.amountSuffix = '',
    this.icon,
    this.iconColor,
    this.iconBackground,
    this.onTap,
    this.emphasized = false,
  });

  final String title;
  final String subtitle;
  final String amount;
  final String amountPrefix;
  final String amountSuffix;
  final IconData? icon;
  final Color? iconColor;
  final Color? iconBackground;
  final VoidCallback? onTap;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final positiveColor = FinoraColors.positive;
    final isPositive =
        amountPrefix == '+' ||
        emphasized == false && amountPrefix.isEmpty && amount.startsWith('+');
    final color = isPositive ? positiveColor : FinoraColors.textPrimary;

    final iconBg = iconBackground ?? FinoraColors.brandPrimarySoft;
    final iconFg = iconColor ?? FinoraColors.brandPrimary;

    final leading = Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: iconBg,
        borderRadius: BorderRadius.circular(FinoraRadii.md),
      ),
      alignment: Alignment.center,
      child: Icon(icon ?? Icons.receipt_long_rounded, size: 22, color: iconFg),
    );

    final body = Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: FinoraSpacing.lg,
        vertical: FinoraSpacing.md,
      ),
      child: Row(
        children: [
          leading,
          const SizedBox(width: FinoraSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: FinoraTextStyles.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: FinoraTextStyles.caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: FinoraSpacing.sm),
          Text(
            '$amountPrefix$amount$amountSuffix',
            style: FinoraTextStyles.metricSmall.copyWith(color: color),
          ),
        ],
      ),
    );

    final tile = AnimatedContainer(
      duration: FinoraMotion.fast,
      decoration: BoxDecoration(
        color: FinoraColors.surfaceAlt,
        borderRadius: BorderRadius.circular(FinoraRadii.lg),
        border: Border.all(
          color: FinoraColors.outline.withValues(alpha: 0.6),
          width: 1,
        ),
      ),
      child: body,
    );

    if (onTap == null) return tile;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(FinoraRadii.lg),
        child: tile,
      ),
    );
  }
}
