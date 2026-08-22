import 'package:intl/intl.dart';

String formatMoney(num? value, {String currency = 'USD'}) {
  if (value == null) return '—';
  final amount = value.toDouble();
  final formatter = NumberFormat.currency(
    locale: 'en_US',
    symbol: _symbolFor(currency),
    decimalDigits: 2,
  );
  return formatter.format(amount);
}

String formatCompactMoney(num? value, {String currency = 'USD'}) {
  if (value == null) return '—';
  final symbol = _symbolFor(currency);
  final amount = value.toDouble();
  if (amount.abs() >= 1000000) {
    return '$symbol${(amount / 1000000).toStringAsFixed(2)}M';
  }
  if (amount.abs() >= 1000) {
    return '$symbol${(amount / 1000).toStringAsFixed(1)}K';
  }
  return '$symbol${amount.toStringAsFixed(0)}';
}

String formatPercent(double? value, {int digits = 1}) {
  if (value == null || value.isNaN || value.isInfinite) return '—';
  return '${(value * 100).toStringAsFixed(digits)}%';
}

String formatDate(DateTime? date) {
  if (date == null) return '—';
  return DateFormat('MMM d, yyyy').format(date);
}

String formatRelativeDate(DateTime? date) {
  if (date == null) return '—';
  final now = DateTime.now();
  final diff = now.difference(date);
  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays < 7) return '${diff.inDays}d ago';
  return DateFormat('MMM d').format(date);
}

String formatMonthYear(DateTime? date) {
  if (date == null) return '—';
  return DateFormat('MMMM yyyy').format(date);
}

String formatMonthDay(DateTime? date) {
  if (date == null) return '—';
  return DateFormat('MMM d').format(date);
}

String _symbolFor(String currency) {
  switch (currency.toUpperCase()) {
    case 'USD':
      return r'$';
    case 'EUR':
      return '€';
    case 'GBP':
      return '£';
    case 'NGN':
      return '₦';
    case 'KES':
      return 'KSh';
    case 'INR':
      return '₹';
    case 'BDT':
      return '৳';
    default:
      return '$currency ';
  }
}

String currencySymbol(String currency) => _symbolFor(currency);
