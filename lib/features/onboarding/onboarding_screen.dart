import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/finora_theme.dart';
import '../../core/widgets/finora_financial_card.dart';
import '../../core/widgets/finora_gradient_button.dart';
import '../../core/widgets/finora_icon_chip.dart';
import '../../data/local/preferences_store.dart';

class _Slide {
  _Slide({required this.title, required this.body, required this.icon});
  final String title;
  final String body;
  final IconData icon;
}

final _slides = <_Slide>[
  _Slide(
    title: 'See your real financial picture',
    body:
        'FinoraTwin pulls your numbers together so you always know what is happening in your business.',
    icon: Icons.insights_rounded,
  ),
  _Slide(
    title: 'Health score that actually means something',
    body:
        'Cash flow, expense control, debt burden and runway — all combined into one clear score.',
    icon: Icons.favorite_rounded,
  ),
  _Slide(
    title: 'Plan before you borrow',
    body:
        'Simulate financing scenarios, see risk, and know exactly how much you can take on.',
    icon: Icons.calculate_rounded,
  ),
  _Slide(
    title: 'Talk to your AI copilot',
    body:
        'Ask questions in plain language. Your copilot reads your numbers to give real answers.',
    icon: Icons.psychology_alt_rounded,
  ),
];

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;

  void _next() {
    if (_index < _slides.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
    } else {
      _complete();
    }
  }

  Future<void> _complete() async {
    await ref.read(preferencesStoreProvider).setOnboardingComplete(true);
    if (!mounted) return;
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (i) => setState(() => _index = i),
                itemCount: _slides.length,
                itemBuilder: (context, i) {
                  final slide = _slides[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: FinoraSpacing.lg,
                      vertical: FinoraSpacing.md,
                    ),
                    child: Center(
                      child: FinoraFinancialCard(
                        tone: i.isEven
                            ? FinoraCardTone.brand
                            : FinoraCardTone.neutral,
                        padding: const EdgeInsets.all(FinoraSpacing.xl),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FinoraIconChip(
                              icon: slide.icon,
                              tone: FinoraBadgeTone.brand,
                              size: 88,
                            ),
                            const SizedBox(height: FinoraSpacing.lg),
                            Text(
                              slide.title,
                              textAlign: TextAlign.center,
                              style: FinoraTextStyles.h1,
                            ),
                            const SizedBox(height: FinoraSpacing.sm),
                            Text(
                              slide.body,
                              textAlign: TextAlign.center,
                              style: FinoraTextStyles.bodyLarge.copyWith(
                                color: FinoraColors.textSecondary,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: FinoraSpacing.lg,
                vertical: FinoraSpacing.sm,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_slides.length, (i) {
                  final isActive = i == _index;
                  return AnimatedContainer(
                    duration: FinoraMotion.base,
                    margin: const EdgeInsets.symmetric(
                      horizontal: FinoraSpacing.xxs,
                    ),
                    width: isActive ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isActive
                          ? FinoraColors.brandPrimary
                          : FinoraColors.outline,
                      borderRadius: BorderRadius.circular(FinoraRadii.pill),
                    ),
                  );
                }),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                FinoraSpacing.lg,
                FinoraSpacing.sm,
                FinoraSpacing.lg,
                FinoraSpacing.lg,
              ),
              child: Column(
                children: [
                  FinoraGradientButton(
                    label: _index == _slides.length - 1
                        ? 'Get started'
                        : 'Continue',
                    onPressed: _next,
                    icon: _index == _slides.length - 1
                        ? Icons.rocket_launch_rounded
                        : Icons.arrow_forward_rounded,
                  ),
                  const SizedBox(height: FinoraSpacing.xs),
                  FinoraTextButton(label: 'Skip', onPressed: _complete),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
