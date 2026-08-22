import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'finora_bottom_navigation.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const _items = <FinoraNavItem>[
    FinoraNavItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'Home',
    ),
    FinoraNavItem(
      icon: Icons.swap_vert_rounded,
      activeIcon: Icons.swap_vert_rounded,
      label: 'Activity',
      assetPath: 'assets/icons/activity.png',
    ),
    FinoraNavItem(
      icon: Icons.auto_awesome_outlined,
      activeIcon: Icons.auto_awesome,
      label: 'AI',
    ),
    FinoraNavItem(
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      label: 'Profile',
    ),
  ];

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final showNavBar = _shouldShowNavBar(context);

    return PopScope<void>(
      canPop: false,
      onPopInvokedWithResult: (_, __) {
        if (FocusManager.instance.primaryFocus?.hasFocus ?? false) {
          FocusManager.instance.primaryFocus?.unfocus();
          return;
        }
        final router = GoRouter.of(context);
        if (router.canPop()) {
          router.pop();
        } else if (navigationShell.currentIndex != 0) {
          navigationShell.goBranch(0);
        } else {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: navigationShell,
        bottomNavigationBar: showNavBar
            ? FinoraBottomNavigation(
                items: _items,
                currentIndex: navigationShell.currentIndex,
                onTap: _goBranch,
              )
            : null,
      ),
    );
  }

  bool _shouldShowNavBar(BuildContext context) {
    final loc = GoRouterState.of(context).uri.path;
    return loc.startsWith('/dashboard') ||
        loc.startsWith('/transactions') ||
        loc.startsWith('/ai-copilot') ||
        loc.startsWith('/profile');
  }
}
