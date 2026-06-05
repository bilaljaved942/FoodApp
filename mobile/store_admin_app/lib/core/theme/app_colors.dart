import 'package:flutter/material.dart';

abstract class AppColors {
  // ─── Primary (Warm Orange) ────────────────────────────────────────────────
  static const Color primary = Color(0xFFFF5722);
  static const Color primaryLight = Color(0xFFFF8A65);
  static const Color primaryDark = Color(0xFFBF360C);

  // ─── Secondary (Crimson Red) ──────────────────────────────────────────────
  static const Color secondary = Color(0xFFD32F2F);
  static const Color secondaryLight = Color(0xFFEF9A9A);
  static const Color secondaryDark = Color(0xFF7F0000);

  // ─── Accent ───────────────────────────────────────────────────────────────
  static const Color accent = Color(0xFFFFC107);
  static const Color accentLight = Color(0xFFFFE082);
  static const Color accentDark = Color(0xFFFF8F00);

  // ─── Success ──────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF2E7D32);
  static const Color successLight = Color(0xFFA5D6A7);

  // ─── Error ────────────────────────────────────────────────────────────────
  static const Color error = Color(0xFFD32F2F);
  static const Color errorLight = Color(0xFFEF9A9A);
  static const Color errorDark = Color(0xFFB71C1C);

  // ─── Neutral / Surface ────────────────────────────────────────────────────
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF5F5F5);
  static const Color onSurface = Color(0xFF1C1B1F);
  static const Color onSurfaceVariant = Color(0xFF49454F);
  static const Color outline = Color(0xFFE0E0E0);
  static const Color starFilled = Color(0xFFFFC107);
  static const Color shimmer = Color(0xFFE0E0E0);
  static const Color divider = Color(0xFFEEEEEE);
}
