import 'package:flutter/material.dart';
import '../theme/finora_theme.dart';

class FinoraSectionHeader extends StatelessWidget {
  const FinoraSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.action,
    this.icon,
    this.padding = const EdgeInsets.symmetric(horizontal: FinoraSpacing.lg),
  });

  final String title;
  final String? subtitle;
  final Widget? action;
  final IconData? icon;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: FinoraColors.brandPrimary),
            const SizedBox(width: FinoraSpacing.xs),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: FinoraTextStyles.h2),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle!, style: FinoraTextStyles.caption),
                ],
              ],
            ),
          ),
          if (action != null) action!,
        ],
      ),
    );
  }
}
