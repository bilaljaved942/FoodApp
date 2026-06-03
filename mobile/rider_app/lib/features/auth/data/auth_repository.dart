import 'package:injectable/injectable.dart';

import '../../../core/network/dio_client.dart';
import '../../../core/storage/storage_service.dart';
import '../domain/auth_state.dart';

@injectable
class AuthRepository {
  final DioClient _client;
  final StorageService _storage;

  AuthRepository(this._client, this._storage);

  Future<RiderUser> login({required String email, required String password}) async {
    final response = await _client.dio.post(
      '/auth/login',
      data: {'email': email, 'password': password},
    );
    final data = response.data as Map<String, dynamic>;
    await _storage.saveAccessToken(data['access_token'] as String);
    await _storage.saveRefreshToken(data['refresh_token'] as String);
    return RiderUser.fromJson(data['user'] as Map<String, dynamic>);
  }

  Future<void> logout() async {
    try { await _client.dio.post('/auth/logout'); } catch (_) {}
    await _storage.clearAuth();
  }

  Future<RiderUser?> getCurrentUser() async {
    final token = _storage.getAccessToken();
    if (token == null) return null;
    final response = await _client.dio.get('/auth/me');
    return RiderUser.fromJson(response.data as Map<String, dynamic>);
  }
}
