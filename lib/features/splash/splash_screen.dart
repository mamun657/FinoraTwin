import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/finora_theme.dart';
import '../../data/auth_session_controller.dart';
import '../../data/local/preferences_store.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _route());
  }

  void _route() {
    Future<void>.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      final session = ref.read(authSessionControllerProvider);
      final onboardingDone = ref
          .read(preferencesStoreProvider)
          .onboardingComplete;
      if (session.isAuthenticated) {
        context.go('/dashboard');
      } else if (!onboardingDone) {
        context.go('/onboarding');
      } else {
        context.go('/auth-entry');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FinoraColors.brandPrimary,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  size: 52,
                  color: FinoraColors.brandPrimary,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'FinoraTwin',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your business. Two steps ahead.',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 48),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Colors.white),
                strokeWidth: 2.4,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
