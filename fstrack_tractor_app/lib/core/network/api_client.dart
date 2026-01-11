import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import 'retry_interceptor.dart';

/// Dio API client singleton with retry interceptor
/// Base URL configured via --dart-define=API_BASE_URL
@lazySingleton
class ApiClient {
  late final Dio _dio;

  Dio get dio => _dio;

  ApiClient({required RetryInterceptor retryInterceptor}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: _getBaseUrl(),
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        contentType: 'application/json',
        responseType: ResponseType.json,
      ),
    );

    // Add retry interceptor
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
