import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'api_constants.dart';

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

  static BaseOptions get _baseOptions => BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        validateStatus: (status) => status != null && status < 500,
      );

  InterceptorsWrapper get _authInterceptor => InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _getAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException err, handler) async {
          if (err.response?.statusCode == 401) {
            try {
              final refreshed = await _refreshToken();
              if (refreshed) {
                final token = await _getAccessToken();
                err.requestOptions.headers['Authorization'] = 'Bearer $token';
                final response = await _dio.fetch(err.requestOptions);
                return handler.resolve(response);
              }
            } catch (_) {}
          }
          return handler.next(err);
        },
      );

  InterceptorsWrapper get _errorInterceptor => InterceptorsWrapper(
        onError: (DioException err, handler) {
          debugPrint('[DioClient] Error: ${err.message}');
          return handler.next(err);
        },
      );

  LogInterceptor get _loggingInterceptor => LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: true,
        responseHeader: false,
        error: true,
        logPrint: (obj) => debugPrint(obj.toString()),
      );

  Dio get dio => _dio;

  Future<String?> _getAccessToken() async => null;
  Future<bool> _refreshToken() async => false;
}
