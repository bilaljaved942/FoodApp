import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// ─── BuildContext extensions ──────────────────────────────────────────────────
extension ContextX on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;
  Size get screenSize => MediaQuery.sizeOf(this);
  double get screenWidth => MediaQuery.sizeOf(this).width;
  double get screenHeight => MediaQuery.sizeOf(this).height;
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
  EdgeInsets get padding => MediaQuery.paddingOf(this);

  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? colorScheme.error : colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void showErrorSnackBar(String message) => showSnackBar(message, isError: true);
}

// ─── String extensions ────────────────────────────────────────────────────────
extension StringX on String {
  bool get isValidEmail =>
      RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(this);

  bool get isValidPhone =>
      RegExp(r'^\+?[0-9]{7,15}$').hasMatch(this);

  bool get isValidPassword => length >= 8;

  String get capitalizeFirst =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';

  String get titleCase => split(' ')
      .map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
      .join(' ');

  String truncate(int maxLength, {String ellipsis = '...'}) =>
      length <= maxLength ? this : '${substring(0, maxLength)}$ellipsis';
}

// ─── num / double extensions ──────────────────────────────────────────────────
extension NumX on num {
  /// Format as currency: 12.5 → '$12.50'
  String toCurrency({String symbol = '\$'}) =>
      '$symbol${toStringAsFixed(2)}';

  /// Compact format: 1500 → '1.5k'
  String toCompact() {
    if (abs() >= 1000000) return '${(this / 1000000).toStringAsFixed(1)}M';
    if (abs() >= 1000) return '${(this / 1000).toStringAsFixed(1)}k';
    return toString();
  }

  SizedBox get verticalSpace => SizedBox(height: toDouble());
  SizedBox get horizontalSpace => SizedBox(width: toDouble());
}

// ─── DateTime extensions ──────────────────────────────────────────────────────
extension DateTimeX on DateTime {
  String get formattedDate => DateFormat('MMM dd, yyyy').format(this);
  String get formattedTime => DateFormat('hh:mm a').format(this);
  String get formattedDateTime => DateFormat('MMM dd, yyyy • hh:mm a').format(this);

  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  String get relativeTime {
    final now = DateTime.now();
    final diff = now.difference(this);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return formattedDate;
  }
}

// ─── List extensions ──────────────────────────────────────────────────────────
extension ListX<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
  T? get lastOrNull => isEmpty ? null : last;
  List<T> separated(T separator) {
    if (isEmpty) return this;
    final result = <T>[];
    for (int i = 0; i < length; i++) {
      result.add(this[i]);
      if (i < length - 1) result.add(separator);
    }
    return result;
  }
}
