import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/finora_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/app_states.dart';
import '../../core/widgets/finora_app_bar.dart';
import '../../core/widgets/finora_financial_card.dart';
import '../../core/widgets/finora_gradient_button.dart';
import '../../core/widgets/finora_transaction_tile.dart';
import '../../data/active_business_controller.dart';
import '../../data/live_data.dart';
import '../../data/repositories/transaction_repository.dart';

class TransactionsFilter {
  const TransactionsFilter({this.type, this.category});
  final TransactionType? type;
  final String? category;

  TransactionsFilter copyWith({
    TransactionType? type,
    bool clearType = false,
    String? category,
    bool clearCategory = false,
  }) {
    return TransactionsFilter(
      type: clearType ? null : type ?? this.type,
      category: clearCategory ? null : category ?? this.category,
    );
  }
}

final _transactionsFilterProvider = StateProvider<TransactionsFilter>(
  (ref) => const TransactionsFilter(),
);

final _transactionsProvider =
    FutureProvider.autoDispose<List<TransactionModel>>((ref) async {
      ref.watch(liveDataVersionProvider);
      final state = ref.watch(activeBusinessControllerProvider);
      if (!state.hasBusiness) return const [];
      final filter = ref.watch(_transactionsFilterProvider);
      final repo = ref.watch(transactionRepositoryProvider);
      final page = await repo.list(
        type: filter.type,
        category: filter.category,
        pageSize: 100,
      );
      return page.items;
    });

class TransactionsScreen extends ConsumerWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(_transactionsFilterProvider);
    final transactions = ref.watch(_transactionsProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: FinoraAppBar(
        title: 'Transactions',
        subtitle: 'All entries',
        showBack: true,
        onBack: () => context.go('/dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => context.push('/transactions/add'),
            tooltip: 'Add transaction',
          ),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                FinoraSpacing.lg,
                FinoraSpacing.sm,
                FinoraSpacing.lg,
                FinoraSpacing.md,
              ),
              child: _FilterRow(filter: filter),
            ),
            Expanded(
              child: transactions.when(
                data: (items) {
                  if (items.isEmpty) {
                    return _EmptyTransactions(filter: filter);
                  }
                  return RefreshIndicator(
                    color: FinoraColors.brandPrimary,
                    onRefresh: () async =>
                        ref.invalidate(_transactionsProvider),
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(
                        FinoraSpacing.lg,
                        0,
                        FinoraSpacing.lg,
                        FinoraSpacing.xl,
                      ),
                      itemCount: items.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: FinoraSpacing.sm),
                      itemBuilder: (_, i) =>
                          _TransactionCard(transaction: items[i]),
                    ),
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: FinoraSpacing.xl),
                  child: LoadingState(),
                ),
                error: (e, _) => ErrorState(
                  message: 'Could not load transactions.',
                  onRetry: () => ref.invalidate(_transactionsProvider),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterRow extends ConsumerWidget {
  const _FilterRow({required this.filter});
  final TransactionsFilter filter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        _FilterChip(
          label: 'All',
          selected: filter.type == null,
          onTap: () => ref.read(_transactionsFilterProvider.notifier).state =
              filter.copyWith(clearType: true),
        ),
        const SizedBox(width: FinoraSpacing.xs),
        _FilterChip(
          label: 'Revenue',
          selected: filter.type == TransactionType.revenue,
          tone: FinoraBadgeTone.positive,
          onTap: () => ref.read(_transactionsFilterProvider.notifier).state =
              filter.copyWith(type: TransactionType.revenue),
        ),
        const SizedBox(width: FinoraSpacing.xs),
        _FilterChip(
          label: 'Expense',
          selected: filter.type == TransactionType.expense,
          tone: FinoraBadgeTone.negative,
          onTap: () => ref.read(_transactionsFilterProvider.notifier).state =
              filter.copyWith(type: TransactionType.expense),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.tone = FinoraBadgeTone.brand,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final FinoraBadgeTone tone;

  @override
  Widget build(BuildContext context) {
    final fg = finoraBadgeFg(tone);
    final bg = finoraBadgeBg(tone);
    final bgColor = selected ? fg : FinoraColors.surfaceAlt;
    final fgColor = selected ? Colors.white : FinoraColors.textPrimary;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(FinoraRadii.pill),
        onTap: onTap,
        child: AnimatedContainer(
          duration: FinoraMotion.fast,
          padding: const EdgeInsets.symmetric(
            horizontal: FinoraSpacing.md,
            vertical: FinoraSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(FinoraRadii.pill),
            border: Border.all(color: selected ? fg : bg, width: 1.2),
          ),
          child: Text(
            label,
            style: FinoraTextStyles.label.copyWith(color: fgColor),
          ),
        ),
      ),
    );
  }
}

class _TransactionCard extends ConsumerWidget {
  const _TransactionCard({required this.transaction});
  final TransactionModel transaction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isRevenue = transaction.type == TransactionType.revenue;
    final txCurrency = transaction.currency.isEmpty
        ? ref.watch(activeBusinessCurrencyProvider)
        : transaction.currency;
    return FinoraTransactionTile(
      title: transaction.category,
      subtitle:
          transaction.description != null && transaction.description!.isNotEmpty
          ? '${transaction.description} • ${formatDate(transaction.occurredAt)}'
          : formatDate(transaction.occurredAt),
      amount: formatMoney(transaction.amount, currency: txCurrency),
      amountPrefix: isRevenue ? '+' : '-',
      icon: isRevenue ? Icons.trending_up_rounded : Icons.trending_down_rounded,
      iconColor: isRevenue ? FinoraColors.positive : FinoraColors.negative,
      iconBackground: isRevenue
          ? FinoraColors.positiveSoft
          : FinoraColors.negativeSoft,
      onTap: () => context.push('/transactions'),
    );
  }
}

class _EmptyTransactions extends StatelessWidget {
  const _EmptyTransactions({required this.filter});
  final TransactionsFilter filter;

  @override
  Widget build(BuildContext context) {
    final isFiltered = filter.type != null || filter.category != null;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(FinoraSpacing.xl),
        child: FinoraFinancialCard(
          tone: FinoraCardTone.neutral,
          padding: const EdgeInsets.symmetric(
            vertical: FinoraSpacing.lg,
            horizontal: FinoraSpacing.md,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.receipt_long_outlined,
                size: 40,
                color: FinoraColors.textMuted,
              ),
              const SizedBox(height: FinoraSpacing.sm),
              Text(
                isFiltered
                    ? 'No transactions match your filters'
                    : 'No transactions yet',
                style: FinoraTextStyles.h4,
              ),
              const SizedBox(height: 4),
              Text(
                isFiltered
                    ? 'Try clearing filters to see all entries.'
                    : 'Log your first entry to see your numbers come alive.',
                style: FinoraTextStyles.caption.copyWith(
                  color: FinoraColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: FinoraSpacing.md),
              FinoraGradientButton(
                label: isFiltered ? 'Clear filters' : 'Add transaction',
                icon: isFiltered
                    ? Icons.filter_alt_off_rounded
                    : Icons.add_rounded,
                fullWidth: false,
                onPressed: () {
                  if (isFiltered) {
                    context.push('/transactions');
                  } else {
                    context.push('/transactions/add');
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
