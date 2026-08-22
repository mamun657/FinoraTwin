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

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final controller = ref.read(authSessionControllerProvider.notifier);
    try {
      await controller.login(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
      );
      if (!mounted) return;
      context.go('/dashboard');
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
              const FinoraAppBar(title: '', showBack: false, transparent: true),
              const SizedBox(height: FinoraSpacing.sm),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: Image.asset('images/login2.png', fit: BoxFit.contain),
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
                      Text(
                        'Welcome back',
                        style: FinoraTextStyles.display.copyWith(fontSize: 28),
                      ),
                      const SizedBox(height: FinoraSpacing.xs),
                      Text(
                        'Sign in to keep your business ahead.',
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
                        onSubmitted: (_) => _submit(),
                        autofillHints: const [AutofillHints.password],
                        validator: Validators.simplePassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscure ? Icons.visibility_off : Icons.visibility,
                          ),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                      const SizedBox(height: FinoraSpacing.xs),
                      Align(
                        alignment: Alignment.centerRight,
                        child: FinoraTextButton(
                          label: 'Forgot password?',
                          onPressed: () => context.push('/forgot-password'),
                        ),
                      ),
                      const SizedBox(height: FinoraSpacing.md),
                      FinoraGradientButton(
                        label: 'Sign in',
                        loading: state.loading,
                        onPressed: _submit,
                        icon: Icons.login_rounded,
                      ),
                      const SizedBox(height: FinoraSpacing.lg),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account? ",
                            style: FinoraTextStyles.body.copyWith(
                              color: FinoraColors.textSecondary,
                            ),
                          ),
                          FinoraTextButton(
                            label: 'Create one',
                            onPressed: () => context.push('/register'),
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
