import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/finora_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/finora_app_bar.dart';
import '../../core/widgets/finora_financial_card.dart';
import '../../core/widgets/finora_metric_card.dart';
import '../../core/widgets/finora_skeleton.dart';
import '../../data/auth_session_controller.dart';
import '../../data/repositories/admin_repository.dart';

class AdminUserDetailsScreen extends ConsumerStatefulWidget {
  const AdminUserDetailsScreen({super.key, required this.userId});
  final String userId;

  @override
  ConsumerState<AdminUserDetailsScreen> createState() =>
      _AdminUserDetailsScreenState();
}

class _AdminUserDetailsScreenState
    extends ConsumerState<AdminUserDetailsScreen> {
  late Future<_DetailData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_DetailData> _load() async {
    final repo = ref.read(adminRepositoryProvider);
    final results = await Future.wait([
      repo.getUser(widget.userId),
      repo.userActivity(widget.userId, pageSize: 30),
    ]);
    return _DetailData(
      user: results[0] as AdminUserDetail,
      activity: results[1] as PagedResult<AdminActivityItem>,
    );
  }

  void _refresh() {
    setState(() {
      _future = _load();
    });
  }

  Future<void> _confirmAction({
    required String title,
    required String message,
    required Future<AdminActionResult> Function() action,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      final res = await action();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res.message)),
      );
      if (res.success) _refresh();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId =
        ref.watch(authSessionControllerProvider).session?.userId;
    return Scaffold(
      backgroundColor: FinoraColors.surface,
      appBar: FinoraAppBar(
        title: 'Account',
        subtitle: 'Manage user access',
        showBack: true,
        onBack: () => context.go('/admin/users'),
      ),
      body: RefreshIndicator(
        color: FinoraColors.brandPrimary,
        onRefresh: () async => _refresh(),
        child: FutureBuilder<_DetailData>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return ListView(
                padding: const EdgeInsets.all(FinoraSpacing.lg),
                children: const [
                  FinoraSkeleton(height: 160),
                  SizedBox(height: FinoraSpacing.md),
                  FinoraSkeleton(height: 64),
                  SizedBox(height: FinoraSpacing.md),
                  FinoraSkeleton(height: 200),
                ],
              );
            }
            if (snap.hasError) {
              return _ErrorView(
                message: snap.error.toString(),
                onRetry: _refresh,
              );
            }
            final data = snap.data!;
            final user = data.user;
            final isSelf = user.id == currentUserId;
            return ListView(
              padding: const EdgeInsets.fromLTRB(
                FinoraSpacing.lg,
                FinoraSpacing.sm,
                FinoraSpacing.lg,
                FinoraSpacing.xxl,
              ),
              children: [
                _IdentityCard(user: user, isSelf: isSelf),
                const SizedBox(height: FinoraSpacing.md),
                _MetricsGrid(user: user),
                const SizedBox(height: FinoraSpacing.md),
                _BusinessCard(business: user.business),
                const SizedBox(height: FinoraSpacing.md),
                _ActionsCard(
                  user: user,
                  isSelf: isSelf,
                  onActivate: isSelf
                      ? null
                      : () => _confirmAction(
                            title: 'Reactivate account',
                            message:
                                '${user.email} will be able to sign in again.',
                            action: () => ref
                                .read(adminRepositoryProvider)
                                .setActive(userId: user.id, active: true),
                          ),
                  onDeactivate: isSelf
                      ? null
                      : () => _confirmAction(
                            title: 'Deactivate account',
                            message:
                                '${user.email} will not be able to sign in until reactivated.',
                            action: () => ref
                                .read(adminRepositoryProvider)
                                .setActive(userId: user.id, active: false),
                          ),
                  onDelete: isSelf
                      ? null
                      : () => _confirmAction(
                            title: 'Delete account',
                            message:
                                'Permanently delete ${user.email} and all their data. This cannot be undone.',
                            action: () => ref
                                .read(adminRepositoryProvider)
                                .deleteUser(user.id),
                          ),
                ),
                const SizedBox(height: FinoraSpacing.md),
                _ActivitySection(activity: data.activity),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _DetailData {
  _DetailData({required this.user, required this.activity});
  final AdminUserDetail user;
  final PagedResult<AdminActivityItem> activity;
}

class _IdentityCard extends StatelessWidget {
  const _IdentityCard({required this.user, required this.isSelf});
  final AdminUserDetail user;
  final bool isSelf;

  @override
  Widget build(BuildContext context) {
    final initials = _initialsFor(user);
    return Container(
      padding: const EdgeInsets.all(FinoraSpacing.lg),
      decoration: BoxDecoration(
        gradient: FinoraGradients.midnight,
        borderRadius: BorderRadius.circular(FinoraRadii.xl),
        boxShadow: FinoraShadows.brandGlow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(FinoraRadii.md),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.25),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  initials,
                  style: GoogleFonts.sora(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 22,
                  ),
                ),
              ),
              const SizedBox(width: FinoraSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      user.fullName.isEmpty ? user.email : user.fullName,
                      style: GoogleFonts.sora(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      user.email,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (isSelf)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'YOU',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: FinoraSpacing.md),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _TagPill(
                label: user.role,
                color: user.role.toLowerCase() == 'admin'
                    ? FinoraColors.info
                    : FinoraColors.brandPrimary,
              ),
              _TagPill(
                label: user.isActive ? 'Active' : 'Inactive',
                color: user.isActive
                    ? FinoraColors.positive
                    : FinoraColors.warning,
              ),
              _TagPill(
                label: 'Joined ${formatDate(user.createdAt)}',
                color: FinoraColors.brandAccent,
              ),
            ],
          ),
          const SizedBox(height: FinoraSpacing.sm),
          Text(
            'User ID: ${user.id}',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 11,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  String _initialsFor(AdminUserDetail user) {
    final base = user.fullName.isNotEmpty ? user.fullName : user.email;
    final parts = base
        .split(RegExp(r'[\s@.]+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }
}

class _TagPill extends StatelessWidget {
  const _TagPill({required this.label, required this.color});
  final String label;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.7),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricsGrid extends StatelessWidget {
  const _MetricsGrid({required this.user});
  final AdminUserDetail user;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      crossAxisSpacing: FinoraSpacing.sm,
      mainAxisSpacing: FinoraSpacing.sm,
      childAspectRatio: 1.1,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      children: [
        FinoraMetricCard(
          label: 'Transactions',
          value: '${user.transactionCount}',
          icon: Icons.swap_vert_rounded,
          accentColor: FinoraColors.brandPrimary,
          compact: true,
        ),
        FinoraMetricCard(
          label: 'Loans',
          value: '${user.loanCount}',
          icon: Icons.account_balance_rounded,
          accentColor: FinoraColors.warning,
          compact: true,
        ),
        FinoraMetricCard(
          label: 'Simulations',
          value: '${user.simulationCount}',
          icon: Icons.psychology_alt_rounded,
          accentColor: FinoraColors.brandViolet,
          compact: true,
        ),
      ],
    );
  }
}

class _BusinessCard extends StatelessWidget {
  const _BusinessCard({required this.business});
  final AdminBusinessSummary? business;

  @override
  Widget build(BuildContext context) {
    if (business == null) {
      return FinoraFinancialCard(
        tone: FinoraCardTone.neutral,
        child: Row(
          children: [
            const Icon(Icons.storefront_rounded,
                color: FinoraColors.textMuted),
            const SizedBox(width: FinoraSpacing.sm),
            Expanded(
              child: Text(
                'No business linked to this account',
                style: FinoraTextStyles.body,
              ),
            ),
          ],
        ),
      );
    }
    final b = business!;
    return FinoraFinancialCard(
      tone: FinoraCardTone.brand,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.storefront_rounded,
                  color: FinoraColors.brandPrimary),
              const SizedBox(width: FinoraSpacing.xs),
              Text('Business', style: FinoraTextStyles.h3),
              const Spacer(),
              Text(b.type, style: FinoraTextStyles.caption),
            ],
          ),
          const SizedBox(height: FinoraSpacing.sm),
          Text(b.name, style: FinoraTextStyles.h2),
          const SizedBox(height: 2),
          if (b.category != null)
            Text(b.category!, style: FinoraTextStyles.caption),
          const SizedBox(height: FinoraSpacing.sm),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              _MiniTag(label: 'Currency ${b.currency}'),
              _MiniTag(label: 'Since ${b.startingYear}'),
              if (b.createdAt != null)
                _MiniTag(label: 'Created ${formatDate(b.createdAt)}'),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniTag extends StatelessWidget {
  const _MiniTag({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: FinoraColors.brandPrimarySoft,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: FinoraColors.brandPrimary,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ActionsCard extends StatelessWidget {
  const _ActionsCard({
    required this.user,
    required this.isSelf,
    required this.onActivate,
    required this.onDeactivate,
    required this.onDelete,
  });

  final AdminUserDetail user;
  final bool isSelf;
  final VoidCallback? onActivate;
  final VoidCallback? onDeactivate;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return FinoraFinancialCard(
      tone: FinoraCardTone.neutral,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.admin_panel_settings_rounded,
                color: FinoraColors.brandPrimary,
              ),
              const SizedBox(width: FinoraSpacing.xs),
              Text('Admin actions', style: FinoraTextStyles.h3),
            ],
          ),
          if (isSelf) ...[
            const SizedBox(height: FinoraSpacing.sm),
            Container(
              padding: const EdgeInsets.all(FinoraSpacing.sm),
              decoration: BoxDecoration(
                color: FinoraColors.warning.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(FinoraRadii.sm),
              ),
              child: Row(
                children: [
                  const Icon(Icons.shield_outlined,
                      color: FinoraColors.warning, size: 18),
                  const SizedBox(width: FinoraSpacing.xs),
                  Expanded(
                    child: Text(
                      'You cannot modify or delete your own admin account.',
                      style: TextStyle(
                        color: FinoraColors.warning,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: FinoraSpacing.sm),
          Wrap(
            spacing: FinoraSpacing.xs,
            runSpacing: FinoraSpacing.xs,
            children: [
              if (onActivate != null)
                FilledButton.icon(
                  onPressed: onActivate,
                  icon: const Icon(Icons.check_circle_outline_rounded,
                      size: 16),
                  label: const Text('Activate'),
                ),
              if (onDeactivate != null)
                FilledButton.tonalIcon(
                  onPressed: onDeactivate,
                  style: FilledButton.styleFrom(
                    backgroundColor:
                        FinoraColors.warning.withValues(alpha: 0.14),
                    foregroundColor: FinoraColors.warning,
                  ),
                  icon: const Icon(Icons.block_rounded, size: 16),
                  label: const Text('Deactivate'),
                ),
              if (onDelete != null)
                FilledButton.icon(
                  onPressed: onDelete,
                  style: FilledButton.styleFrom(
                    backgroundColor:
                        FinoraColors.negative.withValues(alpha: 0.12),
                    foregroundColor: FinoraColors.negative,
                  ),
                  icon: const Icon(Icons.delete_outline_rounded, size: 16),
                  label: const Text('Delete'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActivitySection extends StatelessWidget {
  const _ActivitySection({required this.activity});
  final PagedResult<AdminActivityItem> activity;

  @override
  Widget build(BuildContext context) {
    return FinoraFinancialCard(
      tone: FinoraCardTone.neutral,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.history_rounded,
                color: FinoraColors.brandPrimary,
              ),
              const SizedBox(width: FinoraSpacing.xs),
              Text('Recent activity', style: FinoraTextStyles.h3),
              const Spacer(),
              Text('${activity.totalItems} entries',
                  style: FinoraTextStyles.caption),
            ],
          ),
          const SizedBox(height: FinoraSpacing.sm),
          if (activity.items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: FinoraSpacing.md),
              child: Text(
                'No activity recorded yet for this user.',
                style: FinoraTextStyles.caption,
              ),
            )
          else
            Column(
              children: [
                for (final a in activity.items.take(12)) _Row(item: a),
              ],
            ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.item});
  final AdminActivityItem item;
  @override
  Widget build(BuildContext context) {
    final tone = _toneFor(item.action);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: FinoraSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: finoraBadgeBg(tone),
              borderRadius: BorderRadius.circular(FinoraRadii.sm),
            ),
            alignment: Alignment.center,
            child: Icon(_iconFor(item.action),
                size: 16, color: finoraBadgeFg(tone)),
          ),
          const SizedBox(width: FinoraSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _humanize(item.action),
                  style: FinoraTextStyles.body
                      .copyWith(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (item.entity != null && item.entity!.isNotEmpty)
                  Text(
                    item.entity! +
                        (item.entityId != null
                            ? ' · ${item.entityId}'
                            : ''),
                    style: FinoraTextStyles.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
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

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(FinoraSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded,
                size: 40, color: FinoraColors.negative),
            const SizedBox(height: FinoraSpacing.md),
            Text('Could not load account', style: FinoraTextStyles.h3),
            const SizedBox(height: FinoraSpacing.xs),
            Text(message,
                textAlign: TextAlign.center, style: FinoraTextStyles.caption),
            const SizedBox(height: FinoraSpacing.md),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
