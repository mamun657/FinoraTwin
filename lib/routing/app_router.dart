import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../app_shell/app_shell.dart';
import '../data/auth_session_controller.dart';
import '../features/action_plan/action_plan_screen.dart';
import '../features/admin/admin_activity_screen.dart';
import '../features/admin/admin_dashboard_screen.dart';
import '../features/admin/admin_shell.dart';
import '../features/admin/admin_user_details_screen.dart';
import '../features/admin/admin_users_screen.dart';
import '../features/ai_copilot/ai_copilot_screen.dart';
import '../features/auth/auth_entry_screen.dart';
import '../features/auth/forgot_password_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/register_screen.dart';
import '../features/business_setup/business_setup_screen.dart';
import '../features/capital_simulator/capital_input_screen.dart';
import '../features/capital_simulator/capital_result_screen.dart';
import '../features/cash_pressure/cash_pressure_screen.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/data_quality/data_quality_screen.dart';
import '../features/explore/explore_screen.dart';
import '../features/financial_health/financial_health_screen.dart';
import '../features/funding/funding_screen.dart';
import '../features/goals/goals_screen.dart';
import '../features/leak_detector/leak_detector_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/scenarios/scenarios_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/splash/splash_screen.dart';
import '../data/repositories/capital_repository.dart';
import '../features/transactions/add_transaction_screen.dart';
import '../features/transactions/transactions_screen.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final refresh = _RouterRefresh(ref);
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    refreshListenable: refresh,
    redirect: (context, state) {
      final sessionState = ref.read(authSessionControllerProvider);
      final loggedIn = sessionState.isAuthenticated;
      final loggingIn =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/register' ||
          state.matchedLocation == '/forgot-password' ||
          state.matchedLocation == '/onboarding' ||
          state.matchedLocation == '/auth-entry';
      final onSplash = state.matchedLocation == '/';
      if (!loggedIn && !loggingIn && !onSplash) return '/auth-entry';
      if (loggedIn &&
          (state.matchedLocation == '/login' ||
              state.matchedLocation == '/register' ||
              state.matchedLocation == '/forgot-password' ||
              state.matchedLocation == '/auth-entry')) {
        return '/dashboard';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/auth-entry', builder: (_, __) => const AuthEntryScreen()),
      GoRoute(
        path: '/onboarding',
        builder: (_, __) => const OnboardingScreen(),
      ),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(
        path: '/forgot-password',
        builder: (_, __) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/business-setup',
        builder: (_, __) => const BusinessSetupScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/dashboard',
                builder: (_, __) => const DashboardScreen(),
              ),
              GoRoute(
                path: '/financial-health',
                builder: (_, __) => const FinancialHealthScreen(),
              ),
              GoRoute(
                path: '/capital-simulator',
                builder: (_, __) => const CapitalInputScreen(),
              ),
              GoRoute(
                path: '/capital-simulator/result',
                builder: (_, state) => CapitalResultScreen(
                  requestedAmount:
                      double.tryParse(
                        state.uri.queryParameters['amount'] ?? '',
                      ) ??
                      0,
                  termMonths:
                      int.tryParse(state.uri.queryParameters['term'] ?? '') ??
                      12,
                  annualRate:
                      double.tryParse(
                        state.uri.queryParameters['rate'] ?? '',
                      ) ??
                      0,
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/transactions',
                builder: (_, __) => const TransactionsScreen(),
              ),
              GoRoute(
                path: '/transactions/add',
                builder: (_, __) => const AddTransactionScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/ai-copilot',
                builder: (_, __) => const AiCopilotScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (_, __) => const ProfileScreen(),
              ),
              GoRoute(
                path: '/settings',
                builder: (_, __) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(path: '/scenarios', builder: (_, __) => const ScenariosScreen()),
      GoRoute(path: '/explore', builder: (_, __) => const ExploreScreen()),
      GoRoute(
        path: '/scenarios/result',
        builder: (_, state) {
          final extra = state.extra as SimulationScenario;
          return ScenarioResultScreen(scenario: extra);
        },
      ),
      GoRoute(
        path: '/action-plan',
        builder: (_, __) => const ActionPlanScreen(),
      ),
      GoRoute(
        path: '/leak-detector',
        builder: (_, __) => const LeakDetectorScreen(),
      ),
      GoRoute(path: '/goals', builder: (_, __) => const GoalsScreen()),
      GoRoute(path: '/funding', builder: (_, __) => const FundingScreen()),
      GoRoute(
        path: '/data-quality',
        builder: (_, __) => const DataQualityScreen(),
      ),
      GoRoute(
        path: '/cash-pressure',
        builder: (_, __) => const CashPressureScreen(),
      ),
      GoRoute(
        path: '/admin/users/:id',
        redirect: (context, state) {
          final isAdmin =
              ref.read(authSessionControllerProvider).session?.isAdmin == true;
          return isAdmin ? null : '/dashboard';
        },
        builder: (context, state) =>
            AdminUserDetailsScreen(userId: state.pathParameters['id'] ?? ''),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          final isAdmin =
              ref.read(authSessionControllerProvider).session?.isAdmin == true;
          if (!isAdmin) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) context.go('/dashboard');
            });
            return const Scaffold(body: SizedBox.shrink());
          }
          return AdminShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/admin',
                redirect: (context, state) {
                  final isAdmin =
                      ref
                          .read(authSessionControllerProvider)
                          .session
                          ?.isAdmin ==
                      true;
                  return isAdmin ? null : '/dashboard';
                },
                builder: (_, __) => const AdminDashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/admin/users',
                redirect: (context, state) {
                  final isAdmin =
                      ref
                          .read(authSessionControllerProvider)
                          .session
                          ?.isAdmin ==
                      true;
                  return isAdmin ? null : '/dashboard';
                },
                builder: (_, __) => const AdminUsersScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/admin/activity',
                redirect: (context, state) {
                  final isAdmin =
                      ref
                          .read(authSessionControllerProvider)
                          .session
                          ?.isAdmin ==
                      true;
                  return isAdmin ? null : '/dashboard';
                },
                builder: (_, __) => const AdminActivityScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

class _RouterRefresh extends ChangeNotifier {
  _RouterRefresh(Ref ref) {
    ref.listen<AuthSessionState>(authSessionControllerProvider, (
      previous,
      next,
    ) {
      notifyListeners();
    });
  }
}

final _rootNavigatorKey = GlobalKey<NavigatorState>();
