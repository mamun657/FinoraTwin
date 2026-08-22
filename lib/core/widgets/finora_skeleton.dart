import 'package:flutter/material.dart';
import '../theme/finora_theme.dart';

class FinoraSkeleton extends StatefulWidget {
  const FinoraSkeleton({
    super.key,
    this.width,
    this.height = 16,
    this.radius = FinoraRadii.sm,
  });

  final double? width;
  final double height;
  final double radius;

  @override
  State<FinoraSkeleton> createState() => _FinoraSkeletonState();
}

class _FinoraSkeletonState extends State<FinoraSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        final t = 0.45 + (_ctrl.value * 0.35);
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: FinoraColors.outlineSoft.withValues(alpha: t),
            borderRadius: BorderRadius.circular(widget.radius),
          ),
        );
      },
    );
  }
}
