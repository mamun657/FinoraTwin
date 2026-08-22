import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/finora_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/app_states.dart';
import '../../core/widgets/finora_glass_card.dart';
import '../../core/widgets/finora_hero_header.dart';
import '../../core/widgets/finora_sparkline.dart';
import '../../data/active_business_controller.dart';
import '../../data/live_data.dart';
import '../../data/repositories/transaction_repository.dart';

class LeakDetectorScreen extends ConsumerWidget {
  const LeakDetectorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(activeBusinessControllerProvider);
    if (!state.hasBusiness) {
      return _noBusiness(context);
    }
    final now = DateTime.now();
    final txPage = ref.watch(_leakTransactionsProvider);

    return Scaffold(
      backgroundColor: FinoraColors.surface,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: FinoraHeroHeader(
                height: 240,
                greeting: 'LEAK DETECTOR',
                title: 'Where money slips away',
                subtitle: state.business?.name ?? 'Your business',
                meshColors: FinoraHeroPalettes.healthMesh,
                foregroundExtra: Padding(
                  padding: const EdgeInsets.only(left: 12, top: 8),
                  child: FinoraHeroBackButton(onBack: () => context.pop()),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                FinoraSpacing.lg,
                FinoraSpacing.lg,
                FinoraSpacing.lg,
                FinoraSpacing.xxxl,
              ),
              sliver: SliverList.list(
                children: [
                  Text(
                    'Categories that grew in the last month vs. the one before.',
                    style: FinoraTextStyles.body.copyWith(
                      color: FinoraColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: FinoraSpacing.lg),
                  txPage.when(
                    data: (all) {
                      final expenses = all
                          .where((t) => t.type == TransactionType.expense)
                          .toList();
                      if (expenses.isEmpty) {
                        return FinoraGlassCard(
                          padding: const EdgeInsets.all(FinoraSpacing.lg),
                          child: Text(
                            'No expense transactions found yet.',
                            style: FinoraTextStyles.body.copyWith(
                              color: FinoraColors.textSecondary,
                            ),
                          ),
                        );
                      }
                      final byCat = <String, double>{};
                      final lastMonthByCat = <String, double>{};
                      final thisMonth = now.month;
                      for (final t in expenses) {
                        if (t.occurredAt.month == thisMonth) {
                          byCat[t.category] = (byCat[t.category] ?? 0) + t.amount;
                        }
                        if (t.occurredAt.month == thisMonth - 1 ||
                            (thisMonth == 1 &&
                                t.occurredAt.month == 12 &&
                                t.occurredAt.year == now.year - 1)) {
                          lastMonthByCat[t.category] =
                              (lastMonthByCat[t.category] ?? 0) + t.amount;
                        }
                      }
                      final leaks = <_Leak>[];
                      byCat.forEach((cat, amount) {
                        final prev = lastMonthByCat[cat] ?? 0;
                        if (prev == 0) return;
                        if (amount > prev * 1.20) {
                          leaks.add(_Leak(category: cat, current: amount, previous: prev));
                        }
                      });
                      leaks.sort((a, b) => b.delta.abs().compareTo(a.delta.abs()));

                      if (leaks.isEmpty) {
                        return FinoraGlassCard(
                          padding: const EdgeInsets.all(FinoraSpacing.lg),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  gradient: FinoraGradients.positive,
                                  borderRadius:
                                      BorderRadius.circular(FinoraRadii.md),
                                ),
                                child: const Icon(Icons.check_rounded, color: Colors.white),
                              ),
                              const SizedBox(width: FinoraSpacing.md),
                              const Expanded(
                                child: Text(
                                  'No major leaks detected this month.',
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return Column(
                        children: leaks
                            .map(
                              (l) => Padding(
                                padding: const EdgeInsets.only(
                                  bottom: FinoraSpacing.sm,
                                ),
                                child: _LeakTile(
                                  leak: l,
                                  currency: ref.watch(activeBusinessCurrencyProvider),
                                ),
                              ),
                            )
                            .toList(),
                      );
                    },
                    loading: () => const LoadingState(),
                    error: (e, _) => ErrorState(
                      message: 'Could not load transactions.',
                      onRetry: () => ref.invalidate(_leakTransactionsProvider),
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

  Widget _noBusiness(BuildContext context) => Scaffold(
        backgroundColor: FinoraColors.surface,
        appBar: AppBar(),
        body: Center(
          child: Text('No active business', style: FinoraTextStyles.h2),
        ),
      );
}

final _leakTransactionsProvider =
    FutureProvider.autoDispose<List<TransactionModel>>((ref) async {
  ref.watch(liveDataVersionProvider);
  final state = ref.watch(activeBusinessControllerProvider);
  if (!state.hasBusiness) return const [];
  final repo = ref.watch(transactionRepositoryProvider);
  final now = DateTime.now();
  final from = DateTime(now.year, now.month - 2, 1);
  final page = await repo.list(from: from, pageSize: 200);
  return page.items;
});

class _Leak {
  const _Leak({required this.category, required this.current, required this.previous});
  final String category;
  final double current;
  final double previous;
  double get delta => current - previous;
  double get deltaPercent => previous == 0 ? 0 : ((current - previous) / previous) * 100;
}

class _LeakTile extends StatelessWidget {
  const _LeakTile({required this.leak, required this.currency});
  final _Leak leak;
  final String currency;

  @override
  Widget build(BuildContext context) {
    return FinoraGlassCard(
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
                  gradient: FinoraGradients.amber,
                  borderRadius: BorderRadius.circular(FinoraRadii.md),
                ),
                child: const Icon(Icons.water_drop_outlined, color: Colors.white),
              ),
              const SizedBox(width: FinoraSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(leak.category, style: FinoraTextStyles.h4),
                    Text(
                      'Up ${leak.deltaPercent.toStringAsFixed(0)}% from last month',
                      style: FinoraTextStyles.caption.copyWith(
                        color: FinoraColors.negative,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                formatCompactMoney(leak.current, currency: currency),
                style: FinoraTextStyles.h4.copyWith(color: FinoraColors.negative),
              ),
            ],
          ),
          const SizedBox(height: FinoraSpacing.sm),
          FinoraSparkline(
            points: [leak.previous, leak.current],
            gradient: FinoraGradients.amber,
            height: 50,
            fillOpacity: 0,
          ),
        ],
      ),
    );
  }
}
