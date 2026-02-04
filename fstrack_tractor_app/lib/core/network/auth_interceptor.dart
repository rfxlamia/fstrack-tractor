import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../features/auth/data/datasources/auth_local_datasource.dart';

/// Auth interceptor that injects JWT Bearer token to API requests
/// Skips auth endpoints (/login, /refresh) that don't require authentication
/// Handles storage errors gracefully without blocking requests
@lazySingleton
class AuthInterceptor extends Interceptor {
  /// Auth endpoints that should NOT receive Authorization header
  /// Uses exact path matching (NOT contains) to prevent excluding
  /// authenticated endpoints like /api/v1/auth/me
  static const _authEndpointsWithoutAuth = [
    '/api/v1/auth/login',
    '/api/v1/auth/refresh',
  ];

  final AuthLocalDataSource _authLocalDataSource;

  AuthInterceptor(this._authLocalDataSource);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    try {
      // Skip auth endpoints that don't require authentication
      if (_authEndpointsWithoutAuth.contains(options.path)) {
        return handler.next(options);
      }

      // Get token and inject Authorization header
      final token = _authLocalDataSource.getAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
        debugPrint('🔐 AuthInterceptor: Added Bearer token to ${options.path}');
      } else {
        debugPrint('⚠️  AuthInterceptor: No token available for ${options.path}');
      }
    } catch (e) {
      // Log error but don't block request
      // Storage errors shouldn't prevent API calls
      debugPrint('❌ AuthInterceptor error: $e');
    }

    handler.next(options);
  }
}
