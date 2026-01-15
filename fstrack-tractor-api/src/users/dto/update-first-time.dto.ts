import { ApiProperty } from '@nestjs/swagger';
import { IsBoolean } from 'class-validator';

export class UpdateFirstTimeDto {
  @ApiProperty({
    example: false,
    description: 'Set to false after onboarding complete',
  })
  @IsBoolean()
  isFirstTime: boolean;
}
