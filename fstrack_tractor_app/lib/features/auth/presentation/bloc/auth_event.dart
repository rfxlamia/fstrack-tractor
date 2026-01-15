import 'package:equatable/equatable.dart';

/// Auth events - sealed class pattern following Clean Architecture
sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Event to request user login
class LoginRequested extends AuthEvent {
  final String username;
  final String password;
  final bool rememberMe;

  const LoginRequested({
    required this.username,
    required this.password,
    this.rememberMe = false,
  });

  @override
  List<Object?> get props => [username, password, rememberMe];
}

/// Event to request user logout
class LogoutRequested extends AuthEvent {
  const LogoutRequested();

  @override
  List<Object?> get props => [];
}

/// Event to check current authentication status
class CheckAuthStatus extends AuthEvent {
  const CheckAuthStatus();

  @override
  List<Object?> get props => [];
}

/// Event to clear error state
class ClearError extends AuthEvent {
  const ClearError();

  @override
  List<Object?> get props => [];
}

/// Event when session expiry check runs
class SessionExpiryChecked extends AuthEvent {
  const SessionExpiryChecked();
}

/// Event when session warning banner is dismissed
class SessionWarningDismissed extends AuthEvent {
  const SessionWarningDismissed();
}
