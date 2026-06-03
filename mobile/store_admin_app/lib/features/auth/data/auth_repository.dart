import 'auth_remote_datasource.dart';
import '../../../core/storage/storage_service.dart';

class AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final StorageService storageService;

  AuthRepository(this.remoteDataSource, this.storageService);

  Future<bool> checkAuthStatus() async {
    return await remoteDataSource.checkAuthStatus();
  }
}
