import { ApiProperty } from '@nestjs/swagger';
import { IsInt, IsNotEmpty, Min } from 'class-validator';

/**
 * DTO for assigning an operator to a schedule
 *
 * CRITICAL: operator_id is INTEGER (not UUID or string)
 * - Production schema: operators.id is INTEGER auto-increment
 * - schedules.operator_id FK references operators.id (INTEGER)
 * - Using UUID or string will cause FK constraint violation
 */
export class AssignOperatorDto {
  @ApiProperty({
    description: 'ID operator yang akan ditugaskan (INTEGER)',
    example: 1,
    type: Number,
  })
  @IsInt({ message: 'ID operator harus berupa angka bulat' })
  @Min(1, { message: 'ID operator minimal 1' })
  @IsNotEmpty({ message: 'ID operator wajib diisi' })
  operatorId: number;
}
