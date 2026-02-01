import { ApiProperty } from '@nestjs/swagger';

export class UserResponseDto {
  @ApiProperty({ example: 43 })
  id: number;

  @ApiProperty({ example: 'Dev Kasie User' })
  fullname: string;

  @ApiProperty({ example: 'KASIE_PG' })
  roleId: string | null;

  @ApiProperty({
    example: 'PG001',
    nullable: true,
  })
  plantationGroupId: string | null;

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
