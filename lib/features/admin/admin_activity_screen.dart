import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/finora_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/finora_app_bar.dart';
import '../../core/widgets/finora_financial_card.dart';
import '../../core/widgets/finora_skeleton.dart';
import '../../data/repositories/admin_repository.dart';

class AdminActivityScreen extends ConsumerStatefulWidget {
  const AdminActivityScreen({super.key});

  @override
  ConsumerState<AdminActivityScreen> createState() =>
      _AdminActivityScreenState();
}

class _AdminActivityScreenState extends ConsumerState<AdminActivityScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  Timer? _debounce;
  String _search = '';
  String? _action;
  int _page = 1;
  static const int _pageSize = 30;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 280), () {
      setState(() {
        _search = value.trim();
        _page = 1;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FinoraColors.surface,
      appBar: FinoraAppBar(
        title: 'Activity',
        subtitle: 'Platform audit log',
        showBack: true,
        onBack: () => context.go('/admin'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              FinoraSpacing.lg,
              FinoraSpacing.sm,
              FinoraSpacing.lg,
              FinoraSpacing.sm,
            ),
            child: Column(
              children: [
                TextField(
                  controller: _searchCtrl,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Search by user, entity, action…',
                    prefixIcon: const Icon(Icons.search_rounded),
                    filled: true,
                    fillColor: FinoraColors.surfaceAlt,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(FinoraRadii.md),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: FinoraSpacing.sm),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _ActionChip(
                        label: 'All',
                        selected: _action == null,
                        onTap: () => setState(() {
                          _action = null;
                          _page = 1;
                        }),
                      ),
                      const SizedBox(width: FinoraSpacing.xs),
                      _ActionChip(
                        label: 'Register',
                        selected: _action == 'register',
                        tone: FinoraBadgeTone.brand,
                        onTap: () => setState(() {
                          _action = 'register';
                          _page = 1;
                        }),
                      ),
                      const SizedBox(width: FinoraSpacing.xs),
                      _ActionChip(
                        label: 'Login',
                        selected: _action == 'login',
                        tone: FinoraBadgeTone.positive,
                        onTap: () => setState(() {
                          _action = 'login';
                          _page = 1;
                        }),
                      ),
                      const SizedBox(width: FinoraSpacing.xs),
                      _ActionChip(
                        label: 'Transaction',
                        selected: _action == 'transaction_create',
                        tone: FinoraBadgeTone.brand,
                        onTap: () => setState(() {
                          _action = 'transaction_create';
                          _page = 1;
                        }),
                      ),
                      const SizedBox(width: FinoraSpacing.xs),
                      _ActionChip(
                        label: 'Business',
                        selected: _action == 'business_create',
                        tone: FinoraBadgeTone.info,
                        onTap: () => setState(() {
                          _action = 'business_create';
                          _page = 1;
                        }),
                      ),
                      const SizedBox(width: FinoraSpacing.xs),
                      _ActionChip(
                        label: 'Deactivate',
                        selected: _action == 'user_deactivate',
                        tone: FinoraBadgeTone.warning,
                        onTap: () => setState(() {
                          _action = 'user_deactivate';
                          _page = 1;
                        }),
                      ),
                      const SizedBox(width: FinoraSpacing.xs),
                      _ActionChip(
                        label: 'Activate',
                        selected: _action == 'user_activate',
                        tone: FinoraBadgeTone.positive,
                        onTap: () => setState(() {
                          _action = 'user_activate';
                          _page = 1;
                        }),
                      ),
                      const SizedBox(width: FinoraSpacing.xs),
                      _ActionChip(
                        label: 'Delete',
                        selected: _action == 'user_delete',
                        tone: FinoraBadgeTone.negative,
                        onTap: () => setState(() {
                          _action = 'user_delete';
                          _page = 1;
                        }),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<PagedResult<AdminActivityItem>>(
              key: ValueKey('act=$_action|search=$_search|page=$_page'),
              future: ref.read(adminRepositoryProvider).globalActivity(
                    search: _search.isEmpty ? null : _search,
                    action: _action,
                    page: _page,
                    pageSize: _pageSize,
                  ),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return ListView(
                    padding: const EdgeInsets.all(FinoraSpacing.lg),
                    children: const [
                      FinoraSkeleton(height: 64),
                      SizedBox(height: FinoraSpacing.sm),
                      FinoraSkeleton(height: 64),
                      SizedBox(height: FinoraSpacing.sm),
                      FinoraSkeleton(height: 64),
                    ],
                  );
                }
                if (snap.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(FinoraSpacing.xl),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.cloud_off_rounded,
                              size: 40, color: FinoraColors.negative),
                          const SizedBox(height: FinoraSpacing.md),
                          Text('Could not load activity',
                              style: FinoraTextStyles.h3),
                          const SizedBox(height: FinoraSpacing.xs),
                          Text(
                            snap.error.toString(),
                            textAlign: TextAlign.center,
                            style: FinoraTextStyles.caption,
                          ),
                          const SizedBox(height: FinoraSpacing.md),
                          FilledButton.icon(
                            onPressed: () => setState(() => _page = 1),
                            icon: const Icon(Icons.refresh_rounded),
                            label: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                final res = snap.data!;
                if (res.items.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(FinoraSpacing.xl),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.history_rounded,
                              size: 40, color: FinoraColors.textMuted),
                          const SizedBox(height: FinoraSpacing.md),
                          Text('No activity matches your filters',
                              style: FinoraTextStyles.h3),
                        ],
                      ),
                    ),
                  );
                }
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: FinoraSpacing.lg,
                      ),
                      child: Row(
                        children: [
                          Text('${res.totalItems} entries',
                              style: FinoraTextStyles.caption),
                          const Spacer(),
                          if (_page > 1)
                            IconButton(
                              onPressed: () => setState(() => _page -= 1),
                              icon: const Icon(Icons.chevron_left_rounded),
                            ),
                          Text('Page ${res.page} / ${res.totalPages}',
                              style: FinoraTextStyles.caption),
                          if (res.page < res.totalPages)
                            IconButton(
                              onPressed: () => setState(() => _page += 1),
                              icon: const Icon(Icons.chevron_right_rounded),
                            ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(
                          FinoraSpacing.lg,
                          FinoraSpacing.sm,
                          FinoraSpacing.lg,
                          FinoraSpacing.xxl,
                        ),
                        itemCount: res.items.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: FinoraSpacing.sm),
                        itemBuilder: (context, idx) {
                          final item = res.items[idx];
                          return _ActivityTile(item: item);
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.tone,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final FinoraBadgeTone? tone;

  @override
  Widget build(BuildContext context) {
    final color = switch (tone ?? FinoraBadgeTone.brand) {
      FinoraBadgeTone.brand => FinoraColors.brandPrimary,
      FinoraBadgeTone.positive => FinoraColors.positive,
      FinoraBadgeTone.warning => FinoraColors.warning,
      FinoraBadgeTone.negative => FinoraColors.negative,
      FinoraBadgeTone.info => FinoraColors.info,
      FinoraBadgeTone.neutral => FinoraColors.textPrimary,
    };
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(FinoraRadii.xl),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: FinoraSpacing.md,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: selected
              ? color.withValues(alpha: 0.14)
              : FinoraColors.surfaceAlt,
          border: Border.all(
            color: selected
                ? color.withValues(alpha: 0.4)
                : FinoraColors.outline.withValues(alpha: 0.5),
          ),
          borderRadius: BorderRadius.circular(FinoraRadii.xl),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? color : FinoraColors.textSecondary,
            fontWeight: FontWeight.w600,
            fontSize: 12,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({required this.item});
  final AdminActivityItem item;

  @override
  Widget build(BuildContext context) {
    final tone = _toneFor(item.action);
    return FinoraFinancialCard(
      tone: FinoraCardTone.neutral,
      padding: const EdgeInsets.symmetric(
        horizontal: FinoraSpacing.md,
        vertical: FinoraSpacing.md,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: finoraBadgeBg(tone),
              borderRadius: BorderRadius.circular(FinoraRadii.sm),
            ),
            alignment: Alignment.center,
            child: Icon(_iconFor(item.action),
                size: 18, color: finoraBadgeFg(tone)),
          ),
          const SizedBox(width: FinoraSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _humanize(item.action),
                  style: FinoraTextStyles.body
                      .copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  item.userEmail ?? 'system',
                  style: FinoraTextStyles.caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (item.entity != null && item.entity!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    '${item.entity}${item.entityId != null ? ' · ${item.entityId}' : ''}',
                    style: FinoraTextStyles.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  item.createdAt != null
                      ? formatRelativeDate(item.createdAt!)
                      : '',
                  style: FinoraTextStyles.caption,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  FinoraBadgeTone _toneFor(String action) {
    if (action.contains('delete')) return FinoraBadgeTone.negative;
    if (action.contains('deactivate')) return FinoraBadgeTone.warning;
    if (action.contains('activate')) return FinoraBadgeTone.positive;
    if (action.contains('create')) return FinoraBadgeTone.brand;
    if (action.contains('update')) return FinoraBadgeTone.info;
    if (action == 'login') return FinoraBadgeTone.positive;
    if (action == 'register') return FinoraBadgeTone.brand;
    return FinoraBadgeTone.neutral;
  }

  IconData _iconFor(String action) {
    if (action.contains('delete')) return Icons.delete_outline_rounded;
    if (action.contains('deactivate')) return Icons.block_rounded;
    if (action.contains('activate')) return Icons.check_circle_outline_rounded;
    if (action.contains('create')) return Icons.add_circle_outline_rounded;
    if (action.contains('update')) return Icons.edit_outlined;
    if (action == 'login') return Icons.login_rounded;
    if (action == 'register') return Icons.person_add_alt_rounded;
    return Icons.bolt_rounded;
  }

  String _humanize(String action) {
    return action
        .split('_')
        .map((p) => p.isEmpty ? p : '${p[0].toUpperCase()}${p.substring(1)}')
        .join(' ');
  }
}
