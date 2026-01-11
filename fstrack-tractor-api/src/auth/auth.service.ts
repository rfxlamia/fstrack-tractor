import {
  Injectable,
  UnauthorizedException,
  HttpException,
  HttpStatus,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { UsersService } from '../users/users.service';
import { User } from '../users/entities/user.entity';
import * as bcrypt from 'bcrypt';
import { AuthResponseDto } from './dto';

@Injectable()
export class AuthService {
  constructor(
    private readonly usersService: UsersService,
    private readonly jwtService: JwtService,
  ) {}

  async validateUser(username: string, password: string): Promise<User> {
    // Step 1: Find user by username
    const user = await this.usersService.findByUsername(username);
    if (!user) {
      throw new UnauthorizedException('Username atau password salah');
    }

    // Step 2: Check lockout BEFORE password validation (prevent timing attacks)
    if (user.lockedUntil && user.lockedUntil > new Date()) {
      const remainingMs = user.lockedUntil.getTime() - Date.now();
      const remainingMinutes = Math.ceil(remainingMs / 60000);
      throw new HttpException(
        `Akun terkunci. Silakan coba lagi dalam ${remainingMinutes} menit`,
        HttpStatus.LOCKED, // 423
      );
    }

    // Step 3: Validate password using bcrypt.compare (timing-safe)
    const isPasswordValid = await bcrypt.compare(password, user.passwordHash);
    if (!isPasswordValid) {
      // NOTE: Do NOT increment failed_login_attempts here - that's Story 2.2 scope
      throw new UnauthorizedException('Username atau password salah');
    }

    // Step 4: Update last_login timestamp
    await this.usersService.updateLastLogin(user.id);

    return user;
  }

  login(user: User): AuthResponseDto {
    const payload = {
      sub: user.id,
      username: user.username,
      role: user.role,
      estateId: user.estateId,
    };

    return {
      accessToken: this.jwtService.sign(payload),
      user: {
        id: user.id,
        fullName: user.fullName,
        role: user.role,
        estateId: user.estateId,
        isFirstTime: user.isFirstTime,
      },
    };
  }
}
