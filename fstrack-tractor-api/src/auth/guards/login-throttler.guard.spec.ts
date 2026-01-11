import { ExecutionContext } from '@nestjs/common';
import { Test, TestingModule } from '@nestjs/testing';
import { ThrottlerGuard, ThrottlerException } from '@nestjs/throttler';
import { LoginThrottlerGuard } from './login-throttler.guard';

// Mock the ThrottlerGuard to avoid storage issues
jest.mock('@nestjs/throttler', () => {
  const actual = jest.requireActual('@nestjs/throttler');
  return {
    ...actual,
    ThrottlerException: actual.ThrottlerException,
    ThrottlerGuard: class extends actual.ThrottlerGuard {
      constructor(options: any, storage: any, reflector: any) {
        // Mock parent constructor to avoid storage issues
        super(options, storage, reflector);
      }
    },
  };
});

describe('LoginThrottlerGuard', () => {
  let guard: LoginThrottlerGuard;

  beforeEach(() => {
    // Create guard without full NestJS DI
    guard = Object.create(LoginThrottlerGuard.prototype);
    // Initialize with mock values
    (guard as any).options = { throttlers: [{ name: 'login', ttl: 900000, limit: 5 }] };
  });

  describe('getTracker', () => {
    it('should return login:username when username is provided', async () => {
      const req = {
        body: { username: 'testuser' },
      } as Record<string, any>;

      const result = await (guard as any).getTracker(req);

      expect(result).toBe('login:testuser');
    });

    it('should return login:username when username has special characters', async () => {
      const req = {
        body: { username: 'user.name+test' },
      } as Record<string, any>;

      const result = await (guard as any).getTracker(req);

      expect(result).toBe('login:user.name+test');
    });

    it('should return anonymous when username is missing', async () => {
      const req = {
        body: {},
      } as Record<string, any>;

      const result = await (guard as any).getTracker(req);

      expect(result).toBe('anonymous');
    });

    it('should return anonymous when body is missing', async () => {
      const req = {} as Record<string, any>;

      const result = await (guard as any).getTracker(req);

      expect(result).toBe('anonymous');
    });

    it('should return anonymous when body is null', async () => {
      const req = {
        body: null,
      } as Record<string, any>;

      const result = await (guard as any).getTracker(req);

      expect(result).toBe('anonymous');
    });
  });

  describe('throwThrottlingException', () => {
    it('should throw ThrottlerException with Indonesian message', async () => {
      const context = {} as ExecutionContext;

      try {
        await (guard as any).throwThrottlingException(context);
        fail('Should have thrown an exception');
      } catch (error) {
        expect(error).toBeInstanceOf(ThrottlerException);
        expect((error as ThrottlerException).message).toBe(
          'Terlalu banyak percobaan. Tunggu 15 menit.',
        );
      }
    });

    it('should throw ThrottlerException with correct status code', async () => {
      const context = {} as ExecutionContext;

      try {
        await (guard as any).throwThrottlingException(context);
        fail('Should have thrown an exception');
      } catch (error) {
        expect(error).toBeInstanceOf(ThrottlerException);
        expect((error as ThrottlerException).getStatus()).toBe(429);
      }
    });
  });
});
