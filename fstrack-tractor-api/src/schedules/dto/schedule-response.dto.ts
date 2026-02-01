import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Expose, Type } from 'class-transformer';

/**
 * Schedule Response DTO
 * Serializes schedule data for API responses
 *
 * All fields exposed with @Expose() for consistent serialization
 * Uses camelCase for API fields (database uses snake_case)
 */
export class ScheduleResponseDto {
  @ApiProperty({
    description: 'ID unik schedule (UUID)',
    example: 'a1b2c3d4-e5f6-7890-abcd-ef1234567890',
  })
  @Expose()
  id: string;

  @ApiProperty({
    description: 'Tanggal kerja',
    example: '2026-01-30',
    format: 'date',
  })
  @Expose()
  workDate: Date;

  @ApiProperty({
    description: 'Pola kerja',
    example: 'Rotasi',
  })
  @Expose()
  pattern: string;

  @ApiPropertyOptional({
    description: 'Shift kerja',
    example: 'Pagi',
    nullable: true,
  })
  @Expose()
  shift: string | null;

  @ApiPropertyOptional({
    description: 'ID lokasi (VARCHAR)',
    example: 'LOC001',
    nullable: true,
  })
  @Expose()
  locationId: string | null;

  @ApiPropertyOptional({
    description: 'ID unit (VARCHAR)',
    example: 'UNIT01',
    nullable: true,
  })
  @Expose()
  unitId: string | null;

  @ApiPropertyOptional({
    description: 'ID operator (INTEGER)',
    example: 123,
    type: 'integer',
    nullable: true,
  })
  @Expose()
  operatorId: number | null;

  @ApiProperty({
    description: 'Status schedule',
    example: 'OPEN',
    enum: ['OPEN', 'CLOSED', 'CANCEL'],
  })
  @Expose()
  status: string;

  @ApiPropertyOptional({
    description: 'Waktu mulai kerja',
    example: '2026-01-30T08:00:00.000Z',
    format: 'date-time',
    nullable: true,
  })
  @Expose()
  startTime: Date | null;

  @ApiPropertyOptional({
    description: 'Waktu selesai kerja',
    example: '2026-01-30T17:00:00.000Z',
    format: 'date-time',
    nullable: true,
  })
  @Expose()
  endTime: Date | null;

  @ApiPropertyOptional({
    description: 'Catatan tambahan',
    example: 'Perhatikan kondisi jalan',
    nullable: true,
  })
  @Expose()
  notes: string | null;

  @ApiPropertyOptional({
    description: 'ID laporan (UUID)',
    example: 'b2c3d4e5-f6g7-8901-bcde-f23456789012',
    nullable: true,
  })
  @Expose()
  reportId: string | null;

  @ApiProperty({
    description: 'Waktu pembuatan',
    example: '2026-01-30T08:30:00.000Z',
    format: 'date-time',
  })
  @Expose()
  createdAt: Date;

  @ApiProperty({
    description: 'Waktu terakhir diupdate',
    example: '2026-01-30T08:30:00.000Z',
    format: 'date-time',
  })
  @Expose()
  updatedAt: Date;
}

/**
 * Paginated Schedules Response DTO
 * For list endpoints with pagination
 */
export class PaginatedSchedulesResponseDto {
  @ApiProperty({
    description: 'List schedules',
    type: [ScheduleResponseDto],
  })
  @Expose()
  @Type(() => ScheduleResponseDto)
  data: ScheduleResponseDto[];

  @ApiProperty({
    description: 'Total jumlah records',
    example: 100,
  })
  @Expose()
  total: number;

  @ApiProperty({
    description: 'Halaman saat ini',
    example: 1,
  })
  @Expose()
  page: number;

  @ApiProperty({
    description: 'Jumlah item per halaman',
    example: 10,
  })
  @Expose()
  limit: number;

  @ApiProperty({
    description: 'Total halaman',
    example: 10,
  })
  @Expose()
  totalPages: number;
}
