class Validators {
  const Validators._();

  static final _phoneDigits = RegExp(r'^\d{10}$');
  static final _username = RegExp(r'^[A-Za-z0-9_]{3,24}$');

  static String normalizePhone(String value) {
    var digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('91') && digits.length == 12) {
      digits = digits.substring(2);
    }
    if (digits.startsWith('0') && digits.length == 11) {
      digits = digits.substring(1);
    }
    return digits;
  }

  static String? username(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Enter a username';
    if (!_username.hasMatch(trimmed)) {
      return 'Use 3-24 letters, numbers, or underscores';
    }
    return null;
  }

  static String? phone(String? value) {
    final digits = normalizePhone(value ?? '');
    if (digits.isEmpty) return 'Enter your phone number';
    if (!_phoneDigits.hasMatch(digits)) {
      return 'Enter a valid 10-digit phone number';
    }
    return null;
  }

  static String? password(String? value, {bool isNew = false}) {
    final password = value ?? '';
    if (password.isEmpty) {
      return isNew ? 'Create a password' : 'Enter your password';
    }
    if (password.length < 8) return 'Password must be at least 8 characters';
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) return 'Confirm your password';
    if (value != password) return 'Passwords do not match';
    return null;
  }
}
