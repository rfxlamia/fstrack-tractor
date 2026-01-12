import 'package:injectable/injectable.dart';

import 'package:fstrack_tractor/features/auth/domain/repositories/auth_repository.dart';

/// UseCase to logout user and clear all auth data
@injectable
class LogoutUserUseCase {
  final AuthRepository _authRepository;

  LogoutUserUseCase(this._authRepository);

  /// Execute logout - clears all stored auth data
  Future<void> call() async {
    await _authRepository.logout();
  }
}
