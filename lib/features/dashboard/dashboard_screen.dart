import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/finora_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/app_states.dart';
import '../../core/widgets/finora_glass_card.dart';
import '../../core/widgets/finora_health_ring.dart';
import '../../core/widgets/finora_transaction_tile.dart';
import '../../data/active_business_controller.dart';
import '../../data/auth_session_controller.dart';
import '../../data/live_data.dart';
import '../../data/repositories/financial_repository.dart';
import '../../data/repositories/transaction_repository.dart';

final _financialHealthProvider = FutureProvider.autoDispose<FinancialHealth>((
  ref,
) async {
  ref.watch(liveDataVersionProvider);
  final state = ref.watch(activeBusinessControllerProvider);
  if (!state.hasBusiness) throw StateError('No active business');
  final repo = ref.watch(financialRepositoryProvider);
  return repo.health();
});

final _recentTransactionsProvider =
    FutureProvider.autoDispose<List<TransactionModel>>((ref) async {
      ref.watch(liveDataVersionProvider);
      final state = ref.watch(activeBusinessControllerProvider);
      if (!state.hasBusiness) return const [];
      final repo = ref.watch(transactionRepositoryProvider);
      final page = await repo.list(pageSize: 4);
      return page.items;
    });
final _insightProvider = FutureProvider.autoDispose<_DashboardInsight>((
  ref,
) async {
  ref.watch(liveDataVersionProvider);
  final state = ref.watch(activeBusinessControllerProvider);
  if (!state.hasBusiness) {
    return const _DashboardInsight(
      headline: 'Set up your business to see insights',
      detail: 'Tell us about your business to unlock insights.',
      kind: _InsightKind.neutral,
    );
  }
  final repo = ref.watch(transactionRepositoryProvider);
  final now = DateTime.now();
  final thisMonthStart = DateTime(now.year, now.month, 1);
  final lastMonthStart = DateTime(now.year, now.month - 1, 1);
  final page = await repo.list(pageSize: 500);
  final all = page.items;
  final thisMonth = <TransactionModel>[];
  final lastMonth = <TransactionModel>[];
  for (final t in all) {
    final local = t.occurredAt.toLocal();
    if (!local.isBefore(thisMonthStart)) {
      thisMonth.add(t);
    } else if (!local.isBefore(lastMonthStart)) {
      lastMonth.add(t);
    }
  }
  final byCategory = <String, double>{};
  var thisExpense = 0.0;
  for (final t in thisMonth) {
    if (t.type == TransactionType.expense) {
      thisExpense += t.amount;
      byCategory[t.category] = (byCategory[t.category] ?? 0) + t.amount;
    }
  }

  final lastByCategory = <String, double>{};
  var lastExpense = 0.0;
  for (final t in lastMonth) {
    if (t.type == TransactionType.expense) {
      lastExpense += t.amount;
      lastByCategory[t.category] = (lastByCategory[t.category] ?? 0) + t.amount;
    }
  }

  if (thisMonth.isEmpty && lastMonth.isEmpty) {
    return const _DashboardInsight(
      headline: 'Add your first transaction',
      detail: 'Tap "Add Transaction" to start tracking cash flow.',
      kind: _InsightKind.neutral,
    );
  }

  String? topCategory;
  double topDelta = 0;
  byCategory.forEach((cat, amt) {
    final prev = lastByCategory[cat] ?? 0;
    final delta = amt - prev;
    if (prev > 0 && delta > topDelta) {
      topDelta = delta;
      topCategory = cat;
    }
  });
  final fallbackCurrency = thisMonth.isNotEmpty
      ? thisMonth.first.currency
      : lastMonth.isNotEmpty
      ? lastMonth.first.currency
      : 'USD';

  if (topCategory != null && lastByCategory[topCategory]! > 0) {
    final pct = (topDelta / lastByCategory[topCategory]!) * 100;
    if (pct >= 10) {
      return _DashboardInsight(
        headline: '$topCategory expenses ${pct.round()}% higher',
        detail:
            '${formatCompactMoney(topDelta, currency: fallbackCurrency)} more this month vs last month. Tap to review your spending.',
        kind: _InsightKind.warning,
      );
    }
  }

  if (thisExpense == 0 && lastExpense == 0) {
    return const _DashboardInsight(
      headline: 'No expenses recorded yet',
      detail: 'Add expense entries to see your real spending patterns.',
      kind: _InsightKind.neutral,
    );
  }

  if (thisExpense < lastExpense && lastExpense > 0) {
    final saved = lastExpense - thisExpense;
    final pct = (saved / lastExpense) * 100;
    return _DashboardInsight(
      headline: 'Spending down ${pct.round()}%',
      detail:
          'You saved ${formatCompactMoney(saved, currency: fallbackCurrency)} this month. Keep it going.',
      kind: _InsightKind.positive,
    );
  }

  return _DashboardInsight(
    headline: 'Cash flow on track',
    detail:
        '${thisMonth.length} transactions this month. Open AI Copilot for a deeper read.',
    kind: _InsightKind.positive,
  );
});

enum _InsightKind { positive, warning, neutral }

class _DashboardInsight {
  const _DashboardInsight({
    required this.headline,
    required this.detail,
    required this.kind,
  });
  final String headline;
  final String detail;
  final _InsightKind kind;
}

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authSessionControllerProvider).session;
    final businessState = ref.watch(activeBusinessControllerProvider);

    if (!businessState.hasBusiness) {
      return _EmptyDashboard(
        businessName: businessState.business?.name,
        onSetup: () => context.push('/business-setup'),
      );
    }

    final health = ref.watch(_financialHealthProvider);
    final recent = ref.watch(_recentTransactionsProvider);
    final insight = ref.watch(_insightProvider);
    final currency = ref.watch(activeBusinessCurrencyProvider);
    final businessName = businessState.business?.name ?? 'your business';

    return Scaffold(
      backgroundColor: FinoraColors.surface,
      body: RefreshIndicator(
        color: FinoraColors.brandPrimary,
        onRefresh: () async {
          ref.invalidate(_financialHealthProvider);
          ref.invalidate(_recentTransactionsProvider);
          ref.invalidate(_insightProvider);
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          children: [
            _DashboardHeader(
              name: session?.fullName,
              businessName: businessName,
              onProfileTap: () => context.push('/profile'),
            ),
            const SizedBox(height: FinoraSpacing.md),
            health.when(
              data: (h) => _FinancialHealthHero(
                score: h.overallScore,
                status: h.status,
                cashInHand: h.cashBufferMonths * h.monthlyExpenses,
                netCashFlow: h.monthlyNet,
                runwayMonths: h.cashBufferMonths,
                currency: currency,
                onTap: () => context.push('/financial-health'),
              ),
              loading: () => const _FinancialHealthSkeleton(),
              error: (_, __) => const _FinancialHealthError(),
            ),
            const SizedBox(height: FinoraSpacing.lg),
            const _QuickActionsRow(),
            const SizedBox(height: FinoraSpacing.xl),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: FinoraSpacing.lg),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Recent Transactions',
                      style: FinoraTextStyles.h2,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.go('/transactions'),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('See all'),
                        Icon(Icons.chevron_right_rounded, size: 18),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: FinoraSpacing.sm),
            recent.when(
              data: (items) {
                if (items.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: FinoraSpacing.lg,
                    ),
                    child: FinoraGlassCard(
                      padding: const EdgeInsets.all(FinoraSpacing.lg),
                      child: Row(
                        children: const [
                          Icon(
                            Icons.inbox_outlined,
                            color: FinoraColors.textMuted,
                          ),
                          SizedBox(width: FinoraSpacing.sm),
                          Expanded(
                            child: Text(
                              'No transactions yet. Tap + to add one.',
                              style: TextStyle(
                                color: FinoraColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: FinoraSpacing.lg,
                  ),
                  child: Column(
                    children: items
                        .map(
                          (t) => Padding(
                            padding: const EdgeInsets.only(
                              bottom: FinoraSpacing.sm,
                            ),
                            child: _RecentTransactionTile(
                              transaction: t,
                              currency: currency,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: FinoraSpacing.xl),
                child: LoadingState(),
              ),
              error: (_, __) => Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: FinoraSpacing.lg,
                ),
                child: ErrorState(
                  message: 'Could not load transactions.',
                  onRetry: () => ref.invalidate(_recentTransactionsProvider),
                ),
              ),
            ),
            const SizedBox(height: FinoraSpacing.xl),
            insight.when(
              data: (i) => Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: FinoraSpacing.lg,
                ),
                child: _InsightCard(
                  insight: i,
                  onTap: () => context.push('/ai-copilot'),
                ),
              ),
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(horizontal: FinoraSpacing.lg),
                child: SizedBox(
                  height: 96,
                  child: Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
              error: (_, __) => Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: FinoraSpacing.lg,
                ),
                child: FinoraGlassCard(
                  padding: const EdgeInsets.all(FinoraSpacing.lg),
                  child: Row(
                    children: const [
                      Icon(
                        Icons.error_outline_rounded,
                        color: FinoraColors.textMuted,
                      ),
                      SizedBox(width: FinoraSpacing.sm),
                      Expanded(
                        child: Text(
                          'Could not load insight.',
                          style: TextStyle(color: FinoraColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: FinoraSpacing.xxxl),
          ],
        ),
      ),
      floatingActionButton: _AddTransactionFab(
        onTap: () => context.push('/transactions/add'),
      ),
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({
    required this.name,
    required this.businessName,
    required this.onProfileTap,
  });

  final String? name;
  final String businessName;
  final VoidCallback onProfileTap;

  @override
  Widget build(BuildContext context) {
    final greeting = _greeting();
    final firstName = (name == null || name!.isEmpty)
        ? 'there'
        : name!.split(' ').first;
    final initial = firstName.isEmpty
        ? 'F'
        : firstName.characters.first.toUpperCase();

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          FinoraSpacing.lg,
          FinoraSpacing.md,
          FinoraSpacing.lg,
          FinoraSpacing.md,
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: FinoraColors.brandPrimarySoft,
                borderRadius: BorderRadius.circular(FinoraRadii.pill),
                border: Border.all(
                  color: FinoraColors.brandPrimary.withValues(alpha: 0.18),
                  width: 1,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                initial,
                style: FinoraTextStyles.h3.copyWith(
                  color: FinoraColors.brandPrimaryDark,
                ),
              ),
            ),
            const SizedBox(width: FinoraSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    greeting,
                    style: FinoraTextStyles.caption.copyWith(
                      color: FinoraColors.textSecondary,
                      letterSpacing: 0.6,
                    ),
                  ),
                  Text(
                    'Hi, $firstName',
                    style: FinoraTextStyles.h2,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: FinoraSpacing.sm),
            _IconBubble(icon: Icons.notifications_none_rounded, onTap: () {}),
            const SizedBox(width: FinoraSpacing.xs),
            _IconBubble(
              icon: Icons.person_outline_rounded,
              onTap: onProfileTap,
            ),
          ],
        ),
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'GOOD MORNING';
    if (hour < 17) return 'GOOD AFTERNOON';
    return 'GOOD EVENING';
  }
}

class _IconBubble extends StatelessWidget {
  const _IconBubble({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: FinoraColors.surfaceAlt,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(FinoraRadii.pill),
        side: BorderSide(color: FinoraColors.outline.withValues(alpha: 0.6)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(FinoraRadii.pill),
        onTap: onTap,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, size: 20, color: FinoraColors.textPrimary),
        ),
      ),
    );
  }
}

class _FinancialHealthHero extends StatelessWidget {
  const _FinancialHealthHero({
    required this.score,
    required this.status,
    required this.cashInHand,
    required this.netCashFlow,
    required this.runwayMonths,
    required this.currency,
    required this.onTap,
  });

  final double score;
  final String status;
  final double cashInHand;
  final double netCashFlow;
  final double runwayMonths;
  final String currency;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final healthColor = healthColorFor(status);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: FinoraSpacing.lg),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(FinoraRadii.xxl),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(FinoraSpacing.lg),
            decoration: BoxDecoration(
              color: FinoraColors.surfaceAlt,
              borderRadius: BorderRadius.circular(FinoraRadii.xxl),
              border: Border.all(color: FinoraColors.outline),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x120E1726),
                  blurRadius: 18,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Financial Health',
                        style: FinoraTextStyles.caption.copyWith(
                          color: FinoraColors.textSecondary,
                          letterSpacing: 0.6,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: FinoraSpacing.sm,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: healthColor.withValues(alpha: 0.12),
                          border: Border.all(
                            color: healthColor.withValues(alpha: 0.28),
                          ),
                          borderRadius: BorderRadius.circular(FinoraRadii.pill),
                        ),
                        child: Text(
                          _capitalize(status),
                          style: FinoraTextStyles.caption.copyWith(
                            color: healthColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: FinoraSpacing.md),
                      _HeroStat(
                        label: 'Cash in Hand',
                        value: formatMoney(cashInHand, currency: currency),
                      ),
                      const SizedBox(height: FinoraSpacing.sm),
                      _HeroStat(
                        label: 'Net Cash Flow',
                        value:
                            '${netCashFlow >= 0 ? '+' : '-'}${formatMoney(netCashFlow.abs(), currency: currency)}',
                      ),
                      const SizedBox(height: FinoraSpacing.sm),
                      _HeroStat(
                        label: 'Runway',
                        value: '${runwayMonths.toStringAsFixed(1)} months',
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: FinoraSpacing.md),
                FinoraHealthRing(
                  score: score,
                  status: status,
                  size: 132,
                  label: 'Health',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: FinoraTextStyles.caption.copyWith(
            color: FinoraColors.textMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: FinoraTextStyles.h4.copyWith(color: FinoraColors.textPrimary),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _FinancialHealthSkeleton extends StatelessWidget {
  const _FinancialHealthSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: FinoraSpacing.lg),
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          color: FinoraColors.surfaceAlt,
          borderRadius: BorderRadius.circular(FinoraRadii.xxl),
          border: Border.all(
            color: FinoraColors.outline.withValues(alpha: 0.5),
          ),
        ),
        alignment: Alignment.center,
        child: const CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }
}

class _FinancialHealthError extends StatelessWidget {
  const _FinancialHealthError();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: FinoraSpacing.lg),
      child: FinoraGlassCard(
        padding: const EdgeInsets.all(FinoraSpacing.lg),
        child: Row(
          children: const [
            Icon(Icons.cloud_off_rounded, color: FinoraColors.textMuted),
            SizedBox(width: FinoraSpacing.sm),
            Expanded(
              child: Text(
                'Could not load financial health.',
                style: TextStyle(color: FinoraColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionsRow extends StatelessWidget {
  const _QuickActionsRow();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: FinoraSpacing.lg),
      child: Row(
        children: [
          Expanded(
            child: _QuickActionTile(
              label: 'Add\nTransaction',
              icon: Icons.add_rounded,
              tone: FinoraBadgeTone.brand,
              assetPath: 'assets/icons/transaction.png',
              onTap: () => context.push('/transactions/add'),
            ),
          ),
          const SizedBox(width: FinoraSpacing.sm),
          Expanded(
            child: _QuickActionTile(
              label: 'Simulate\nLoan',
              icon: Icons.calculate_outlined,
              tone: FinoraBadgeTone.info,
              assetPath: 'assets/icons/simulation.png',
              onTap: () => context.push('/capital-simulator'),
            ),
          ),
          const SizedBox(width: FinoraSpacing.sm),
          Expanded(
            child: _QuickActionTile(
              label: 'Ask AI',
              icon: Icons.auto_awesome_outlined,
              tone: FinoraBadgeTone.positive,
              assetPath: 'assets/icons/ai-robot.png',
              onTap: () => context.go('/ai-copilot'),
            ),
          ),
          const SizedBox(width: FinoraSpacing.sm),
          Expanded(
            child: _QuickActionTile(
              label: 'View All',
              icon: Icons.grid_view_rounded,
              tone: FinoraBadgeTone.neutral,
              assetPath: 'assets/icons/apps.png',
              onTap: () => context.push('/explore'),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({
    required this.label,
    required this.icon,
    required this.tone,
    required this.onTap,
    this.assetPath,
  });

  final String label;
  final IconData icon;
  final FinoraBadgeTone tone;
  final VoidCallback onTap;
  final String? assetPath;

  @override
  Widget build(BuildContext context) {
    final fg = finoraBadgeFg(tone);
    final bg = finoraBadgeBg(tone);
    return Material(
      color: FinoraColors.surfaceAlt,
      borderRadius: BorderRadius.circular(FinoraRadii.lg),
      child: InkWell(
        borderRadius: BorderRadius.circular(FinoraRadii.lg),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(FinoraRadii.lg),
            border: Border.all(
              color: FinoraColors.outline.withValues(alpha: 0.55),
            ),
            boxShadow: FinoraShadows.xs,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: FinoraSpacing.xs,
            vertical: FinoraSpacing.md,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(FinoraRadii.md),
                ),
                alignment: Alignment.center,
                child: assetPath != null
                    ? ColorFiltered(
                        colorFilter: ColorFilter.mode(fg, BlendMode.srcIn),
                        child: Image.asset(
                          assetPath!,
                          width: 20,
                          height: 20,
                          fit: BoxFit.contain,
                        ),
                      )
                    : Icon(icon, color: fg, size: 20),
              ),
              const SizedBox(height: FinoraSpacing.xs),
              Text(
                label,
                textAlign: TextAlign.center,
                style: FinoraTextStyles.caption.copyWith(
                  color: FinoraColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({required this.insight, required this.onTap});
  final _DashboardInsight insight;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final (icon, grad, bg) = switch (insight.kind) {
      _InsightKind.positive => (
        Icons.auto_awesome_rounded,
        FinoraGradients.forest,
        FinoraColors.positiveSoft,
      ),
      _InsightKind.warning => (
        Icons.warning_amber_rounded,
        FinoraGradients.amber,
        FinoraColors.warningSoft,
      ),
      _InsightKind.neutral => (
        Icons.insights_rounded,
        FinoraGradients.brand,
        FinoraColors.brandPrimarySoft,
      ),
    };
    final fg = switch (insight.kind) {
      _InsightKind.positive => FinoraColors.positive,
      _InsightKind.warning => FinoraColors.warning,
      _InsightKind.neutral => FinoraColors.brandPrimaryDark,
    };
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(FinoraRadii.lg),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(FinoraSpacing.md),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(FinoraRadii.lg),
            border: Border.all(color: fg.withValues(alpha: 0.18), width: 1),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: grad,
                  borderRadius: BorderRadius.circular(FinoraRadii.md),
                ),
                alignment: Alignment.center,
                child: Icon(icon, color: Colors.white, size: 22),
              ),
              const SizedBox(width: FinoraSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      insight.headline,
                      style: FinoraTextStyles.label.copyWith(color: fg),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      insight.detail,
                      style: FinoraTextStyles.caption.copyWith(
                        color: fg.withValues(alpha: 0.85),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: fg.withValues(alpha: 0.55),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentTransactionTile extends StatelessWidget {
  const _RecentTransactionTile({
    required this.transaction,
    required this.currency,
  });
  final TransactionModel transaction;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final isRevenue = transaction.type == TransactionType.revenue;
    return FinoraTransactionTile(
      title: transaction.category,
      subtitle: formatRelativeDate(transaction.occurredAt),
      amount: formatMoney(transaction.amount, currency: currency),
      amountPrefix: isRevenue ? '+' : '-',
      icon: isRevenue ? Icons.south_west_rounded : Icons.north_east_rounded,
      iconColor: isRevenue ? FinoraColors.positive : FinoraColors.negative,
      iconBackground: isRevenue
          ? FinoraColors.positiveSoft
          : FinoraColors.negativeSoft,
      onTap: () => context.push('/transactions'),
    );
  }
}

class _AddTransactionFab extends StatelessWidget {
  const _AddTransactionFab({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: FinoraGradients.brand,
        borderRadius: BorderRadius.circular(FinoraRadii.pill),
        boxShadow: FinoraShadows.brandGlow,
      ),
      child: FloatingActionButton.extended(
        backgroundColor: Colors.transparent,
        elevation: 0,
        onPressed: onTap,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'Add Transaction',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class _EmptyDashboard extends StatelessWidget {
  const _EmptyDashboard({required this.businessName, required this.onSetup});
  final String? businessName;
  final VoidCallback onSetup;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FinoraColors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(FinoraSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.storefront_outlined, size: 60),
              const SizedBox(height: FinoraSpacing.md),
              Text(
                businessName == null
                    ? 'Set up your business'
                    : 'Loading $businessName',
                style: FinoraTextStyles.h1,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: FinoraSpacing.sm),
              Text(
                'Tell us about your business to see your dashboard.',
                style: FinoraTextStyles.body.copyWith(
                  color: FinoraColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: FinoraSpacing.xl),
              Material(
                color: FinoraColors.brandPrimary,
                borderRadius: BorderRadius.circular(FinoraRadii.md),
                child: InkWell(
                  borderRadius: BorderRadius.circular(FinoraRadii.md),
                  onTap: onSetup,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: FinoraSpacing.lg,
                      vertical: FinoraSpacing.md,
                    ),
                    child: Text(
                      'Set up business',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
