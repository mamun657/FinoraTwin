import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/error/error_handler.dart';
import '../../core/theme/finora_theme.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/finora_app_bar.dart';
import '../../core/widgets/finora_amount_field.dart';
import '../../core/widgets/finora_dropdown.dart';
import '../../core/widgets/finora_financial_card.dart';
import '../../core/widgets/finora_gradient_button.dart';
import '../../data/active_business_controller.dart';

class BusinessSetupScreen extends ConsumerStatefulWidget {
  const BusinessSetupScreen({super.key});

  @override
  ConsumerState<BusinessSetupScreen> createState() =>
      _BusinessSetupScreenState();
}

class _BusinessSetupScreenState extends ConsumerState<BusinessSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _opexCtrl = TextEditingController();
  final _cashCtrl = TextEditingController();
  String _type = 'Retail';
  String _category = 'General';
  String _currency = 'USD';
  int _year = DateTime.now().year;
  bool _saving = false;

  static const _typeOptions = <String, String>{
    'Retail': 'Retail',
    'Manufacturing': 'Manufacturing',
    'Service': 'Service',
    'Wholesale': 'Wholesale',
    'Food and Beverage': 'FoodAndBeverage',
    'Agriculture': 'Agriculture',
    'Other': 'Other',
  };
  static const _categories = [
    'General',
    'Fashion',
    'Food',
    'Tech',
    'Beauty',
    'Logistics',
    'Education',
    'Health',
  ];
  static const _currencies = ['USD', 'EUR', 'GBP', 'NGN', 'KES', 'INR', 'BDT'];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _opexCtrl.dispose();
    _cashCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await ref
          .read(activeBusinessControllerProvider.notifier)
          .update(
            name: _nameCtrl.text.trim(),
            type: _typeOptions[_type] ?? 'Other',
            category: _category,
            startingYear: _year,
            currency: _currency,
            monthlyOpEx: double.parse(_opexCtrl.text.replaceAll(',', '.')),
            currentCashBuffer: double.parse(
              _cashCtrl.text.replaceAll(',', '.'),
            ),
          );
      if (!mounted) return;
      context.go('/dashboard');
    } catch (e) {
      if (!mounted) return;
      showErrorSnackBar(context, e);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencySymbol = _currency == 'BDT' ? '৳' : _currency;
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
              const FinoraAppBar(title: 'Set up business', showBack: true),
              const SizedBox(height: FinoraSpacing.sm),
              FinoraFinancialCard(
                tone: FinoraCardTone.brand,
                padding: const EdgeInsets.all(FinoraSpacing.lg),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tell us about your business',
                        style: FinoraTextStyles.h1,
                      ),
                      const SizedBox(height: FinoraSpacing.xs),
                      Text(
                        'A few details so FinoraTwin can tailor insights to you.',
                        style: FinoraTextStyles.bodyLarge.copyWith(
                          color: FinoraColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: FinoraSpacing.lg),
                      AppTextField(
                        label: 'Business name',
                        controller: _nameCtrl,
                        prefixIcon: Icons.storefront_outlined,
                        validator: Validators.businessName,
                      ),
                      const SizedBox(height: FinoraSpacing.md),
                      FinoraDropdown<String>(
                        label: 'Type',
                        value: _type,
                        options: _typeOptions.keys.toList(),
                        onChanged: (v) => setState(() => _type = v!),
                      ),
                      const SizedBox(height: FinoraSpacing.md),
                      FinoraDropdown<String>(
                        label: 'Category',
                        value: _category,
                        options: _categories,
                        onChanged: (v) => setState(() => _category = v!),
                      ),
                      const SizedBox(height: FinoraSpacing.md),
                      Row(
                        children: [
                          Expanded(
                            child: FinoraDropdown<String>(
                              label: 'Currency',
                              value: _currency,
                              options: _currencies,
                              onChanged: (v) => setState(() => _currency = v!),
                            ),
                          ),
                          const SizedBox(width: FinoraSpacing.sm),
                          Expanded(
                            child: FinoraDropdown<int>(
                              label: 'Started',
                              value: _year,
                              options: List<int>.generate(
                                15,
                                (i) => DateTime.now().year - i,
                              ),
                              optionLabel: (y) => '$y',
                              onChanged: (y) => setState(() => _year = y!),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: FinoraSpacing.md),
                      FinoraAmountField(
                        label: 'Average monthly operating expenses',
                        controller: _opexCtrl,
                        currencySymbol: currencySymbol,
                        helper:
                            'Rent, salaries, utilities - what you spend each month.',
                        validator: (v) =>
                            Validators.positiveNumber(v, label: 'OpEx'),
                      ),
                      const SizedBox(height: FinoraSpacing.md),
                      FinoraAmountField(
                        label: 'Current cash buffer',
                        controller: _cashCtrl,
                        currencySymbol: currencySymbol,
                        helper: 'Cash you have on hand right now.',
                        validator: (v) =>
                            Validators.positiveNumber(v, label: 'Cash buffer'),
                      ),
                      const SizedBox(height: FinoraSpacing.xl),
                      FinoraGradientButton(
                        label: 'Continue',
                        loading: _saving,
                        onPressed: _submit,
                        icon: Icons.arrow_forward_rounded,
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
