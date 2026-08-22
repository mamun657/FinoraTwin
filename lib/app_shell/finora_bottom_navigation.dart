import 'package:flutter/material.dart';
import '../core/theme/finora_theme.dart';

class FinoraNavItem {
  const FinoraNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    this.assetPath,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String? assetPath;
}

class FinoraBottomNavigation extends StatelessWidget {
  const FinoraBottomNavigation({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  final List<FinoraNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(
          FinoraSpacing.md,
          0,
          FinoraSpacing.md,
          FinoraSpacing.sm,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: FinoraSpacing.xs,
          vertical: FinoraSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: FinoraColors.surfaceAlt,
          borderRadius: BorderRadius.circular(FinoraRadii.xl),
          border: Border.all(
            color: FinoraColors.outline.withValues(alpha: 0.6),
            width: 1,
          ),
          boxShadow: FinoraShadows.md,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(items.length, (i) {
            final selected = i == currentIndex;
            final item = items[i];
            return Expanded(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => onTap(i),
                  borderRadius: BorderRadius.circular(FinoraRadii.lg),
                  child: AnimatedContainer(
                    duration: FinoraMotion.fast,
                    padding: const EdgeInsets.symmetric(
                      vertical: FinoraSpacing.xs,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedContainer(
                          duration: FinoraMotion.fast,
                          width: 36,
                          height: 28,
                          decoration: BoxDecoration(
                            gradient: selected ? FinoraGradients.brand : null,
                            borderRadius: BorderRadius.circular(
                              FinoraRadii.pill,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: item.assetPath != null
                              ? ColorFiltered(
                                  colorFilter: selected
                                      ? const ColorFilter.mode(
                                          Colors.white,
                                          BlendMode.srcIn,
                                        )
                                      : const ColorFilter.mode(
                                          FinoraColors.textSecondary,
                                          BlendMode.srcIn,
                                        ),
                                  child: Image.asset(
                                    item.assetPath!,
                                    width: 18,
                                    height: 18,
                                    fit: BoxFit.contain,
                                  ),
                                )
                              : Icon(
                                  selected ? item.activeIcon : item.icon,
                                  size: 18,
                                  color: selected
                                      ? Colors.white
                                      : FinoraColors.textSecondary,
                                ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.label,
                          style: FinoraTextStyles.caption.copyWith(
                            fontSize: 11,
                            fontWeight: selected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: selected
                                ? FinoraColors.brandPrimaryDark
                                : FinoraColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
