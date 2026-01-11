import { ThrottlerException } from '@nestjs/throttler';
import { LoginThrottlerGuard } from './login-throttler.guard';

describe('LoginThrottlerGuard', () => {
  let guard: LoginThrottlerGuard;

  beforeEach(() => {
    // Create guard without full NestJS DI using Object.create
    guard = Object.create(LoginThrottlerGuard.prototype) as LoginThrottlerGuard;
  });

  describe('getTracker', () => {
    it('should return login:username when username is provided', async () => {
      const req: Record<string, unknown> = {
        body: { username: 'testuser' },
      };

      const result = await guard['getTracker'](req);

      expect(result).toBe('login:testuser');
    });

    it('should return login:username when username has special characters', async () => {
      const req: Record<string, unknown> = {
        body: { username: 'user.name+test' },
      };

      const result = await guard['getTracker'](req);

      expect(result).toBe('login:user.name+test');
    });

    it('should return anonymous when username is missing', async () => {
      const req: Record<string, unknown> = {
        body: {},
      };

      const result = await guard['getTracker'](req);

      expect(result).toBe('anonymous');
    });

    it('should return anonymous when body is missing', async () => {
      const req: Record<string, unknown> = {};

      const result = await guard['getTracker'](req);

      expect(result).toBe('anonymous');
    });

    it('should return anonymous when body is null', async () => {
      const req: Record<string, unknown> = {
        body: null,
      };

      const result = await guard['getTracker'](req);

      expect(result).toBe('anonymous');
    });
  });

  describe('throwThrottlingException', () => {
    it('should throw ThrottlerException with Indonesian message', () => {
      expect(() => {
        void guard['throwThrottlingException']();
      }).toThrow(ThrottlerException);

      try {
        void guard['throwThrottlingException']();
      } catch (error) {
        expect((error as ThrottlerException).message).toBe(
          'Terlalu banyak percobaan. Tunggu 15 menit.',
        );
      }
    });

    it('should throw ThrottlerException with correct status code', () => {
      try {
        void guard['throwThrottlingException']();
      } catch (error) {
        expect(error).toBeInstanceOf(ThrottlerException);
        expect((error as ThrottlerException).getStatus()).toBe(429);
      }
    });
  });
});
