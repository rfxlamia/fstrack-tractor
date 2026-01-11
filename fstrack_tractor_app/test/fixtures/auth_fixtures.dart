import 'package:fstrack_tractor/features/auth/data/models/login_result.dart';
import 'package:fstrack_tractor/features/auth/data/models/user_model.dart';
import 'package:fstrack_tractor/features/auth/domain/entities/user_entity.dart';

/// Test fixtures for Auth-related data
class AuthFixtures {
  static const String validAccessToken =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJ1c2VyLTEyMyIsImlhdCI6MTcwNDg0NDgwMH0.test';
  static const String validRefreshToken = 'refresh-token-123';

  static LoginResult successfulLoginResult() => LoginResult(
        user: UserModel(
          id: 'user-123',
          fullName: 'Pak Suswanto',
          role: UserRole.kasie,
          estateId: 'estate-001',
          isFirstTime: false,
        ),
        accessToken: validAccessToken,
        refreshToken: validRefreshToken,
      );

  static Map<String, dynamic> loginSuccessJson() => {
        'accessToken': validAccessToken,
        'refreshToken': validRefreshToken,
        'user': {
          'id': 'user-123',
          'fullName': 'Pak Suswanto',
          'role': 'KASIE',
          'estateId': 'estate-001',
          'isFirstTime': false,
        },
      };

  static Map<String, dynamic> unauthorizedErrorJson() => {
        'statusCode': 401,
        'message': 'Username atau password salah',
        'error': 'Unauthorized',
      };

  static Map<String, dynamic> lockedAccountErrorJson() => {
        'statusCode': 423,
        'message': 'Akun terkunci selama 30 menit',
        'error': 'Locked',
      };

  static Map<String, dynamic> rateLimitErrorJson() => {
        'statusCode': 429,
        'message': 'Terlalu banyak percobaan. Tunggu 15 menit.',
        'error': 'Too Many Requests',
      };
}
