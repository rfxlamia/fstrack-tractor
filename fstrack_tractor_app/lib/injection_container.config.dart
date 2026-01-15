// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:connectivity_plus/connectivity_plus.dart' as _i895;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import 'core/di/core_module.dart' as _i849;
import 'core/location/hardcoded_location_provider.dart' as _i157;
import 'core/location/location_provider.dart' as _i712;
import 'core/network/api_client.dart' as _i871;
import 'core/network/connectivity_checker.dart' as _i887;
import 'core/network/connectivity_service.dart' as _i76;
import 'core/network/retry_interceptor.dart' as _i189;
import 'core/router/app_router.dart' as _i110;
import 'core/storage/hive_service.dart' as _i946;
import 'features/auth/data/datasources/auth_local_datasource.dart' as _i1043;
import 'features/auth/data/datasources/auth_remote_datasource.dart' as _i588;
import 'features/auth/data/datasources/session_warning_storage.dart' as _i1012;
import 'features/auth/data/repositories/auth_repository_impl.dart' as _i111;
import 'features/auth/data/services/session_expiry_checker_impl.dart' as _i363;
import 'features/auth/domain/repositories/auth_repository.dart' as _i1015;
import 'features/auth/domain/services/session_expiry_checker.dart' as _i406;
import 'features/auth/domain/usecases/login_user_usecase.dart' as _i323;
import 'features/auth/domain/usecases/logout_user_usecase.dart' as _i84;
import 'features/auth/domain/usecases/validate_token_usecase.dart' as _i183;
import 'features/auth/presentation/bloc/auth_bloc.dart' as _i363;
import 'features/weather/data/datasources/weather_local_datasource.dart'
    as _i141;
import 'features/weather/data/datasources/weather_remote_datasource.dart'
    as _i739;
import 'features/weather/data/repositories/weather_repository_impl.dart'
    as _i876;
import 'features/weather/domain/repositories/weather_repository.dart' as _i256;
import 'features/weather/domain/usecases/get_current_weather_usecase.dart'
    as _i515;
import 'features/weather/presentation/bloc/weather_bloc.dart' as _i989;

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
    gh.lazySingleton<_i895.Connectivity>(() => coreModule.connectivity);
    gh.lazySingleton<_i189.RetryInterceptor>(() => _i189.RetryInterceptor());
    gh.factory<_i712.LocationProvider>(() => _i157.HardcodedLocationProvider());
    gh.factory<_i141.WeatherLocalDataSource>(
        () => _i141.WeatherLocalDataSource(gh<_i946.HiveService>()));
    gh.singleton<_i887.ConnectivityChecker>(
      () => _i76.ConnectivityService(gh<_i895.Connectivity>()),
      dispose: (i) => i.dispose(),
    );
    gh.lazySingleton<_i1012.SessionWarningStorage>(
        () => _i1012.SessionWarningStorageImpl(gh<_i946.HiveService>()));
    gh.lazySingleton<_i1043.AuthLocalDataSource>(
        () => _i1043.AuthLocalDataSource(hiveService: gh<_i946.HiveService>()));
    gh.lazySingleton<_i871.ApiClient>(
        () => _i871.ApiClient(retryInterceptor: gh<_i189.RetryInterceptor>()));
    gh.lazySingleton<_i588.AuthRemoteDataSource>(
        () => _i588.AuthRemoteDataSource(apiClient: gh<_i871.ApiClient>()));
    gh.lazySingleton<_i406.SessionExpiryChecker>(
        () => _i363.SessionExpiryCheckerImpl(
              gh<_i1043.AuthLocalDataSource>(),
              gh<_i1012.SessionWarningStorage>(),
            ));
    gh.lazySingleton<_i1015.AuthRepository>(() => _i111.AuthRepositoryImpl(
          remoteDataSource: gh<_i588.AuthRemoteDataSource>(),
          localDataSource: gh<_i1043.AuthLocalDataSource>(),
        ));
    gh.factory<_i739.WeatherRemoteDataSource>(
        () => _i739.WeatherRemoteDataSource(gh<_i871.ApiClient>()));
    gh.lazySingleton<_i256.WeatherRepository>(() => _i876.WeatherRepositoryImpl(
          remoteDataSource: gh<_i739.WeatherRemoteDataSource>(),
          localDataSource: gh<_i141.WeatherLocalDataSource>(),
        ));
    gh.factory<_i183.ValidateTokenUseCase>(() => _i183.ValidateTokenUseCase(
          gh<_i1015.AuthRepository>(),
          gh<_i887.ConnectivityChecker>(),
        ));
    gh.factory<_i323.LoginUserUseCase>(() =>
        _i323.LoginUserUseCase(authRepository: gh<_i1015.AuthRepository>()));
    gh.factory<_i84.LogoutUserUseCase>(
        () => _i84.LogoutUserUseCase(gh<_i1015.AuthRepository>()));
    gh.singleton<_i363.AuthBloc>(() => _i363.AuthBloc(
          loginUserUseCase: gh<_i323.LoginUserUseCase>(),
          logoutUserUseCase: gh<_i84.LogoutUserUseCase>(),
          validateTokenUseCase: gh<_i183.ValidateTokenUseCase>(),
          authRepository: gh<_i1015.AuthRepository>(),
        ));
    gh.lazySingleton<_i110.AppRouter>(
        () => _i110.AppRouter(authBloc: gh<_i363.AuthBloc>()));
    gh.factory<_i515.GetCurrentWeatherUseCase>(
        () => _i515.GetCurrentWeatherUseCase(gh<_i256.WeatherRepository>()));
    gh.factory<_i989.WeatherBloc>(() => _i989.WeatherBloc(
          getCurrentWeatherUseCase: gh<_i515.GetCurrentWeatherUseCase>(),
          weatherRepository: gh<_i256.WeatherRepository>(),
          locationProvider: gh<_i712.LocationProvider>(),
        ));
    return this;
  }
}

class _$CoreModule extends _i849.CoreModule {}
