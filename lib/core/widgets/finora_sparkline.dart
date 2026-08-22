import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/finora_theme.dart';

class FinoraSparkline extends StatelessWidget {
  const FinoraSparkline({
    super.key,
    required this.points,
    required this.gradient,
    this.height = 64,
    this.fillOpacity = 0.18,
    this.strokeWidth = 2.4,
    this.showDots = false,
    this.smooth = true,
  });

  final List<double> points;
  final LinearGradient gradient;
  final double height;
  final double fillOpacity;
  final double strokeWidth;
  final bool showDots;
  final bool smooth;

  @override
  Widget build(BuildContext context) {
    if (points.length < 2) {
      return SizedBox(
        height: height,
        child: Center(
          child: Text(
            'Not enough data',
            style: FinoraTextStyles.caption.copyWith(
              color: FinoraColors.textMuted,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: height,
      child: CustomPaint(
        painter: _SparklinePainter(
          points: points,
          gradient: gradient,
          fillOpacity: fillOpacity,
          strokeWidth: strokeWidth,
          showDots: showDots,
          smooth: smooth,
        ),
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  _SparklinePainter({
    required this.points,
    required this.gradient,
    required this.fillOpacity,
    required this.strokeWidth,
    required this.showDots,
    required this.smooth,
  });

  final List<double> points;
  final LinearGradient gradient;
  final double fillOpacity;
  final double strokeWidth;
  final bool showDots;
  final bool smooth;

  @override
  void paint(Canvas canvas, Size size) {
    final maxV = points.reduce(math.max);
    final minV = points.reduce(math.min);
    final range = (maxV - minV).abs() < 0.0001 ? 1.0 : (maxV - minV);

    final stepX = size.width / (points.length - 1);

    final positions = <Offset>[];
    for (int i = 0; i < points.length; i++) {
      final x = i * stepX;
      final norm = (points[i] - minV) / range;
      final y = size.height - (norm * size.height);
      positions.add(Offset(x, y));
    }

    final path = Path();
    if (smooth && positions.length > 2) {
      path.moveTo(positions.first.dx, positions.first.dy);
      for (int i = 0; i < positions.length - 1; i++) {
        final p0 = positions[i];
        final p1 = positions[i + 1];
        final mid = Offset((p0.dx + p1.dx) / 2, (p0.dy + p1.dy) / 2);
        path.quadraticBezierTo(p0.dx, p0.dy, mid.dx, mid.dy);
      }
      path.lineTo(positions.last.dx, positions.last.dy);
    } else {
      path.moveTo(positions.first.dx, positions.first.dy);
      for (final p in positions.skip(1)) {
        path.lineTo(p.dx, p.dy);
      }
    }

    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    final fillPaint = Paint()
      ..shader = gradient.createShader(
        Rect.fromLTWH(0, 0, size.width, size.height),
      )
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    fillPaint.color = fillPaint.color.withValues(alpha: fillOpacity);

    canvas.drawPath(fillPath, fillPaint);

    final strokePaint = Paint()
      ..shader = gradient.createShader(
        Rect.fromLTWH(0, 0, size.width, size.height),
      )
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, strokePaint);

    if (showDots) {
      final dotPaint = Paint()..color = Colors.white;
      for (final p in positions) {
        canvas.drawCircle(p, 3.5, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) =>
      oldDelegate.points != points ||
      oldDelegate.gradient != gradient ||
      oldDelegate.fillOpacity != fillOpacity ||
      oldDelegate.strokeWidth != strokeWidth;
}

class FinoraBarChart extends StatelessWidget {
  const FinoraBarChart({
    super.key,
    required this.values,
    required this.labels,
    required this.gradient,
    this.height = 140,
    this.valueFormatter,
  });

  final List<double> values;
  final List<String> labels;
  final LinearGradient gradient;
  final double height;
  final String Function(double)? valueFormatter;

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) {
      return SizedBox(
        height: height,
        child: Center(
          child: Text(
            'No data',
            style: FinoraTextStyles.caption.copyWith(
              color: FinoraColors.textMuted,
            ),
          ),
        ),
      );
    }

    final maxV = values.reduce(math.max).abs();
    final minV = values.reduce(math.min);
    final range = (maxV - minV).abs() < 0.0001 ? 1.0 : (maxV - minV);

    return SizedBox(
      height: height + 28,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(values.length, (i) {
          final norm = ((values[i] - (minV < 0 ? minV : 0)) /
                  (range + (minV < 0 ? minV.abs() : 0)))
              .clamp(0.05, 1.0);
          final isNegative = values[i] < 0;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    height: height * norm,
                    decoration: BoxDecoration(
                      gradient: isNegative
                          ? FinoraGradients.danger
                          : gradient,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    labels[i],
                    style: FinoraTextStyles.caption.copyWith(
                      fontSize: 10,
                      color: FinoraColors.textMuted,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class FinoraPressureGauge extends StatelessWidget {
  const FinoraPressureGauge({
    super.key,
    required this.value,
    required this.label,
    this.size = 200,
    this.gradient = FinoraGradients.danger,
  });

  final double value;
  final String label;
  final double size;
  final LinearGradient gradient;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _GaugePainter(
          value: value.clamp(0.0, 1.0),
          gradient: gradient,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: FinoraTextStyles.overline.copyWith(
                  color: FinoraColors.textMuted,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${(value * 100).round()}',
                style: FinoraTextStyles.metric.copyWith(
                  color: FinoraColors.textPrimary,
                ),
              ),
              Text(
                'Pressure',
                style: FinoraTextStyles.caption.copyWith(
                  color: FinoraColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  _GaugePainter({required this.value, required this.gradient});
  final double value;
  final LinearGradient gradient;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = (size.shortestSide / 2) - 12;

    final track = Paint()
      ..color = FinoraColors.outlineSoft
      ..strokeWidth = 18
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const start = 3.14159 * 0.8;
    const sweep = 3.14159 * 1.4;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      start,
      sweep,
      false,
      track,
    );

    final progress = Paint()
      ..shader = gradient.createShader(rect)
      ..strokeWidth = 18
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      start,
      sweep * value,
      false,
      progress,
    );
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) =>
      oldDelegate.value != value || oldDelegate.gradient != gradient;
}