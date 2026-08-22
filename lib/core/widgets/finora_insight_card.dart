import 'package:flutter/material.dart';
import '../theme/finora_theme.dart';

class FinoraInsightCard extends StatelessWidget {
  const FinoraInsightCard({
    super.key,
    required this.title,
    this.description,
    this.icon,
    this.tone = FinoraBadgeTone.brand,
    this.action,
    this.onTap,
    this.padding = const EdgeInsets.all(FinoraSpacing.lg),
  });

  final String title;
  final String? description;
  final IconData? icon;
  final FinoraBadgeTone tone;
  final Widget? action;
  final VoidCallback? onTap;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final bg = finoraBadgeBg(tone);
    final fg = finoraBadgeFg(tone);

    final decoration = BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(FinoraRadii.lg),
      border: Border.all(color: fg.withValues(alpha: 0.18), width: 1),
    );

    final iconBox = Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: fg.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(FinoraRadii.md),
      ),
      alignment: Alignment.center,
      child: Icon(icon ?? Icons.lightbulb_rounded, size: 20, color: fg),
    );

    final inner = Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          iconBox,
          const SizedBox(width: FinoraSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: FinoraTextStyles.label.copyWith(color: fg),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (description != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    description!,
                    style: FinoraTextStyles.caption.copyWith(
                      color: fg.withValues(alpha: 0.85),
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (action != null) ...[
                  const SizedBox(height: FinoraSpacing.sm),
                  Align(alignment: Alignment.centerLeft, child: action!),
                ],
              ],
            ),
          ),
        ],
      ),
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
