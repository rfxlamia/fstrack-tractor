import {
  Injectable,
  ExecutionContext,
  UnauthorizedException,
} from '@nestjs/common';
import { ThrottlerGuard, ThrottlerException } from '@nestjs/throttler';

/**
 * Custom throttler guard for login endpoint.
 * Tracks by username instead of IP to prevent shared IP blocking.
 */
@Injectable()
export class LoginThrottlerGuard extends ThrottlerGuard {
  /**
   * Override to use username instead of IP for tracking.
   * This prevents shared IP blocking (corporate networks, VPNs).
   */
  protected async getTracker(req: Record<string, any>): Promise<string> {
    const body = req.body as { username?: string };
    if (!body?.username) {
      return 'anonymous';
    }
    return `login:${body.username}`;
  }

  /**
   * Override to return Bahasa Indonesia error message.
   */
  protected async throwThrottlingException(
    context: ExecutionContext,
  ): Promise<void> {
    throw new ThrottlerException('Terlalu banyak percobaan. Tunggu 15 menit.');
  }
}
