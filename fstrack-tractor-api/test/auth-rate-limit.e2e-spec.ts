/* eslint-disable @typescript-eslint/no-unsafe-member-access */
/* eslint-disable @typescript-eslint/no-unsafe-assignment */
/* eslint-disable @typescript-eslint/no-unsafe-argument */
import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication, ValidationPipe } from '@nestjs/common';
import request from 'supertest';
import { App } from 'supertest/types';
import { AppModule } from './../src/app.module';
import { DataSource } from 'typeorm';
import * as bcrypt from 'bcrypt';

describe('Auth Rate Limiting and Lockout (e2e)', () => {
  let app: INestApplication<App>;
  let dataSource: DataSource;

  // Create unique users for each test to avoid rate limit accumulation
  const getUniqueUser = (prefix: string) => {
    const uniqueId =
      `${Date.now()}${Math.random().toString(36).substring(2, 8)}`.substring(
        0,
        12,
      );
    return {
      id: `00000000-0000-0000-0000-${uniqueId}`,
      username: `test_user_${prefix}`,
      password: `${prefix}Password123`,
      fullName: `Test User ${prefix}`,
      role: 'KASIE' as const,
      estateId: null,
      isFirstTime: true,
    };
  };

  beforeAll(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = moduleFixture.createNestApplication();
    app.setGlobalPrefix('api');
    app.useGlobalPipes(
      new ValidationPipe({
        whitelist: true,
        forbidNonWhitelisted: true,
        transform: true,
      }),
    );
    await app.init();

    dataSource = moduleFixture.get<DataSource>(DataSource);
  });

  afterAll(async () => {
    await app.close();
  });

  beforeEach(async () => {
    // Clean up any test users from previous runs
    await dataSource.query(
      "DELETE FROM users WHERE username LIKE 'test_user_%'",
    );
  });

  describe('Rate Limiting - Basic Verification', () => {
    it('should return 429 Too Many Requests after 5 failed attempts', async () => {
      const testUser = getUniqueUser('ratelimit');
      const passwordHash = await bcrypt.hash(testUser.password, 10);

      await dataSource.query(
        `INSERT INTO users (id, username, password_hash, full_name, role, estate_id, is_first_time, failed_login_attempts, locked_until)
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)`,
        [
          testUser.id,
          testUser.username,
          passwordHash,
          testUser.fullName,
          testUser.role,
          testUser.estateId,
          testUser.isFirstTime,
          0,
          null,
        ],
      );

      // First 5 attempts should return 401
      for (let i = 0; i < 5; i++) {
        await request(app.getHttpServer())
          .post('/api/v1/auth/login')
          .send({ username: testUser.username, password: 'wrongpassword' })
          .expect(401);
      }

      // 6th attempt should be rate limited (429)
      const response = await request(app.getHttpServer())
        .post('/api/v1/auth/login')
        .send({ username: testUser.username, password: 'wrongpassword' })
        .expect(429);

      expect(response.body.message).toBe(
        'Terlalu banyak percobaan. Tunggu 15 menit.',
      );
    });
  });

  describe('Account Lockout - Core Functionality', () => {
    it('should lock account after 10 failed attempts and return 423', async () => {
      const testUser = getUniqueUser('lockout');
      const passwordHash = await bcrypt.hash(testUser.password, 10);

      // Pre-set user with 9 failed attempts to avoid rate limiter
      await dataSource.query(
        `INSERT INTO users (id, username, password_hash, full_name, role, estate_id, is_first_time, failed_login_attempts, locked_until)
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)`,
        [
          testUser.id,
          testUser.username,
          passwordHash,
          testUser.fullName,
          testUser.role,
          testUser.estateId,
          testUser.isFirstTime,
          9, // Already at 9 failed attempts
          null,
        ],
      );

      // 10th attempt should trigger lockout and return 423
      const response = await request(app.getHttpServer())
        .post('/api/v1/auth/login')
        .send({ username: testUser.username, password: 'wrongpassword' })
        .expect(423);

      expect(response.body.message).toMatch(/Akun terkunci/);
    });

    it('should set locked_until to approximately 30 minutes in future', async () => {
      const testUser = getUniqueUser('lockout2');
      const passwordHash = await bcrypt.hash(testUser.password, 10);

      // Pre-set user with 9 failed attempts to avoid rate limiter
      // This way we only need 1 more attempt to trigger lockout
      await dataSource.query(
        `INSERT INTO users (id, username, password_hash, full_name, role, estate_id, is_first_time, failed_login_attempts, locked_until)
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)`,
        [
          testUser.id,
          testUser.username,
          passwordHash,
          testUser.fullName,
          testUser.role,
          testUser.estateId,
          testUser.isFirstTime,
          9, // Already at 9 failed attempts
          null,
        ],
      );

      // 10th attempt should trigger lockout (only 1 request, no rate limit)
      await request(app.getHttpServer())
        .post('/api/v1/auth/login')
        .send({ username: testUser.username, password: 'wrongpassword' })
        .expect(423); // Account locked on 10th failure

      // Check locked_until in database
      const result = await dataSource.query(
        'SELECT locked_until FROM users WHERE username = $1',
        [testUser.username],
      );

      const lockedUntil = new Date(result[0].locked_until);
      const now = new Date();
      const expectedMinTime = new Date(now.getTime() + 29 * 60 * 1000);
      const expectedMaxTime = new Date(now.getTime() + 31 * 60 * 1000);

      expect(lockedUntil.getTime()).toBeGreaterThanOrEqual(
        expectedMinTime.getTime(),
      );
      expect(lockedUntil.getTime()).toBeLessThanOrEqual(
        expectedMaxTime.getTime(),
      );
    });

    it('should return 423 for any attempt on locked account', async () => {
      const testUser = getUniqueUser('lockout3');
      const passwordHash = await bcrypt.hash(testUser.password, 10);

      // Pre-lock the account by setting locked_until in the future
      const lockedUntil = new Date(Date.now() + 30 * 60 * 1000); // 30 minutes from now
      await dataSource.query(
        `INSERT INTO users (id, username, password_hash, full_name, role, estate_id, is_first_time, failed_login_attempts, locked_until)
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)`,
        [
          testUser.id,
          testUser.username,
          passwordHash,
          testUser.fullName,
          testUser.role,
          testUser.estateId,
          testUser.isFirstTime,
          10, // Already at lockout threshold
          lockedUntil,
        ],
      );

      // Even correct password should return 423 (account is locked)
      const response = await request(app.getHttpServer())
        .post('/api/v1/auth/login')
        .send({ username: testUser.username, password: testUser.password })
        .expect(423);

      expect(response.body.message).toMatch(/Akun terkunci/);
    });

    it('should reset failed_attempts and clear lockout on successful login', async () => {
      const testUser = getUniqueUser('lockout4');
      const passwordHash = await bcrypt.hash(testUser.password, 10);

      await dataSource.query(
        `INSERT INTO users (id, username, password_hash, full_name, role, estate_id, is_first_time, failed_login_attempts, locked_until)
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)`,
        [
          testUser.id,
          testUser.username,
          passwordHash,
          testUser.fullName,
          testUser.role,
          testUser.estateId,
          testUser.isFirstTime,
          5,
          null,
        ],
      );

      // Successful login should reset counters
      await request(app.getHttpServer())
        .post('/api/v1/auth/login')
        .send({ username: testUser.username, password: testUser.password })
        .expect(200);

      const result = await dataSource.query(
        'SELECT failed_login_attempts, locked_until FROM users WHERE username = $1',
        [testUser.username],
      );
      expect(result[0].failed_login_attempts).toBe(0);
      expect(result[0].locked_until).toBeNull();
    });

    it('should clear expired lockout on next login attempt', async () => {
      const testUser = getUniqueUser('lockout5');
      const passwordHash = await bcrypt.hash(testUser.password, 10);

      // Create user with expired lockout (5 minutes ago)
      await dataSource.query(
        `INSERT INTO users (id, username, password_hash, full_name, role, estate_id, is_first_time, failed_login_attempts, locked_until)
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)`,
        [
          testUser.id,
          testUser.username,
          passwordHash,
          testUser.fullName,
          testUser.role,
          testUser.estateId,
          testUser.isFirstTime,
          10,
          new Date(Date.now() - 5 * 60 * 1000),
        ],
      );

      // Login should work and clear expired lock
      const response = await request(app.getHttpServer())
        .post('/api/v1/auth/login')
        .send({ username: testUser.username, password: testUser.password })
        .expect(200);

      expect(response.body).toHaveProperty('accessToken');

      // Verify counters are cleared
      const result = await dataSource.query(
        'SELECT failed_login_attempts, locked_until FROM users WHERE username = $1',
        [testUser.username],
      );
      expect(result[0].failed_login_attempts).toBe(0);
      expect(result[0].locked_until).toBeNull();
    });
  });

  describe('Integration - Rate Limiting and Lockout Work Together', () => {
    it('should demonstrate independent operation of rate limiting and lockout', async () => {
      const testUser = getUniqueUser('combined');
      const passwordHash = await bcrypt.hash(testUser.password, 10);

      await dataSource.query(
        `INSERT INTO users (id, username, password_hash, full_name, role, estate_id, is_first_time, failed_login_attempts, locked_until)
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)`,
        [
          testUser.id,
          testUser.username,
          passwordHash,
          testUser.fullName,
          testUser.role,
          testUser.estateId,
          testUser.isFirstTime,
          0,
          null,
        ],
      );

      // Rate limit: 5 requests per 15 min -> 429
      // Lockout: 10 cumulative failures -> 423

      // Make 5 failed attempts (should get 401 for each)
      for (let i = 0; i < 5; i++) {
        await request(app.getHttpServer())
          .post('/api/v1/auth/login')
          .send({ username: testUser.username, password: 'wrongpassword' })
          .expect(401);
      }

      // 6th attempt should be rate limited (429), not lockout (423)
      const response = await request(app.getHttpServer())
        .post('/api/v1/auth/login')
        .send({ username: testUser.username, password: 'wrongpassword' })
        .expect(429);

      expect(response.body.message).toBe(
        'Terlalu banyak percobaan. Tunggu 15 menit.',
      );
    });
  });
});
