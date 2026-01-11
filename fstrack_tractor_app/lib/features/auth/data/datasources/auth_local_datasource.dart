import 'package:injectable/injectable.dart';

import '../../../../core/storage/hive_service.dart';
import '../models/user_model.dart';

/// Local data source for authentication using Hive encrypted box
/// Keys: 'accessToken', 'refreshToken', 'userJson'
@lazySingleton
class AuthLocalDataSource {
  static const String _accessTokenKey = 'accessToken';
  static const String _refreshTokenKey = 'refreshToken';
  static const String _userJsonKey = 'userJson';

  final HiveService _hiveService;

  AuthLocalDataSource({required HiveService hiveService})
      : _hiveService = hiveService;

  /// Save auth data to encrypted Hive box
  Future<void> saveAuthData({
    required String accessToken,
    required String refreshToken,
    required UserModel user,
  }) async {
    final authBox = _hiveService.authBox;

    await authBox.put(_accessTokenKey, accessToken);
    await authBox.put(_refreshTokenKey, refreshToken);
    await authBox.put(_userJsonKey, user.toJson());
  }

  /// Get stored access token
  String? getAccessToken() {
    return _hiveService.authBox.get(_accessTokenKey) as String?;
  }

  /// Get stored refresh token
  String? getRefreshToken() {
    return _hiveService.authBox.get(_refreshTokenKey) as String?;
  }

  /// Get stored user data
  UserModel? getUser() {
    final userJson = _hiveService.authBox.get(_userJsonKey) as Map?;
    if (userJson == null) {
      return null;
    }
    return UserModel.fromJson(Map<String, dynamic>.from(userJson));
  }

  /// Check if user is authenticated (has valid tokens)
  bool isAuthenticated() {
    final accessToken = getAccessToken();
    final user = getUser();
    return accessToken != null && user != null;
  }

  /// Clear all auth data
  Future<void> clearAuthData() async {
    final authBox = _hiveService.authBox;
    await authBox.delete(_accessTokenKey);
    await authBox.delete(_refreshTokenKey);
    await authBox.delete(_userJsonKey);
  }
}
