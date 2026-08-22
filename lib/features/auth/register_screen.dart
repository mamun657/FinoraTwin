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
import '../../data/auth_session_controller.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final controller = ref.read(authSessionControllerProvider.notifier);
    final fullName = _nameCtrl.text.trim();
    final businessName = fullName.isEmpty
        ? 'My Business'
        : '$fullName Business';
    try {
      await controller.register(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
        fullName: fullName,
        businessName: businessName,
      );
      if (!mounted) return;
      context.go('/business-setup');
    } catch (e) {
      if (!mounted) return;
      showErrorSnackBar(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authSessionControllerProvider);
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
              const FinoraAppBar(title: 'Create account', showBack: true),
              const SizedBox(height: FinoraSpacing.sm),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 180),
                  child: Image.asset('images/signup.jpg', fit: BoxFit.contain),
                ),
              ),
              const SizedBox(height: FinoraSpacing.lg),
              FinoraFinancialCard(
                tone: FinoraCardTone.brand,
                padding: const EdgeInsets.all(FinoraSpacing.lg),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tell us about you', style: FinoraTextStyles.h1),
                      const SizedBox(height: FinoraSpacing.xs),
                      Text(
                        'A few quick details to set up your workspace.',
                        style: FinoraTextStyles.bodyLarge.copyWith(
                          color: FinoraColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: FinoraSpacing.lg),
                      AppTextField(
                        label: 'Full name',
                        controller: _nameCtrl,
                        prefixIcon: Icons.person_outline,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.name],
                        validator: Validators.fullName,
                      ),
                      const SizedBox(height: FinoraSpacing.md),
                      AppTextField(
                        label: 'Email',
                        controller: _emailCtrl,
                        prefixIcon: Icons.mail_outline,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.email],
                        validator: Validators.email,
                      ),
                      const SizedBox(height: FinoraSpacing.md),
                      AppTextField(
                        label: 'Password',
                        controller: _passwordCtrl,
                        obscureText: _obscure,
                        prefixIcon: Icons.lock_outline,
                        textInputAction: TextInputAction.done,
                        autofillHints: const [AutofillHints.newPassword],
                        validator: Validators.password,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscure ? Icons.visibility_off : Icons.visibility,
                          ),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                      const SizedBox(height: FinoraSpacing.xs),
                      Text(
                        'At least 8 characters with upper and lower case letters and a number.',
                        style: FinoraTextStyles.caption.copyWith(
                          color: FinoraColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: FinoraSpacing.lg),
                      FinoraGradientButton(
                        label: 'Continue',
                        loading: state.loading,
                        onPressed: _submit,
                        icon: Icons.arrow_forward_rounded,
                      ),
                      const SizedBox(height: FinoraSpacing.md),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already have an account? ',
                            style: FinoraTextStyles.body.copyWith(
                              color: FinoraColors.textSecondary,
                            ),
                          ),
                          FinoraTextButton(
                            label: 'Sign in',
                            onPressed: () => context.pop(),
                          ),
                        ],
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
