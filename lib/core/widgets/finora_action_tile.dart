import 'package:flutter/material.dart';
import '../theme/finora_theme.dart';

class FinoraActionTile extends StatelessWidget {
  const FinoraActionTile({
    super.key,
    required this.label,
    required this.icon,
    this.tone = FinoraBadgeTone.brand,
    this.onTap,
    this.compact = false,
  });

  final String label;
  final IconData icon;
  final FinoraBadgeTone tone;
  final VoidCallback? onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final bg = finoraBadgeBg(tone);
    final fg = finoraBadgeFg(tone);

    final decoration = BoxDecoration(
      color: FinoraColors.surfaceAlt,
      borderRadius: BorderRadius.circular(FinoraRadii.lg),
      border: Border.all(
        color: FinoraColors.outline.withValues(alpha: 0.6),
        width: 1,
      ),
    );

    if (compact) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(FinoraRadii.lg),
          child: AnimatedContainer(
            duration: FinoraMotion.fast,
            decoration: decoration,
            padding: const EdgeInsets.symmetric(
              horizontal: FinoraSpacing.xs,
              vertical: FinoraSpacing.sm,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(FinoraRadii.md),
                  ),
                  alignment: Alignment.center,
                  child: Icon(icon, size: 20, color: fg),
                ),
                const SizedBox(height: FinoraSpacing.xs),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: FinoraTextStyles.caption.copyWith(
                    color: FinoraColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(FinoraRadii.lg),
        child: AnimatedContainer(
          duration: FinoraMotion.fast,
          decoration: decoration,
          padding: const EdgeInsets.symmetric(
            horizontal: FinoraSpacing.md,
            vertical: FinoraSpacing.md,
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(FinoraRadii.md),
                ),
                alignment: Alignment.center,
                child: Icon(icon, size: 18, color: fg),
              ),
              const SizedBox(width: FinoraSpacing.sm),
              Expanded(
                child: Text(
                  label,
                  style: FinoraTextStyles.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: FinoraColors.textMuted,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
