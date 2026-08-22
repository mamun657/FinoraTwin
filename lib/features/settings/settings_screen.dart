import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/finora_theme.dart';
import '../../core/widgets/finora_action_tile.dart';
import '../../core/widgets/finora_app_bar.dart';
import '../../core/widgets/finora_financial_card.dart';
import '../../core/widgets/finora_gradient_button.dart';
import '../../core/widgets/finora_section_header.dart';
import '../../core/widgets/finora_status_badge.dart';
import '../../data/auth_session_controller.dart';
import '../../data/local/preferences_store.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late final TextEditingController _urlController;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController(text: ref.read(apiBaseUrlProvider));
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _saveUrl() async {
    final value = _urlController.text.trim();
    if (value.isEmpty) return;
    await ref.read(preferencesStoreProvider).setApiBaseUrl(value);
    if (!mounted) return;
    setState(() => _saved = true);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('API base URL saved.')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FinoraColors.surface,
      appBar: const FinoraAppBar(
        title: 'Settings',
        subtitle: 'Preferences and configuration',
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
          const FinoraSectionHeader(
            title: 'Connection',
            subtitle: 'Point Finora to your backend',
            icon: Icons.cloud_outlined,
          ),
          const SizedBox(height: FinoraSpacing.sm),
          FinoraFinancialCard(
            tone: FinoraCardTone.neutral,
            padding: const EdgeInsets.all(FinoraSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.link_rounded,
                      color: FinoraColors.brandPrimary,
                    ),
                    const SizedBox(width: FinoraSpacing.xs),
                    Text('API base URL', style: FinoraTextStyles.h4),
                  ],
                ),
                const SizedBox(height: FinoraSpacing.xs),
                Text(
                  'Default points to the Android emulator host. Change this to your backend if you are running on a physical device.',
                  style: FinoraTextStyles.caption,
                ),
                const SizedBox(height: FinoraSpacing.md),
                TextField(
                  controller: _urlController,
                  keyboardType: TextInputType.url,
                  autofillHints: const [AutofillHints.url],
                  decoration: InputDecoration(
                    hintText: 'http://10.0.2.2:5087',
                    prefixIcon: const Icon(Icons.http_rounded),
                    filled: true,
                    fillColor: FinoraColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(FinoraRadii.md),
                      borderSide: BorderSide(
                        color: FinoraColors.outline.withValues(alpha: 0.6),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(FinoraRadii.md),
                      borderSide: BorderSide(
                        color: FinoraColors.outline.withValues(alpha: 0.6),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(FinoraRadii.md),
                      borderSide: const BorderSide(
                        color: FinoraColors.brandPrimary,
                        width: 1.4,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: FinoraSpacing.md),
                FinoraGradientButton(
                  label: 'Save URL',
                  icon: Icons.save_outlined,
                  onPressed: _saveUrl,
                ),
                if (_saved) ...[
                  const SizedBox(height: FinoraSpacing.sm),
                  FinoraStatusBadge(
                    label: 'Saved. Restart to apply.',
                    icon: Icons.check_circle_rounded,
                    tone: FinoraBadgeTone.positive,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: FinoraSpacing.xl),
          const FinoraSectionHeader(
            title: 'Account',
            subtitle: 'Profile and access',
            icon: Icons.account_circle_outlined,
          ),
          const SizedBox(height: FinoraSpacing.sm),
          FinoraActionTile(
            icon: Icons.person_outline_rounded,
            label: 'Profile',
            onTap: () => context.go('/profile'),
          ),
          const SizedBox(height: FinoraSpacing.sm),
          if (ref.watch(authSessionControllerProvider).session?.isAdmin == true)
            Padding(
              padding: const EdgeInsets.only(bottom: FinoraSpacing.sm),
              child: FinoraFinancialCard(
                tone: FinoraCardTone.brand,
                padding: const EdgeInsets.all(FinoraSpacing.md),
                onTap: () => context.go('/admin'),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: FinoraGradients.brand,
                        borderRadius: BorderRadius.circular(FinoraRadii.md),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.admin_panel_settings_rounded,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: FinoraSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Admin Console', style: FinoraTextStyles.h4),
                          const SizedBox(height: 2),
                          Text(
                            'Manage users, audit activity, and inspect system stats.',
                            style: FinoraTextStyles.caption,
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: FinoraColors.textMuted,
                    ),
                  ],
                ),
              ),
            ),
          FinoraActionTile(
            icon: Icons.logout_rounded,
            label: 'Sign out',
            tone: FinoraBadgeTone.negative,
            onTap: () async {
              await ref.read(authSessionControllerProvider.notifier).logout();
              if (context.mounted) {
                // Defer to next frame so the auth-state change reaches
                // go_router's refreshListenable before we navigate.
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (context.mounted) context.go('/auth-entry');
                });
              }
            },
          ),
          const SizedBox(height: FinoraSpacing.xl),
          const FinoraSectionHeader(
            title: 'About',
            subtitle: 'App information',
            icon: Icons.info_outline_rounded,
          ),
          const SizedBox(height: FinoraSpacing.sm),
          FinoraFinancialCard(
            tone: FinoraCardTone.neutral,
            padding: const EdgeInsets.all(FinoraSpacing.lg),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: FinoraColors.brandPrimarySoft,
                    borderRadius: BorderRadius.circular(FinoraRadii.md),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: FinoraColors.brandPrimary,
                  ),
                ),
                const SizedBox(width: FinoraSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('FinoraTwin', style: FinoraTextStyles.h4),
                      const SizedBox(height: 2),
                      Text(
                        'Your digital twin for smarter money decisions.',
                        style: FinoraTextStyles.caption,
                      ),
                    ],
                  ),
                ),
                Text(
                  'v1.0.0',
                  style: FinoraTextStyles.caption.copyWith(
                    color: FinoraColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
