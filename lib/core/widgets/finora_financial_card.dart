import 'package:flutter/material.dart';
import '../theme/finora_theme.dart';

class FinoraFinancialCard extends StatelessWidget {
  const FinoraFinancialCard({
    super.key,
    this.title,
    this.subtitle,
    required this.child,
    this.trailing,
    this.onTap,
    this.padding = const EdgeInsets.all(FinoraSpacing.lg),
    this.tone = FinoraCardTone.neutral,
  });

  final String? title;
  final String? subtitle;
  final Widget child;
  final Widget? trailing;
  final VoidCallback? onTap;
  final EdgeInsets padding;
  final FinoraCardTone tone;

  Color _bg(BuildContext context) {
    switch (tone) {
      case FinoraCardTone.brand:
        return FinoraColors.brandPrimarySoft;
      case FinoraCardTone.positive:
        return FinoraColors.positiveSoft;
      case FinoraCardTone.warning:
        return FinoraColors.warningSoft;
      case FinoraCardTone.negative:
        return FinoraColors.negativeSoft;
      case FinoraCardTone.neutral:
        return FinoraColors.surfaceAlt;
    }
  }

  Color _border() {
    switch (tone) {
      case FinoraCardTone.brand:
        return FinoraColors.brandPrimary.withValues(alpha: 0.18);
      case FinoraCardTone.positive:
        return FinoraColors.positive.withValues(alpha: 0.18);
      case FinoraCardTone.warning:
        return FinoraColors.warning.withValues(alpha: 0.20);
      case FinoraCardTone.negative:
        return FinoraColors.negative.withValues(alpha: 0.18);
      case FinoraCardTone.neutral:
        return FinoraColors.outline.withValues(alpha: 0.6);
    }
  }

  @override
  Widget build(BuildContext context) {
    final decoration = BoxDecoration(
      color: _bg(context),
      borderRadius: BorderRadius.circular(FinoraRadii.lg),
      border: Border.all(color: _border(), width: 1),
      boxShadow: FinoraShadows.xs,
    );

    final header = title == null && subtitle == null
        ? null
        : Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (title != null) Text(title!, style: FinoraTextStyles.h4),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(subtitle!, style: FinoraTextStyles.caption),
                    ],
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          );

    final content = Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (header != null) ...[
            header,
            const SizedBox(height: FinoraSpacing.sm),
          ],
          child,
        ],
      ),
    );

    final card = AnimatedContainer(
      duration: FinoraMotion.fast,
      decoration: decoration,
      child: content,
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

enum FinoraCardTone { neutral, brand, positive, warning, negative }
