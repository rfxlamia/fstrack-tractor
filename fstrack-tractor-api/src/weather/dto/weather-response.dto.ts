import { ApiProperty } from '@nestjs/swagger';

/**
 * Response DTO for weather endpoint.
 * Includes Swagger documentation for API consumers.
 */
export class WeatherResponseDto {
  @ApiProperty({ example: 28, description: 'Temperature dalam Celsius' })
  temperature: number;

  @ApiProperty({ example: 'berawan', description: 'Kondisi cuaca' })
  condition: string;

  @ApiProperty({ example: '03d', description: 'Icon code untuk display' })
  icon: string;

  @ApiProperty({ example: 75, description: 'Humidity percentage' })
  humidity: number;

  @ApiProperty({ example: 'Lampung Tengah', description: 'Nama lokasi' })
  location: string;

  @ApiProperty({
    example: '2026-01-13T10:30:00.000Z',
    description: 'Timestamp ISO 8601',
  })
  timestamp: string;
}
