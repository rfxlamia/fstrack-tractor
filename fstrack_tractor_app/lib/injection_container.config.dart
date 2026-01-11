// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import 'core/di/core_module.dart' as _i849;
import 'core/network/api_client.dart' as _i871;
import 'core/network/retry_interceptor.dart' as _i189;
import 'core/storage/hive_service.dart' as _i946;
import 'features/auth/data/datasources/auth_local_datasource.dart' as _i1043;
import 'features/auth/data/datasources/auth_remote_datasource.dart' as _i588;
import 'features/auth/data/repositories/auth_repository_impl.dart' as _i111;
import 'features/auth/domain/repositories/auth_repository.dart' as _i1015;
import 'features/auth/domain/usecases/login_user_usecase.dart' as _i323;
import 'features/auth/presentation/bloc/auth_bloc.dart' as _i363;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    final coreModule = _$CoreModule();
    gh.lazySingleton<_i946.HiveService>(() => coreModule.hiveService);
    gh.lazySingleton<_i189.RetryInterceptor>(() => _i189.RetryInterceptor());
    gh.lazySingleton<_i1043.AuthLocalDataSource>(
        () => _i1043.AuthLocalDataSource(hiveService: gh<_i946.HiveService>()));
    gh.lazySingleton<_i871.ApiClient>(
        () => _i871.ApiClient(retryInterceptor: gh<_i189.RetryInterceptor>()));
    gh.lazySingleton<_i588.AuthRemoteDataSource>(
        () => _i588.AuthRemoteDataSource(apiClient: gh<_i871.ApiClient>()));
    gh.lazySingleton<_i1015.AuthRepository>(() => _i111.AuthRepositoryImpl(
          remoteDataSource: gh<_i588.AuthRemoteDataSource>(),
          localDataSource: gh<_i1043.AuthLocalDataSource>(),
        ));
    gh.factory<_i323.LoginUserUseCase>(() =>
        _i323.LoginUserUseCase(authRepository: gh<_i1015.AuthRepository>()));
    gh.singleton<_i363.AuthBloc>(
        () => _i363.AuthBloc(loginUserUseCase: gh<_i323.LoginUserUseCase>()));
    return this;
  }
}

class _$CoreModule extends _i849.CoreModule {}
