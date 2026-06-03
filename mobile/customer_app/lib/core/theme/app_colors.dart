import 'package:flutter/material.dart';

/// All colour constants for the FoodApp customer application.
/// Palette centred on warm oranges and deep reds — evoking appetite.
abstract class AppColors {
  // ─── Primary (Warm Orange) ────────────────────────────────────────────────
  static const Color primary = Color(0xFFFF5722);       // Deep Orange 600
  static const Color primaryLight = Color(0xFFFF8A65);  // Deep Orange 300
  static const Color primaryDark = Color(0xFFBF360C);   // Deep Orange 900

  // ─── Secondary (Crimson Red) ──────────────────────────────────────────────
  static const Color secondary = Color(0xFFD32F2F);     // Red 700
  static const Color secondaryLight = Color(0xFFEF9A9A); // Red 200
  static const Color secondaryDark = Color(0xFF7F0000);  // Red 900

  // ─── Accent (Amber for highlights) ───────────────────────────────────────
  static const Color accent = Color(0xFFFFC107);        // Amber 500
  static const Color accentLight = Color(0xFFFFE082);   // Amber 200
  static const Color accentDark = Color(0xFFFF8F00);    // Amber 700

  // ─── Success ─────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF2E7D32);       // Green 800
  static const Color successLight = Color(0xFFA5D6A7);  // Green 200
  static const Color successDark = Color(0xFF1B5E20);   // Green 900

  // ─── Warning ─────────────────────────────────────────────────────────────
  static const Color warning = Color(0xFFF57C00);       // Orange 700
  static const Color warningLight = Color(0xFFFFCC80);  // Orange 200
  static const Color warningDark = Color(0xFFE65100);   // Orange 900

  // ─── Error ────────────────────────────────────────────────────────────────
  static const Color error = Color(0xFFB00020);
  static const Color errorLight = Color(0xFFCF6679);
  static const Color errorDark = Color(0xFF790000);

  // ─── Neutral / Surface ───────────────────────────────────────────────────
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF5F5F5);
  static const Color onSurface = Color(0xFF1C1B1F);
  static const Color onSurfaceVariant = Color(0xFF49454F);
  static const Color outline = Color(0xFFE0E0E0);

  // ─── Rating Star ─────────────────────────────────────────────────────────
  static const Color starFilled = Color(0xFFFFC107);
  static const Color starEmpty = Color(0xFFE0E0E0);

  // ─── Status chips ────────────────────────────────────────────────────────
  static const Color statusPending = Color(0xFFFFF3E0);
  static const Color statusPendingText = Color(0xFFE65100);
  static const Color statusConfirmed = Color(0xFFE3F2FD);
  static const Color statusConfirmedText = Color(0xFF1565C0);
  static const Color statusDelivered = Color(0xFFE8F5E9);
  static const Color statusDeliveredText = Color(0xFF2E7D32);
  static const Color statusCancelled = Color(0xFFFFEBEE);
  static const Color statusCancelledText = Color(0xFFC62828);

  // ─── Misc ─────────────────────────────────────────────────────────────────
  static const Color divider = Color(0xFFEEEEEE);
  static const Color shimmer = Color(0xFFE0E0E0);
  static const Color shimmerHighlight = Color(0xFFF5F5F5);
  static const Color shadow = Color(0x1A000000);
  static const Color overlay = Color(0x80000000);
  static const Color transparent = Colors.transparent;
}
