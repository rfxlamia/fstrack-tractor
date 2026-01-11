import 'user_model.dart';

/// Login result containing user and tokens from API
class LoginResult {
  final UserModel user;
  final String accessToken;
  final String? refreshToken;

  const LoginResult({
    required this.user,
    required this.accessToken,
    this.refreshToken,
  });

  factory LoginResult.fromJson(Map<String, dynamic> json) {
    return LoginResult(
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String?,
    );
  }
}
