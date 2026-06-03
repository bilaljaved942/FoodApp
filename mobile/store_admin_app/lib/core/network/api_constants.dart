import 'dart:io';

/// All API endpoint constants for the FoodApp Store Admin application.
abstract class ApiConstants {
  static final String baseUrl = Platform.isAndroid ? 'http://10.0.2.2:8000/api' : 'http://localhost:8000/api';

  // Auth
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';
  static const String me = '/auth/me';

  // Store
  static const String myStore = '/store/me';
  static const String updateStore = '/store/update';
  static const String storeStats = '/store/stats';

  // Products
  static const String products = '/store/products';
  static String productById(String id) => '/store/products/$id';
  static const String createProduct = '/store/products';
  static String updateProduct(String id) => '/store/products/$id';
  static String deleteProduct(String id) => '/store/products/$id';
  static String toggleProductAvailability(String id) => '/store/products/$id/availability';

  // Orders
  static const String orders = '/store/orders';
  static String orderById(String id) => '/store/orders/$id';
  static String acceptOrder(String id) => '/store/orders/$id/accept';
  static String rejectOrder(String id) => '/store/orders/$id/reject';
  static String updateOrderStatus(String id) => '/store/orders/$id/status';

  // Categories
  static const String categories = '/store/categories';

  // Profile
  static const String profile = '/store/profile';
  static const String fcmToken = '/notifications/fcm-token';

  // WebSocket
  static final String wsBaseUrl = Platform.isAndroid ? 'ws://10.0.2.2:8000/ws' : 'ws://localhost:8000/ws';
  static String ordersWs(String storeId) => '$wsBaseUrl/store/$storeId/orders';
}
