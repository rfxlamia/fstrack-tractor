import 'dart:io';

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

/// Retry interceptor with exponential backoff
/// Retries up to 3 times on network errors (timeout, connection refused)
/// Does NOT retry on 4xx errors (client errors)
@lazySingleton
class RetryInterceptor extends Interceptor {
  static const int maxRetries = 3;
  static const List<int> _retryDelays = [1, 2, 4]; // seconds

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    // Only retry on network errors
    if (!_shouldRetry(err)) {
      return handler.next(err);
    }

    final requestOptions = err.requestOptions;
    final retryCount = _getRetryCount(requestOptions);

    if (retryCount >= maxRetries) {
      // Max retries reached, pass error through
      return handler.next(err);
    }

    // Exponential backoff delay
    await Future.delayed(Duration(seconds: _retryDelays[retryCount]));

    // Increment retry count
    requestOptions.extra['retry_count'] = retryCount + 1;

    try {
      // Retry the request
      final response = await _retryRequest(requestOptions);
      handler.resolve(response);
    } catch (e) {
      // If retry fails, pass original error
      handler.next(err);
    }
  }

  bool _shouldRetry(DioException error) {
    // Network errors that can be retried
    return error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.error is SocketException ||
        error.error is HttpException;
  }

  int _getRetryCount(RequestOptions options) {
    return options.extra['retry_count'] as int? ?? 0;
  }

  Future<Response> _retryRequest(RequestOptions options) async {
    // Create new Dio with same baseUrl to preserve configuration
    final dio = Dio(
      BaseOptions(
        baseUrl: options.baseUrl,
        connectTimeout: options.connectTimeout,
        receiveTimeout: options.receiveTimeout,
      ),
    );
    return dio.request(
      options.path,
      options: Options(
        method: options.method,
        headers: options.headers,
        contentType: options.contentType,
        responseType: options.responseType,
      ),
      data: options.data,
      queryParameters: options.queryParameters,
    );
  }
}
