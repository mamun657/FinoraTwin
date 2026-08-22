import 'package:flutter/material.dart';

import '../theme/finora_theme.dart';

class AppPrimaryButton extends StatelessWidget {
  const AppPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.loading = false,
    this.fullWidth = true,
    this.gradient,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;
  final bool fullWidth;
  final LinearGradient? gradient;

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
            mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18),
                const SizedBox(width: 8),
              ],
              Text(label),
            ],
          );

    return SizedBox(
      width: fullWidth ? double.infinity : null,
      child: Opacity(
        opacity: disabled ? 0.7 : 1,
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            gradient: g,
            borderRadius: BorderRadius.circular(FinoraRadii.md),
            boxShadow: disabled ? const [] : FinoraShadows.brandGlow,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(FinoraRadii.md),
              onTap: disabled ? null : onPressed,
              child: Center(child: child),
            ),
          ),
        ),
      ),
    );
  }
}

class AppSecondaryButton extends StatelessWidget {
  const AppSecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.loading = false,
    this.fullWidth = true,
    this.tone = AppButtonTone.brand,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;
  final bool fullWidth;
  final AppButtonTone tone;

  @override
  Widget build(BuildContext context) {
    final disabled = loading || onPressed == null;
    final fg = switch (tone) {
      AppButtonTone.brand => FinoraColors.brandPrimary,
      AppButtonTone.danger => FinoraColors.negative,
      AppButtonTone.neutral => FinoraColors.textPrimary,
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
            mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18),
                const SizedBox(width: 8),
              ],
              Text(label),
            ],
          );

    return SizedBox(
      width: fullWidth ? double.infinity : null,
      child: Opacity(
        opacity: disabled ? 0.7 : 1,
        child: OutlinedButton(
          onPressed: disabled ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: fg,
            side: BorderSide(color: fg.withValues(alpha: 0.45)),
          ),
          child: child,
        ),
      ),
    );
  }
}

enum AppButtonTone { brand, danger, neutral }
