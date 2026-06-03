import 'dart:io';

/// All API endpoint constants for the FoodApp customer application.
abstract class ApiConstants {
  // ─── Base ─────────────────────────────────────────────────────────────────
  static final String baseUrl = Platform.isAndroid ? 'http://10.0.2.2:8000/api' : 'http://localhost:8000/api';

  // ─── Auth ────────────────────────────────────────────────────────────────
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String verifyOtp = '/auth/verify-otp';
  static const String resendOtp = '/auth/resend-otp';
  static const String me = '/auth/me';

  // ─── Stores ───────────────────────────────────────────────────────────────
  static const String stores = '/stores';
  static String storeById(String id) => '/stores/$id';
  static String storeMenu(String storeId) => '/stores/$storeId/menu';
  static String storeReviews(String storeId) => '/stores/$storeId/reviews';
  static String storeCategories(String storeId) => '/stores/$storeId/categories';
  static const String nearbyStores = '/stores/nearby';
  static const String featuredStores = '/stores/featured';
  static const String searchStores = '/stores/search';

  // ─── Products ─────────────────────────────────────────────────────────────
  static const String products = '/products';
  static String productById(String id) => '/products/$id';
  static const String searchProducts = '/products/search';

  // ─── Cart ─────────────────────────────────────────────────────────────────
  static const String cart = '/cart';
  static const String cartItems = '/cart/items';
  static String cartItem(String itemId) => '/cart/items/$itemId';
  static const String cartClear = '/cart/clear';

  // ─── Orders ───────────────────────────────────────────────────────────────
  static const String orders = '/orders';
  static String orderById(String id) => '/orders/$id';
  static String orderTracking(String id) => '/orders/$id/tracking';
  static String orderCancel(String id) => '/orders/$id/cancel';
  static String orderReorder(String id) => '/orders/$id/reorder';
  static const String orderHistory = '/orders/history';

  // ─── Checkout ─────────────────────────────────────────────────────────────
  static const String checkout = '/checkout';
  static const String checkoutValidate = '/checkout/validate';
  static const String applyCoupon = '/checkout/apply-coupon';
  static const String removeCoupon = '/checkout/remove-coupon';

  // ─── Payments ─────────────────────────────────────────────────────────────
  static const String paymentIntent = '/payments/create-intent';
  static const String paymentConfirm = '/payments/confirm';
  static const String paymentMethods = '/payments/methods';

  // ─── Addresses ────────────────────────────────────────────────────────────
  static const String addresses = '/addresses';
  static String addressById(String id) => '/addresses/$id';
  static const String defaultAddress = '/addresses/default';
  static const String geocode = '/addresses/geocode';

  // ─── Profile ──────────────────────────────────────────────────────────────
  static const String profile = '/profile';
  static const String updateProfile = '/profile/update';
  static const String updateAvatar = '/profile/avatar';
  static const String changePassword = '/profile/change-password';

  // ─── Notifications ────────────────────────────────────────────────────────
  static const String notifications = '/notifications';
  static String notificationById(String id) => '/notifications/$id';
  static const String notificationsMarkRead = '/notifications/mark-all-read';
  static const String fcmToken = '/notifications/fcm-token';

  // ─── Reviews ──────────────────────────────────────────────────────────────
  static const String reviews = '/reviews';
  static String reviewById(String id) => '/reviews/$id';

  // ─── Categories ───────────────────────────────────────────────────────────
  static const String categories = '/categories';
  static String categoryById(String id) => '/categories/$id';

  // ─── Favourites ───────────────────────────────────────────────────────────
  static const String favourites = '/favourites';
  static String favouriteStore(String storeId) => '/favourites/stores/$storeId';

  // ─── WebSocket ────────────────────────────────────────────────────────────
  static final String wsBaseUrl = Platform.isAndroid ? 'ws://10.0.2.2:8000/ws' : 'ws://localhost:8000/ws';
  static String orderTrackingWs(String orderId) => '$wsBaseUrl/orders/$orderId/tracking';
}
