import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login_user_usecase.dart';
import '../../domain/usecases/validate_token_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// Auth Bloc - manages authentication state for the entire app
/// Singleton pattern - single instance app-wide
@singleton
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUserUseCase _loginUserUseCase;
  final ValidateTokenUseCase _validateTokenUseCase;
  final AuthRepository _authRepository;

  AuthBloc({
    required LoginUserUseCase loginUserUseCase,
    required ValidateTokenUseCase validateTokenUseCase,
    required AuthRepository authRepository,
  })  : _loginUserUseCase = loginUserUseCase,
        _validateTokenUseCase = validateTokenUseCase,
        _authRepository = authRepository,
        super(const AuthInitial()) {
    _registerEventHandlers();
  }

  void _registerEventHandlers() {
    on<LoginRequested>(_handleLoginRequested);
    on<LogoutRequested>(_handleLogoutRequested);
    on<CheckAuthStatus>(_handleCheckAuthStatus);
    on<ClearError>(_handleClearError);
  }

  Future<void> _handleLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await _loginUserUseCase(
      username: event.username,
      password: event.password,
      rememberMe: event.rememberMe,
    );

    result.fold(
      (failure) {
        emit(AuthError(message: failure.message));
      },
      (user) {
        emit(AuthSuccess(user: user));
      },
    );
  }

  Future<void> _handleLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    // TODO: Implement logout use case (Story 2.5)
    // For now, just emit unauthenticated state
    emit(const AuthUnauthenticated());
  }

  Future<void> _handleCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    final isValid = await _validateTokenUseCase();
    if (isValid) {
      final user = await _authRepository.getCurrentUser();
      if (user != null) {
        emit(AuthSuccess(user: user));
        return;
      }
    }
    emit(const AuthUnauthenticated());
  }

  void _handleClearError(ClearError event, Emitter<AuthState> emit) {
    // Return to appropriate state based on current state
    final currentState = state;
    if (currentState is AuthError) {
      // Go back to unauthenticated if we were in error state
      emit(const AuthUnauthenticated());
    }
  }
}
