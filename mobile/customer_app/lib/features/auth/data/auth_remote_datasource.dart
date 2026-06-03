import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

import '../../../core/network/api_constants.dart';
import '../../../core/network/dio_client.dart';
import '../domain/auth_models.dart';

part 'auth_remote_datasource.g.dart';

/// Retrofit-generated remote data source for all auth API calls.
@RestApi()
@injectable
abstract class AuthRemoteDataSource {
  @factoryMethod
  factory AuthRemoteDataSource(DioClient client) =>
      _AuthRemoteDataSource(client.dio);

  @POST(ApiConstants.login)
  Future<AuthResponse> login(@Body() LoginRequest request);

  @POST(ApiConstants.register)
  Future<AuthResponse> register(@Body() RegisterRequest request);

  @POST(ApiConstants.logout)
  Future<void> logout();

  @POST(ApiConstants.refreshToken)
  Future<AuthResponse> refreshToken(@Body() RefreshTokenRequest request);

  @POST(ApiConstants.forgotPassword)
  Future<void> forgotPassword(@Body() ForgotPasswordRequest request);

  @GET(ApiConstants.me)
  Future<User> getMe();
}
