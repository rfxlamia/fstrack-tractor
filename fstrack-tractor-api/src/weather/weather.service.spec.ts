/* eslint-disable @typescript-eslint/unbound-method */
import { Test, TestingModule } from '@nestjs/testing';
import { ConfigService } from '@nestjs/config';
import { WeatherService } from './weather.service';
import { WEATHER_PROVIDER, WeatherProviderInterface } from './adapters';
import { WeatherServiceUnavailableException } from './exceptions';

describe('WeatherService', () => {
  let service: WeatherService;
  let weatherProvider: jest.Mocked<WeatherProviderInterface>;

  const mockWeatherData = {
    temperature: 28,
    condition: 'berawan',
    icon: '03d',
    humidity: 75,
    location: 'Lampung Tengah',
    timestamp: '2026-01-13T10:30:00.000Z',
  };

  const mockDefaultLocation = {
    latitude: -4.8357,
    longitude: 105.0273,
    name: 'Lampung Tengah',
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        WeatherService,
        {
          provide: WEATHER_PROVIDER,
          useValue: {
            getCurrentWeather: jest.fn(),
          },
        },
        {
          provide: ConfigService,
          useValue: {
            get: jest.fn((key: string) => {
              const config: Record<string, unknown> = {
                'weather.defaultLocation': mockDefaultLocation,
              };
              return config[key];
            }),
          },
        },
      ],
    }).compile();

    service = module.get<WeatherService>(WeatherService);
    weatherProvider = module.get(WEATHER_PROVIDER);

    jest.clearAllMocks();
  });

  describe('getCurrentWeather', () => {
    it('should return weather data when provider succeeds', async () => {
      weatherProvider.getCurrentWeather.mockResolvedValue(mockWeatherData);

      const result = await service.getCurrentWeather();

      expect(result).toEqual(mockWeatherData);
      expect(weatherProvider.getCurrentWeather).toHaveBeenCalledWith(
        mockDefaultLocation.latitude,
        mockDefaultLocation.longitude,
      );
    });

    it('should use default location when lat/lon not provided', async () => {
      weatherProvider.getCurrentWeather.mockResolvedValue(mockWeatherData);

      await service.getCurrentWeather();

      expect(weatherProvider.getCurrentWeather).toHaveBeenCalledWith(
        -4.8357,
        105.0273,
      );
    });

    it('should use custom lat/lon when provided', async () => {
      weatherProvider.getCurrentWeather.mockResolvedValue(mockWeatherData);

      await service.getCurrentWeather(-6.2, 106.8);

      expect(weatherProvider.getCurrentWeather).toHaveBeenCalledWith(
        -6.2,
        106.8,
      );
    });

    it('should throw WeatherServiceUnavailableException on provider error', async () => {
      weatherProvider.getCurrentWeather.mockRejectedValue(
        new Error('API Error'),
      );

      await expect(service.getCurrentWeather()).rejects.toThrow(
        WeatherServiceUnavailableException,
      );
    });

    it('should pass correct coordinates to provider', async () => {
      weatherProvider.getCurrentWeather.mockResolvedValue(mockWeatherData);

      await service.getCurrentWeather(-5.0, 120.0);

      expect(weatherProvider.getCurrentWeather).toHaveBeenCalledWith(
        -5.0,
        120.0,
      );
    });

    it('should handle provider returning partial custom location name', async () => {
      const customLocationData = { ...mockWeatherData, location: 'Jakarta' };
      weatherProvider.getCurrentWeather.mockResolvedValue(customLocationData);

      const result = await service.getCurrentWeather(-6.2, 106.8);

      expect(result.location).toBe('Jakarta');
    });

    it('should use default location when only lat is provided', async () => {
      weatherProvider.getCurrentWeather.mockResolvedValue(mockWeatherData);

      await service.getCurrentWeather(-4.8357, undefined);

      expect(weatherProvider.getCurrentWeather).toHaveBeenCalledWith(
        -4.8357,
        105.0273,
      );
    });

    it('should use default location when only lon is provided', async () => {
      weatherProvider.getCurrentWeather.mockResolvedValue(mockWeatherData);

      await service.getCurrentWeather(undefined, 105.0273);

      expect(weatherProvider.getCurrentWeather).toHaveBeenCalledWith(
        -4.8357,
        105.0273,
      );
    });

    it('should handle null/undefined default location config gracefully', async () => {
      const moduleWithNullConfig: TestingModule =
        await Test.createTestingModule({
          providers: [
            WeatherService,
            {
              provide: WEATHER_PROVIDER,
              useValue: {
                getCurrentWeather: jest.fn().mockResolvedValue(mockWeatherData),
              },
            },
            {
              provide: ConfigService,
              useValue: {
                get: jest.fn(() => null),
              },
            },
          ],
        }).compile();

      const serviceWithNullConfig =
        moduleWithNullConfig.get<WeatherService>(WeatherService);
      // eslint-disable-next-line @typescript-eslint/no-unsafe-assignment
      const providerWithNullConfig = moduleWithNullConfig.get(WEATHER_PROVIDER);

      const result = await serviceWithNullConfig.getCurrentWeather();

      expect(result).toEqual(mockWeatherData);
      // eslint-disable-next-line @typescript-eslint/no-unsafe-member-access
      expect(providerWithNullConfig.getCurrentWeather).toHaveBeenCalledWith(
        -4.8357, // Fallback values
        105.0273,
      );
    });
  });
});
