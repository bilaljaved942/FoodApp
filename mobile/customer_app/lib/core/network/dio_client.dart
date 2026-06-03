import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'api_constants.dart';

/// Dio HTTP client with:
///  - BaseOptions (timeout, base URL, headers)
///  - JWT auth interceptor
///  - Logging interceptor (debug only)
///  - Error response interceptor
class DioClient {
  late final Dio _dio;

  DioClient() {
    _dio = Dio(_baseOptions);
    _dio.interceptors.addAll([
      _authInterceptor,
      _errorInterceptor,
      if (kDebugMode) _loggingInterceptor,
    ]);
  }

  // ─── Base Options ────────────────────────────────────────────────────────
  static BaseOptions get _baseOptions => BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        validateStatus: (status) => status != null && status < 500,
      );

  // ─── Auth Interceptor ────────────────────────────────────────────────────
  InterceptorsWrapper get _authInterceptor => InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _getAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException err, handler) async {
          // Attempt token refresh on 401
          if (err.response?.statusCode == 401) {
            try {
              final refreshed = await _refreshToken();
              if (refreshed) {
                final token = await _getAccessToken();
                err.requestOptions.headers['Authorization'] = 'Bearer $token';
                final response = await _dio.fetch(err.requestOptions);
                return handler.resolve(response);
              }
            } catch (_) {
              // Refresh failed — propagate error for auth BLoC to handle
            }
          }
          return handler.next(err);
        },
      );

  // ─── Error Interceptor ───────────────────────────────────────────────────
  InterceptorsWrapper get _errorInterceptor => InterceptorsWrapper(
        onError: (DioException err, handler) {
          final apiError = _mapDioError(err);
          debugPrint('[DioClient] Error: ${apiError.message}');
          return handler.next(
            DioException(
              requestOptions: err.requestOptions,
              response: err.response,
              type: err.type,
              error: apiError,
              message: apiError.message,
            ),
          );
        },
      );

  // ─── Logging Interceptor ─────────────────────────────────────────────────
  LogInterceptor get _loggingInterceptor => LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: true,
        responseHeader: false,
        error: true,
        logPrint: (obj) => debugPrint(obj.toString()),
      );

  // ─── Public accessors ────────────────────────────────────────────────────
  Dio get dio => _dio;

  // ─── Helpers ─────────────────────────────────────────────────────────────
  Future<String?> _getAccessToken() async {
    // TODO: read from secure storage / Hive box
    return null;
  }

  Future<bool> _refreshToken() async {
    // TODO: call refresh endpoint and persist new tokens
    return false;
  }

  ApiError _mapDioError(DioException err) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiError(
          message: 'Connection timed out. Please check your internet.',
          statusCode: 408,
        );
      case DioExceptionType.badResponse:
        final status = err.response?.statusCode ?? 0;
        final data = err.response?.data;
        final message = data is Map ? (data['message'] ?? 'Server error') : 'Server error';
        return ApiError(message: message.toString(), statusCode: status);
      case DioExceptionType.cancel:
        return ApiError(message: 'Request was cancelled.', statusCode: 0);
      case DioExceptionType.connectionError:
        return ApiError(message: 'No internet connection.', statusCode: 0);
      default:
        return ApiError(message: err.message ?? 'Unexpected error occurred.', statusCode: 0);
    }
  }
}

/// Lightweight error model returned by the interceptor.
class ApiError {
  final String message;
  final int statusCode;

  const ApiError({required this.message, required this.statusCode});

  @override
  String toString() => 'ApiError($statusCode): $message';
}
