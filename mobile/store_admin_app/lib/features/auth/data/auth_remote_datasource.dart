import '../../../core/network/dio_client.dart';

class AuthRemoteDataSource {
  final DioClient dioClient;

  AuthRemoteDataSource(this.dioClient);

  Future<bool> checkAuthStatus() async {
    // TODO: implement remote auth status check
    return false;
  }
}
