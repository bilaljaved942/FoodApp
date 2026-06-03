import 'dart:io';

/// All API endpoint constants for the FoodApp Rider application.
abstract class ApiConstants {
  static final String baseUrl = Platform.isAndroid ? 'http://10.0.2.2:8000/api' : 'http://localhost:8000/api';

  // Auth
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';
  static const String me = '/auth/me';

  // Rider orders
  static const String availableOrders = '/rider/orders/available';
  static const String activeOrder = '/rider/orders/active';
  static String acceptOrder(String id) => '/rider/orders/$id/accept';
  static String rejectOrder(String id) => '/rider/orders/$id/reject';
  static String updateOrderStatus(String id) => '/rider/orders/$id/status';
  static String orderById(String id) => '/rider/orders/$id';

  // Rider location
  static const String updateLocation = '/rider/location';
  static const String toggleAvailability = '/rider/availability';

  // Earnings
  static const String earnings = '/rider/earnings';
  static const String earningsHistory = '/rider/earnings/history';

  // Profile
  static const String profile = '/rider/profile';
  static const String updateProfile = '/rider/profile/update';
  static const String fcmToken = '/notifications/fcm-token';

  // WebSocket
  static final String wsBaseUrl = Platform.isAndroid ? 'ws://10.0.2.2:8000/ws' : 'ws://localhost:8000/ws';
  static String ordersWs(String riderId) => '$wsBaseUrl/rider/$riderId/orders';
}
