import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/finora_theme.dart';
import '../../data/auth_session_controller.dart';

class AdminShell extends StatelessWidget {
  const AdminShell({
    super.key,
    required this.navigationShell,
    this.currentLocation,
  });

  final StatefulNavigationShell navigationShell;
  final String? currentLocation;

  static const _items = <_NavItem>[
    _NavItem(
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard_rounded,
      label: 'Dashboard',
    ),
    _NavItem(
      icon: Icons.people_alt_outlined,
      activeIcon: Icons.people_alt_rounded,
      label: 'Users',
    ),
    _NavItem(
      icon: Icons.receipt_long_outlined,
      activeIcon: Icons.receipt_long_rounded,
      label: 'Activity',
    ),
  ];

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  bool _isActive(int index) {
    final loc = currentLocation ?? '';
    if (index == 0) return loc.startsWith('/admin/dashboard');
    if (index == 1) return loc.startsWith('/admin/users');
    if (index == 2) return loc.startsWith('/admin/activity');
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final session = _findSession(context);
    final isWide = MediaQuery.of(context).size.width >= 760;

    return PopScope<void>(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        final router = GoRouter.of(context);
        if (router.canPop()) {
          router.pop();
          return;
        }
        context.go('/dashboard');
      },
      child: Scaffold(
        backgroundColor: FinoraColors.surface,
        body: Row(
          children: [
            if (isWide) _SideRail(
              items: _items,
              currentIndex: navigationShell.currentIndex,
              isActive: _isActive,
              onTap: _goBranch,
              session: session,
            ),
            Expanded(child: navigationShell),
          ],
        ),
        bottomNavigationBar: isWide
            ? null
            : SafeArea(
                top: false,
                child: Container(
                  decoration: BoxDecoration(
                    color: FinoraColors.surfaceAlt,
                    border: Border(
                      top: BorderSide(color: FinoraColors.outline),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      for (int i = 0; i < _items.length; i++)
                        _BottomBarButton(
                          item: _items[i],
                          active: navigationShell.currentIndex == i,
                          onTap: () => _goBranch(i),
                        ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  dynamic _findSession(BuildContext context) {
    try {
      return context;
    } catch (_) {
      return null;
    }
  }
}

class _NavItem {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
  final IconData icon;
  final IconData activeIcon;
  final String label;
}

class _SideRail extends ConsumerWidget {
  const _SideRail({
    required this.items,
    required this.currentIndex,
    required this.isActive,
    required this.onTap,
    required this.session,
  });

  final List<_NavItem> items;
  final int currentIndex;
  final bool Function(int) isActive;
  final void Function(int) onTap;
  final dynamic session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authSessionControllerProvider);
    final user = auth.session;
    final email = user?.email ?? '';
    final name = user?.fullName ?? 'Administrator';
    final initials = _initials(name.isNotEmpty ? name : email);

    return Container(
      width: 256,
      decoration: BoxDecoration(
        color: FinoraColors.surfaceAlt,
        border: Border(
          right: BorderSide(color: FinoraColors.outline),
        ),
      ),
      child: SafeArea(
        right: false,
        child: Padding(
          padding: const EdgeInsets.all(FinoraSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: FinoraGradients.brand,
                      borderRadius:
                          BorderRadius.circular(FinoraRadii.md),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.admin_panel_settings_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: FinoraSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'FinoraTwin',
                          style: FinoraTextStyles.h4.copyWith(
                            letterSpacing: -0.2,
                          ),
                        ),
                        Text(
                          'Admin Console',
                          style: FinoraTextStyles.caption.copyWith(
                            color: FinoraColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: FinoraSpacing.lg),
              Container(
                padding: const EdgeInsets.all(FinoraSpacing.md),
                decoration: BoxDecoration(
                  color: FinoraColors.brandPrimarySoft,
                  borderRadius:
                      BorderRadius.circular(FinoraRadii.md),
                  border: Border.all(
                    color: FinoraColors.brandPrimary.withValues(alpha: 0.15),
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: FinoraColors.brandPrimary,
                      child: Text(
                        initials,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: FinoraSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: FinoraTextStyles.h4.copyWith(fontSize: 14),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            email,
                            style: FinoraTextStyles.caption,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: FinoraSpacing.lg),
              for (int i = 0; i < items.length; i++) ...[
                _SideRailItem(
                  item: items[i],
                  active: currentIndex == i,
                  onTap: () => onTap(i),
                ),
                const SizedBox(height: FinoraSpacing.xs),
              ],
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: FinoraSpacing.md,
                  vertical: FinoraSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: FinoraColors.brandPrimarySoft,
                  borderRadius:
                      BorderRadius.circular(FinoraRadii.pill),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.shield_rounded,
                      size: 14,
                      color: FinoraColors.brandPrimaryDark,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Admin role',
                      style: FinoraTextStyles.caption.copyWith(
                        color: FinoraColors.brandPrimaryDark,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: FinoraSpacing.sm),
              OutlinedButton.icon(
                onPressed: () async {
                  await ref
                      .read(authSessionControllerProvider.notifier)
                      .logout();
                  if (!context.mounted) return;
                  context.go('/auth-entry');
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(44),
                  foregroundColor: FinoraColors.negative,
                  side: const BorderSide(color: FinoraColors.negative),
                ),
                icon: const Icon(Icons.logout_rounded, size: 18),
                label: const Text('Log out'),
              ),
              const SizedBox(height: FinoraSpacing.sm),
              TextButton.icon(
                onPressed: () => context.go('/dashboard'),
                style: TextButton.styleFrom(
                  foregroundColor: FinoraColors.textSecondary,
                ),
                icon: const Icon(Icons.arrow_back_rounded, size: 18),
                label: const Text('Back to app'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _initials(String s) {
    final parts = s.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'A';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }
}

class _SideRailItem extends StatelessWidget {
  const _SideRailItem({
    required this.item,
    required this.active,
    required this.onTap,
  });

  final _NavItem item;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active ? FinoraColors.brandPrimarySoft : Colors.transparent,
      borderRadius: BorderRadius.circular(FinoraRadii.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(FinoraRadii.md),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: FinoraSpacing.md,
            vertical: FinoraSpacing.sm,
          ),
          child: Row(
            children: [
              Icon(
                active ? item.activeIcon : item.icon,
                size: 20,
                color: active
                    ? FinoraColors.brandPrimaryDark
                    : FinoraColors.textSecondary,
              ),
              const SizedBox(width: FinoraSpacing.sm),
              Text(
                item.label,
                style: FinoraTextStyles.label.copyWith(
                  color: active
                      ? FinoraColors.brandPrimaryDark
                      : FinoraColors.textPrimary,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomBarButton extends StatelessWidget {
  const _BottomBarButton({
    required this.item,
    required this.active,
    required this.onTap,
  });

  final _NavItem item;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active
        ? FinoraColors.brandPrimaryDark
        : FinoraColors.textSecondary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(FinoraRadii.md),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 6,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(active ? item.activeIcon : item.icon, color: color),
            const SizedBox(height: 2),
            Text(
              item.label,
              style: FinoraTextStyles.caption.copyWith(
                color: color,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
