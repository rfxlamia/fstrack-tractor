import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Expose } from 'class-transformer';

/**
 * Operator Response DTO
 * Serializes operator data for API responses
 *
 * Field mapping:
 * - id: operator.id (INTEGER)
 * - operatorName: operator.user.fullName (from JOIN with users table)
 * - unitId: operator.unit_id (VARCHAR(16), nullable)
 *
 * All fields exposed with @Expose() for consistent serialization
 * Uses camelCase for API fields (database uses snake_case)
 */
export class OperatorResponseDto {
  @ApiProperty({
    description: 'ID operator (INTEGER auto-increment)',
    example: 1,
    type: 'integer',
  })
  @Expose()
  id: number;

  @ApiProperty({
    description: 'Nama operator (dari users.fullname)',
    example: 'Budi Santoso',
  })
  @Expose()
  operatorName: string;

  @ApiPropertyOptional({
    description: 'ID unit (VARCHAR)',
    example: 'UNIT01',
    nullable: true,
  })
  @Expose()
  unitId: string | null;
}
