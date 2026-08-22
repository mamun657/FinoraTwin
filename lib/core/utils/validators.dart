class Validators {
  Validators._();

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    final regex = RegExp(r'^[\w.\-+]+@[\w\-]+\.[\w\-.]+$');
    if (!regex.hasMatch(value.trim())) return 'Enter a valid email';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'Use at least 8 characters';
    if (!RegExp('[A-Z]').hasMatch(value)) return 'Add an uppercase letter';
    if (!RegExp('[a-z]').hasMatch(value)) return 'Add a lowercase letter';
    if (!RegExp('[0-9]').hasMatch(value)) return 'Add a number';
    return null;
  }

  static String? simplePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Use at least 6 characters';
    return null;
  }

  static String? fullName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Full name is required';
    if (value.trim().length < 2) return 'Name is too short';
    return null;
  }

  static String? businessName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Business name is required';
    }
    return null;
  }

  static String? positiveNumber(String? value, {String label = 'Amount'}) {
    if (value == null || value.trim().isEmpty) return '$label is required';
    final parsed = double.tryParse(value.replaceAll(',', '.'));
    if (parsed == null) return 'Enter a valid number';
    if (parsed <= 0) return '$label must be greater than zero';
    return null;
  }

  static String? positiveInteger(String? value, {String label = 'Value'}) {
    if (value == null || value.trim().isEmpty) return '$label is required';
    final parsed = int.tryParse(value);
    if (parsed == null) return 'Enter a whole number';
    if (parsed <= 0) return '$label must be greater than zero';
    return null;
  }

  static String? interestRate(String? value) {
    if (value == null || value.trim().isEmpty) return 'Rate is required';
    final parsed = double.tryParse(value.replaceAll(',', '.'));
    if (parsed == null) return 'Enter a valid rate';
    if (parsed < 0 || parsed > 100) return 'Rate must be between 0 and 100';
    return null;
  }
}
