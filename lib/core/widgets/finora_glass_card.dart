import 'package:flutter/material.dart';
import '../theme/finora_theme.dart';

class FinoraGlassCard extends StatelessWidget {
  const FinoraGlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(FinoraSpacing.lg),
    this.margin = EdgeInsets.zero,
    this.gradient,
    this.borderRadius,
    this.borderColor,
    this.shadow,
    this.tint = Colors.white,
    this.tintOpacity = 0.92,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final Gradient? gradient;
  final BorderRadius? borderRadius;
  final Color? borderColor;
  final List<BoxShadow>? shadow;
  final Color tint;
  final double tintOpacity;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(FinoraRadii.xl);
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        gradient: gradient,
        color: gradient == null ? tint.withValues(alpha: tintOpacity) : null,
        borderRadius: radius,
        border: Border.all(
          color: borderColor ?? FinoraColors.outline.withValues(alpha: 0.5),
          width: 1,
        ),
        boxShadow: shadow ?? FinoraShadows.xs,
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

class FinoraFeatureTile extends StatelessWidget {
  const FinoraFeatureTile({
    super.key,
    required this.title,
    required this.icon,
    required this.gradient,
    this.subtitle,
    this.badge,
    this.onTap,
  });

  final String title;
  final String? subtitle;
  final IconData icon;
  final LinearGradient gradient;
  final String? badge;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(FinoraRadii.lg),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(FinoraRadii.lg),
            boxShadow: FinoraShadows.sm,
          ),
          child: Padding(
            padding: const EdgeInsets.all(FinoraSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(FinoraRadii.md),
                  ),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (badge != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(
                            FinoraRadii.pill,
                          ),
                        ),
                        child: Text(
                          badge!,
                          style: FinoraTextStyles.caption.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                    Text(
                      title,
                      style: FinoraTextStyles.h4.copyWith(color: Colors.white),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: FinoraTextStyles.caption.copyWith(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 11,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FinoraStatTile extends StatelessWidget {
  const FinoraStatTile({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.gradient,
    this.delta,
    this.deltaTone = FinoraBadgeTone.positive,
  });

  final String label;
  final String value;
  final IconData icon;
  final LinearGradient gradient;
  final String? delta;
  final FinoraBadgeTone deltaTone;

  @override
  Widget build(BuildContext context) {
    return FinoraGlassCard(
      padding: const EdgeInsets.all(FinoraSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(FinoraRadii.sm),
            ),
            child: Icon(icon, size: 18, color: Colors.white),
          ),
          const SizedBox(height: FinoraSpacing.sm),
          Text(
            label,
            style: FinoraTextStyles.caption.copyWith(
              color: FinoraColors.textSecondary,
            ),
          ),
          const SizedBox(height: 2),
          Text(value, style: FinoraTextStyles.metricSmall),
          if (delta != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  deltaTone == FinoraBadgeTone.positive
                      ? Icons.arrow_drop_up_rounded
                      : Icons.arrow_drop_down_rounded,
                  size: 18,
                  color: finoraBadgeFg(deltaTone),
                ),
                Text(
                  delta!,
                  style: FinoraTextStyles.caption.copyWith(
                    color: finoraBadgeFg(deltaTone),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class FinoraProgressRing extends StatelessWidget {
  const FinoraProgressRing({
    super.key,
    required this.value,
    required this.gradient,
    this.size = 64,
    this.strokeWidth = 7,
    this.trackColor,
    this.label,
    this.labelStyle,
  });

  final double value;
  final LinearGradient gradient;
  final double size;
  final double strokeWidth;
  final Color? trackColor;
  final String? label;
  final TextStyle? labelStyle;

  @override
  Widget build(BuildContext context) {
    final clamped = value.clamp(0.0, 1.0);
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(
          progress: clamped,
          gradient: gradient,
          strokeWidth: strokeWidth,
          trackColor: trackColor ?? FinoraColors.outlineSoft,
        ),
        child: Center(
          child: label != null
              ? Text(label!, style: labelStyle ?? FinoraTextStyles.label)
              : null,
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.gradient,
    required this.strokeWidth,
    required this.trackColor,
  });

  final double progress;
  final LinearGradient gradient;
  final double strokeWidth;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = (size.shortestSide - strokeWidth) / 2;

    final track = Paint()
      ..color = trackColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, track);

    if (progress <= 0) return;

    final progressPaint = Paint()
      ..shader = gradient.createShader(rect)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -1.5708,
      progress * 6.2831853,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.gradient != gradient ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.trackColor != trackColor;
}

class FinoraListTile extends StatelessWidget {
  const FinoraListTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.icon,
    this.trailing,
    this.onTap,
    this.statusLabel,
    this.statusTone = FinoraBadgeTone.positive,
  });

  final String title;
  final String subtitle;
  final LinearGradient gradient;
  final IconData icon;
  final Widget? trailing;
  final VoidCallback? onTap;
  final String? statusLabel;
  final FinoraBadgeTone statusTone;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(FinoraRadii.lg),
        onTap: onTap,
        child: FinoraGlassCard(
          padding: const EdgeInsets.all(FinoraSpacing.md),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(FinoraRadii.md),
                ),
                child: Icon(icon, color: Colors.white, size: 22),
              ),
              const SizedBox(width: FinoraSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(title, style: FinoraTextStyles.h4),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: FinoraTextStyles.caption.copyWith(
                        color: FinoraColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (statusLabel != null) ...[
                const SizedBox(width: FinoraSpacing.xs),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: FinoraSpacing.sm,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: finoraBadgeBg(statusTone),
                    borderRadius: BorderRadius.circular(FinoraRadii.pill),
                  ),
                  child: Text(
                    statusLabel!,
                    style: FinoraTextStyles.caption.copyWith(
                      color: finoraBadgeFg(statusTone),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
              if (trailing != null) trailing!,
            ],
          ),
        ),
      ),
    );
  }
}

class FinoraScoreBar extends StatelessWidget {
  const FinoraScoreBar({
    super.key,
    required this.label,
    required this.value,
    required this.gradient,
    this.helper,
  });

  final String label;
  final double value;
  final LinearGradient gradient;
  final String? helper;

  @override
  Widget build(BuildContext context) {
    final pct = (value * 100).clamp(0.0, 100.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(child: Text(label, style: FinoraTextStyles.label)),
            Text(
              '${pct.toStringAsFixed(0)}%',
              style: FinoraTextStyles.label.copyWith(
                color: FinoraColors.textPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(FinoraRadii.pill),
          child: Stack(
            children: [
              Container(
                height: 10,
                color: FinoraColors.outlineSoft,
              ),
              FractionallySizedBox(
                widthFactor: (value.clamp(0.0, 1.0)),
                child: Container(
                  height: 10,
                  decoration: BoxDecoration(gradient: gradient),
                ),
              ),
            ],
          ),
        ),
        if (helper != null) ...[
          const SizedBox(height: 4),
          Text(
            helper!,
            style: FinoraTextStyles.caption.copyWith(
              color: FinoraColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}

class FinoraMetricPill extends StatelessWidget {
  const FinoraMetricPill({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.tone = FinoraBadgeTone.brand,
  });

  final String label;
  final String value;
  final IconData icon;
  final FinoraBadgeTone tone;

  @override
  Widget build(BuildContext context) {
    final fg = finoraBadgeFg(tone);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: FinoraSpacing.md,
        vertical: FinoraSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: finoraBadgeBg(tone),
        borderRadius: BorderRadius.circular(FinoraRadii.lg),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: fg),
          const SizedBox(width: 6),
          Text(
            value,
            style: FinoraTextStyles.label.copyWith(
              color: fg,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: FinoraTextStyles.caption.copyWith(color: fg),
          ),
        ],
      ),
    );
  }
}