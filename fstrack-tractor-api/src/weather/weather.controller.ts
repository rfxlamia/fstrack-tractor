import { Controller, Get, Query, HttpCode, HttpStatus } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiQuery, ApiResponse } from '@nestjs/swagger';
import { WeatherService } from './weather.service';
import { WeatherResponseDto } from './dto';
import { GetWeatherQueryDto } from './dto';

/**
 * Weather controller - API layer.
 * Handles HTTP requests for weather endpoint.
 * NO AUTHENTICATION required (graceful fallback for offline support).
 */
@ApiTags('weather')
@Controller('v1/weather')
export class WeatherController {
  constructor(private readonly weatherService: WeatherService) {}

  /**
   * GET /api/v1/weather - Get current weather.
   * Optional query params for custom coordinates.
   * @param query Optional latitude and longitude
   * @returns WeatherResponseDto with current weather data
   */
  @Get()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Get current weather',
    description: 'Mendapatkan data cuaca saat ini',
  })
  @ApiQuery({
    name: 'lat',
    required: false,
    type: Number,
    example: -4.8357,
    description: 'Latitude coordinate',
  })
  @ApiQuery({
    name: 'lon',
    required: false,
    type: Number,
    example: 105.0273,
    description: 'Longitude coordinate',
  })
  @ApiResponse({
    status: 200,
    description: 'Data cuaca berhasil didapatkan',
    type: WeatherResponseDto,
  })
  @ApiResponse({
    status: 503,
    description: 'Layanan cuaca tidak tersedia',
  })
  async getWeather(
    @Query() query: GetWeatherQueryDto,
  ): Promise<WeatherResponseDto> {
    const weatherData = await this.weatherService.getCurrentWeather(
      query.lat,
      query.lon,
    );
    return weatherData;
  }
}
