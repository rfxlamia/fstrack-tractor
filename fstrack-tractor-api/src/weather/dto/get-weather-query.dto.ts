import { IsOptional, IsNumber } from 'class-validator';
import { Transform } from 'class-transformer';
import { ApiPropertyOptional } from '@nestjs/swagger';

/**
 * Query DTO for weather endpoint.
 * Supports optional latitude and longitude parameters.
 */
export class GetWeatherQueryDto {
  @ApiPropertyOptional({ example: -4.8357, description: 'Latitude coordinate' })
  @IsOptional()
  @IsNumber()
  @Transform(({ value }: { value: string }) => parseFloat(value))
  lat?: number;

  @ApiPropertyOptional({
    example: 105.0273,
    description: 'Longitude coordinate',
  })
  @IsOptional()
  @IsNumber()
  @Transform(({ value }: { value: string }) => parseFloat(value))
  lon?: number;
}
