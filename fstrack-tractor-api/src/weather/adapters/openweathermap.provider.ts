import { Injectable, Logger, HttpStatus } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { HttpService } from '@nestjs/axios';
import { AxiosError } from 'axios';
import { firstValueFrom } from 'rxjs';
import {
  type WeatherProviderInterface,
  WeatherData,
} from './weather-provider.interface';
import { WeatherServiceUnavailableException } from '../exceptions';

/**
 * OpenWeatherMap API response structure.
 * Used for type-safe response transformation.
 */
interface OpenWeatherMapResponse {
  main: {
    temp: number;
    humidity: number;
  };
  weather: Array<{
    description: string;
    icon: string;
  }>;
  name: string;
  dt: number;
}

/**
 * OpenWeatherMap provider implementation.
 * Implements WeatherProviderInterface for swappable weather data sources.
 * Handles API calls with proper error handling and response transformation.
 */
@Injectable()
export class OpenWeatherMapProvider implements WeatherProviderInterface {
  private readonly logger = new Logger(OpenWeatherMapProvider.name);
  private readonly apiKey: string;
  private readonly timeout: number;
  private readonly apiUrl = 'https://api.openweathermap.org/data/2.5/weather';

  constructor(
    private readonly httpService: HttpService,
    private readonly configService: ConfigService,
  ) {
    this.apiKey = this.configService.get<string>('weather.apiKey', '');
    this.timeout = this.configService.get<number>('weather.timeout', 5000);
  }

  /**
   * Get current weather from OpenWeatherMap API.
   * @param lat Latitude coordinate
   * @param lon Longitude coordinate
   * @returns Promise resolving to WeatherData
   * @throws WeatherServiceUnavailableException on API errors
   */
  async getCurrentWeather(lat: number, lon: number): Promise<WeatherData> {
    this.logger.debug(`Fetching weather for lat=${lat}, lon=${lon}`);

    try {
      const response = await firstValueFrom(
        this.httpService.get(this.apiUrl, {
          params: {
            lat,
            lon,
            appid: this.apiKey,
            units: 'metric',
            lang: 'id',
          },
          timeout: this.timeout,
        }),
      );

      // Transform OpenWeatherMap response to WeatherData interface
      const weatherData = this.transformResponse(
        response.data as OpenWeatherMapResponse,
      );
      this.logger.debug(
        `Weather data received: ${weatherData.condition} at ${weatherData.location}`,
      );
      return weatherData;
    } catch (error) {
      return this.handleError(error, lat, lon);
    }
  }

  /**
   * Transform OpenWeatherMap API response to WeatherData interface.
   * @param responseData Raw API response data
   * @returns Transformed WeatherData
   */
  private transformResponse(responseData: OpenWeatherMapResponse): WeatherData {
    return {
      temperature: Math.round(responseData.main.temp),
      condition: responseData.weather[0]?.description ?? 'Unknown',
      icon: responseData.weather[0]?.icon ?? '01d',
      humidity: responseData.main.humidity,
      location: responseData.name,
      timestamp: new Date(responseData.dt * 1000).toISOString(),
    };
  }

  /**
   * Handle errors from HTTP requests.
   * Maps various error types to appropriate messages.
   * @param error The error caught from HTTP request
   * @param lat Latitude of request
   * @param lon Longitude of request
   * @returns Never returns, always throws
   */
  private handleError(error: unknown, lat: number, lon: number): never {
    const errorContext = { lat, lon, errorType: this.getErrorType(error) };

    if (this.isTimeoutError(error)) {
      this.logger.error('Weather API request timed out', errorContext);
      throw new WeatherServiceUnavailableException(
        'Layanan cuaca tidak tersedia',
      );
    }

    if (this.isAxiosError(error)) {
      const status = error.response?.status;

      switch (status) {
        case HttpStatus.UNAUTHORIZED:
          this.logger.error(
            'Weather API unauthorized - invalid API key',
            errorContext,
          );
          throw new WeatherServiceUnavailableException(
            'Layanan cuaca tidak tersedia',
          );
        case HttpStatus.TOO_MANY_REQUESTS:
          this.logger.error('Weather API rate limited', errorContext);
          throw new WeatherServiceUnavailableException(
            'Layanan cuaca sibuk, coba lagi nanti',
          );
        case HttpStatus.NOT_FOUND:
          this.logger.error('Weather API location not found', errorContext);
          throw new WeatherServiceUnavailableException(
            'Layanan cuaca tidak tersedia',
          );
        default:
          this.logger.error(`Weather API error: ${status}`, errorContext);
          throw new WeatherServiceUnavailableException(
            'Layanan cuaca tidak tersedia',
          );
      }
    }

    // Network error
    this.logger.error('Weather API network error', errorContext);
    throw new WeatherServiceUnavailableException(
      'Koneksi ke layanan cuaca gagal',
    );
  }

  /**
   * Check if error is an axios timeout error.
   * @param error The error to check
   * @returns True if timeout error
   */
  private isTimeoutError(error: unknown): boolean {
    if (error instanceof AxiosError) {
      return (
        error.code === 'ECONNABORTED' || error.message?.includes('timeout')
      );
    }
    return false;
  }

  /**
   * Check if error is an axios error with response.
   * @param error The error to check
   * @returns True if axios error with response
   */
  private isAxiosError(error: unknown): error is AxiosError {
    return error instanceof AxiosError && error.response !== undefined;
  }

  /**
   * Get error type string for logging.
   * @param error The error to classify
   * @returns Error type string
   */
  private getErrorType(error: unknown): string {
    if (this.isTimeoutError(error)) return 'TIMEOUT';
    if (this.isAxiosError(error)) {
      const status = error.response?.status;
      if (status === 401) return 'UNAUTHORIZED';
      if (status === 429) return 'RATE_LIMIT';
      if (status === 404) return 'NOT_FOUND';
      return `HTTP_${status}`;
    }
    return 'NETWORK_ERROR';
  }
}
