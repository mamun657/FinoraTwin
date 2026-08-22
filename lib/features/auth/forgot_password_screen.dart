import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/error/error_handler.dart';
import '../../core/theme/finora_theme.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/finora_app_bar.dart';
import '../../core/widgets/finora_financial_card.dart';
import '../../core/widgets/finora_gradient_button.dart';
import '../../core/widgets/finora_icon_chip.dart';
import '../../data/repositories/auth_repository.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool _sending = false;
  bool _sent = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _sending = true);
    try {
      await ref
          .read(authRepositoryProvider)
          .requestPasswordReset(email: _emailCtrl.text.trim());
      if (!mounted) return;
      setState(() => _sent = true);
    } catch (e) {
      if (!mounted) return;
      showErrorSnackBar(context, e);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(
            horizontal: FinoraSpacing.lg,
            vertical: FinoraSpacing.md,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const FinoraAppBar(title: 'Reset password', showBack: true),
              const SizedBox(height: FinoraSpacing.lg),
              FinoraFinancialCard(
                tone: FinoraCardTone.brand,
                padding: const EdgeInsets.all(FinoraSpacing.lg),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          FinoraIconChip(
                            icon: _sent
                                ? Icons.mark_email_read_outlined
                                : Icons.lock_reset_rounded,
                            tone: _sent
                                ? FinoraBadgeTone.positive
                                : FinoraBadgeTone.brand,
                            size: 44,
                          ),
                          const SizedBox(width: FinoraSpacing.md),
                          Expanded(
                            child: Text(
                              'Forgot your password?',
                              style: FinoraTextStyles.h1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: FinoraSpacing.md),
                      Text(
                        _sent
                            ? 'If an account exists for that email, you will receive a reset link shortly.'
                            : 'Enter your email and we will send you instructions to reset your password.',
                        style: FinoraTextStyles.bodyLarge.copyWith(
                          color: FinoraColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: FinoraSpacing.lg),
                      AppTextField(
                        label: 'Email',
                        controller: _emailCtrl,
                        prefixIcon: Icons.mail_outline,
                        keyboardType: TextInputType.emailAddress,
                        validator: Validators.email,
                        enabled: !_sent,
                      ),
                      const SizedBox(height: FinoraSpacing.lg),
                      FinoraGradientButton(
                        label: _sent ? 'Email sent' : 'Send reset link',
                        loading: _sending,
                        onPressed: _sent ? null : _submit,
                        icon: _sent
                            ? Icons.check_circle_rounded
                            : Icons.send_rounded,
                      ),
                      const SizedBox(height: FinoraSpacing.md),
                      Center(
                        child: FinoraTextButton(
                          label: 'Back to sign in',
                          onPressed: () => context.pop(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: FinoraSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}
