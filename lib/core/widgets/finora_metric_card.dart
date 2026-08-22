import 'package:flutter/material.dart';
import '../theme/finora_theme.dart';

class FinoraMetricCard extends StatelessWidget {
  const FinoraMetricCard({
    super.key,
    required this.label,
    required this.value,
    this.helper,
    this.icon,
    this.accentColor,
    this.gradient,
    this.onTap,
    this.compact = false,
  });

  final String label;
  final String value;
  final String? helper;
  final IconData? icon;
  final Color? accentColor;
  final Gradient? gradient;
  final VoidCallback? onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final accent = accentColor ?? FinoraColors.brandPrimary;
    final isHero = gradient != null;

    final inner = Padding(
      padding: EdgeInsets.symmetric(
        horizontal: FinoraSpacing.lg,
        vertical: compact ? FinoraSpacing.md : FinoraSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null)
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: compact ? 28 : 32,
                height: compact ? 28 : 32,
                decoration: BoxDecoration(
                  color: isHero
                      ? Colors.white.withValues(alpha: 0.18)
                      : accent.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(FinoraRadii.sm),
                ),
                alignment: Alignment.center,
                child: Icon(
                  icon,
                  size: compact ? 16 : 18,
                  color: isHero ? Colors.white : accent,
                ),
              ),
            ),
          const SizedBox(height: FinoraSpacing.xs),
          Text(
            label,
            style: FinoraTextStyles.caption.copyWith(
              color: isHero
                  ? Colors.white.withValues(alpha: 0.85)
                  : FinoraColors.textSecondary,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
            maxLines: 2,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: compact ? FinoraSpacing.xs : FinoraSpacing.sm),
          compact
              ? FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    style: FinoraTextStyles.metricSmall.copyWith(
                      color: isHero ? Colors.white : FinoraColors.textPrimary,
                    ),
                    maxLines: 1,
                    softWrap: false,
                  ),
                )
              : Text(
                  value,
                  style: FinoraTextStyles.metric.copyWith(
                    color: isHero ? Colors.white : FinoraColors.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
          if (helper != null) ...[
            const SizedBox(height: 4),
            Text(
              helper!,
              style: FinoraTextStyles.caption.copyWith(
                color: isHero
                    ? Colors.white.withValues(alpha: 0.85)
                    : FinoraColors.textSecondary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );

    final decoration = BoxDecoration(
      gradient: gradient,
      color: gradient == null ? FinoraColors.surfaceAlt : null,
      borderRadius: BorderRadius.circular(FinoraRadii.lg),
      border: gradient == null
          ? Border.all(
              color: FinoraColors.outline.withValues(alpha: 0.6),
              width: 1,
            )
          : null,
      boxShadow: gradient != null ? FinoraShadows.brandGlow : FinoraShadows.xs,
    );

    final card = AnimatedContainer(
      duration: FinoraMotion.fast,
      decoration: decoration,
      child: inner,
    );

    if (onTap == null) return card;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(FinoraRadii.lg),
        child: card,
      ),
    );
  }
}
