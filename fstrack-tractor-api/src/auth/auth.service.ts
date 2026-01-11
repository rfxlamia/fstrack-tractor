import { Injectable, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { UsersService } from '../users/users.service';
import { User } from '../users/entities/user.entity';
import { AccountLockedException } from './exceptions';
import * as bcrypt from 'bcrypt';
import { AuthResponseDto } from './dto';

@Injectable()
export class AuthService {
  constructor(
    private readonly usersService: UsersService,
    private readonly jwtService: JwtService,
  ) {}

  /**
   * Validates user credentials and returns the user if valid.
   * Checks lockout status BEFORE password validation to prevent timing attacks.
   * @param username - The username to validate
   * @param password - The plain text password to validate
   * @returns The validated User entity
   * @throws UnauthorizedException if credentials are invalid
   * @throws AccountLockedException if account is locked (HTTP 423)
   */
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
      throw new AccountLockedException(remainingMinutes);
    }

    // Step 2a: Clear expired lockout if lock period just passed
    if (user.lockedUntil && user.lockedUntil <= new Date()) {
      await this.usersService.clearExpiredLockout(user.id);
    }

    // Step 3: Validate password using bcrypt.compare (timing-safe)
    const isPasswordValid = await bcrypt.compare(password, user.passwordHash);
    if (!isPasswordValid) {
      // Increment failed attempts
      const newCount = await this.usersService.incrementFailedAttempts(user.id);

      // Lock if threshold reached (10 failures)
      if (newCount >= 10) {
        await this.usersService.lockAccount(user.id);
        throw new AccountLockedException(30);
      }

      throw new UnauthorizedException('Username atau password salah');
    }

    // Step 4: Success: reset attempts and update last login
    await this.usersService.resetFailedAttempts(user.id);
    await this.usersService.updateLastLogin(user.id);

    return user;
  }

  /**
   * Generates JWT access token and returns auth response with user data.
   * JWT payload contains: sub (userId), username, role, estateId.
   * Token expires in 14 days as per NFR11.
   * @param user - The validated User entity
   * @returns AuthResponseDto containing accessToken and user info
   */
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
