import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/usecases/login_user_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// Auth Bloc - manages authentication state for the entire app
/// Singleton pattern - single instance app-wide
@singleton
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUserUseCase _loginUserUseCase;

  AuthBloc({required LoginUserUseCase loginUserUseCase})
      : _loginUserUseCase = loginUserUseCase,
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
    // TODO: Implement check auth status (Story 2.4)
    // For now, emit unauthenticated
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
