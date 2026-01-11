import { ApiProperty } from '@nestjs/swagger';

export class UserResponseDto {
  @ApiProperty({ example: 'a1b2c3d4-e5f6-7890-abcd-ef1234567890' })
  id: string;

  @ApiProperty({ example: 'Dev Kasie User' })
  fullName: string;

  @ApiProperty({ example: 'KASIE' })
  role: string;

  @ApiProperty({
    example: 'a1b2c3d4-e5f6-7890-abcd-ef1234567890',
    nullable: true,
  })
  estateId: string | null;

  @ApiProperty({ example: true })
  isFirstTime: boolean;
}

export class AuthResponseDto {
  @ApiProperty({
    example: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
    description: 'JWT access token',
  })
  accessToken: string;

  @ApiProperty({ type: UserResponseDto, description: 'Data user yang login' })
  user: UserResponseDto;
}
