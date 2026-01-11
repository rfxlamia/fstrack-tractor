import { HttpException, HttpStatus } from '@nestjs/common';

/**
 * Exception thrown when a user attempts to login to a locked account.
 * Returns HTTP 423 Locked status with remaining lockout time in message.
 */
export class AccountLockedException extends HttpException {
  constructor(remainingMinutes: number) {
    super(
      `Akun terkunci. Silakan coba lagi dalam ${remainingMinutes} menit`,
      HttpStatus.LOCKED,
    );
  }
}
