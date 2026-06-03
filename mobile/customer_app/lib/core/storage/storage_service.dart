import 'package:hive_flutter/hive_flutter.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Keys used throughout the storage service.
abstract class StorageKeys {
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String userId = 'user_id';
  static const String userEmail = 'user_email';
  static const String userName = 'user_name';
  static const String isOnboarded = 'is_onboarded';
  static const String cartBox = 'cart_box';
  static const String addressBox = 'address_box';
}

/// Centralised local storage service wrapping [SharedPreferences] (key-value)
/// and [Hive] (structured / encrypted boxes).
@singleton
class StorageService {
  static const String _authBoxName = 'auth_box';

  late SharedPreferences _prefs;
  late Box<dynamic> _authBox;

  /// Must be called before using [StorageService].
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _authBox = await Hive.openBox(_authBoxName);
  }

  // ─── Access Token ─────────────────────────────────────────────────────────
  Future<void> saveAccessToken(String token) async =>
      _authBox.put(StorageKeys.accessToken, token);

  String? getAccessToken() =>
      _authBox.get(StorageKeys.accessToken) as String?;

  Future<void> deleteAccessToken() async =>
      _authBox.delete(StorageKeys.accessToken);

  // ─── Refresh Token ────────────────────────────────────────────────────────
  Future<void> saveRefreshToken(String token) async =>
      _authBox.put(StorageKeys.refreshToken, token);

  String? getRefreshToken() =>
      _authBox.get(StorageKeys.refreshToken) as String?;

  Future<void> deleteRefreshToken() async =>
      _authBox.delete(StorageKeys.refreshToken);

  // ─── User Info ────────────────────────────────────────────────────────────
  Future<void> saveUserId(String id) async =>
      _prefs.setString(StorageKeys.userId, id);

  String? getUserId() => _prefs.getString(StorageKeys.userId);

  Future<void> saveUserEmail(String email) async =>
      _prefs.setString(StorageKeys.userEmail, email);

  String? getUserEmail() => _prefs.getString(StorageKeys.userEmail);

  Future<void> saveUserName(String name) async =>
      _prefs.setString(StorageKeys.userName, name);

  String? getUserName() => _prefs.getString(StorageKeys.userName);

  // ─── Onboarding ───────────────────────────────────────────────────────────
  bool get isOnboarded => _prefs.getBool(StorageKeys.isOnboarded) ?? false;

  Future<void> setOnboarded() async =>
      _prefs.setBool(StorageKeys.isOnboarded, true);

  // ─── Clear All (logout) ───────────────────────────────────────────────────
  Future<void> clearAuth() async {
    await _authBox.deleteAll([StorageKeys.accessToken, StorageKeys.refreshToken]);
    await _prefs.remove(StorageKeys.userId);
    await _prefs.remove(StorageKeys.userEmail);
    await _prefs.remove(StorageKeys.userName);
  }
}
