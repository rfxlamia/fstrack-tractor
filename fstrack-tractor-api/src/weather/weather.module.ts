import { Module } from '@nestjs/common';
import { HttpModule } from '@nestjs/axios';
import { WeatherController } from './weather.controller';
import { WeatherService } from './weather.service';
import { OpenWeatherMapProvider } from './adapters';
import { WEATHER_PROVIDER } from './adapters/weather-provider.interface';

/**
 * Weather module - encapsulates all weather-related components.
 * Configures HttpModule with timeout for external API calls.
 * Uses Symbol-based DI token for swappable provider.
 */
@Module({
  imports: [
    HttpModule.register({
      timeout: 5000,
      maxRedirects: 5,
    }),
  ],
  controllers: [WeatherController],
  providers: [
    {
      provide: WEATHER_PROVIDER,
      useClass: OpenWeatherMapProvider,
    },
    WeatherService,
  ],
  exports: [WeatherService],
})
export class WeatherModule {}
