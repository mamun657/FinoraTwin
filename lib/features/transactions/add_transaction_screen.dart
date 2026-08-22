import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/error/error_handler.dart';
import '../../core/theme/finora_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/finora_amount_field.dart';
import '../../core/widgets/finora_app_bar.dart';
import '../../core/widgets/finora_dropdown.dart';
import '../../core/widgets/finora_financial_card.dart';
import '../../core/widgets/finora_gradient_button.dart';
import '../../core/widgets/finora_icon_chip.dart';
import '../../data/active_business_controller.dart';
import '../../data/repositories/transaction_repository.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  ConsumerState<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  TransactionType _type = TransactionType.revenue;
  String _category = 'Sales';
  DateTime _date = DateTime.now();
  bool _saving = false;

  static const _revenueCategories = [
    'Sales',
    'Services',
    'Subscriptions',
    'Other income',
  ];
  static const _expenseCategories = [
    'Rent',
    'Salaries',
    'Utilities',
    'Marketing',
    'Inventory',
    'Transport',
    'Other expense',
  ];

  @override
  void initState() {
    super.initState();
    _category = _revenueCategories.first;
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  List<String> get _categories => _type == TransactionType.revenue
      ? _revenueCategories
      : _expenseCategories;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final state = ref.read(activeBusinessControllerProvider);
    if (!state.hasBusiness) return;
    setState(() => _saving = true);
    try {
      await ref
          .read(transactionRepositoryProvider)
          .create(
            type: _type,
            category: _category,
            amount: double.parse(_amountCtrl.text.replaceAll(',', '.')),
            description: _descriptionCtrl.text.trim(),
            occurredAt: _date,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Transaction saved')));
      context.pop();
    } catch (e) {
      if (!mounted) return;
      showErrorSnackBar(context, e);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currency = ref.watch(activeBusinessCurrencyProvider);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      resizeToAvoidBottomInset: true,
      appBar: FinoraAppBar(
        title: 'Add transaction',
        subtitle: 'Log a new revenue or expense',
        showBack: true,
        onBack: () => context.pop(),
      ),
      body: SafeArea(
        bottom: false,
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => FocusScope.of(context).unfocus(),
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                FinoraSpacing.lg,
                FinoraSpacing.md,
                FinoraSpacing.lg,
                FinoraSpacing.xl,
              ),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              children: [
                _TypeToggleRow(
                  type: _type,
                  onChanged: (t) => setState(() {
                    _type = t;
                    _category =
                        (t == TransactionType.revenue
                                ? _revenueCategories
                                : _expenseCategories)
                            .first;
                  }),
                ),
                const SizedBox(height: FinoraSpacing.lg),
                FinoraFinancialCard(
                  tone: FinoraCardTone.brand,
                  padding: const EdgeInsets.all(FinoraSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          FinoraIconChip(
                            icon: Icons.payments_rounded,
                            tone: FinoraBadgeTone.brand,
                            size: 36,
                          ),
                          const SizedBox(width: FinoraSpacing.sm),
                          Text('Amount', style: FinoraTextStyles.h4),
                        ],
                      ),
                      const SizedBox(height: FinoraSpacing.sm),
                      FinoraAmountField(
                        label: 'Amount',
                        controller: _amountCtrl,
                        currencySymbol: _symbolFor(currency),
                        autofocus: true,
                        textInputAction: TextInputAction.next,
                        hint: '0.00',
                        validator: (v) =>
                            Validators.positiveNumber(v, label: 'Amount'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: FinoraSpacing.lg),
                Text('Category', style: FinoraTextStyles.label),
                const SizedBox(height: FinoraSpacing.xs),
                FinoraDropdown<String>(
                  label: 'Category',
                  value: _category,
                  options: _categories,
                  prefixIcon: Icons.category_outlined,
                  onChanged: (v) => setState(() => _category = v!),
                ),
                const SizedBox(height: FinoraSpacing.lg),
                Text('Date', style: FinoraTextStyles.label),
                const SizedBox(height: FinoraSpacing.xs),
                _DateField(date: _date, onTap: _pickDate),
                const SizedBox(height: FinoraSpacing.lg),
                AppTextField(
                  label: 'Description (optional)',
                  controller: _descriptionCtrl,
                  prefixIcon: Icons.notes_rounded,
                  maxLines: 3,
                  textInputAction: TextInputAction.newline,
                ),
                const SizedBox(height: FinoraSpacing.xl),
                FinoraGradientButton(
                  label: 'Save transaction',
                  loading: _saving,
                  onPressed: _submit,
                  icon: Icons.check_rounded,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _symbolFor(String currency) {
  switch (currency.toUpperCase()) {
    case 'BDT':
      return '\u09F3';
    case 'USD':
      return '\$';
    case 'EUR':
      return '\u20AC';
    case 'GBP':
      return '\u00A3';
    case 'INR':
      return '\u20B9';
    default:
      return '$currency ';
  }
}

class _TypeToggleRow extends StatelessWidget {
  const _TypeToggleRow({required this.type, required this.onChanged});
  final TransactionType type;
  final ValueChanged<TransactionType> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _TypeToggle(
            selected: type == TransactionType.revenue,
            label: 'Revenue',
            icon: Icons.trending_up_rounded,
            tone: FinoraBadgeTone.positive,
            onTap: () => onChanged(TransactionType.revenue),
          ),
        ),
        const SizedBox(width: FinoraSpacing.sm),
        Expanded(
          child: _TypeToggle(
            selected: type == TransactionType.expense,
            label: 'Expense',
            icon: Icons.trending_down_rounded,
            tone: FinoraBadgeTone.negative,
            onTap: () => onChanged(TransactionType.expense),
          ),
        ),
      ],
    );
  }
}

class _TypeToggle extends StatelessWidget {
  const _TypeToggle({
    required this.selected,
    required this.label,
    required this.icon,
    required this.tone,
    required this.onTap,
  });

  final bool selected;
  final String label;
  final IconData icon;
  final FinoraBadgeTone tone;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = finoraBadgeFg(tone);
    final bg = finoraBadgeBg(tone);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(FinoraRadii.lg),
        onTap: onTap,
        child: AnimatedContainer(
          duration: FinoraMotion.fast,
          padding: const EdgeInsets.symmetric(
            vertical: FinoraSpacing.md,
            horizontal: FinoraSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: selected ? bg : FinoraColors.surfaceAlt,
            borderRadius: BorderRadius.circular(FinoraRadii.lg),
            border: Border.all(
              color: selected
                  ? fg
                  : FinoraColors.outline.withValues(alpha: 0.6),
              width: selected ? 1.4 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: selected ? fg : FinoraColors.textSecondary),
              const SizedBox(width: FinoraSpacing.xs),
              Text(
                label,
                style: FinoraTextStyles.label.copyWith(
                  color: selected ? fg : FinoraColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({required this.date, required this.onTap});
  final DateTime date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(FinoraRadii.md),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: FinoraSpacing.md,
            vertical: FinoraSpacing.md,
          ),
          decoration: BoxDecoration(
            color: FinoraColors.surfaceAlt,
            borderRadius: BorderRadius.circular(FinoraRadii.md),
            border: Border.all(color: FinoraColors.outline, width: 1.2),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.calendar_today_rounded,
                size: 18,
                color: FinoraColors.brandPrimary,
              ),
              const SizedBox(width: FinoraSpacing.sm),
              Text(formatDate(date), style: FinoraTextStyles.body),
              const Spacer(),
              const Icon(
                Icons.chevron_right_rounded,
                color: FinoraColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
