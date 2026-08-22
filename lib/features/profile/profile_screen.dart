import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/finora_theme.dart';
import '../../core/widgets/finora_action_tile.dart';
import '../../core/widgets/finora_app_bar.dart';
import '../../core/widgets/finora_financial_card.dart';
import '../../core/widgets/finora_gradient_button.dart';
import '../../core/widgets/finora_icon_chip.dart';
import '../../core/widgets/finora_section_header.dart';
import '../../data/auth_session_controller.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authSessionControllerProvider).session;

    return Scaffold(
      backgroundColor: FinoraColors.surface,
      appBar: const FinoraAppBar(
        title: 'Profile',
        subtitle: 'Account and preferences',
        showBack: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          FinoraSpacing.lg,
          FinoraSpacing.sm,
          FinoraSpacing.lg,
          FinoraSpacing.xl,
        ),
        children: [
          _ProfileHeader(name: session?.fullName, email: session?.email),
          const SizedBox(height: FinoraSpacing.xl),
          const FinoraSectionHeader(
            title: 'Account',
            subtitle: 'Manage your business and access',
            icon: Icons.business_center_rounded,
          ),
          const SizedBox(height: FinoraSpacing.sm),
          FinoraActionTile(
            icon: Icons.settings_outlined,
            label: 'Business settings',
            onTap: () => context.go('/settings'),
          ),
          const SizedBox(height: FinoraSpacing.sm),
          FinoraActionTile(
            icon: Icons.swap_horiz_rounded,
            label: 'Switch business',
            onTap: () => context.go('/onboarding'),
          ),
          const SizedBox(height: FinoraSpacing.xl),
          const FinoraSectionHeader(
            title: 'Security',
            subtitle: 'Keep your twin safe',
            icon: Icons.shield_outlined,
          ),
          const SizedBox(height: FinoraSpacing.sm),
          FinoraActionTile(
            icon: Icons.lock_outline,
            label: 'Security',
            tone: FinoraBadgeTone.positive,
            onTap: () {
              showDialog<void>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Security'),
                  content: const Text(
                    'Your access and refresh tokens are stored in Android encrypted shared preferences. They are cleared automatically when you sign out.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: FinoraSpacing.sm),
          FinoraActionTile(
            icon: Icons.privacy_tip_outlined,
            label: 'Privacy',
            tone: FinoraBadgeTone.info,
            onTap: () {
              showDialog<void>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Privacy'),
                  content: const Text(
                    'FinoraTwin stores your transactions, simulations, and chat locally. The backend only receives what is needed to compute your insights and simulations.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: FinoraSpacing.xl),
          const FinoraSectionHeader(
            title: 'Support',
            subtitle: 'Need a hand?',
            icon: Icons.help_outline_rounded,
          ),
          const SizedBox(height: FinoraSpacing.sm),
          FinoraActionTile(
            icon: Icons.chat_bubble_outline_rounded,
            label: 'Open AI Copilot',
            tone: FinoraBadgeTone.brand,
            onTap: () => context.go('/ai-copilot'),
          ),
          const SizedBox(height: FinoraSpacing.xl),
          FinoraOutlinedButton(
            label: 'Sign out',
            icon: Icons.logout_rounded,
            tone: FinoraBadgeTone.negative,
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Sign out?'),
                  content: const Text(
                    'You will need to sign in again to access your data.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () =>
                          Navigator.of(context, rootNavigator: true).pop(false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () =>
                          Navigator.of(context, rootNavigator: true).pop(true),
                      child: const Text('Sign out'),
                    ),
                  ],
                ),
              );
              if (confirmed == true) {
                await ref.read(authSessionControllerProvider.notifier).logout();
              }
            },
          ),
          const SizedBox(height: FinoraSpacing.lg),
          Center(
            child: Text(
              'FinoraTwin v1.0.0',
              style: FinoraTextStyles.caption.copyWith(
                color: FinoraColors.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.name, required this.email});

  final String? name;
  final String? email;

  @override
  Widget build(BuildContext context) {
    final displayName = (name == null || name!.isEmpty)
        ? (email == null || email!.isEmpty)
              ? 'Signed-in user'
              : email!
        : name!;
    final initials = _initials(displayName);

    return FinoraFinancialCard(
      tone: FinoraCardTone.brand,
      padding: const EdgeInsets.all(FinoraSpacing.lg),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(FinoraRadii.lg),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.4),
                width: 1.4,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              initials,
              style: FinoraTextStyles.h2.copyWith(
                color: FinoraColors.brandPrimary,
                fontWeight: FontWeight.w800,
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
                  displayName,
                  style: FinoraTextStyles.h3.copyWith(
                    color: FinoraColors.brandPrimaryDark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                if (email != null && email!.isNotEmpty)
                  Text(
                    email!,
                    style: FinoraTextStyles.caption.copyWith(
                      color: FinoraColors.brandPrimaryDark.withValues(
                        alpha: 0.85,
                      ),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: FinoraSpacing.sm),
                Row(
                  children: [
                    FinoraIconChip(
                      icon: Icons.verified_user_rounded,
                      tone: FinoraBadgeTone.positive,
                    ),
                    const SizedBox(width: FinoraSpacing.xs),
                    Text(
                      'Verified',
                      style: FinoraTextStyles.label.copyWith(
                        color: FinoraColors.brandPrimaryDark,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _initials(String value) {
    final parts = value.trim().split(RegExp(r'\s+|@'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return (parts.first.characters.first + parts[1].characters.first)
        .toUpperCase();
  }
}
