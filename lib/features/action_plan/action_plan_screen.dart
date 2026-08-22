import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/finora_theme.dart';
import '../../core/widgets/app_states.dart';
import '../../core/widgets/finora_glass_card.dart';
import '../../core/widgets/finora_hero_header.dart';
import '../../data/active_business_controller.dart';
import '../../data/live_data.dart';
import '../../data/repositories/financial_repository.dart';

class ActionPlanScreen extends ConsumerWidget {
  const ActionPlanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final health = ref.watch(_healthProvider);
    final state = ref.watch(activeBusinessControllerProvider);

    return Scaffold(
      backgroundColor: FinoraColors.surface,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: FinoraHeroHeader(
                height: 240,
                greeting: 'ACTION PLAN',
                title: 'Recommended moves',
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
                  health.when(
                    data: (h) {
                      final recs = h.recommendations;
                      if (recs.isEmpty) {
                        return FinoraGlassCard(
                          padding: const EdgeInsets.all(20),
                          child: Text(
                            'No recommendations yet. Log a few transactions to get tailored advice.',
                            style: FinoraTextStyles.body.copyWith(
                              color: FinoraColors.textSecondary,
                            ),
                          ),
                        );
                      }
                      return Column(
                        children: recs
                            .asMap()
                            .entries
                            .map(
                              (entry) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _RecommendationCard(
                                  index: entry.key + 1,
                                  text: entry.value,
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
                      message: 'Could not load recommendations.',
                      onRetry: () => ref.invalidate(_healthProvider),
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

class _RecommendationCard extends StatelessWidget {
  const _RecommendationCard({required this.index, required this.text});
  final int index;
  final String text;

  @override
  Widget build(BuildContext context) {
    return FinoraGlassCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: FinoraGradients.forest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                '$index',
                style: FinoraTextStyles.h4.copyWith(color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Recommendation', style: FinoraTextStyles.overline),
                const SizedBox(height: 4),
                Text(text, style: FinoraTextStyles.body),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

final _healthProvider = FutureProvider.autoDispose<FinancialHealth>((
  ref,
) async {
  ref.watch(liveDataVersionProvider);
  final state = ref.watch(activeBusinessControllerProvider);
  if (!state.hasBusiness) throw StateError('No active business');
  final repo = ref.watch(financialRepositoryProvider);
  return repo.health();
});