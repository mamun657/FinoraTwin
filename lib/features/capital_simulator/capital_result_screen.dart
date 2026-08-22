import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/finora_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/finora_app_bar.dart';
import '../../core/widgets/finora_financial_card.dart';
import '../../core/widgets/finora_gradient_button.dart';
import '../../core/widgets/finora_icon_chip.dart';
import '../../core/widgets/finora_metric_card.dart';
import '../../core/widgets/finora_section_header.dart';
import '../../core/widgets/finora_status_badge.dart';
import '../../data/repositories/capital_repository.dart';

final _simulationProvider = FutureProvider.autoDispose
    .family<SimulationResult, ({double amount, int term, double rate})>((
      ref,
      args,
    ) async {
      final repo = ref.watch(capitalRepositoryProvider);
      return repo.simulate(
        requestedAmount: args.amount,
        termMonths: args.term,
        annualInterestRate: args.rate,
      );
    });

class CapitalResultScreen extends ConsumerWidget {
  const CapitalResultScreen({
    super.key,
    required this.requestedAmount,
    required this.termMonths,
    required this.annualRate,
  });

  final double requestedAmount;
  final int termMonths;
  final double annualRate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final args = (amount: requestedAmount, term: termMonths, rate: annualRate);
    final async = ref.watch(_simulationProvider(args));

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: FinoraAppBar(
        title: 'Simulation result',
        subtitle:
            '${formatMoney(requestedAmount, currency: 'USD')} · $termMonths mo · ${annualRate.toStringAsFixed(1)}%',
        showBack: true,
      ),
      body: async.when(
        data: (result) => _ResultBody(result: result),
        loading: () => const _LoadingView(),
        error: (e, _) => _ErrorView(
          onRetry: () => ref.invalidate(_simulationProvider(args)),
        ),
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
          Text('Could not run the simulation', style: FinoraTextStyles.title),
          const SizedBox(height: FinoraSpacing.xs),
          Text(
            'Check your connection and try again.',
            style: FinoraTextStyles.caption,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: FinoraSpacing.lg),
          FinoraGradientButton(
            label: 'Retry',
            icon: Icons.refresh_rounded,
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }
}

class _ResultBody extends StatelessWidget {
  const _ResultBody({required this.result});
  final SimulationResult result;

  @override
  Widget build(BuildContext context) {
    final riskColor = riskColorFor(result.riskLevel);
    final riskTone = _toneForRisk(result.riskLevel);
    final requested = formatMoney(
      result.requestedAmount,
      currency: result.currency,
    );
    final recommended = formatMoney(
      result.recommendedAmount,
      currency: result.currency,
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        FinoraSpacing.lg,
        FinoraSpacing.md,
        FinoraSpacing.lg,
        FinoraSpacing.xl,
      ),
      children: [
        _HeroCard(
          result: result,
          riskColor: riskColor,
          riskTone: riskTone,
          recommended: recommended,
        ),
        const SizedBox(height: FinoraSpacing.lg),
        const FinoraSectionHeader(
          title: 'At a glance',
          subtitle: 'Monthly load and capacity',
        ),
        const SizedBox(height: FinoraSpacing.sm),
        _MetricGrid(result: result),
        const SizedBox(height: FinoraSpacing.lg),
        const FinoraSectionHeader(
          title: 'Advisor notes',
          subtitle: 'Why this recommendation',
        ),
        const SizedBox(height: FinoraSpacing.sm),
        if (result.notes.isEmpty)
          _EmptyNotesCard()
        else
          _NotesCard(notes: result.notes),
        if (result.scenarios.isNotEmpty) ...[
          const SizedBox(height: FinoraSpacing.lg),
          const FinoraSectionHeader(
            title: 'Scenarios',
            subtitle: 'Different sales change assumptions',
          ),
          const SizedBox(height: FinoraSpacing.sm),
          _ScenariosCard(scenarios: result.scenarios),
        ],
        const SizedBox(height: FinoraSpacing.lg),
        const FinoraSectionHeader(
          title: 'Stress test',
          subtitle: 'What a downturn could look like',
        ),
        const SizedBox(height: FinoraSpacing.sm),
        _StressTestCard(result: result),
        const SizedBox(height: FinoraSpacing.lg),
        FinoraGradientButton(
          label: 'Ask AI to refine this',
          icon: Icons.smart_toy_outlined,
          onPressed: () => context.go('/ai-copilot'),
        ),
        const SizedBox(height: FinoraSpacing.sm),
        FinoraOutlinedButton(
          label: 'Run another simulation',
          icon: Icons.refresh_rounded,
          onPressed: () => context.go('/capital-simulator'),
        ),
        const SizedBox(height: FinoraSpacing.md),
        Text(
          'Requested $requested · Based on live business data',
          style: FinoraTextStyles.caption,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.result,
    required this.riskColor,
    required this.riskTone,
    required this.recommended,
  });

  final SimulationResult result;
  final Color riskColor;
  final FinoraBadgeTone riskTone;
  final String recommended;

  @override
  Widget build(BuildContext context) {
    return FinoraFinancialCard(
      tone: FinoraCardTone.brand,
      padding: const EdgeInsets.all(FinoraSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              FinoraIconChip(
                icon: Icons.auto_graph_rounded,
                tone: FinoraBadgeTone.brand,
                size: 44,
              ),
              const SizedBox(width: FinoraSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Loan readiness',
                      style: FinoraTextStyles.overline.copyWith(
                        color: FinoraColors.brandPrimaryDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Recommended for your business',
                      style: FinoraTextStyles.caption,
                    ),
                  ],
                ),
              ),
              FinoraStatusBadge(
                label: '${result.riskLevel} risk',
                icon: riskIconFor(result.riskLevel),
                tone: riskTone,
              ),
            ],
          ),
          const SizedBox(height: FinoraSpacing.lg),
          Text(
            'Recommended amount',
            style: FinoraTextStyles.overline.copyWith(
              color: FinoraColors.brandPrimaryDark,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            recommended,
            style: FinoraTextStyles.display.copyWith(
              color: FinoraColors.brandPrimaryDark,
            ),
          ),
          const SizedBox(height: FinoraSpacing.sm),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Requested', style: FinoraTextStyles.caption),
                    const SizedBox(height: 2),
                    Text(
                      formatMoney(
                        result.requestedAmount,
                        currency: result.currency,
                      ),
                      style: FinoraTextStyles.label,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Risk score', style: FinoraTextStyles.caption),
                    const SizedBox(height: 2),
                    Text(
                      result.riskScore.toStringAsFixed(0),
                      style: FinoraTextStyles.label.copyWith(color: riskColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricGrid extends StatelessWidget {
  const _MetricGrid({required this.result});
  final SimulationResult result;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: FinoraMetricCard(
            label: 'Monthly repayment',
            value: formatMoney(
              result.monthlyRepaymentEstimate,
              currency: result.currency,
            ),
            helper:
                'Over ${result.generatedAt.month == 1 ? '12' : 'term'} months',
            icon: Icons.event_repeat_rounded,
            accentColor: FinoraColors.brandPrimary,
            compact: true,
          ),
        ),
        const SizedBox(width: FinoraSpacing.sm),
        Expanded(
          child: FinoraMetricCard(
            label: 'Projected cash flow',
            value: formatMoney(
              result.projectedCashFlow,
              currency: result.currency,
            ),
            helper: 'After loan service',
            icon: Icons.trending_up_rounded,
            accentColor: FinoraColors.positive,
            compact: true,
          ),
        ),
        const SizedBox(width: FinoraSpacing.sm),
        Expanded(
          child: FinoraMetricCard(
            label: 'Max sustainable',
            value: formatMoney(
              result.maximumSustainableAmount,
              currency: result.currency,
            ),
            helper: 'Healthy ceiling',
            icon: Icons.flag_rounded,
            accentColor: FinoraColors.brandViolet,
            compact: true,
          ),
        ),
      ],
    );
  }
}

class _EmptyNotesCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FinoraFinancialCard(
      tone: FinoraCardTone.neutral,
      padding: const EdgeInsets.all(FinoraSpacing.md),
      child: Row(
        children: [
          const FinoraIconChip(
            icon: Icons.info_outline_rounded,
            tone: FinoraBadgeTone.neutral,
          ),
          const SizedBox(width: FinoraSpacing.sm),
          Expanded(
            child: Text(
              'No specific notes for this scenario.',
              style: FinoraTextStyles.caption,
            ),
          ),
        ],
      ),
    );
  }
}

class _NotesCard extends StatelessWidget {
  const _NotesCard({required this.notes});
  final List<String> notes;

  @override
  Widget build(BuildContext context) {
    return FinoraFinancialCard(
      tone: FinoraCardTone.neutral,
      padding: const EdgeInsets.all(FinoraSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final n in notes)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 6),
                    child: Icon(
                      Icons.fiber_manual_record,
                      size: 8,
                      color: FinoraColors.brandPrimary,
                    ),
                  ),
                  const SizedBox(width: FinoraSpacing.sm),
                  Expanded(
                    child: Text(
                      n,
                      style: FinoraTextStyles.body.copyWith(height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ScenariosCard extends StatelessWidget {
  const _ScenariosCard({required this.scenarios});
  final List<SimulationScenario> scenarios;

  @override
  Widget build(BuildContext context) {
    return FinoraFinancialCard(
      tone: FinoraCardTone.neutral,
      padding: const EdgeInsets.all(FinoraSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final s in scenarios) ...[
            _ScenarioRow(scenario: s),
            if (s != scenarios.last)
              const Divider(height: 24, color: FinoraColors.outlineSoft),
          ],
        ],
      ),
    );
  }
}

class _ScenarioRow extends StatelessWidget {
  const _ScenarioRow({required this.scenario});
  final SimulationScenario scenario;

  @override
  Widget build(BuildContext context) {
    final tone = scenario.feasible
        ? FinoraBadgeTone.positive
        : FinoraBadgeTone.negative;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(scenario.label, style: FinoraTextStyles.label),
              const SizedBox(height: 2),
              Text(
                '${formatPercent(scenario.percentOfRevenue)} of revenue · ${formatMoney(scenario.monthlyRepayment)} / mo',
                style: FinoraTextStyles.caption,
              ),
              const SizedBox(height: 4),
              Text(
                formatMoney(scenario.amount),
                style: FinoraTextStyles.body.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: FinoraSpacing.sm),
        FinoraStatusBadge(
          label: scenario.feasible ? 'Feasible' : 'Risky',
          icon: scenario.feasible
              ? Icons.check_circle_rounded
              : Icons.warning_amber_rounded,
          tone: tone,
        ),
      ],
    );
  }
}

class _StressTestCard extends StatelessWidget {
  const _StressTestCard({required this.result});
  final SimulationResult result;

  @override
  Widget build(BuildContext context) {
    final stress = result.stressTest;
    final tone = _toneForRisk(stress.riskLevel);
    final color = riskColorFor(stress.riskLevel);
    final hasContent =
        stress.adjustedRevenue > 0 ||
        stress.adjustedExpenses > 0 ||
        stress.adjustedNetCashFlow != 0;

    return FinoraFinancialCard(
      tone: FinoraCardTone.warning,
      padding: const EdgeInsets.all(FinoraSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const FinoraIconChip(
                icon: Icons.bolt_rounded,
                tone: FinoraBadgeTone.warning,
              ),
              const SizedBox(width: FinoraSpacing.sm),
              Expanded(
                child: Text(
                  'Downturn projection',
                  style: FinoraTextStyles.label,
                ),
              ),
              FinoraStatusBadge(
                label: '${stress.riskLevel} risk',
                icon: riskIconFor(stress.riskLevel),
                tone: tone,
              ),
            ],
          ),
          const SizedBox(height: FinoraSpacing.md),
          if (hasContent) ...[
            _StressLine(
              label: 'Adjusted revenue',
              value: formatMoney(
                stress.adjustedRevenue,
                currency: result.currency,
              ),
            ),
            _StressLine(
              label: 'Adjusted expenses',
              value: formatMoney(
                stress.adjustedExpenses,
                currency: result.currency,
              ),
            ),
            _StressLine(
              label: 'Net cash flow',
              value: formatMoney(
                stress.adjustedNetCashFlow,
                currency: result.currency,
              ),
              color: color,
              emphasized: true,
            ),
            _StressLine(
              label: 'Cash buffer',
              value:
                  '${stress.adjustedCashBufferWeeks.toStringAsFixed(1)} weeks',
            ),
          ] else
            Text(
              'No stress figures reported for this scenario.',
              style: FinoraTextStyles.caption,
            ),
          if (stress.notes.isNotEmpty) ...[
            const SizedBox(height: FinoraSpacing.sm),
            for (final n in stress.notes)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text(
                  '• $n',
                  style: FinoraTextStyles.caption.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _StressLine extends StatelessWidget {
  const _StressLine({
    required this.label,
    required this.value,
    this.color,
    this.emphasized = false,
  });

  final String label;
  final String value;
  final Color? color;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: emphasized
                  ? FinoraTextStyles.label
                  : FinoraTextStyles.body,
            ),
          ),
          Text(
            value,
            style: (emphasized ? FinoraTextStyles.label : FinoraTextStyles.body)
                .copyWith(
                  color: color ?? FinoraColors.textPrimary,
                  fontWeight: emphasized ? FontWeight.w800 : FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

FinoraBadgeTone _toneForRisk(String risk) {
  switch (risk.toLowerCase()) {
    case 'low':
      return FinoraBadgeTone.positive;
    case 'medium':
    case 'moderate':
      return FinoraBadgeTone.warning;
    case 'high':
    case 'severe':
      return FinoraBadgeTone.negative;
    default:
      return FinoraBadgeTone.neutral;
  }
}
