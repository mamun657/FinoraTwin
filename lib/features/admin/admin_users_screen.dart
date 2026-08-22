import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/finora_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/finora_app_bar.dart';
import '../../core/widgets/finora_financial_card.dart';
import '../../core/widgets/finora_skeleton.dart';
import '../../data/auth_session_controller.dart';
import '../../data/repositories/admin_repository.dart';

class AdminUsersScreen extends ConsumerStatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  ConsumerState<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends ConsumerState<AdminUsersScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  Timer? _debounce;
  String _search = '';
  bool? _filterActive;
  String? _filterRole;
  int _page = 1;
  static const int _pageSize = 20;

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

  void _reload() {
    setState(() {
      _page = 1;
    });
  }

  Future<void> _confirmAction({
    required String title,
    required String message,
    required Future<AdminActionResult> Function() action,
    required VoidCallback onSuccess,
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
      if (res.success) onSuccess();
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
        title: 'Users',
        subtitle: 'Manage platform accounts',
        showBack: true,
        onBack: () => context.go('/admin'),
      ),
      body: Column(
        children: [
          _SearchAndFilters(
            controller: _searchCtrl,
            onChanged: _onSearchChanged,
            isActiveFilter: _filterActive,
            roleFilter: _filterRole,
            onActiveChanged: (v) {
              setState(() {
                _filterActive = v;
                _page = 1;
              });
            },
            onRoleChanged: (v) {
              setState(() {
                _filterRole = v;
                _page = 1;
              });
            },
          ),
          Expanded(
            child: FutureBuilder<PagedResult<AdminUserListItem>>(
              key: ValueKey('page=$_page|search=$_search|act=$_filterActive|role=$_filterRole'),
              future: ref.read(adminRepositoryProvider).listUsers(
                    search: _search.isEmpty ? null : _search,
                    isActive: _filterActive,
                    role: _filterRole,
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
                  return _ErrorView(
                    message: snap.error.toString(),
                    onRetry: _reload,
                  );
                }
                final res = snap.data!;
                if (res.items.isEmpty) {
                  return _EmptyView(onReset: () {
                    _searchCtrl.clear();
                    setState(() {
                      _search = '';
                      _filterActive = null;
                      _filterRole = null;
                      _page = 1;
                    });
                  });
                }
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        FinoraSpacing.lg,
                        FinoraSpacing.sm,
                        FinoraSpacing.lg,
                        0,
                      ),
                      child: Row(
                        children: [
                          Text(
                            '${res.totalItems} accounts',
                            style: FinoraTextStyles.caption,
                          ),
                          const Spacer(),
                          if (_page > 1)
                            IconButton(
                              onPressed: () => setState(() => _page -= 1),
                              icon: const Icon(Icons.chevron_left_rounded),
                            ),
                          Text(
                            'Page ${res.page} / ${res.totalPages}',
                            style: FinoraTextStyles.caption,
                          ),
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
                        separatorBuilder: (_, __) => const SizedBox(height: FinoraSpacing.sm),
                        itemBuilder: (context, idx) {
                          final user = res.items[idx];
                          final isSelf = user.id == currentUserId;
                          return _UserTile(
                            user: user,
                            isSelf: isSelf,
                            onTap: () => context.go('/admin/users/${user.id}'),
                            onActivate: isSelf
                                ? null
                                : () => _confirmAction(
                                      title: 'Reactivate account',
                                      message:
                                          '${user.email} will be able to sign in again.',
                                      action: () => ref
                                          .read(adminRepositoryProvider)
                                          .setActive(
                                            userId: user.id,
                                            active: true,
                                          ),
                                      onSuccess: _reload,
                                    ),
                            onDeactivate: isSelf
                                ? null
                                : () => _confirmAction(
                                      title: 'Deactivate account',
                                      message:
                                          '${user.email} will not be able to sign in until reactivated.',
                                      action: () => ref
                                          .read(adminRepositoryProvider)
                                          .setActive(
                                            userId: user.id,
                                            active: false,
                                          ),
                                      onSuccess: _reload,
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
                                      onSuccess: _reload,
                                    ),
                          );
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

class _SearchAndFilters extends StatelessWidget {
  const _SearchAndFilters({
    required this.controller,
    required this.onChanged,
    required this.isActiveFilter,
    required this.roleFilter,
    required this.onActiveChanged,
    required this.onRoleChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final bool? isActiveFilter;
  final String? roleFilter;
  final ValueChanged<bool?> onActiveChanged;
  final ValueChanged<String?> onRoleChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        FinoraSpacing.lg,
        FinoraSpacing.sm,
        FinoraSpacing.lg,
        FinoraSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: controller,
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: 'Search by email or name…',
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
                _FilterChip(
                  label: 'All status',
                  selected: isActiveFilter == null,
                  onTap: () => onActiveChanged(null),
                ),
                const SizedBox(width: FinoraSpacing.xs),
                _FilterChip(
                  label: 'Active',
                  selected: isActiveFilter == true,
                  tone: FinoraBadgeTone.positive,
                  onTap: () => onActiveChanged(true),
                ),
                const SizedBox(width: FinoraSpacing.xs),
                _FilterChip(
                  label: 'Inactive',
                  selected: isActiveFilter == false,
                  tone: FinoraBadgeTone.warning,
                  onTap: () => onActiveChanged(false),
                ),
                const SizedBox(width: FinoraSpacing.md),
                _FilterChip(
                  label: 'All roles',
                  selected: roleFilter == null,
                  onTap: () => onRoleChanged(null),
                ),
                const SizedBox(width: FinoraSpacing.xs),
                _FilterChip(
                  label: 'Users',
                  selected: roleFilter == 'User',
                  tone: FinoraBadgeTone.brand,
                  onTap: () => onRoleChanged('User'),
                ),
                const SizedBox(width: FinoraSpacing.xs),
                _FilterChip(
                  label: 'Admins',
                  selected: roleFilter == 'Admin',
                  tone: FinoraBadgeTone.info,
                  onTap: () => onRoleChanged('Admin'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
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
          color: selected ? color.withValues(alpha: 0.14) : FinoraColors.surfaceAlt,
          border: Border.all(
            color: selected ? color.withValues(alpha: 0.4) : FinoraColors.outline.withValues(alpha: 0.5),
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

class _UserTile extends StatelessWidget {
  const _UserTile({
    required this.user,
    required this.isSelf,
    required this.onTap,
    required this.onActivate,
    required this.onDeactivate,
    required this.onDelete,
  });

  final AdminUserListItem user;
  final bool isSelf;
  final VoidCallback onTap;
  final VoidCallback? onActivate;
  final VoidCallback? onDeactivate;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final avatar = Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: (user.role.toLowerCase() == 'admin'
                ? FinoraColors.info
                : FinoraColors.brandPrimary)
            .withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(FinoraRadii.md),
        border: Border.all(
          color: FinoraColors.outline.withValues(alpha: 0.5),
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        _initialsFor(user),
        style: const TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 14,
          color: FinoraColors.brandPrimary,
        ),
      ),
    );

    return FinoraFinancialCard(
      tone: FinoraCardTone.neutral,
      padding: const EdgeInsets.symmetric(
        horizontal: FinoraSpacing.md,
        vertical: FinoraSpacing.md,
      ),
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          avatar,
          const SizedBox(width: FinoraSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        user.fullName.isEmpty ? user.email : user.fullName,
                        style: FinoraTextStyles.body.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isSelf)
                      Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: FinoraColors.info.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'You',
                            style: TextStyle(
                              color: FinoraColors.info,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  user.email,
                  style: FinoraTextStyles.caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    _StatusPill(isActive: user.isActive),
                    _RolePill(role: user.role),
                    if (user.hasBusiness && user.businessName != null)
                      _MiniPill(
                        icon: Icons.storefront_rounded,
                        label: user.businessName!,
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  user.lastLoginAt != null
                      ? 'Last login ${formatRelativeDate(user.lastLoginAt!)}'
                      : 'Never signed in',
                  style: FinoraTextStyles.caption,
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          PopupMenuButton<String>(
            tooltip: 'Actions',
            onSelected: (value) {
              switch (value) {
                case 'view':
                  onTap();
                  break;
                case 'activate':
                  onActivate?.call();
                  break;
                case 'deactivate':
                  onDeactivate?.call();
                  break;
                case 'delete':
                  onDelete?.call();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'view',
                child: ListTile(
                  leading: Icon(Icons.person_search_rounded),
                  title: Text('View details'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              if (onActivate != null)
                const PopupMenuItem(
                  value: 'activate',
                  child: ListTile(
                    leading: Icon(Icons.check_circle_outline_rounded),
                    title: Text('Activate'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              if (onDeactivate != null)
                const PopupMenuItem(
                  value: 'deactivate',
                  child: ListTile(
                    leading: Icon(Icons.block_rounded),
                    title: Text('Deactivate'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              if (onDelete != null)
                const PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(
                      Icons.delete_outline_rounded,
                      color: FinoraColors.negative,
                    ),
                    title: Text(
                      'Delete',
                      style: TextStyle(color: FinoraColors.negative),
                    ),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              if (onActivate == null && onDeactivate == null && onDelete == null)
                const PopupMenuItem(
                  enabled: false,
                  child: Text('No actions for your own account'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _initialsFor(AdminUserListItem user) {
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

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.isActive});
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final tone =
        isActive ? FinoraBadgeTone.positive : FinoraBadgeTone.warning;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: finoraBadgeBg(tone),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: finoraBadgeFg(tone).withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: finoraBadgeFg(tone),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            isActive ? 'Active' : 'Inactive',
            style: TextStyle(
              color: finoraBadgeFg(tone),
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _RolePill extends StatelessWidget {
  const _RolePill({required this.role});
  final String role;
  @override
  Widget build(BuildContext context) {
    final tone = role.toLowerCase() == 'admin'
        ? FinoraBadgeTone.info
        : FinoraBadgeTone.neutral;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: finoraBadgeBg(tone),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: finoraBadgeFg(tone).withValues(alpha: 0.4)),
      ),
      child: Text(
        role,
        style: TextStyle(
          color: finoraBadgeFg(tone),
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _MiniPill extends StatelessWidget {
  const _MiniPill({required this.icon, required this.label});
  final IconData icon;
  final String label;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: FinoraColors.brandViolet.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: FinoraColors.brandViolet),
          const SizedBox(width: 4),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 140),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: FinoraColors.brandViolet,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
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
            const Icon(
              Icons.cloud_off_rounded,
              size: 40,
              color: FinoraColors.negative,
            ),
            const SizedBox(height: FinoraSpacing.md),
            Text('Could not load users', style: FinoraTextStyles.h3),
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

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.onReset});
  final VoidCallback onReset;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(FinoraSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.person_search_rounded,
              size: 40,
              color: FinoraColors.textMuted,
            ),
            const SizedBox(height: FinoraSpacing.md),
            Text('No users match your filters', style: FinoraTextStyles.h3),
            const SizedBox(height: FinoraSpacing.md),
            OutlinedButton.icon(
              onPressed: onReset,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reset filters'),
            ),
          ],
        ),
      ),
    );
  }
}
