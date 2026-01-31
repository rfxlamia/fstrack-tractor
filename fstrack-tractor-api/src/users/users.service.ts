import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { User } from './entities/user.entity';

@Injectable()
export class UsersService {
  constructor(
    @InjectRepository(User)
    private readonly userRepository: Repository<User>,
  ) {}

  /**
   * Finds a user by their username.
   * @param username - The username to search for
   * @returns The User entity if found, null otherwise
   */
  async findByUsername(username: string): Promise<User | null> {
    return this.userRepository.findOne({ where: { username } });
  }

  /**
   * Finds a user by their ID.
   * @param id - The user's ID (integer)
   * @returns The User entity if found, null otherwise
   */
  async findById(id: number): Promise<User | null> {
    return this.userRepository.findOne({ where: { id } });
  }

  /**
   * Updates the user's first-time login flag.
   * @param id - The user's ID (integer)
   * @param isFirstTime - Whether this is the user's first login
   */
  async updateFirstTime(id: number, isFirstTime: boolean): Promise<void> {
    await this.userRepository.update(id, { isFirstTime });
  }

  /**
   * Updates the user's last login timestamp to current time.
   * @param id - The user's ID (integer)
   */
  async updateLastLogin(id: number): Promise<void> {
    await this.userRepository.update(id, { lastLogin: new Date() });
  }

  /**
   * Increments failed_login_attempts atomically.
   * Returns the new count for lockout threshold check.
   * @param userId - The user's ID (integer)
   * @returns The new failed login attempts count
   */
  async incrementFailedAttempts(userId: number): Promise<number> {
    await this.userRepository
      .createQueryBuilder()
      .update(User)
      .set({ failedLoginAttempts: () => 'failed_login_attempts + 1' })
      .where('id = :id', { id: userId })
      .execute();

    const user = await this.userRepository.findOne({ where: { id: userId } });
    return user?.failedLoginAttempts ?? 0;
  }

  /**
   * Resets failed attempts and clears any lock.
   * Called on successful login.
   * @param userId - The user's ID (integer)
   */
  async resetFailedAttempts(userId: number): Promise<void> {
    await this.userRepository.update(userId, {
      failedLoginAttempts: 0,
      lockedUntil: null,
    });
  }

  /**
   * Locks account for 30 minutes.
   * Called when failed_login_attempts reaches 10.
   * @param userId - The user's ID (integer)
   */
  async lockAccount(userId: number): Promise<void> {
    const lockUntil = new Date();
    lockUntil.setMinutes(lockUntil.getMinutes() + 30);

    await this.userRepository.update(userId, {
      lockedUntil: lockUntil,
    });
  }

  /**
   * Clears expired lockout.
   * Called when user attempts login after lock expired.
   * @param userId - The user's ID (integer)
   */
  async clearExpiredLockout(userId: number): Promise<void> {
    await this.userRepository.update(userId, {
      failedLoginAttempts: 0,
      lockedUntil: null,
    });
  }
}
