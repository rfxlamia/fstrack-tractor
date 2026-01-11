import { Controller, Post, Body, HttpCode, HttpStatus } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBody } from '@nestjs/swagger';
import { AuthService } from './auth.service';
import { LoginDto, AuthResponseDto } from './dto';

@ApiTags('auth')
@Controller('v1/auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Post('login')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'User login',
    description: 'Autentikasi user dengan username dan password',
  })
  @ApiBody({ type: LoginDto })
  @ApiResponse({
    status: 200,
    description: 'Login berhasil',
    type: AuthResponseDto,
  })
  @ApiResponse({
    status: 400,
    description: 'Username dan password harus diisi',
  })
  @ApiResponse({
    status: 401,
    description: 'Username atau password salah',
  })
  @ApiResponse({
    status: 423,
    description: 'Akun terkunci. Silakan coba lagi dalam X menit',
  })
  async login(@Body() loginDto: LoginDto): Promise<AuthResponseDto> {
    const user = await this.authService.validateUser(
      loginDto.username,
      loginDto.password,
    );
    return this.authService.login(user);
  }
}
