import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/finora_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/app_states.dart';
import '../../core/widgets/finora_glass_card.dart';
import '../../core/widgets/finora_health_ring.dart';
import '../../core/widgets/finora_hero_header.dart';
import '../../data/active_business_controller.dart';
import '../../data/live_data.dart';
import '../../data/repositories/capital_repository.dart';
import '../../data/repositories/financial_repository.dart';

class FundingScreen extends ConsumerWidget {
  const FundingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bundle = ref.watch(_fundingBundleProvider);
    final state = ref.watch(activeBusinessControllerProvider);

    return Scaffold(
      backgroundColor: FinoraColors.surface,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: FinoraHeroHeader(
                height: 260,
                greeting: 'LENDER VIEW',
                title: 'Funding readiness',
                subtitle: state.business?.name ?? 'Your business',
                meshColors: FinoraHeroPalettes.successMesh,
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
                  bundle.when(
                    data: (b) {
                      final score = _readinessScore(
                        b.health.overallScore,
                        b.health.cashBufferMonths,
                      );
                      return Column(
                        children: [
                          FinoraGlassCard(
                            padding: const EdgeInsets.all(20),
                            child: Row(
                              children: [
                                FinoraHealthRing(
                                  score: score,
                                  status: _statusFor(score),
                                  size: 96,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text('Readiness',
                                          style: FinoraTextStyles.overline),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${score.round()} / 100',
                                        style: FinoraTextStyles.metric,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Risk: ${b.simulation.riskLevel}',
                                        style: FinoraTextStyles.caption
                                            .copyWith(
                                          color: FinoraColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          _MetricsRow(
                            monthlyRevenue: b.health.monthlyRevenue,
                            monthlyExpenses: b.health.monthlyExpenses,
                            monthlyNet: b.health.monthlyNet,
                            currency: b.currency,
                          ),
                          const SizedBox(height: 12),
                          _BufferCard(
                            months: b.health.cashBufferMonths,
                            weeks: b.health.cashBufferWeeks,
                          ),
                          const SizedBox(height: 12),
                          if (b.simulation.notes.isNotEmpty)
                            _NotesCard(notes: b.simulation.notes),
                        ],
                      );
                    },
                    loading: () => const Padding(
                      padding: EdgeInsets.symmetric(vertical: 80),
                      child: LoadingState(),
                    ),
                    error: (e, _) => ErrorState(
                      message: 'Could not load funding readiness.',
                      onRetry: () => ref.invalidate(_fundingBundleProvider),
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

  double _readinessScore(double health, double months) {
    final m = months.clamp(0, 6) / 6;
    return ((health * 0.6) + (m * 40)).clamp(0, 100);
  }

  String _statusFor(double score) =>
      score >= 70 ? 'Strong' : score >= 45 ? 'Workable' : 'Build up';
}

class _MetricsRow extends StatelessWidget {
  const _MetricsRow({
    required this.monthlyRevenue,
    required this.monthlyExpenses,
    required this.monthlyNet,
    required this.currency,
  });
  final double monthlyRevenue;
  final double monthlyExpenses;
  final double monthlyNet;
  final String currency;

  @override
  Widget build(BuildContext context) {
    return FinoraGlassCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: _Stat(
              label: 'Revenue',
              value: formatCompactMoney(monthlyRevenue, currency: currency),
              tone: FinoraColors.positive,
            ),
          ),
          const SizedBox(
            height: 36,
            child: VerticalDivider(width: 1, thickness: 1),
          ),
          Expanded(
            child: _Stat(
              label: 'Expenses',
              value: formatCompactMoney(monthlyExpenses, currency: currency),
              tone: FinoraColors.negative,
            ),
          ),
          const SizedBox(
            height: 36,
            child: VerticalDivider(width: 1, thickness: 1),
          ),
          Expanded(
            child: _Stat(
              label: 'Net',
              value: formatCompactMoney(monthlyNet, currency: currency),
              tone: monthlyNet >= 0
                  ? FinoraColors.textPrimary
                  : FinoraColors.negative,
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, required this.tone});
  final String label;
  final String value;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: FinoraTextStyles.overline),
        const SizedBox(height: 4),
        Text(value, style: FinoraTextStyles.h4.copyWith(color: tone)),
      ],
    );
  }
}

class _BufferCard extends StatelessWidget {
  const _BufferCard({required this.months, required this.weeks});
  final double months;
  final double weeks;

  @override
  Widget build(BuildContext context) {
    return FinoraGlassCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: FinoraGradients.ocean,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.savings_rounded,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Cash buffer', style: FinoraTextStyles.overline),
                const SizedBox(height: 4),
                Text(
                  '${months.toStringAsFixed(1)} months',
                  style: FinoraTextStyles.h2,
                ),
                const SizedBox(height: 2),
                Text(
                  '${weeks.round()} weeks of runway',
                  style: FinoraTextStyles.caption.copyWith(
                    color: FinoraColors.textSecondary,
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

class _NotesCard extends StatelessWidget {
  const _NotesCard({required this.notes});
  final List<String> notes;

  @override
  Widget build(BuildContext context) {
    return FinoraGlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Lender notes', style: FinoraTextStyles.overline),
          const SizedBox(height: 8),
          for (final note in notes)
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
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(note, style: FinoraTextStyles.body),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _FundingBundle {
  const _FundingBundle({
    required this.health,
    required this.simulation,
    required this.currency,
  });
  final FinancialHealth health;
  final SimulationResult simulation;
  final String currency;
}

final _fundingBundleProvider = FutureProvider.autoDispose<_FundingBundle>((
  ref,
) async {
  ref.watch(liveDataVersionProvider);
  final state = ref.watch(activeBusinessControllerProvider);
  if (!state.hasBusiness) throw StateError('No active business');
  final repo = ref.watch(financialRepositoryProvider);
  final capital = ref.watch(capitalRepositoryProvider);
  final results = await Future.wait([
    repo.health(),
    capital.simulate(requestedAmount: 50000, termMonths: 12),
  ]);
  return _FundingBundle(
    health: results[0] as FinancialHealth,
    simulation: results[1] as SimulationResult,
    currency: state.business?.currency ?? 'USD',
  );
});