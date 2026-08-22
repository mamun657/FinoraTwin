import 'package:flutter/material.dart';
import '../theme/finora_theme.dart';

class FinoraStatusBadge extends StatelessWidget {
  const FinoraStatusBadge({
    super.key,
    required this.label,
    this.tone = FinoraBadgeTone.neutral,
    this.icon,
    this.compact = false,
  });

  final String label;
  final FinoraBadgeTone tone;
  final IconData? icon;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final bg = finoraBadgeBg(tone);
    final fg = finoraBadgeFg(tone);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? FinoraSpacing.sm : FinoraSpacing.md,
        vertical: compact ? 4 : FinoraSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(FinoraRadii.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: fg),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: compact ? 11 : 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}
