import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/finora_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/finora_app_bar.dart';
import '../../core/widgets/finora_financial_card.dart';
import '../../core/widgets/finora_health_ring.dart';
import '../../core/widgets/finora_icon_chip.dart';
import '../../core/widgets/finora_insight_card.dart';
import '../../core/widgets/finora_metric_card.dart';
import '../../core/widgets/finora_section_header.dart';
import '../../core/widgets/finora_status_badge.dart';
import '../../data/active_business_controller.dart';
import '../../data/repositories/financial_repository.dart';

final _healthProvider = FutureProvider.autoDispose<FinancialHealth>((
  ref,
) async {
  final state = ref.watch(activeBusinessControllerProvider);
  if (!state.hasBusiness) throw StateError('No active business');
  return ref.watch(financialRepositoryProvider).health();
});

class FinancialHealthScreen extends ConsumerWidget {
  const FinancialHealthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final health = ref.watch(_healthProvider);
    final currency = ref.watch(activeBusinessCurrencyProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const FinoraAppBar(
        title: 'Financial health',
        subtitle: 'Composite score and breakdowns',
        showBack: true,
      ),
      body: health.when(
        data: (h) => RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(_healthProvider);
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              FinoraSpacing.lg,
              FinoraSpacing.md,
              FinoraSpacing.lg,
              FinoraSpacing.xl,
            ),
            children: [
              _OverviewCard(health: h),
              const SizedBox(height: FinoraSpacing.lg),
              const FinoraSectionHeader(
                title: 'At a glance',
                subtitle: 'Monthly flow and runway',
              ),
              const SizedBox(height: FinoraSpacing.sm),
              _MetricGrid(health: h, currency: currency),
              const SizedBox(height: FinoraSpacing.lg),
              const FinoraSectionHeader(
                title: 'Score breakdown',
                subtitle: 'Each pillar of the composite score',
              ),
              const SizedBox(height: FinoraSpacing.sm),
              _BreakdownCard(health: h),
              if (h.recommendations.isNotEmpty) ...[
                const SizedBox(height: FinoraSpacing.lg),
                const FinoraSectionHeader(
                  title: 'Recommendations',
                  subtitle: 'Practical next steps',
                ),
                const SizedBox(height: FinoraSpacing.sm),
                for (final r in h.recommendations) ...[
                  FinoraInsightCard(
                    icon: Icons.tips_and_updates_rounded,
                    title: r,
                    tone: FinoraBadgeTone.brand,
                  ),
                  const SizedBox(height: FinoraSpacing.sm),
                ],
              ],
              if (h.alerts.isNotEmpty) ...[
                const SizedBox(height: FinoraSpacing.lg),
                const FinoraSectionHeader(
                  title: 'Alerts',
                  subtitle: 'Things to watch this week',
                ),
                const SizedBox(height: FinoraSpacing.sm),
                for (final a in h.alerts) ...[
                  FinoraInsightCard(
                    icon: Icons.warning_amber_rounded,
                    title: a,
                    tone: FinoraBadgeTone.negative,
                  ),
                  const SizedBox(height: FinoraSpacing.sm),
                ],
              ],
              const SizedBox(height: FinoraSpacing.lg),
              FinoraStatusBadge(
                label: 'Updated ${formatRelativeDate(DateTime.now())}',
                icon: Icons.schedule_rounded,
                tone: FinoraBadgeTone.neutral,
              ),
            ],
          ),
        ),
        loading: () => const _LoadingView(),
        error: (e, _) =>
            _ErrorView(onRetry: () => ref.invalidate(_healthProvider)),
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        width: 28,
        height: 28,
        child: CircularProgressIndicator(strokeWidth: 2.4),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(FinoraSpacing.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const FinoraIconChip(
            icon: Icons.error_outline_rounded,
            tone: FinoraBadgeTone.negative,
            size: 56,
          ),
          const SizedBox(height: FinoraSpacing.md),
          Text('Could not load health', style: FinoraTextStyles.title),
          const SizedBox(height: FinoraSpacing.xs),
          Text(
            'Pull to refresh or retry below.',
            style: FinoraTextStyles.caption,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: FinoraSpacing.lg),
          _GradientRetryButton(onPressed: onRetry),
        ],
      ),
    );
  }
}

class _GradientRetryButton extends StatelessWidget {
  const _GradientRetryButton({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        gradient: FinoraGradients.brand,
        borderRadius: BorderRadius.circular(FinoraRadii.md),
        boxShadow: FinoraShadows.brandGlow,
      ),
      alignment: Alignment.center,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(FinoraRadii.md),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: FinoraSpacing.lg,
              vertical: FinoraSpacing.sm,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.refresh_rounded,
                  size: 18,
                  color: Colors.white,
                ),
                const SizedBox(width: FinoraSpacing.xs),
                Text(
                  'Retry',
                  style: FinoraTextStyles.button.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({required this.health});
  final FinancialHealth health;

  @override
  Widget build(BuildContext context) {
    final tone = _toneForHealth(health.status);
    return FinoraFinancialCard(
      tone: FinoraCardTone.brand,
      padding: const EdgeInsets.all(FinoraSpacing.lg),
      child: Column(
        children: [
          FinoraHealthRing(
            score: health.overallScore,
            status: health.status,
            size: 180,
          ),
          const SizedBox(height: FinoraSpacing.md),
          FinoraStatusBadge(
            label: health.status,
            icon: Icons.health_and_safety_rounded,
            tone: tone,
          ),
          const SizedBox(height: FinoraSpacing.sm),
          Text(
            'Composite financial health score',
            style: FinoraTextStyles.caption,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _MetricGrid extends StatelessWidget {
  const _MetricGrid({required this.health, required this.currency});
  final FinancialHealth health;
  final String currency;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: FinoraMetricCard(
                label: 'Monthly revenue',
                value: formatMoney(health.monthlyRevenue, currency: currency),
                helper: 'Last 30 days',
                icon: Icons.trending_up_rounded,
                accentColor: FinoraColors.positive,
              ),
            ),
            const SizedBox(width: FinoraSpacing.sm),
            Expanded(
              child: FinoraMetricCard(
                label: 'Monthly expenses',
                value: formatMoney(health.monthlyExpenses, currency: currency),
                helper: 'Last 30 days',
                icon: Icons.trending_down_rounded,
                accentColor: FinoraColors.negative,
              ),
            ),
          ],
        ),
        const SizedBox(height: FinoraSpacing.sm),
        Row(
          children: [
            Expanded(
              child: FinoraMetricCard(
                label: 'Net cash flow',
                value: formatMoney(health.monthlyNet, currency: currency),
                helper: health.monthlyNet >= 0 ? 'Positive' : 'Negative',
                icon: Icons.swap_vert_rounded,
                accentColor: health.monthlyNet >= 0
                    ? FinoraColors.positive
                    : FinoraColors.negative,
              ),
            ),
            const SizedBox(width: FinoraSpacing.sm),
            Expanded(
              child: FinoraMetricCard(
                label: 'Cash buffer',
                value: '${health.cashBufferMonths.toStringAsFixed(1)} mo',
                helper: '${health.cashBufferWeeks.toStringAsFixed(1)} weeks',
                icon: Icons.savings_rounded,
                accentColor: FinoraColors.brandViolet,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _BreakdownCard extends StatelessWidget {
  const _BreakdownCard({required this.health});
  final FinancialHealth health;

  @override
  Widget build(BuildContext context) {
    final bars = [
      _ScoreBar(
        'Cash flow',
        health.cashFlowStabilityScore,
        FinoraColors.brandPrimary,
        Icons.water_drop_rounded,
      ),
      _ScoreBar(
        'Expense control',
        health.expenseControlScore,
        FinoraColors.brandAccent,
        Icons.tune_rounded,
      ),
      _ScoreBar(
        'Debt burden',
        health.debtBurdenScore,
        FinoraColors.info,
        Icons.account_balance_rounded,
      ),
      _ScoreBar(
        'Cash buffer',
        health.cashBufferScore,
        FinoraColors.warning,
        Icons.savings_rounded,
      ),
      _ScoreBar(
        'Revenue stability',
        health.revenueStabilityScore,
        FinoraColors.positive,
        Icons.show_chart_rounded,
      ),
    ];

    return FinoraFinancialCard(
      tone: FinoraCardTone.neutral,
      padding: const EdgeInsets.all(FinoraSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= bars.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            bars[index].label,
                            style: const TextStyle(
                              fontSize: 10,
                              color: FinoraColors.textSecondary,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                maxY: 100,
                minY: 0,
                barGroups: [
                  for (int i = 0; i < bars.length; i++)
                    BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: bars[i].score,
                          color: bars[i].color,
                          width: 22,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: FinoraSpacing.md),
          ...bars.map(
            (b) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: b.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(FinoraRadii.sm),
                    ),
                    alignment: Alignment.center,
                    child: Icon(b.icon, size: 16, color: b.color),
                  ),
                  const SizedBox(width: FinoraSpacing.sm),
                  Expanded(child: Text(b.label, style: FinoraTextStyles.body)),
                  Text(
                    b.score.toStringAsFixed(0),
                    style: FinoraTextStyles.label.copyWith(
                      color: FinoraColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreBar {
  _ScoreBar(this.label, this.score, this.color, this.icon);
  final String label;
  final double score;
  final Color color;
  final IconData icon;
}

FinoraBadgeTone _toneForHealth(String status) {
  switch (status.toLowerCase()) {
    case 'strong':
      return FinoraBadgeTone.positive;
    case 'healthy':
      return FinoraBadgeTone.brand;
    case 'fair':
      return FinoraBadgeTone.warning;
    case 'weak':
    case 'critical':
      return FinoraBadgeTone.negative;
    default:
      return FinoraBadgeTone.neutral;
  }
}
