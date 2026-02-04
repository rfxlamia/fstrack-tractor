import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import 'auth_interceptor.dart';
import 'retry_interceptor.dart';

/// Dio API client singleton with auth and retry interceptors
/// Base URL configured via --dart-define=API_BASE_URL
@lazySingleton
class ApiClient {
  late final Dio _dio;

  Dio get dio => _dio;

  ApiClient({
    required AuthInterceptor authInterceptor,
    required RetryInterceptor retryInterceptor,
  }) {
    _dio = Dio(
      BaseOptions(
        baseUrl: _getBaseUrl(),
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        contentType: 'application/json',
        responseType: ResponseType.json,
        headers: {
          // Bypass ngrok free tier warning page
          'ngrok-skip-browser-warning': 'true',
          // Custom user-agent as backup
          'User-Agent': 'FsTrack-Mobile-App/1.0',
        },
      ),
    );

    // Add interceptors in order: auth first, then retry
    // Auth must run before retry to ensure retried requests have token
    _dio.interceptors.add(authInterceptor);
    _dio.interceptors.add(retryInterceptor);
  }

  String _getBaseUrl() {
    // Check for environment variable first (set via --dart-define)
    const apiBaseUrl = String.fromEnvironment('API_BASE_URL');
    if (apiBaseUrl.isNotEmpty) {
      return apiBaseUrl;
    }

    // Default to localhost for development
    return 'http://localhost:3000';
  }
}
