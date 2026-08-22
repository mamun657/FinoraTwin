import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/finora_theme.dart';
import '../../core/widgets/app_states.dart';
import '../../core/widgets/finora_glass_card.dart';
import '../../core/widgets/finora_health_ring.dart';
import '../../core/widgets/finora_hero_header.dart';
import '../../data/active_business_controller.dart';
import '../../data/live_data.dart';
import '../../data/repositories/financial_repository.dart';

class DataQualityScreen extends ConsumerWidget {
  const DataQualityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final health = ref.watch(_financialHealthProvider);
    final state = ref.watch(activeBusinessControllerProvider);

    return Scaffold(
      backgroundColor: FinoraColors.surface,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: FinoraHeroHeader(
                height: 240,
                greeting: 'DATA HEALTH',
                title: 'Records checkup',
                subtitle: state.business?.name ?? 'Your business',
                meshColors: FinoraHeroPalettes.healthMesh,
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
                  health.when(
                    data: (h) {
                      final score = _computeScore(h);
                      final status = score >= 80
                          ? 'Excellent'
                          : score >= 50
                              ? 'Good'
                              : 'Needs attention';
                      return Column(
                        children: [
                          FinoraGlassCard(
                            padding: const EdgeInsets.all(20),
                            child: Row(
                              children: [
                                FinoraHealthRing(
                                  score: score.toDouble(),
                                  status: status,
                                  size: 90,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text('Data quality', style: FinoraTextStyles.overline),
                                      const SizedBox(height: 4),
                                      Text(status, style: FinoraTextStyles.h2),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Score is based on transaction coverage.',
                                        style: FinoraTextStyles.caption.copyWith(
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
                          _CheckItem(title: 'Revenue transactions', ok: h.monthlyRevenue > 0),
                          _CheckItem(title: 'Expense transactions', ok: h.monthlyExpenses > 0),
                          _CheckItem(title: 'Cash buffer tracked', ok: h.cashBufferMonths > 0),
                          _CheckItem(
                            title: 'AI recommendations available',
                            ok: h.recommendations.isNotEmpty,
                          ),
                        ],
                      );
                    },
                    loading: () => const Padding(
                      padding: EdgeInsets.symmetric(vertical: 80),
                      child: LoadingState(),
                    ),
                    error: (e, _) => ErrorState(
                      message: 'Could not load data quality.',
                      onRetry: () => ref.invalidate(_financialHealthProvider),
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

  int _computeScore(FinancialHealth h) {
    var score = 0;
    if (h.monthlyRevenue > 0) score += 30;
    if (h.monthlyExpenses > 0) score += 30;
    if (h.cashBufferMonths > 0) score += 20;
    if (h.recommendations.isNotEmpty) score += 20;
    return score.clamp(0, 100);
  }
}

class _CheckItem extends StatelessWidget {
  const _CheckItem({required this.title, required this.ok});
  final String title;
  final bool ok;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: FinoraGlassCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              ok ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
              color: ok ? FinoraColors.positive : FinoraColors.textMuted,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: FinoraTextStyles.body.copyWith(
                  color: ok ? FinoraColors.textPrimary : FinoraColors.textSecondary,
                ),
              ),
            ),
            Text(
              ok ? 'OK' : 'Pending',
              style: FinoraTextStyles.caption.copyWith(
                color: ok ? FinoraColors.positive : FinoraColors.textMuted,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final _financialHealthProvider = FutureProvider.autoDispose<FinancialHealth>((
  ref,
) async {
  ref.watch(liveDataVersionProvider);
  final state = ref.watch(activeBusinessControllerProvider);
  if (!state.hasBusiness) throw StateError('No active business');
  final repo = ref.watch(financialRepositoryProvider);
  return repo.health();
});