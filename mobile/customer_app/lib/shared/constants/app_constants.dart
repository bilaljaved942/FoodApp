/// Application-wide constants for the FoodApp customer app.
abstract class AppConstants {
  // ─── App Info ─────────────────────────────────────────────────────────────
  static const String appName = 'FoodApp';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';

  // ─── Pagination ───────────────────────────────────────────────────────────
  static const int defaultPageSize = 20;
  static const int firstPage = 1;

  // ─── Timeouts ─────────────────────────────────────────────────────────────
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  // ─── Cache ────────────────────────────────────────────────────────────────
  static const Duration cacheMaxAge = Duration(minutes: 5);
  static const int maxCacheSize = 10 * 1024 * 1024; // 10 MB

  // ─── Search ───────────────────────────────────────────────────────────────
  static const Duration searchDebounce = Duration(milliseconds: 400);
  static const int minSearchLength = 2;

  // ─── Map ──────────────────────────────────────────────────────────────────
  static const double defaultLatitude = 37.7749;
  static const double defaultLongitude = -122.4194;
  static const double defaultZoom = 14.0;
  static const double deliveryRadiusKm = 10.0;

  // ─── Orders ───────────────────────────────────────────────────────────────
  static const double minimumOrderAmount = 5.0;
  static const double deliveryFeeBase = 2.99;
  static const double freeDeliveryThreshold = 30.0;
  static const double serviceFeePercent = 0.05; // 5%

  // ─── Animation durations ──────────────────────────────────────────────────
  static const Duration shortAnimation = Duration(milliseconds: 150);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // ─── Image quality ────────────────────────────────────────────────────────
  static const int imageQuality = 80;
  static const int maxImageSizeMb = 5;

  // ─── Snackbar ────────────────────────────────────────────────────────────
  static const Duration snackBarDuration = Duration(seconds: 3);

  // ─── Order statuses ───────────────────────────────────────────────────────
  static const String orderStatusPending = 'pending';
  static const String orderStatusConfirmed = 'confirmed';
  static const String orderStatusPreparing = 'preparing';
  static const String orderStatusReadyForPickup = 'ready_for_pickup';
  static const String orderStatusOnTheWay = 'on_the_way';
  static const String orderStatusDelivered = 'delivered';
  static const String orderStatusCancelled = 'cancelled';

  static const List<String> activeOrderStatuses = [
    orderStatusConfirmed,
    orderStatusPreparing,
    orderStatusReadyForPickup,
    orderStatusOnTheWay,
  ];

  // ─── Payment methods ──────────────────────────────────────────────────────
  static const String paymentCard = 'card';
  static const String paymentCash = 'cash';
  static const String paymentWallet = 'wallet';

  // ─── Regex patterns ───────────────────────────────────────────────────────
  static const String emailPattern =
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
  static const String phonePattern = r'^\+?[0-9]{7,15}$';
}
