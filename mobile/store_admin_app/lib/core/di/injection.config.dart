// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// coverage:ignore-file

import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import '../../features/auth/data/auth_remote_datasource.dart' as _i100;
import '../../features/auth/data/auth_repository.dart' as _i101;
import '../../features/auth/presentation/auth_bloc.dart' as _i102;
import '../network/dio_client.dart' as _i200;
import '../storage/storage_service.dart' as _i300;

extension GetItInjectableX on _i174.GetIt {
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);

    gh.singleton<_i300.StorageService>(() => _i300.StorageService());
    gh.singleton<_i200.DioClient>(() => _i200.DioClient());
    gh.factory<_i100.AuthRemoteDataSource>(
        () => _i100.AuthRemoteDataSource(gh<_i200.DioClient>()));
    gh.factory<_i101.AuthRepository>(
        () => _i101.AuthRepository(gh<_i100.AuthRemoteDataSource>(), gh<_i300.StorageService>()));
    gh.factory<_i102.AuthBloc>(
        () => _i102.AuthBloc(gh<_i101.AuthRepository>()));

    return this;
  }
}
