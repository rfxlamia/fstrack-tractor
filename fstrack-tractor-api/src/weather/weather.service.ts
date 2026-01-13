import { Inject, Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import {
  WEATHER_PROVIDER,
  type WeatherProviderInterface,
  WeatherData,
} from './adapters';
import { WeatherServiceUnavailableException } from './exceptions';

/**
 * Weather service - business logic layer.
 * Coordinates between controller and weather provider.
 * Handles default location fallback and error transformation.
 */
@Injectable()
export class WeatherService {
  private readonly logger = new Logger(WeatherService.name);
  private readonly defaultLocation: {
    latitude: number;
    longitude: number;
    name: string;
  };

  constructor(
    @Inject(WEATHER_PROVIDER)
    private readonly weatherProvider: WeatherProviderInterface,
    private readonly configService: ConfigService,
  ) {
    const defaultLocationConfig = this.configService.get<{
      latitude: number;
      longitude: number;
      name: string;
    }>('weather.defaultLocation');

    this.defaultLocation = defaultLocationConfig || {
      latitude: -4.8357,
      longitude: 105.0273,
      name: 'Lampung Tengah',
    };

    this.logger.debug(
      `Weather service initialized with default location: ${this.defaultLocation.name}`,
    );
  }

  /**
   * Get current weather for given coordinates or default location.
   * @param lat Optional latitude coordinate
   * @param lon Optional longitude coordinate
   * @returns Promise resolving to WeatherData
   * @throws WeatherServiceUnavailableException on provider errors
   */
  async getCurrentWeather(lat?: number, lon?: number): Promise<WeatherData> {
    const latitude = lat ?? this.defaultLocation.latitude;
    const longitude = lon ?? this.defaultLocation.longitude;

    this.logger.debug(`Getting weather for lat=${latitude}, lon=${longitude}`);

    try {
      const weatherData = await this.weatherProvider.getCurrentWeather(
        latitude,
        longitude,
      );
      return weatherData;
    } catch (error) {
      this.logger.error(`Failed to get weather: ${error}`);
      throw new WeatherServiceUnavailableException(
        'Layanan cuaca tidak tersedia',
      );
    }
  }
}
