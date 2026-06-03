import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../core/network/dio_client.dart';
import '../../../core/storage/storage_service.dart';
import '../domain/auth_models.dart';
import 'auth_remote_datasource.dart';

/// Repository that mediates between the remote data source and local storage.
/// Returns [AuthResponse] on success and throws [DioException] / [Exception] on failure.
@injectable
class AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final StorageService _storageService;

  AuthRepository(this._remoteDataSource, this._storageService);

  // ─── Login ────────────────────────────────────────────────────────────────
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final response = await _remoteDataSource.login(
      LoginRequest(email: email, password: password),
    );
    await _persistSession(response);
    return response;
  }

  // ─── Register ─────────────────────────────────────────────────────────────
  Future<AuthResponse> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    final response = await _remoteDataSource.register(
      RegisterRequest(name: name, email: email, password: password, phone: phone),
    );
    await _persistSession(response);
    return response;
  }

  // ─── Logout ───────────────────────────────────────────────────────────────
  Future<void> logout() async {
    try {
      await _remoteDataSource.logout();
    } catch (_) {
      // Best-effort remote logout; always clear local session.
    } finally {
      await _storageService.clearAuth();
    }
  }

  // ─── Refresh Token ────────────────────────────────────────────────────────
  Future<AuthResponse?> refreshToken() async {
    final token = _storageService.getRefreshToken();
    if (token == null) return null;
    final response = await _remoteDataSource.refreshToken(
      RefreshTokenRequest(refreshToken: token),
    );
    await _persistSession(response);
    return response;
  }

  // ─── Forgot Password ──────────────────────────────────────────────────────
  Future<void> forgotPassword(String email) async {
    await _remoteDataSource.forgotPassword(ForgotPasswordRequest(email: email));
  }

  // ─── Get Current User ─────────────────────────────────────────────────────
  Future<User?> getCurrentUser() async {
    final token = _storageService.getAccessToken();
    if (token == null) return null;
    return _remoteDataSource.getMe();
  }

  // ─── Check Session ────────────────────────────────────────────────────────
  bool get hasSession => _storageService.getAccessToken() != null;

  // ─── Helper ───────────────────────────────────────────────────────────────
  Future<void> _persistSession(AuthResponse response) async {
    await _storageService.saveAccessToken(response.accessToken);
    await _storageService.saveRefreshToken(response.refreshToken);
    await _storageService.saveUserId(response.user.id);
    await _storageService.saveUserEmail(response.user.email);
    await _storageService.saveUserName(response.user.name);
  }
}
