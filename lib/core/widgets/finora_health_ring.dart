import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/finora_theme.dart';

class FinoraHealthRing extends StatelessWidget {
  const FinoraHealthRing({
    super.key,
    required this.score,
    required this.status,
    this.size = 160,
    this.label = 'Financial health',
  });

  final double score;
  final String status;
  final double size;
  final String label;

  @override
  Widget build(BuildContext context) {
    final color = healthColorFor(status);
    final clamped = score.clamp(0.0, 100.0);
    final pct = clamped / 100.0;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CustomPaint(
              painter: _RingPainter(
                progress: pct,
                color: color,
                trackColor: FinoraColors.outlineSoft,
                stroke: 14,
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                clamped.round().toString(),
                style: FinoraTextStyles.display.copyWith(
                  color: FinoraColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                status[0].toUpperCase() + status.substring(1),
                style: FinoraTextStyles.overline.copyWith(color: color),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.color,
    required this.trackColor,
    required this.stroke,
  });

  final double progress;
  final Color color;
  final Color trackColor;
  final double stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = math.min(size.width, size.height) / 2 - stroke / 2;

    final trackPaint = Paint()
      ..color = trackColor
      ..strokeWidth = stroke
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);

    if (progress <= 0) return;

    final progressPaint = Paint()
      ..shader = SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: -math.pi / 2 + 2 * math.pi,
        colors: [color.withValues(alpha: 0.6), color],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..strokeWidth = stroke
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.progress != progress ||
      old.color != color ||
      old.trackColor != trackColor;
}
