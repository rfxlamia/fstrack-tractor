import { IsNotEmpty, IsString } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class LoginDto {
  @ApiProperty({ example: 'dev_kasie', description: 'Username pengguna' })
  @IsString({ message: 'Username harus berupa string' })
  @IsNotEmpty({ message: 'Username harus diisi' })
  username: string;

  @ApiProperty({ example: 'DevPassword123', description: 'Password pengguna' })
  @IsString({ message: 'Password harus berupa string' })
  @IsNotEmpty({ message: 'Password harus diisi' })
  password: string;
}
