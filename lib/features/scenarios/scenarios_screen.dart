import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/finora_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/app_states.dart';
import '../../core/widgets/finora_glass_card.dart';
import '../../core/widgets/finora_hero_header.dart';
import '../../core/widgets/finora_health_ring.dart';
import '../../data/active_business_controller.dart';
import '../../data/live_data.dart';
import '../../data/repositories/capital_repository.dart';

class ScenariosScreen extends ConsumerWidget {
  const ScenariosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scenarios = ref.watch(_scenariosProvider);
    final currency = ref.watch(activeBusinessCurrencyProvider);
    final state = ref.watch(activeBusinessControllerProvider);

    return Scaffold(
      backgroundColor: FinoraColors.surface,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: FinoraHeroHeader(
                height: 240,
                greeting: 'BUSINESS TWIN',
                title: 'Future scenarios',
                subtitle: state.business?.name ?? 'Your business',
                meshColors: FinoraHeroPalettes.riskMesh,
                foregroundExtra: Padding(
                  padding: const EdgeInsets.only(left: 12, top: 8),
                  child: FinoraHeroBackButton(onBack: () => context.pop()),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
              sliver: SliverList.list(
                children: [
                  Text(
                    'Simulate capital decisions before you commit.',
                    style: FinoraTextStyles.body.copyWith(
                      color: FinoraColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  scenarios.when(
                    data: (result) {
                      if (result.scenarios.isEmpty) {
                        return FinoraGlassCard(
                          padding: const EdgeInsets.all(20),
                          child: Text(
                            'Run the capital simulator to see scenarios.',
                            style: FinoraTextStyles.body.copyWith(
                              color: FinoraColors.textSecondary,
                            ),
                          ),
                        );
                      }
                      return Column(
                        children: result.scenarios
                            .map(
                              (s) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _ScenarioCard(
                                  scenario: s,
                                  currency: currency,
                                  onTap: () => context.push(
                                    '/scenarios/result',
                                    extra: s,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      );
                    },
                    loading: () => const Padding(
                      padding: EdgeInsets.symmetric(vertical: 80),
                      child: LoadingState(),
                    ),
                    error: (e, _) => ErrorState(
                      message: 'Could not load scenarios.',
                      onRetry: () => ref.invalidate(_scenariosProvider),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScenarioCard extends StatelessWidget {
  const _ScenarioCard({
    required this.scenario,
    required this.currency,
    required this.onTap,
  });
  final SimulationScenario scenario;
  final String currency;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: FinoraGlassCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: FinoraGradients.violet,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.psychology_alt_rounded,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(scenario.label, style: FinoraTextStyles.h4),
                        const SizedBox(height: 2),
                        Text(
                          scenario.feasible ? 'FEASIBLE' : 'STRETCH',
                          style: FinoraTextStyles.overline.copyWith(
                            color: scenario.feasible
                                ? FinoraColors.positive
                                : FinoraColors.warning,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: FinoraColors.textMuted,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _MiniMetric(
                      label: 'Amount',
                      value: formatCompactMoney(
                        scenario.amount,
                        currency: currency,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MiniMetric(
                      label: 'Monthly',
                      value: formatCompactMoney(
                        scenario.monthlyRepayment,
                        currency: currency,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MiniMetric(
                      label: '% of revenue',
                      value: '${scenario.percentOfRevenue.toStringAsFixed(0)}%',
                      color: scenario.feasible
                          ? FinoraColors.positive
                          : FinoraColors.warning,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniMetric extends StatelessWidget {
  const _MiniMetric({
    required this.label,
    required this.value,
    this.color,
  });
  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: FinoraTextStyles.overline),
        const SizedBox(height: 2),
        Text(
          value,
          style: FinoraTextStyles.h4.copyWith(color: color),
        ),
      ],
    );
  }
}

class ScenarioResultScreen extends ConsumerWidget {
  const ScenarioResultScreen({super.key, required this.scenario});
  final SimulationScenario scenario;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currency = ref.watch(activeBusinessCurrencyProvider);
    final state = ref.watch(activeBusinessControllerProvider);

    return Scaffold(
      backgroundColor: FinoraColors.surface,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: FinoraHeroHeader(
                height: 260,
                greeting: 'SCENARIO',
                title: scenario.label,
                subtitle: state.business?.name ?? 'Your business',
                meshColors: FinoraHeroPalettes.riskMesh,
                foregroundExtra: Padding(
                  padding: const EdgeInsets.only(left: 12, top: 8),
                  child: FinoraHeroBackButton(onBack: () => context.pop()),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
              sliver: SliverList.list(
                children: [
                  FinoraGlassCard(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        FinoraHealthRing(
                          score: scenario.percentOfRevenue.clamp(0, 100),
                          status: scenario.feasible
                              ? 'Feasible'
                              : 'Risky',
                          size: 96,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Risk', style: FinoraTextStyles.overline),
                              const SizedBox(height: 2),
                              Text(
                                scenario.feasible
                                    ? 'Comfortable for your cash flow'
                                    : 'Tight against revenue',
                                style: FinoraTextStyles.h4,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  FinoraGlassCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Requested amount', style: FinoraTextStyles.overline),
                        const SizedBox(height: 4),
                        Text(
                          formatCompactMoney(
                            scenario.amount,
                            currency: currency,
                          ),
                          style: FinoraTextStyles.metric,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  FinoraGlassCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Monthly repayment', style: FinoraTextStyles.overline),
                        const SizedBox(height: 4),
                        Text(
                          formatCompactMoney(
                            scenario.monthlyRepayment,
                            currency: currency,
                          ),
                          style: FinoraTextStyles.h2,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${scenario.percentOfRevenue.toStringAsFixed(1)}% of monthly revenue',
                          style: FinoraTextStyles.caption.copyWith(
                            color: FinoraColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  FinoraGlassCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Notes', style: FinoraTextStyles.overline),
                        const SizedBox(height: 8),
                        Text(
                          scenario.feasible
                              ? 'This scenario fits within your monthly cash flow.'
                              : 'Consider a longer term or smaller amount.',
                          style: FinoraTextStyles.body,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final _scenariosProvider = FutureProvider.autoDispose<SimulationResult>((
  ref,
) async {
  ref.watch(liveDataVersionProvider);
  final repo = ref.watch(capitalRepositoryProvider);
  return repo.simulate(requestedAmount: 50000, termMonths: 12);
});