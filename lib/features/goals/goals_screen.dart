import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme/finora_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/finora_glass_card.dart';
import '../../core/widgets/finora_hero_header.dart';
import '../../data/active_business_controller.dart';

class _Goal {
  _Goal({required this.id, required this.title, required this.saved, required this.target});
  final String id;
  final String title;
  final double saved;
  final double target;

  double get percent => target == 0 ? 0 : (saved / target).clamp(0.0, 1.0);

  Map<String, dynamic> toJson() =>
      {'id': id, 'title': title, 'saved': saved, 'target': target};

  static _Goal fromJson(Map<String, dynamic> j) => _Goal(
        id: j['id'] as String,
        title: j['title'] as String,
        saved: (j['saved'] as num).toDouble(),
        target: (j['target'] as num).toDouble(),
      );
}

final goalsProvider =
    StateNotifierProvider<GoalsController, List<_Goal>>((ref) => GoalsController());

class GoalsController extends StateNotifier<List<_Goal>> {
  GoalsController() : super([]) {
    _load();
  }

  static const _key = 'finora_goals_v1';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return;
    try {
      final list = (jsonDecode(raw) as List)
          .map((e) => _Goal.fromJson(e as Map<String, dynamic>))
          .toList();
      state = list;
    } catch (_) {}
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final list = state.map((g) => g.toJson()).toList();
    await prefs.setString(_key, jsonEncode(list));
  }

  Future<void> add(String title, double target) async {
    final goal = _Goal(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      saved: 0,
      target: target,
    );
    state = [...state, goal];
    await _save();
  }

  Future<void> contribute(String id, double amount) async {
    state = state
        .map((g) => g.id == id
            ? _Goal(id: g.id, title: g.title, saved: g.saved + amount, target: g.target)
            : g)
        .toList();
    await _save();
  }

  Future<void> remove(String id) async {
    state = state.where((g) => g.id != id).toList();
    await _save();
  }
}

class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goals = ref.watch(goalsProvider);
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
                greeting: 'GOAL PLANNER',
                title: 'Hit your targets',
                subtitle: state.business?.name ?? 'Your business',
                meshColors: FinoraHeroPalettes.dashboardMesh,
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
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Track savings goals.',
                          style: FinoraTextStyles.body.copyWith(
                            color: FinoraColors.textSecondary,
                          ),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => _showAddDialog(context, ref),
                        icon: const Icon(Icons.add),
                        label: const Text('Add'),
                      ),
                    ],
                  ),
                  const SizedBox(height: FinoraSpacing.md),
                  if (goals.isEmpty)
                    FinoraGlassCard(
                      padding: const EdgeInsets.all(FinoraSpacing.lg),
                      child: Text(
                        'No goals yet. Tap Add to set your first one.',
                        style: FinoraTextStyles.body.copyWith(
                          color: FinoraColors.textSecondary,
                        ),
                      ),
                    ),
                  ...goals.map(
                    (g) => Padding(
                      padding: const EdgeInsets.only(bottom: FinoraSpacing.sm),
                      child: _GoalTile(
                        goal: g,
                        currency: currency,
                        onContribute: () => _showContributeDialog(context, ref, g.id),
                        onDelete: () => ref.read(goalsProvider.notifier).remove(g.id),
                      ),
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

  Future<void> _showAddDialog(BuildContext context, WidgetRef ref) async {
    final titleCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    final currency = ref.read(activeBusinessCurrencyProvider);
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add goal'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(labelText: 'Goal name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: amountCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Target ($currency)',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              final t = titleCtrl.text.trim();
              final a = double.tryParse(amountCtrl.text) ?? 0;
              if (t.isEmpty || a <= 0) return;
              Navigator.pop(ctx, {'title': t, 'amount': a});
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
    if (result != null) {
      ref.read(goalsProvider.notifier).add(result['title'] as String, result['amount'] as double);
    }
  }

  Future<void> _showContributeDialog(BuildContext context, WidgetRef ref, String goalId) async {
    final amountCtrl = TextEditingController();
    final currency = ref.read(activeBusinessCurrencyProvider);
    final result = await showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add to goal'),
        content: TextField(
          controller: amountCtrl,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: 'Amount ($currency)'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              final a = double.tryParse(amountCtrl.text) ?? 0;
              if (a <= 0) return;
              Navigator.pop(ctx, a);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
    if (result != null) {
      ref.read(goalsProvider.notifier).contribute(goalId, result);
    }
  }
}

class _GoalTile extends StatelessWidget {
  const _GoalTile({
    required this.goal,
    required this.currency,
    required this.onContribute,
    required this.onDelete,
  });

  final _Goal goal;
  final String currency;
  final VoidCallback onContribute;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return FinoraGlassCard(
      padding: const EdgeInsets.all(FinoraSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(goal.title, style: FinoraTextStyles.h4)),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: FinoraColors.textMuted),
                onPressed: onDelete,
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            '${formatMoney(goal.saved, currency: currency)} of ${formatMoney(goal.target, currency: currency)}',
            style: FinoraTextStyles.caption.copyWith(
              color: FinoraColors.textSecondary,
            ),
          ),
          const SizedBox(height: FinoraSpacing.sm),
          FinoraScoreBar(
            value: goal.percent,
            gradient: FinoraGradients.ocean,
            label: '${(goal.percent * 100).round()}%',
          ),
          const SizedBox(height: FinoraSpacing.sm),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: onContribute,
              icon: const Icon(Icons.add),
              label: const Text('Add to goal'),
            ),
          ),
        ],
      ),
    );
  }
}
