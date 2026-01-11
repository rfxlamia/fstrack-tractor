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

describe('AuthController (e2e)', () => {
  let app: INestApplication<App>;
  let dataSource: DataSource;

  const testUser = {
    id: '00000000-0000-0000-0000-000000000001',
    username: 'test_user',
    password: 'TestPassword123',
    fullName: 'Test User',
    role: 'KASIE',
    estateId: null,
    isFirstTime: true,
  };

  const lockedUser = {
    id: '00000000-0000-0000-0000-000000000002',
    username: 'locked_user',
    password: 'LockedPassword123',
    fullName: 'Locked User',
    role: 'KASIE',
    estateId: null,
    isFirstTime: true,
    lockedUntil: new Date(Date.now() + 30 * 60 * 1000), // 30 minutes from now
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

    // Clean up and insert test users
    await dataSource.query('DELETE FROM users WHERE username IN ($1, $2)', [
      testUser.username,
      lockedUser.username,
    ]);

    const passwordHash = await bcrypt.hash(testUser.password, 10);
    const lockedPasswordHash = await bcrypt.hash(lockedUser.password, 10);

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

    await dataSource.query(
      `INSERT INTO users (id, username, password_hash, full_name, role, estate_id, is_first_time, failed_login_attempts, locked_until)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)`,
      [
        lockedUser.id,
        lockedUser.username,
        lockedPasswordHash,
        lockedUser.fullName,
        lockedUser.role,
        lockedUser.estateId,
        lockedUser.isFirstTime,
        10,
        lockedUser.lockedUntil,
      ],
    );
  });

  afterAll(async () => {
    // Clean up test users
    await dataSource.query('DELETE FROM users WHERE username IN ($1, $2)', [
      testUser.username,
      lockedUser.username,
    ]);
    await app.close();
  });

  describe('POST /api/v1/auth/login', () => {
    it('should return 200 and token on successful login', async () => {
      const response = await request(app.getHttpServer())
        .post('/api/v1/auth/login')
        .send({
          username: testUser.username,
          password: testUser.password,
        })
        .expect(200);

      expect(response.body).toHaveProperty('accessToken');
      expect(response.body).toHaveProperty('user');
      expect(response.body.user).toEqual({
        id: testUser.id,
        fullName: testUser.fullName,
        role: testUser.role,
        estateId: testUser.estateId,
        isFirstTime: testUser.isFirstTime,
      });

      // Verify JWT is valid format
      expect(response.body.accessToken).toMatch(/^eyJ/);
    });

    it('should return 400 when username is missing', async () => {
      const response = await request(app.getHttpServer())
        .post('/api/v1/auth/login')
        .send({
          password: 'somepassword',
        })
        .expect(400);

      expect(response.body.message).toContain('Username harus diisi');
    });

    it('should return 400 when password is missing', async () => {
      const response = await request(app.getHttpServer())
        .post('/api/v1/auth/login')
        .send({
          username: 'someuser',
        })
        .expect(400);

      expect(response.body.message).toContain('Password harus diisi');
    });

    it('should return 400 when both fields are missing', async () => {
      const response = await request(app.getHttpServer())
        .post('/api/v1/auth/login')
        .send({})
        .expect(400);

      expect(response.body.message).toEqual(
        expect.arrayContaining([
          expect.stringMatching(/Username/),
          expect.stringMatching(/Password/),
        ]),
      );
    });

    it('should return 401 when username does not exist', async () => {
      const response = await request(app.getHttpServer())
        .post('/api/v1/auth/login')
        .send({
          username: 'nonexistent_user',
          password: 'somepassword',
        })
        .expect(401);

      expect(response.body.message).toBe('Username atau password salah');
    });

    it('should return 401 when password is incorrect', async () => {
      const response = await request(app.getHttpServer())
        .post('/api/v1/auth/login')
        .send({
          username: testUser.username,
          password: 'wrongpassword',
        })
        .expect(401);

      expect(response.body.message).toBe('Username atau password salah');
    });

    it('should return 423 when account is locked', async () => {
      const response = await request(app.getHttpServer())
        .post('/api/v1/auth/login')
        .send({
          username: lockedUser.username,
          password: lockedUser.password,
        })
        .expect(423);

      expect(response.body.message).toMatch(/Akun terkunci/);
      expect(response.body.message).toMatch(/menit/);
    });

    it('should update last_login on successful login', async () => {
      // Get last_login before
      const beforeResult = await dataSource.query(
        'SELECT last_login FROM users WHERE id = $1',
        [testUser.id],
      );
      const beforeLogin = beforeResult[0].last_login;

      await request(app.getHttpServer())
        .post('/api/v1/auth/login')
        .send({
          username: testUser.username,
          password: testUser.password,
        })
        .expect(200);

      // Get last_login after
      const afterResult = await dataSource.query(
        'SELECT last_login FROM users WHERE id = $1',
        [testUser.id],
      );
      const afterLogin = afterResult[0].last_login;

      expect(afterLogin).not.toEqual(beforeLogin);
      expect(new Date(afterLogin).getTime()).toBeGreaterThan(Date.now() - 5000);
    });
  });
});
