import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/error/error_handler.dart';
import '../../core/theme/finora_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/finora_amount_field.dart';
import '../../core/widgets/finora_app_bar.dart';
import '../../core/widgets/finora_dropdown.dart';
import '../../core/widgets/finora_financial_card.dart';
import '../../core/widgets/finora_gradient_button.dart';
import '../../core/widgets/finora_icon_chip.dart';
import '../../core/widgets/finora_section_header.dart';
import '../../data/active_business_controller.dart';
import '../../data/repositories/capital_repository.dart';

const _purposes = <String>[
  'Working capital',
  'Inventory',
  'Equipment',
  'Hiring',
  'Marketing',
  'Expansion',
];

class CapitalInputScreen extends ConsumerStatefulWidget {
  const CapitalInputScreen({super.key});

  @override
  ConsumerState<CapitalInputScreen> createState() => _CapitalInputScreenState();
}

class _CapitalInputScreenState extends ConsumerState<CapitalInputScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _termController = TextEditingController(text: '12');
  final _rateController = TextEditingController(text: '18');
  String _purpose = _purposes.first;

  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_recalc);
    _termController.addListener(_recalc);
    _rateController.addListener(_recalc);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _termController.dispose();
    _rateController.dispose();
    super.dispose();
  }

  void _recalc() {
    if (mounted) setState(() {});
  }

  double? get _amount =>
      double.tryParse(_amountController.text.trim().replaceAll(',', '.'));
  int? get _term => int.tryParse(_termController.text.trim());
  double? get _rate => double.tryParse(_rateController.text.trim());

  double? get _monthlyPayment {
    final p = _amount;
    final t = _term;
    final r = _rate;
    if (p == null || t == null || r == null || p <= 0 || t <= 0) return null;
    final monthly = r / 100.0 / 12.0;
    if (monthly <= 0) return p / t;
    final factor = monthly;
    final pow = _pow1p(monthly, t);
    return p * (factor * pow) / (pow - 1);
  }

  double _pow1p(double x, int n) {
    double result = 1.0;
    for (var i = 0; i < n; i++) {
      result = result * (1 + x);
    }
    return result;
  }

  double? get _totalRepayment {
    final m = _monthlyPayment;
    final t = _term;
    if (m == null || t == null) return null;
    return m * t;
  }

  double? get _totalInterest {
    final p = _amount;
    final rep = _totalRepayment;
    if (p == null || rep == null) return null;
    return rep - p;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final amount = _amount!;
    final term = _term!;
    final rate = _rate!;

    setState(() => _submitting = true);
    try {
      final repo = ref.read(capitalRepositoryProvider);
      final state = ref.read(activeBusinessControllerProvider);
      if (!state.hasBusiness) {
        throw StateError('No active business selected.');
      }
      await repo.simulate(
        requestedAmount: amount,
        purpose: _purpose,
        termMonths: term,
        annualInterestRate: rate,
      );
      if (!mounted) return;
      context.push(
        '/capital-simulator/result?amount=$amount&term=$term&rate=$rate',
      );
    } catch (e) {
      if (!mounted) return;
      showErrorSnackBar(context, e);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currency = ref.watch(activeBusinessCurrencyProvider);
    final cs = currencySymbol(currency);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: FinoraAppBar(
        title: 'Capital simulator',
        subtitle: 'Estimate what your business can sustain',
        showBack: true,
        onBack: () => context.pop(),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          FinoraSpacing.lg,
          FinoraSpacing.md,
          FinoraSpacing.lg,
          FinoraSpacing.xl,
        ),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        children: [
          FinoraFinancialCard(
            tone: FinoraCardTone.brand,
            child: Row(
              children: [
                const FinoraIconChip(
                  icon: Icons.auto_graph_rounded,
                  tone: FinoraBadgeTone.brand,
                  size: 44,
                ),
                const SizedBox(width: FinoraSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Loan readiness',
                        style: FinoraTextStyles.overline.copyWith(
                          color: FinoraColors.brandPrimaryDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Run a fresh scenario based on your live revenue and expenses.',
                        style: FinoraTextStyles.caption,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: FinoraSpacing.lg),
          const FinoraSectionHeader(
            title: 'Loan details',
            subtitle: 'Tune the inputs to compare scenarios',
          ),
          const SizedBox(height: FinoraSpacing.sm),
          Form(
            key: _formKey,
            child: FinoraFinancialCard(
              tone: FinoraCardTone.neutral,
              padding: const EdgeInsets.all(FinoraSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FinoraAmountField(
                    controller: _amountController,
                    currencySymbol: cs,
                    label: 'Requested amount',
                    hint: '50000',
                    helper: 'Principal you plan to borrow',
                    validator: (v) =>
                        Validators.positiveNumber(v, label: 'Amount'),
                  ),
                  const SizedBox(height: FinoraSpacing.md),
                  FinoraDropdown<String>(
                    label: 'Purpose',
                    value: _purpose,
                    prefixIcon: Icons.flag_rounded,
                    options: _purposes,
                    onChanged: (v) {
                      if (v == null) return;
                      setState(() => _purpose = v);
                    },
                  ),
                  const SizedBox(height: FinoraSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _termController,
                          keyboardType: TextInputType.number,
                          style: FinoraTextStyles.body,
                          validator: (v) =>
                              Validators.positiveInteger(v, label: 'Term'),
                          decoration: _inputDecoration(
                            label: 'Term (months)',
                            icon: Icons.calendar_today_rounded,
                          ),
                        ),
                      ),
                      const SizedBox(width: FinoraSpacing.sm),
                      Expanded(
                        child: TextFormField(
                          controller: _rateController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          style: FinoraTextStyles.body,
                          validator: Validators.interestRate,
                          decoration: _inputDecoration(
                            label: 'Interest rate (%)',
                            icon: Icons.percent_rounded,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: FinoraSpacing.lg),
                  FinoraGradientButton(
                    label: 'Run simulation',
                    icon: Icons.calculate_rounded,
                    loading: _submitting,
                    onPressed: _submit,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: FinoraSpacing.lg),
          const FinoraSectionHeader(
            title: 'Live preview',
            subtitle: 'Updates as you type',
          ),
          const SizedBox(height: FinoraSpacing.sm),
          _LivePreview(
            currency: currency,
            monthly: _monthlyPayment,
            totalInterest: _totalInterest,
            totalRepayment: _totalRepayment,
            amount: _amount,
            term: _term,
          ),
          const SizedBox(height: FinoraSpacing.lg),
          FinoraFinancialCard(
            tone: FinoraCardTone.warning,
            padding: const EdgeInsets.all(FinoraSpacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const FinoraIconChip(
                  icon: Icons.lightbulb_outline_rounded,
                  tone: FinoraBadgeTone.warning,
                  size: 36,
                ),
                const SizedBox(width: FinoraSpacing.sm),
                Expanded(
                  child: Text(
                    'Results are advisory. They combine cash-flow runway, debt-service coverage, and stress tests.',
                    style: FinoraTextStyles.caption.copyWith(height: 1.4),
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

InputDecoration _inputDecoration({
  required String label,
  required IconData icon,
}) {
  return InputDecoration(
    labelText: label,
    labelStyle: FinoraTextStyles.label,
    prefixIcon: Icon(icon, size: 20, color: FinoraColors.brandPrimary),
    filled: true,
    fillColor: FinoraColors.surfaceAlt,
    contentPadding: const EdgeInsets.symmetric(
      horizontal: FinoraSpacing.md,
      vertical: 14,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(FinoraRadii.md),
      borderSide: BorderSide(color: FinoraColors.outline, width: 1.2),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(FinoraRadii.md),
      borderSide: BorderSide(color: FinoraColors.outline, width: 1.2),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(FinoraRadii.md),
      borderSide: BorderSide(
        color: FinoraColors.brandPrimary.withValues(alpha: 0.55),
        width: 1.4,
      ),
    ),
  );
}

class _LivePreview extends StatelessWidget {
  const _LivePreview({
    required this.currency,
    required this.monthly,
    required this.totalInterest,
    required this.totalRepayment,
    required this.amount,
    required this.term,
  });

  final String currency;
  final double? monthly;
  final double? totalInterest;
  final double? totalRepayment;
  final double? amount;
  final int? term;

  @override
  Widget build(BuildContext context) {
    return FinoraFinancialCard(
      tone: FinoraCardTone.neutral,
      padding: const EdgeInsets.all(FinoraSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const FinoraIconChip(
                icon: Icons.receipt_long_rounded,
                tone: FinoraBadgeTone.brand,
                size: 36,
              ),
              const SizedBox(width: FinoraSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Estimated monthly payment',
                      style: FinoraTextStyles.caption,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      monthly == null
                          ? '—'
                          : formatMoney(monthly!, currency: currency),
                      style: FinoraTextStyles.h2.copyWith(
                        color: FinoraColors.brandPrimaryDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: FinoraSpacing.md),
          _PreviewRow(
            label: 'Principal',
            value: amount == null
                ? '—'
                : formatMoney(amount!, currency: currency),
          ),
          _PreviewRow(
            label: 'Term',
            value: term == null ? '—' : '$term months',
          ),
          _PreviewRow(
            label: 'Total interest',
            value: totalInterest == null
                ? '—'
                : formatMoney(totalInterest!, currency: currency),
          ),
          const Divider(height: 24),
          _PreviewRow(
            label: 'Total repayment',
            value: totalRepayment == null
                ? '—'
                : formatMoney(totalRepayment!, currency: currency),
            emphasized: true,
          ),
        ],
      ),
    );
  }
}

class _PreviewRow extends StatelessWidget {
  const _PreviewRow({
    required this.label,
    required this.value,
    this.emphasized = false,
  });

  final String label;
  final String value;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: emphasized
                  ? FinoraTextStyles.label
                  : FinoraTextStyles.body,
            ),
          ),
          Text(
            value,
            style: (emphasized ? FinoraTextStyles.label : FinoraTextStyles.body)
                .copyWith(
                  color: emphasized
                      ? FinoraColors.brandPrimaryDark
                      : FinoraColors.textPrimary,
                  fontWeight: emphasized ? FontWeight.w800 : FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
