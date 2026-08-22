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
import '../../data/repositories/financial_repository.dart';

class CashPressureScreen extends ConsumerWidget {
  const CashPressureScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pressure = ref.watch(_cashPressureProvider);
    final state = ref.watch(activeBusinessControllerProvider);

    return Scaffold(
      backgroundColor: FinoraColors.surface,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: FinoraHeroHeader(
                height: 260,
                greeting: 'CASH FORECAST',
                title: 'Cash pressure',
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
                  pressure.when(
                    data: (p) {
                      return Column(
                        children: [
                          FinoraGlassCard(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                FinoraPressureGauge(
                                  value: p.pressure,
                                  label: p.label,
                                  size: 200,
                                  gradient: FinoraGradients.danger,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  p.description,
                                  textAlign: TextAlign.center,
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
                            child: Row(
                              children: [
                                _StatCell(
                                  label: 'Monthly net',
                                  value: formatMoney(p.monthlyNet, currency: p.currency),
                                  highlight: p.monthlyNet >= 0,
                                ),
                                const SizedBox(
                                  height: 36,
                                  child: VerticalDivider(width: 1, thickness: 1),
                                ),
                                _StatCell(
                                  label: 'Buffer',
                                  value: '${p.bufferMonths.toStringAsFixed(1)} mo',
                                  highlight: p.bufferMonths >= 3,
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
                                Text('Recommendations', style: FinoraTextStyles.h4),
                                const SizedBox(height: 8),
                                const _RecRow(text: 'Collect receivables earlier'),
                                const _Divider(),
                                const _RecRow(text: 'Reduce discretionary spend'),
                                const _Divider(),
                                const _RecRow(text: 'Negotiate longer payment terms'),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                    loading: () => const Padding(
                      padding: EdgeInsets.symmetric(vertical: 80),
                      child: LoadingState(),
                    ),
                    error: (e, _) => ErrorState(
                      message: 'Could not compute pressure.',
                      onRetry: () => ref.invalidate(_cashPressureProvider),
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

class _StatCell extends StatelessWidget {
  const _StatCell({required this.label, required this.value, required this.highlight});
  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(label, style: FinoraTextStyles.overline),
          const SizedBox(height: 4),
          Text(
            value,
            style: FinoraTextStyles.h3.copyWith(
              color: highlight ? FinoraColors.textPrimary : FinoraColors.negative,
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, thickness: 1);
  }
}

class _RecRow extends StatelessWidget {
  const _RecRow({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          const Icon(Icons.bolt_rounded, color: FinoraColors.brandPrimary, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: FinoraTextStyles.body)),
        ],
      ),
    );
  }
}

class _CashPressure {
  const _CashPressure({
    required this.pressure,
    required this.label,
    required this.description,
    required this.monthlyNet,
    required this.bufferMonths,
    required this.currency,
  });
  final double pressure;
  final String label;
  final String description;
  final double monthlyNet;
  final double bufferMonths;
  final String currency;
}

final _cashPressureProvider = FutureProvider.autoDispose<_CashPressure>((
  ref,
) async {
  ref.watch(liveDataVersionProvider);
  final state = ref.watch(activeBusinessControllerProvider);
  if (!state.hasBusiness) throw StateError('No active business');
  final repo = ref.watch(financialRepositoryProvider);
  final h = await repo.health();
  final months = h.cashBufferMonths;
  final monthlyNet = h.monthlyNet;
  double pressure = 0;
  String label = 'Healthy';
  String desc = 'You have a healthy cash runway right now.';
  if (months < 1) {
    pressure = 0.95;
    label = 'Critical';
    desc = 'Less than 1 month of runway. Act immediately.';
  } else if (months < 2) {
    pressure = 0.7;
    label = 'High';
    desc = '2 months of buffer or less. Tighten outflow.';
  } else if (months < 3.5) {
    pressure = 0.45;
    label = 'Watch';
    desc = 'Buffer is under 3.5 months. Plan ahead.';
  }
  return _CashPressure(
    pressure: pressure,
    label: label,
    description: desc,
    monthlyNet: monthlyNet,
    bufferMonths: months.clamp(0, 24),
    currency: state.business?.currency ?? 'BDT',
  );
});