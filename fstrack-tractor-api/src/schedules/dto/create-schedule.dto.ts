import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsNotEmpty,
  IsString,
  IsDateString,
  IsOptional,
  IsInt,
  MaxLength,
} from 'class-validator';

/**
 * Create Schedule DTO
 * Validates request body for POST /api/v1/schedules
 *
 * IMPORTANT Type Rules:
 * - operatorId: INTEGER (not UUID)
 * - locationId: VARCHAR (not UUID)
 * - unitId: VARCHAR (not UUID)
 */
export class CreateScheduleDto {
  @ApiProperty({
    description: 'Tanggal kerja (format YYYY-MM-DD)',
    example: '2026-01-30',
    format: 'date',
    required: true,
  })
  @IsNotEmpty({ message: 'Tanggal kerja wajib diisi' })
  @IsDateString({}, { message: 'Format tanggal tidak valid' })
  workDate: string;

  @ApiProperty({
    description: 'Pola kerja (maksimal 16 karakter)',
    example: 'Rotasi',
    maxLength: 16,
    required: true,
  })
  @IsNotEmpty({ message: 'Pola kerja wajib diisi' })
  @IsString({ message: 'Pola kerja harus berupa teks' })
  @MaxLength(16, { message: 'Pola kerja maksimal 16 karakter' })
  pattern: string;

  @ApiPropertyOptional({
    description: 'Shift kerja: Pagi/Malam (maksimal 16 karakter)',
    example: 'Pagi',
    maxLength: 16,
    required: false,
  })
  @IsOptional()
  @IsString({ message: 'Shift harus berupa teks' })
  @MaxLength(16, { message: 'Shift maksimal 16 karakter' })
  shift?: string;

  @ApiPropertyOptional({
    description: 'ID lokasi - VARCHAR(32), bukan UUID (contoh: LOC001)',
    example: 'LOC001',
    maxLength: 32,
    required: false,
  })
  @IsOptional()
  @IsString({ message: 'ID lokasi harus berupa teks' })
  @MaxLength(32, { message: 'ID lokasi maksimal 32 karakter' })
  locationId?: string;

  @ApiPropertyOptional({
    description: 'ID unit - VARCHAR(16), bukan UUID (contoh: UNIT01)',
    example: 'UNIT01',
    maxLength: 16,
    required: false,
  })
  @IsOptional()
  @IsString({ message: 'ID unit harus berupa teks' })
  @MaxLength(16, { message: 'ID unit maksimal 16 karakter' })
  unitId?: string;

  @ApiPropertyOptional({
    description:
      'ID operator - INTEGER (bukan UUID), mengacu ke operators.id auto-increment',
    example: 123,
    type: 'integer',
    required: false,
  })
  @IsOptional()
  @IsInt({ message: 'ID operator harus berupa angka' })
  operatorId?: number;

  @ApiPropertyOptional({
    description: 'Catatan tambahan (opsional)',
    example: 'Perhatikan kondisi jalan',
    required: false,
  })
  @IsOptional()
  @IsString({ message: 'Catatan harus berupa teks' })
  notes?: string;
}
