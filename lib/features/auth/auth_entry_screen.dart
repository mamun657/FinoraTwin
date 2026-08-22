import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/finora_theme.dart';
import '../../core/widgets/finora_glass_card.dart';
import '../../core/widgets/finora_gradient_button.dart';

class AuthEntryScreen extends StatelessWidget {
  const AuthEntryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: double.infinity,
              height: 320,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CustomPaint(
                    painter: _AuthHeroMeshPainter(
                      FinoraHeroPalettes.dashboardMesh,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withValues(alpha: 0.0),
                          Colors.white.withValues(alpha: 0.06),
                        ],
                      ),
                    ),
                  ),
                  SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 18),
                          Container(
                            width: 88,
                            height: 88,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0x33000000),
                                  blurRadius: 24,
                                  offset: Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.auto_graph_rounded,
                              size: 52,
                              color: FinoraColors.brandPrimary,
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Welcome to FinoraTwin',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.4,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Your AI financial twin for\n'
                            'smarter business decisions',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: Colors.white.withValues(alpha: 0.92),
                              fontSize: 15,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 36),
              child: FinoraGlassCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: FinoraColors.brandPrimary
                                .withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.shield_moon_rounded,
                            color: FinoraColors.brandPrimary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Real data, real insights',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'No spreadsheets. No guessing.',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color:
                                      theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    FinoraGradientButton(
                      label: 'Create Account',
                      icon: Icons.person_add_alt_1_rounded,
                      onPressed: () => context.push('/register'),
                    ),
                    const SizedBox(height: 12),
                    FinoraOutlinedButton(
                      label: 'Log In',
                      icon: Icons.login_rounded,
                      onPressed: () => context.push('/login'),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'By continuing you agree to keep your business '
                      'data safe and private.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 11,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AuthHeroMeshPainter extends CustomPainter {
  _AuthHeroMeshPainter(this.colors);
  final List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final base = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: colors,
      ).createShader(rect);
    canvas.drawRect(rect, base);

    final paint1 = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.7, -0.8),
        radius: 1.1,
        colors: [
          Colors.white.withValues(alpha: 0.35),
          Colors.white.withValues(alpha: 0.0),
        ],
      ).createShader(rect);
    canvas.drawRect(rect, paint1);

    final paint2 = Paint()
      ..shader = RadialGradient(
        center: const Alignment(1.2, 1.3),
        radius: 0.9,
        colors: [
          const Color(0xFF1E1B4B).withValues(alpha: 0.55),
          const Color(0xFF1E1B4B).withValues(alpha: 0.0),
        ],
      ).createShader(rect);
    canvas.drawRect(rect, paint2);

    final paint3 = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.6, -0.6),
        radius: 0.7,
        colors: [
          const Color(0xFFFFB07C).withValues(alpha: 0.35),
          const Color(0xFFFFB07C).withValues(alpha: 0.0),
        ],
      ).createShader(rect);
    canvas.drawRect(rect, paint3);
  }

  @override
  bool shouldRepaint(covariant _AuthHeroMeshPainter oldDelegate) =>
      oldDelegate.colors != colors;
}
