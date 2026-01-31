/* eslint-disable @typescript-eslint/no-unsafe-assignment */
/* eslint-disable @typescript-eslint/unbound-method */
import { Test, TestingModule } from '@nestjs/testing';
import { ConfigService } from '@nestjs/config';
import { HttpService } from '@nestjs/axios';
import { of, throwError } from 'rxjs';
import { AxiosError } from 'axios';
import { OpenWeatherMapProvider } from './openweathermap.provider';
import { WeatherServiceUnavailableException } from '../exceptions';

describe('OpenWeatherMapProvider', () => {
  let provider: OpenWeatherMapProvider;
  let httpService: jest.Mocked<HttpService>;

  const mockWeatherResponse = {
    data: {
      main: {
        temp: 28.5,
        humidity: 75,
      },
      weather: [
        {
          description: 'berawan',
          icon: '03d',
        },
      ],
      name: 'Lampung Tengah',
      dt: 1705133400,
    },
    status: 200,
    statusText: 'OK',
    headers: {},
    config: { headers: {} as any },
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        OpenWeatherMapProvider,
        {
          provide: HttpService,
          useValue: {
            get: jest.fn(),
          },
        },
        {
          provide: ConfigService,
          useValue: {
            get: jest.fn((key: string) => {
              const config: Record<string, unknown> = {
                'weather.apiKey': 'test-api-key',
                'weather.timeout': 5000,
              };
              return config[key];
            }),
          },
        },
      ],
    }).compile();

    provider = module.get<OpenWeatherMapProvider>(OpenWeatherMapProvider);
    httpService = module.get(HttpService);

    jest.clearAllMocks();
  });

  describe('getCurrentWeather', () => {
    it('should return WeatherData when API succeeds', async () => {
      jest.spyOn(httpService, 'get').mockReturnValue(of(mockWeatherResponse));

      const result = await provider.getCurrentWeather(-4.8357, 105.0273);

      expect(result).toEqual({
        temperature: 29,
        condition: 'berawan',
        icon: '03d',
        humidity: 75,
        location: 'Lampung Tengah',
        timestamp: expect.stringMatching(
          /2024-01-13T\d{2}:\d{2}:\d{2}\.\d{3}Z/,
        ),
      });

      expect(httpService.get).toHaveBeenCalledWith(
        'https://api.openweathermap.org/data/2.5/weather',

        expect.objectContaining({
          params: expect.objectContaining({
            lat: -4.8357,
            lon: 105.0273,
            appid: 'test-api-key',
            units: 'metric',
            lang: 'id',
          }),
        }),
      );
    });

    it('should transform OpenWeatherMap response correctly', async () => {
      jest.spyOn(httpService, 'get').mockReturnValue(of(mockWeatherResponse));

      const result = await provider.getCurrentWeather(0, 0);

      // Temperature should be rounded
      expect(result.temperature).toBe(29);
      // Condition should be from weather[0].description
      expect(result.condition).toBe('berawan');
      // Timestamp should be converted from Unix timestamp (ISO format)
      expect(result.timestamp).toMatch(
        /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{3}Z$/,
      );
    });

    it('should throw WeatherServiceUnavailableException on timeout', async () => {
      const timeoutError = new AxiosError('Timeout of 5000ms exceeded');
      timeoutError.code = 'ECONNABORTED';
      jest
        .spyOn(httpService, 'get')
        .mockReturnValue(throwError(() => timeoutError));

      await expect(
        provider.getCurrentWeather(-4.8357, 105.0273),
      ).rejects.toThrow(WeatherServiceUnavailableException);
    });

    it('should throw WeatherServiceUnavailableException on 401 (invalid API key)', async () => {
      const unauthorizedError = new AxiosError('Unauthorized');
      unauthorizedError.response = {
        status: 401,
        data: {},
        headers: {},
        statusText: 'Unauthorized',
      } as AxiosError['response'];
      jest
        .spyOn(httpService, 'get')
        .mockReturnValue(throwError(() => unauthorizedError));

      await expect(
        provider.getCurrentWeather(-4.8357, 105.0273),
      ).rejects.toThrow(WeatherServiceUnavailableException);
    });

    it('should throw WeatherServiceUnavailableException on 429 (rate limit)', async () => {
      const rateLimitError = new AxiosError('Too Many Requests');
      rateLimitError.response = {
        status: 429,
        data: {},
        headers: {},
        statusText: 'Too Many Requests',
      } as AxiosError['response'];
      jest
        .spyOn(httpService, 'get')
        .mockReturnValue(throwError(() => rateLimitError));

      await expect(
        provider.getCurrentWeather(-4.8357, 105.0273),
      ).rejects.toThrow(WeatherServiceUnavailableException);
    });

    it('should throw WeatherServiceUnavailableException on network error', async () => {
      const networkError = new AxiosError('Network Error');
      jest
        .spyOn(httpService, 'get')
        .mockReturnValue(throwError(() => networkError));

      await expect(
        provider.getCurrentWeather(-4.8357, 105.0273),
      ).rejects.toThrow(WeatherServiceUnavailableException);
    });

    it('should throw WeatherServiceUnavailableException on 404 (location not found)', async () => {
      const notFoundError = new AxiosError('Not Found');
      notFoundError.response = {
        status: 404,
        data: {},
        headers: {},
        statusText: 'Not Found',
      } as AxiosError['response'];
      jest
        .spyOn(httpService, 'get')
        .mockReturnValue(throwError(() => notFoundError));

      await expect(
        provider.getCurrentWeather(-4.8357, 105.0273),
      ).rejects.toThrow(WeatherServiceUnavailableException);
    });

    it('should throw WeatherServiceUnavailableException on unknown HTTP status', async () => {
      const unknownError = new AxiosError('Internal Server Error');
      unknownError.response = {
        status: 500,
        data: {},
        headers: {},
        statusText: 'Internal Server Error',
      } as AxiosError['response'];
      jest
        .spyOn(httpService, 'get')
        .mockReturnValue(throwError(() => unknownError));

      await expect(
        provider.getCurrentWeather(-4.8357, 105.0273),
      ).rejects.toThrow(WeatherServiceUnavailableException);
    });

    it('should detect timeout via error message when code is not ECONNABORTED', async () => {
      const timeoutError = new AxiosError('timeout of 5000ms exceeded');
      // No code set, but message contains 'timeout'
      jest
        .spyOn(httpService, 'get')
        .mockReturnValue(throwError(() => timeoutError));

      await expect(
        provider.getCurrentWeather(-4.8357, 105.0273),
      ).rejects.toThrow(WeatherServiceUnavailableException);
    });

    it('should use configured API key from config service', async () => {
      // Create a fresh module with the mock
      const testModule: TestingModule = await Test.createTestingModule({
        providers: [
          OpenWeatherMapProvider,
          {
            provide: HttpService,
            useValue: {
              get: jest.fn().mockReturnValue(of(mockWeatherResponse)),
            },
          },
          {
            provide: ConfigService,
            useValue: {
              get: jest.fn((key: string) => {
                const config: Record<string, unknown> = {
                  'weather.apiKey': 'test-api-key',
                  'weather.timeout': 5000,
                };
                return config[key];
              }),
            },
          },
        ],
      }).compile();

      const testProvider = testModule.get<OpenWeatherMapProvider>(
        OpenWeatherMapProvider,
      );
      const testHttpService = testModule.get(HttpService);

      await testProvider.getCurrentWeather(0, 0);

      expect(testHttpService.get).toHaveBeenCalledWith(
        expect.any(String),

        expect.objectContaining({
          params: expect.objectContaining({
            appid: 'test-api-key',
          }),
        }),
      );
    });
  });
});
