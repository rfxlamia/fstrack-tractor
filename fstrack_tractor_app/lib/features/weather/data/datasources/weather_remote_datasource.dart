import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/weather_model.dart';

/// Remote data source for weather API calls
///
/// Uses existing ApiClient for HTTP requests.
@injectable
class WeatherRemoteDataSource {
  final ApiClient _apiClient;

  WeatherRemoteDataSource(this._apiClient);

  /// Fetch current weather from API
  ///
  /// Throws ServerException on API errors.
  /// Timeout: 5 seconds per AC5 specification.
  Future<WeatherModel> getCurrentWeather({
    required double lat,
    required double lon,
  }) async {
    try {
      final response = await _apiClient.dio.get(
        '/api/v1/weather',
        queryParameters: {
          'lat': lat,
          'lon': lon,
        },
        options: Options(
          sendTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
        ),
      );

      if (response.statusCode == 200) {
        return WeatherModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw ServerException(
          response.data?['message'] ?? 'Gagal memuat data cuaca',
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data?['message'] ?? 'Gagal memuat data cuaca',
      );
    }
  }
}
