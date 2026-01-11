import 'dart:io';

import 'package:dio/dio.dart';

import 'exceptions.dart';
import 'failures.dart';

/// Maps Dio errors to domain failures with user-friendly messages in Bahasa Indonesia
class ErrorMapper {
  /// Map DioException to Failure
  static Failure mapDioException(DioException exception) {
    switch (exception.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return NetworkFailure();

      case DioExceptionType.badResponse:
        return _mapHttpStatus(exception.response?.statusCode);

      case DioExceptionType.cancel:
        return ServerFailure('Permintaan dibatalkan');

      case DioExceptionType.badCertificate:
        return ServerFailure('Sertifikat tidak valid');

      case DioExceptionType.connectionError:
        return NetworkFailure();

      case DioExceptionType.unknown:
        // Check for socket errors
        if (exception.error is SocketException) {
          return NetworkFailure();
        }
        return ServerFailure(exception.message ?? 'Terjadi kesalahan');
    }
  }

  /// Map HTTP status code to Failure
  static Failure _mapHttpStatus(int? statusCode) {
    if (statusCode == null) {
      return ServerFailure('Respons tidak valid dari server');
    }

    switch (statusCode) {
      case 400:
        return ServerFailure('Permintaan tidak valid');
      case 401:
        return AuthFailure('Username atau password salah');
      case 403:
        return ServerFailure('Akses ditolak');
      case 404:
        return ServerFailure('Data tidak ditemukan');
      case 422:
        return ServerFailure('Data tidak valid');
      case 423:
        return AuthFailure('Akun terkunci selama 30 menit');
      case 429:
        return AuthFailure('Terlalu banyak percobaan. Tunggu 15 menit.');
      case 500:
        return ServerFailure('Kesalahan server');
      case 502:
        return ServerFailure('Server tidak merespons');
      case 503:
        return ServerFailure('Layanan tidak tersedia');
      default:
        return ServerFailure('Kode kesalahan: $statusCode');
    }
  }

  /// Map exception to Failure
  static Failure mapException(Exception exception) {
    if (exception is DioException) {
      return mapDioException(exception);
    }

    if (exception is ServerException) {
      return ServerFailure(exception.message);
    }

    if (exception is AuthException) {
      return AuthFailure(exception.message);
    }

    if (exception is NetworkException) {
      return NetworkFailure();
    }

    if (exception is CacheException) {
      return CacheFailure(exception.message);
    }

    return ServerFailure(exception.toString());
  }
}
