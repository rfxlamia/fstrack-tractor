/* eslint-disable @typescript-eslint/no-unsafe-assignment, @typescript-eslint/no-unsafe-call, @typescript-eslint/no-unsafe-member-access */
import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication, ValidationPipe } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import request from 'supertest';
import { App } from 'supertest/types';
import { WeatherModule } from '../src/weather/weather.module';
import { WEATHER_PROVIDER } from '../src/weather/adapters';
import { WeatherData } from '../src/weather/adapters/weather-provider.interface';
import { HttpStatus } from '@nestjs/common';
import { HttpModule } from '@nestjs/axios';
import configuration from '../src/config/configuration';

describe('WeatherController (e2e)', () => {
  let app: INestApplication<App>;

  const mockWeatherData: WeatherData = {
    temperature: 28,
    condition: 'berawan',
    icon: '03d',
    humidity: 75,
    location: 'Lampung Tengah',
    timestamp: '2026-01-13T10:30:00.000Z',
  };

  beforeEach(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [
        ConfigModule.forRoot({
          isGlobal: true,
          load: [configuration],
          envFilePath: ['.env.development', '.env'],
        }),
        WeatherModule,
        HttpModule.register({
          timeout: 5000,
          maxRedirects: 5,
        }),
      ],
      providers: [
        {
          provide: WEATHER_PROVIDER,
          useValue: {
            getCurrentWeather: jest.fn(),
          },
        },
      ],
    })
      .overrideProvider(WEATHER_PROVIDER)
      .useValue({
        getCurrentWeather: jest.fn(),
      })
      .compile();

    app = moduleFixture.createNestApplication();
    app.setGlobalPrefix('api');
    app.useGlobalPipes(
      new ValidationPipe({
        whitelist: true,
        forbidNonWhitelisted: true,
        transform: true,
      }),
    );
    await app.init();
  });

  afterEach(async () => {
    await app.close();
  });

  describe('GET /api/v1/weather', () => {
    it('should return 200 with valid weather data', () => {
      const weatherProvider = app.get(WEATHER_PROVIDER);
      weatherProvider.getCurrentWeather.mockResolvedValue(mockWeatherData);

      return request(app.getHttpServer())
        .get('/api/v1/weather')
        .expect(HttpStatus.OK)
        .expect((res) => {
          expect(res.body).toEqual(mockWeatherData);
        });
    });

    it('should use custom coordinates when provided', () => {
      const weatherProvider = app.get(WEATHER_PROVIDER);
      weatherProvider.getCurrentWeather.mockResolvedValue({
        ...mockWeatherData,
        location: 'Jakarta',
      });

      return request(app.getHttpServer())
        .get('/api/v1/weather?lat=-6.2&lon=106.8')
        .expect(HttpStatus.OK)
        .expect((res) => {
          expect(res.body.location).toBe('Jakarta');
          expect(weatherProvider.getCurrentWeather).toHaveBeenCalledWith(
            -6.2,
            106.8,
          );
        });
    });

    it('should return 503 when provider fails', () => {
      const weatherProvider = app.get(WEATHER_PROVIDER);
      weatherProvider.getCurrentWeather.mockRejectedValue(
        new Error('API Error'),
      );

      return request(app.getHttpServer())
        .get('/api/v1/weather')
        .expect(HttpStatus.SERVICE_UNAVAILABLE)
        .expect((res) => {
          expect(res.body.message).toBe('Layanan cuaca tidak tersedia');
        });
    });

    it('should return response matching WeatherResponseDto schema', () => {
      const weatherProvider = app.get(WEATHER_PROVIDER);
      weatherProvider.getCurrentWeather.mockResolvedValue(mockWeatherData);

      return request(app.getHttpServer())
        .get('/api/v1/weather')
        .expect(HttpStatus.OK)
        .expect((res) => {
          const body = res.body as WeatherData;
          expect(body).toHaveProperty('temperature');
          expect(typeof body.temperature).toBe('number');
          expect(body).toHaveProperty('condition');
          expect(typeof body.condition).toBe('string');
          expect(body).toHaveProperty('icon');
          expect(typeof body.icon).toBe('string');
          expect(body).toHaveProperty('humidity');
          expect(typeof body.humidity).toBe('number');
          expect(body).toHaveProperty('location');
          expect(typeof body.location).toBe('string');
          expect(body).toHaveProperty('timestamp');
          expect(typeof body.timestamp).toBe('string');
        });
    });

    it('should accept only lat parameter', () => {
      const weatherProvider = app.get(WEATHER_PROVIDER);
      weatherProvider.getCurrentWeather.mockResolvedValue(mockWeatherData);

      return request(app.getHttpServer())
        .get('/api/v1/weather?lat=-4.8357')
        .expect(HttpStatus.OK)
        .expect((res) => {
          expect(res.body).toEqual(mockWeatherData);
        });
    });

    it('should accept only lon parameter', () => {
      const weatherProvider = app.get(WEATHER_PROVIDER);
      weatherProvider.getCurrentWeather.mockResolvedValue(mockWeatherData);

      return request(app.getHttpServer())
        .get('/api/v1/weather?lon=105.0273')
        .expect(HttpStatus.OK)
        .expect((res) => {
          expect(res.body).toEqual(mockWeatherData);
        });
    });

    it('should not require authentication', () => {
      const weatherProvider = app.get(WEATHER_PROVIDER);
      weatherProvider.getCurrentWeather.mockResolvedValue(mockWeatherData);

      // No authorization header provided
      return request(app.getHttpServer())
        .get('/api/v1/weather')
        .expect(HttpStatus.OK);
    });
  });
});
