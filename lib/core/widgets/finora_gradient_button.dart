import 'package:flutter/material.dart';
import '../theme/finora_theme.dart';

class FinoraGradientButton extends StatelessWidget {
  const FinoraGradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.loading = false,
    this.fullWidth = true,
    this.gradient,
    this.height = 52,
    this.compact = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;
  final bool fullWidth;
  final Gradient? gradient;
  final double height;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final disabled = loading || onPressed == null;
    final g = gradient ?? FinoraGradients.brand;

    final child = loading
        ? const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.4,
              valueColor: AlwaysStoppedAnimation(Colors.white),
            ),
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: Colors.white),
                const SizedBox(width: FinoraSpacing.xs),
              ],
              Text(
                label,
                style: FinoraTextStyles.button.copyWith(
                  fontSize: compact ? 14 : 15,
                ),
              ),
            ],
          );

    final box = AnimatedContainer(
      duration: FinoraMotion.fast,
      height: height,
      decoration: BoxDecoration(
        gradient: disabled
            ? LinearGradient(
                colors: [
                  g.colors.first.withValues(alpha: 0.5),
                  g.colors.last.withValues(alpha: 0.5),
                ],
              )
            : g,
        borderRadius: BorderRadius.circular(FinoraRadii.md),
        boxShadow: disabled ? const [] : FinoraShadows.brandGlow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: disabled ? null : onPressed,
          borderRadius: BorderRadius.circular(FinoraRadii.md),
          child: Center(child: child),
        ),
      ),
    );

    return fullWidth ? SizedBox(width: double.infinity, child: box) : box;
  }
}

class FinoraOutlinedButton extends StatelessWidget {
  const FinoraOutlinedButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.loading = false,
    this.fullWidth = true,
    this.tone = FinoraBadgeTone.brand,
    this.height = 52,
    this.compact = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;
  final bool fullWidth;
  final FinoraBadgeTone tone;
  final double height;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final disabled = loading || onPressed == null;
    final fg = switch (tone) {
      FinoraBadgeTone.brand => FinoraColors.brandPrimary,
      FinoraBadgeTone.positive => FinoraColors.positive,
      FinoraBadgeTone.warning => FinoraColors.warning,
      FinoraBadgeTone.negative => FinoraColors.negative,
      FinoraBadgeTone.info => FinoraColors.info,
      FinoraBadgeTone.neutral => FinoraColors.textPrimary,
    };

    final child = loading
        ? SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.4,
              valueColor: AlwaysStoppedAnimation(fg),
            ),
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: fg),
                const SizedBox(width: FinoraSpacing.xs),
              ],
              Text(
                label,
                style: FinoraTextStyles.button.copyWith(
                  fontSize: compact ? 14 : 15,
                  color: fg,
                ),
              ),
            ],
          );

    final box = AnimatedContainer(
      duration: FinoraMotion.fast,
      height: height,
      decoration: BoxDecoration(
        color: FinoraColors.surfaceAlt,
        borderRadius: BorderRadius.circular(FinoraRadii.md),
        border: Border.all(color: fg.withValues(alpha: 0.45), width: 1.2),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: disabled ? null : onPressed,
          borderRadius: BorderRadius.circular(FinoraRadii.md),
          child: Center(child: child),
        ),
      ),
    );

    return fullWidth ? SizedBox(width: double.infinity, child: box) : box;
  }
}

class FinoraTextButton extends StatelessWidget {
  const FinoraTextButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.color,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final Color? color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final fg = color ?? FinoraColors.brandPrimary;
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: fg,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: fg),
            const SizedBox(width: 6),
          ],
          Text(label, style: FinoraTextStyles.label.copyWith(color: fg)),
        ],
      ),
    );
  }
}
