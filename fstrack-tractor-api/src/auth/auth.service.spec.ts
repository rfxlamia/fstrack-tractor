/* eslint-disable @typescript-eslint/unbound-method */
import { Test, TestingModule } from '@nestjs/testing';
import { UnauthorizedException, HttpStatus } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { AuthService } from './auth.service';
import { UsersService } from '../users/users.service';
import { User } from '../users/entities/user.entity';
import { UserRole } from '../users/enums/user-role.enum';
import { AccountLockedException } from './exceptions';
import * as bcrypt from 'bcrypt';

jest.mock('bcrypt');

describe('AuthService', () => {
  let authService: AuthService;
  let usersService: jest.Mocked<UsersService>;
  let jwtService: jest.Mocked<JwtService>;

  const mockUser: User = {
    id: '123e4567-e89b-12d3-a456-426614174000',
    username: 'dev_kasie',
    passwordHash: '$2b$10$hashedpassword',
    fullName: 'Dev Kasie User',
    role: UserRole.KASIE,
    estateId: null,
    isFirstTime: true,
    failedLoginAttempts: 0,
    lockedUntil: null,
    lastLogin: null,
    createdAt: new Date(),
    updatedAt: new Date(),
  };

  const mockLockedUser: User = {
    ...mockUser,
    lockedUntil: new Date(Date.now() + 15 * 60 * 1000), // 15 minutes from now
  };

  const mockExpiredLockUser: User = {
    ...mockUser,
    lockedUntil: new Date(Date.now() - 5 * 60 * 1000), // 5 minutes ago (expired)
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        AuthService,
        {
          provide: UsersService,
          useValue: {
            findByUsername: jest.fn(),
            updateLastLogin: jest.fn(),
            incrementFailedAttempts: jest.fn(),
            resetFailedAttempts: jest.fn(),
            lockAccount: jest.fn(),
            clearExpiredLockout: jest.fn(),
          },
        },
        {
          provide: JwtService,
          useValue: {
            sign: jest.fn(),
          },
        },
      ],
    }).compile();

    authService = module.get<AuthService>(AuthService);
    usersService = module.get(UsersService);
    jwtService = module.get(JwtService);

    jest.clearAllMocks();
  });

  describe('validateUser', () => {
    it('should return user when credentials are valid', async () => {
      usersService.findByUsername.mockResolvedValue(mockUser);
      (bcrypt.compare as jest.Mock).mockResolvedValue(true);
      usersService.updateLastLogin.mockResolvedValue();
      usersService.resetFailedAttempts.mockResolvedValue();

      const result = await authService.validateUser(
        'dev_kasie',
        'DevPassword123',
      );

      expect(result).toEqual(mockUser);
      expect(usersService.findByUsername).toHaveBeenCalledWith('dev_kasie');
      expect(bcrypt.compare).toHaveBeenCalledWith(
        'DevPassword123',
        mockUser.passwordHash,
      );
      expect(usersService.resetFailedAttempts).toHaveBeenCalledWith(
        mockUser.id,
      );
      expect(usersService.updateLastLogin).toHaveBeenCalledWith(mockUser.id);
    });

    it('should throw UnauthorizedException when user not found', async () => {
      usersService.findByUsername.mockResolvedValue(null);

      await expect(
        authService.validateUser('nonexistent', 'password'),
      ).rejects.toThrow(
        new UnauthorizedException('Username atau password salah'),
      );

      expect(usersService.findByUsername).toHaveBeenCalledWith('nonexistent');
      expect(bcrypt.compare).not.toHaveBeenCalled();
    });

    it('should throw UnauthorizedException when password is invalid', async () => {
      usersService.findByUsername.mockResolvedValue(mockUser);
      (bcrypt.compare as jest.Mock).mockResolvedValue(false);
      usersService.incrementFailedAttempts.mockResolvedValue(1);

      await expect(
        authService.validateUser('dev_kasie', 'wrongpassword'),
      ).rejects.toThrow(
        new UnauthorizedException('Username atau password salah'),
      );

      expect(usersService.findByUsername).toHaveBeenCalledWith('dev_kasie');
      expect(bcrypt.compare).toHaveBeenCalledWith(
        'wrongpassword',
        mockUser.passwordHash,
      );
      expect(usersService.incrementFailedAttempts).toHaveBeenCalledWith(
        mockUser.id,
      );
      expect(usersService.updateLastLogin).not.toHaveBeenCalled();
      expect(usersService.resetFailedAttempts).not.toHaveBeenCalled();
    });

    it('should throw AccountLockedException when account is locked', async () => {
      usersService.findByUsername.mockResolvedValue(mockLockedUser);

      await expect(
        authService.validateUser('dev_kasie', 'DevPassword123'),
      ).rejects.toThrow(AccountLockedException);

      try {
        await authService.validateUser('dev_kasie', 'DevPassword123');
      } catch (error) {
        expect(error).toBeInstanceOf(AccountLockedException);
        expect((error as AccountLockedException).getStatus()).toBe(
          HttpStatus.LOCKED,
        );
        expect((error as AccountLockedException).message).toMatch(
          /Akun terkunci/,
        );
        expect((error as AccountLockedException).message).toMatch(/menit/);
      }

      // Password should NOT be checked when account is locked
      expect(bcrypt.compare).not.toHaveBeenCalled();
    });

    it('should update last_login on successful validation', async () => {
      usersService.findByUsername.mockResolvedValue(mockUser);
      (bcrypt.compare as jest.Mock).mockResolvedValue(true);
      usersService.updateLastLogin.mockResolvedValue();
      usersService.resetFailedAttempts.mockResolvedValue();

      await authService.validateUser('dev_kasie', 'DevPassword123');

      expect(usersService.updateLastLogin).toHaveBeenCalledWith(mockUser.id);
    });

    it('should not update last_login on failed validation', async () => {
      usersService.findByUsername.mockResolvedValue(mockUser);
      (bcrypt.compare as jest.Mock).mockResolvedValue(false);
      usersService.incrementFailedAttempts.mockResolvedValue(1);

      await expect(
        authService.validateUser('dev_kasie', 'wrongpassword'),
      ).rejects.toThrow();

      expect(usersService.updateLastLogin).not.toHaveBeenCalled();
    });

    it('should call incrementFailedAttempts on invalid password', async () => {
      usersService.findByUsername.mockResolvedValue(mockUser);
      (bcrypt.compare as jest.Mock).mockResolvedValue(false);
      usersService.incrementFailedAttempts.mockResolvedValue(2);

      await expect(
        authService.validateUser('dev_kasie', 'wrongpassword'),
      ).rejects.toThrow();

      expect(usersService.incrementFailedAttempts).toHaveBeenCalledWith(
        mockUser.id,
      );
    });

    it('should call resetFailedAttempts on successful login', async () => {
      usersService.findByUsername.mockResolvedValue(mockUser);
      (bcrypt.compare as jest.Mock).mockResolvedValue(true);
      usersService.resetFailedAttempts.mockResolvedValue();
      usersService.updateLastLogin.mockResolvedValue();

      await authService.validateUser('dev_kasie', 'DevPassword123');

      expect(usersService.resetFailedAttempts).toHaveBeenCalledWith(
        mockUser.id,
      );
    });

    it('should lock account after 10 failed attempts', async () => {
      usersService.findByUsername.mockResolvedValue(mockUser);
      (bcrypt.compare as jest.Mock).mockResolvedValue(false);
      usersService.incrementFailedAttempts.mockResolvedValue(10);
      usersService.lockAccount.mockResolvedValue();

      await expect(
        authService.validateUser('dev_kasie', 'wrongpassword'),
      ).rejects.toThrow(AccountLockedException);

      expect(usersService.incrementFailedAttempts).toHaveBeenCalledWith(
        mockUser.id,
      );
      expect(usersService.lockAccount).toHaveBeenCalledWith(mockUser.id);
    });

    it('should throw AccountLockedException on 10th failed attempt', async () => {
      usersService.findByUsername.mockResolvedValue(mockUser);
      (bcrypt.compare as jest.Mock).mockResolvedValue(false);
      usersService.incrementFailedAttempts.mockResolvedValue(10);
      usersService.lockAccount.mockResolvedValue();

      try {
        await authService.validateUser('dev_kasie', 'wrongpassword');
        fail('Should have thrown AccountLockedException');
      } catch (error) {
        expect(error).toBeInstanceOf(AccountLockedException);
        expect((error as AccountLockedException).getStatus()).toBe(
          HttpStatus.LOCKED,
        );
      }
    });

    it('should clear expired lockout on next login attempt', async () => {
      usersService.findByUsername.mockResolvedValue(mockExpiredLockUser);
      (bcrypt.compare as jest.Mock).mockResolvedValue(true);
      usersService.clearExpiredLockout.mockResolvedValue();
      usersService.resetFailedAttempts.mockResolvedValue();
      usersService.updateLastLogin.mockResolvedValue();

      const result = await authService.validateUser(
        'dev_kasie',
        'DevPassword123',
      );

      expect(result).toEqual(mockExpiredLockUser);
      expect(usersService.clearExpiredLockout).toHaveBeenCalledWith(
        mockUser.id,
      );
    });

    it('should not check password when lock has just expired but not cleared yet', async () => {
      // User with expired lock attempts login - lock should be cleared first
      usersService.findByUsername.mockResolvedValue(mockExpiredLockUser);
      (bcrypt.compare as jest.Mock).mockResolvedValue(false);
      usersService.clearExpiredLockout.mockResolvedValue();
      usersService.incrementFailedAttempts.mockResolvedValue(1);

      await expect(
        authService.validateUser('dev_kasie', 'wrongpassword'),
      ).rejects.toThrow();

      // Clear expired lockout should be called
      expect(usersService.clearExpiredLockout).toHaveBeenCalledWith(
        mockUser.id,
      );
      // Then increment should be called
      expect(usersService.incrementFailedAttempts).toHaveBeenCalledWith(
        mockUser.id,
      );
    });
  });

  describe('login', () => {
    it('should return access token and user data', () => {
      const mockToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.test';
      jwtService.sign.mockReturnValue(mockToken);

      const result = authService.login(mockUser);

      expect(result).toEqual({
        accessToken: mockToken,
        user: {
          id: mockUser.id,
          fullName: mockUser.fullName,
          role: mockUser.role,
          estateId: mockUser.estateId,
          isFirstTime: mockUser.isFirstTime,
        },
      });
    });

    it('should generate JWT with correct payload structure', () => {
      jwtService.sign.mockReturnValue('token');

      authService.login(mockUser);

      expect(jwtService.sign).toHaveBeenCalledWith({
        sub: mockUser.id,
        username: mockUser.username,
        role: mockUser.role,
        estateId: mockUser.estateId,
      });
    });

    it('should include estateId in payload when user has one', () => {
      const userWithEstate = { ...mockUser, estateId: 'estate-123' };
      jwtService.sign.mockReturnValue('token');

      authService.login(userWithEstate);

      expect(jwtService.sign).toHaveBeenCalledWith({
        sub: userWithEstate.id,
        username: userWithEstate.username,
        role: userWithEstate.role,
        estateId: 'estate-123',
      });
    });
  });
});
