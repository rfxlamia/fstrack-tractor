import 'package:equatable/equatable.dart';

import '../../domain/entities/user_entity.dart';

/// Auth states - sealed class pattern following Clean Architecture
sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state - no authentication action taken
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Loading state - authentication operation in progress
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// Success state - user successfully authenticated
class AuthSuccess extends AuthState {
  final UserEntity user;

  const AuthSuccess({required this.user});

  @override
  List<Object?> get props => [user];
}

/// Error state - authentication failed
class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Reason for logout/unauthenticated state
enum LogoutReason { userRequest, sessionExpired }

/// State when user is not authenticated (initial or after logout)
class AuthUnauthenticated extends AuthState {
  final LogoutReason reason;

  const AuthUnauthenticated({this.reason = LogoutReason.userRequest});

  @override
  List<Object?> get props => [reason];
}
