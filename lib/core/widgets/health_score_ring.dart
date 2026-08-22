import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/finora_theme.dart';

class HealthScoreRing extends StatelessWidget {
  const HealthScoreRing({
    super.key,
    required this.score,
    required this.color,
    this.size = 132,
    this.strokeWidth = 12,
    this.label,
  });

  final double score;
  final Color color;
  final double size;
  final double strokeWidth;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final pct = (score.clamp(0, 100)) / 100;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(
          progress: pct,
          color: color,
          strokeWidth: strokeWidth,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                score.toStringAsFixed(0),
                style: TextStyle(
                  fontSize: size * 0.28,
                  fontWeight: FontWeight.w700,
                  color: FinoraColors.textPrimary,
                ),
              ),
              if (label != null)
                Text(
                  label!,
                  style: const TextStyle(
                    color: FinoraColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  final double progress;
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = (size.shortestSide - strokeWidth) / 2;
    final center = Offset(size.width / 2, size.height / 2);
    final bg = Paint()
      ..color = color.withValues(alpha: 0.15)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final fg = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bg);
    final sweep = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweep,
      false,
      fg,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.progress != progress ||
      old.color != color ||
      old.strokeWidth != strokeWidth;
}
