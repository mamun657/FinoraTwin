import 'package:flutter/material.dart';
import '../theme/finora_theme.dart';

class FinoraSimulationResultCard extends StatelessWidget {
  const FinoraSimulationResultCard({
    super.key,
    required this.title,
    required this.probability,
    required this.recommendation,
    this.monthlyTarget,
    this.runwayMonths,
    this.gradient = FinoraGradients.brand,
    this.tone = FinoraBadgeTone.brand,
    this.icon,
  });

  final String title;
  final double probability;
  final String recommendation;
  final String? monthlyTarget;
  final double? runwayMonths;
  final Gradient gradient;
  final FinoraBadgeTone tone;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final pct = (probability * 100).clamp(0, 100).round();

    final decoration = BoxDecoration(
      gradient: gradient,
      borderRadius: BorderRadius.circular(FinoraRadii.lg),
      boxShadow: FinoraShadows.brandGlow,
    );

    return Container(
      decoration: decoration,
      padding: const EdgeInsets.all(FinoraSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.20),
                  borderRadius: BorderRadius.circular(FinoraRadii.md),
                ),
                alignment: Alignment.center,
                child: Icon(
                  icon ?? Icons.auto_graph_rounded,
                  size: 20,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: FinoraSpacing.md),
              Expanded(
                child: Text(
                  title,
                  style: FinoraTextStyles.h2.copyWith(color: Colors.white),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: FinoraSpacing.lg),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$pct%',
                style: FinoraTextStyles.display.copyWith(color: Colors.white),
              ),
              const SizedBox(width: FinoraSpacing.sm),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'success probability',
                  style: FinoraTextStyles.caption.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: FinoraSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(FinoraRadii.pill),
            child: LinearProgressIndicator(
              value: probability.clamp(0, 1).toDouble(),
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.20),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: FinoraSpacing.lg),
          Container(
            padding: const EdgeInsets.all(FinoraSpacing.md),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(FinoraRadii.md),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recommended next step',
                  style: FinoraTextStyles.overline.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  recommendation,
                  style: FinoraTextStyles.body.copyWith(
                    color: Colors.white,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          if (monthlyTarget != null || runwayMonths != null) ...[
            const SizedBox(height: FinoraSpacing.md),
            Row(
              children: [
                if (monthlyTarget != null)
                  Expanded(
                    child: _MetricChip(
                      label: 'Monthly target',
                      value: monthlyTarget!,
                    ),
                  ),
                if (monthlyTarget != null && runwayMonths != null)
                  const SizedBox(width: FinoraSpacing.sm),
                if (runwayMonths != null)
                  Expanded(
                    child: _MetricChip(
                      label: 'Runway',
                      value: '${runwayMonths!.toStringAsFixed(1)} mo',
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

class _MetricChip extends StatelessWidget {
  const _MetricChip({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(FinoraSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(FinoraRadii.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: FinoraTextStyles.overline.copyWith(
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: FinoraTextStyles.metricSmall.copyWith(color: Colors.white),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
