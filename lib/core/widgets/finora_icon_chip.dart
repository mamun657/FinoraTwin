import 'package:flutter/material.dart';
import '../theme/finora_theme.dart';

class FinoraIconChip extends StatelessWidget {
  const FinoraIconChip({
    super.key,
    required this.icon,
    this.tone = FinoraBadgeTone.brand,
    this.size = 36,
  });

  final IconData icon;
  final FinoraBadgeTone tone;
  final double size;

  @override
  Widget build(BuildContext context) {
    final bg = finoraBadgeBg(tone);
    final fg = finoraBadgeFg(tone);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(FinoraRadii.md),
      ),
      alignment: Alignment.center,
      child: Icon(icon, size: size * 0.55, color: fg),
    );
  }
}
