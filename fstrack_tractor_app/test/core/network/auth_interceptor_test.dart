import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fstrack_tractor/core/network/auth_interceptor.dart';
import 'package:fstrack_tractor/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthLocalDataSource extends Mock implements AuthLocalDataSource {}

void main() {
  late AuthInterceptor interceptor;
  late MockAuthLocalDataSource mockAuthLocalDataSource;

  setUp(() {
    mockAuthLocalDataSource = MockAuthLocalDataSource();
    interceptor = AuthInterceptor(mockAuthLocalDataSource);
  });

  group('AuthInterceptor', () {
    test('adds Authorization header when token exists', () {
      // Arrange
      const testToken = 'test_jwt_token_12345';
      when(() => mockAuthLocalDataSource.getAccessToken()).thenReturn(testToken);
      final options = RequestOptions(path: '/api/v1/schedules');
      final handler = _TestHandler();

      // Act
      interceptor.onRequest(options, handler);

      // Assert
      expect(options.headers['Authorization'], equals('Bearer $testToken'));
      expect(handler.nextCalled, isTrue);
    });

    test('skips Authorization header when token is null', () {
      // Arrange
      when(() => mockAuthLocalDataSource.getAccessToken()).thenReturn(null);
      final options = RequestOptions(path: '/api/v1/schedules');
      final handler = _TestHandler();

      // Act
      interceptor.onRequest(options, handler);

      // Assert
      expect(options.headers.containsKey('Authorization'), isFalse);
      expect(handler.nextCalled, isTrue);
    });

    test('skips Authorization header when token is empty', () {
      // Arrange
      when(() => mockAuthLocalDataSource.getAccessToken()).thenReturn('');
      final options = RequestOptions(path: '/api/v1/schedules');
      final handler = _TestHandler();

      // Act
      interceptor.onRequest(options, handler);

      // Assert
      expect(options.headers.containsKey('Authorization'), isFalse);
      expect(handler.nextCalled, isTrue);
    });

    test('skips auth header for /api/v1/auth/login endpoint', () {
      // Arrange
      final options = RequestOptions(path: '/api/v1/auth/login');
      final handler = _TestHandler();

      // Act
      interceptor.onRequest(options, handler);

      // Assert
      expect(options.headers.containsKey('Authorization'), isFalse);
      expect(handler.nextCalled, isTrue);
      // Token should not be fetched for whitelisted endpoints
      verifyNever(() => mockAuthLocalDataSource.getAccessToken());
    });

    test('skips auth header for /api/v1/auth/refresh endpoint', () {
      // Arrange
      final options = RequestOptions(path: '/api/v1/auth/refresh');
      final handler = _TestHandler();

      // Act
      interceptor.onRequest(options, handler);

      // Assert
      expect(options.headers.containsKey('Authorization'), isFalse);
      expect(handler.nextCalled, isTrue);
      verifyNever(() => mockAuthLocalDataSource.getAccessToken());
    });

    test('ADDS auth header for /api/v1/auth/me endpoint (requires auth)', () {
      // Arrange
      const testToken = 'test_token_for_me_endpoint';
      when(() => mockAuthLocalDataSource.getAccessToken()).thenReturn(testToken);
      final options = RequestOptions(path: '/api/v1/auth/me');
      final handler = _TestHandler();

      // Act
      interceptor.onRequest(options, handler);

      // Assert
      expect(
        options.headers['Authorization'],
        equals('Bearer $testToken'),
        reason: '/api/v1/auth/me requires authentication for token validation',
      );
      expect(handler.nextCalled, isTrue);
    });

    test('handles storage exceptions gracefully without crashing', () {
      // Arrange
      when(() => mockAuthLocalDataSource.getAccessToken())
          .thenThrow(Exception('Hive storage error'));
      final options = RequestOptions(path: '/api/v1/schedules');
      final handler = _TestHandler();

      // Act & Assert - should not throw
      expect(
        () => interceptor.onRequest(options, handler),
        returnsNormally,
      );
      expect(options.headers.containsKey('Authorization'), isFalse);
      expect(handler.nextCalled, isTrue);
    });

    test('adds auth header for work plan endpoints', () {
      // Arrange
      const testToken = 'work_plan_token';
      when(() => mockAuthLocalDataSource.getAccessToken()).thenReturn(testToken);
      final options = RequestOptions(path: '/api/v1/schedules');
      final handler = _TestHandler();

      // Act
      interceptor.onRequest(options, handler);

      // Assert
      expect(options.headers['Authorization'], equals('Bearer $testToken'));
      expect(handler.nextCalled, isTrue);
    });

    test('adds auth header for weather endpoints', () {
      // Arrange
      const testToken = 'weather_token';
      when(() => mockAuthLocalDataSource.getAccessToken()).thenReturn(testToken);
      final options = RequestOptions(path: '/api/v1/weather');
      final handler = _TestHandler();

      // Act
      interceptor.onRequest(options, handler);

      // Assert
      expect(options.headers['Authorization'], equals('Bearer $testToken'));
      expect(handler.nextCalled, isTrue);
    });

    test('preserves existing headers when adding Authorization', () {
      // Arrange
      const testToken = 'test_token';
      when(() => mockAuthLocalDataSource.getAccessToken()).thenReturn(testToken);
      final options = RequestOptions(
        path: '/api/v1/schedules',
        headers: {
          'Content-Type': 'application/json',
          'Custom-Header': 'custom-value',
        },
      );
      final handler = _TestHandler();

      // Act
      interceptor.onRequest(options, handler);

      // Assert
      expect(options.headers['Authorization'], equals('Bearer $testToken'));
      expect(options.headers['Content-Type'], equals('application/json'));
      expect(options.headers['Custom-Header'], equals('custom-value'));
      expect(handler.nextCalled, isTrue);
    });
  });
}

/// Simple test handler to verify interceptor calls handler.next()
class _TestHandler extends RequestInterceptorHandler {
  bool nextCalled = false;

  @override
  void next(RequestOptions requestOptions) {
    nextCalled = true;
  }
}
