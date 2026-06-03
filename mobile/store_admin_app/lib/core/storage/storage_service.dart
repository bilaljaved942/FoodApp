import 'package:hive_flutter/hive_flutter.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@singleton
class StorageService {
  static const String _authBoxName = 'auth_box';
  late SharedPreferences _prefs;
  late Box<dynamic> _authBox;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _authBox = await Hive.openBox(_authBoxName);
  }

  Future<void> saveAccessToken(String token) async => _authBox.put('access_token', token);
  String? getAccessToken() => _authBox.get('access_token') as String?;

  Future<void> saveRefreshToken(String token) async => _authBox.put('refresh_token', token);
  String? getRefreshToken() => _authBox.get('refresh_token') as String?;

  Future<void> saveUserId(String id) async => _prefs.setString('user_id', id);
  String? getUserId() => _prefs.getString('user_id');

  Future<void> clearAuth() async {
    await _authBox.deleteAll(['access_token', 'refresh_token']);
    await _prefs.remove('user_id');
  }
}
