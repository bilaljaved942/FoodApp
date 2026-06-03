/// Form field and business-logic validators used throughout the customer app.
abstract class Validators {
  // ─── Email ────────────────────────────────────────────────────────────────
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    final pattern = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!pattern.hasMatch(value.trim())) return 'Enter a valid email address';
    return null;
  }

  // ─── Phone ────────────────────────────────────────────────────────────────
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) return 'Phone number is required';
    final pattern = RegExp(r'^\+?[0-9]{7,15}$');
    if (!pattern.hasMatch(value.trim())) return 'Enter a valid phone number';
    return null;
  }

  // ─── Password ─────────────────────────────────────────────────────────────
  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'Password must be at least 8 characters';
    if (!value.contains(RegExp(r'[A-Z]'))) return 'Must include an uppercase letter';
    if (!value.contains(RegExp(r'[0-9]'))) return 'Must include a number';
    return null;
  }

  /// Confirm password validator — requires the value to match [original].
  static String? Function(String?) confirmPassword(String original) =>
      (String? value) {
        if (value == null || value.isEmpty) return 'Please confirm your password';
        if (value != original) return 'Passwords do not match';
        return null;
      };

  // ─── Name ─────────────────────────────────────────────────────────────────
  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) return 'Name is required';
    if (value.trim().length < 2) return 'Name must be at least 2 characters';
    if (value.trim().length > 60) return 'Name must be less than 60 characters';
    return null;
  }

  // ─── Required ─────────────────────────────────────────────────────────────
  static String? required(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) return '$fieldName is required';
    return null;
  }

  // ─── OTP ──────────────────────────────────────────────────────────────────
  static String? otp(String? value, {int length = 6}) {
    if (value == null || value.isEmpty) return 'OTP is required';
    if (value.length != length) return 'OTP must be $length digits';
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) return 'OTP must be numeric';
    return null;
  }

  // ─── Address ──────────────────────────────────────────────────────────────
  static String? address(String? value) {
    if (value == null || value.trim().isEmpty) return 'Address is required';
    if (value.trim().length < 10) return 'Please enter a complete address';
    return null;
  }

  // ─── Postal Code ──────────────────────────────────────────────────────────
  static String? postalCode(String? value) {
    if (value == null || value.trim().isEmpty) return 'Postal code is required';
    final pattern = RegExp(r'^[A-Z0-9]{3,10}$', caseSensitive: false);
    if (!pattern.hasMatch(value.trim())) return 'Enter a valid postal code';
    return null;
  }

  // ─── Amount ───────────────────────────────────────────────────────────────
  static String? positiveAmount(String? value) {
    if (value == null || value.isEmpty) return 'Amount is required';
    final amount = double.tryParse(value);
    if (amount == null) return 'Enter a valid number';
    if (amount <= 0) return 'Amount must be greater than zero';
    return null;
  }
}
