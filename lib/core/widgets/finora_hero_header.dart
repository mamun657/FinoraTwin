import 'package:flutter/material.dart';
import '../theme/finora_theme.dart';

class FinoraHeroHeader extends StatelessWidget {
  const FinoraHeroHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.greeting,
    this.meshColors = FinoraHeroPalettes.dashboardMesh,
    this.trailing,
    this.height = 220,
    this.showProfileChip = false,
    this.profileInitial,
    this.profileLabel,
    this.onProfileTap,
    this.foregroundExtra,
  });

  final String title;
  final String? subtitle;
  final String? greeting;
  final List<Color> meshColors;
  final Widget? trailing;
  final double height;
  final bool showProfileChip;
  final String? profileInitial;
  final String? profileLabel;
  final VoidCallback? onProfileTap;
  final Widget? foregroundExtra;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(painter: _HeroMeshPainter(meshColors)),
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
          Padding(
            padding: const EdgeInsets.fromLTRB(
              FinoraSpacing.lg,
              FinoraSpacing.lg,
              FinoraSpacing.lg,
              FinoraSpacing.xl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (greeting != null)
                      Expanded(
                        child: Text(
                          greeting!,
                          style: FinoraTextStyles.overline.copyWith(
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                        ),
                      ),
                    if (showProfileChip)
                      _ProfileChip(
                        initial: profileInitial ?? 'F',
                        label: profileLabel ?? 'FinoraTwin',
                        onTap: onProfileTap,
                      ),
                    if (!showProfileChip && trailing != null) trailing!,
                  ],
                ),
                const Spacer(),
                Text(
                  title,
                  style: FinoraTextStyles.display.copyWith(
                    color: Colors.white,
                    fontSize: 28,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: FinoraSpacing.xs),
                  Text(
                    subtitle!,
                    style: FinoraTextStyles.body.copyWith(
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ],
                if (foregroundExtra != null) ...[
                  const SizedBox(height: FinoraSpacing.md),
                  foregroundExtra!,
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileChip extends StatelessWidget {
  const _ProfileChip({
    required this.initial,
    required this.label,
    this.onTap,
  });

  final String initial;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(FinoraRadii.pill),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: FinoraSpacing.sm,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(FinoraRadii.pill),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.35),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 26,
                height: 26,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(FinoraRadii.pill),
                ),
                child: Text(
                  initial,
                  style: FinoraTextStyles.label.copyWith(
                    color: FinoraColors.brandPrimaryDark,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: FinoraSpacing.xs),
              Text(
                label,
                style: FinoraTextStyles.label.copyWith(color: Colors.white),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 18,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroMeshPainter extends CustomPainter {
  _HeroMeshPainter(this.colors);
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
  bool shouldRepaint(covariant _HeroMeshPainter oldDelegate) =>
      oldDelegate.colors != colors;
}

class FinoraHeroBackButton extends StatelessWidget {
  const FinoraHeroBackButton({
    super.key,
    required this.onBack,
    this.iconColor = Colors.white,
  });

  final VoidCallback onBack;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.18),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onBack,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(Icons.arrow_back_rounded, color: iconColor, size: 22),
        ),
      ),
    );
  }
}

class FinoraMiniGradientChip extends StatelessWidget {
  const FinoraMiniGradientChip({
    super.key,
    required this.label,
    required this.icon,
    required this.gradient,
    this.onTap,
  });

  final String label;
  final IconData icon;
  final LinearGradient gradient;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(FinoraRadii.pill),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: FinoraSpacing.sm,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(FinoraRadii.pill),
            boxShadow: FinoraShadows.sm,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: Colors.white),
              const SizedBox(width: 4),
              Text(
                label,
                style: FinoraTextStyles.label.copyWith(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}