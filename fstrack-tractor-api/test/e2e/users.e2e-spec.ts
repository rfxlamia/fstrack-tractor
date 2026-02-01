/* eslint-disable @typescript-eslint/no-unsafe-member-access */
/* eslint-disable @typescript-eslint/no-unsafe-assignment */

import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication, ValidationPipe } from '@nestjs/common';
import request from 'supertest';
import { App } from 'supertest/types';
import { AppModule } from '../../src/app.module';
import { DataSource } from 'typeorm';
import * as bcrypt from 'bcrypt';

describe('UsersController (e2e)', () => {
  let app: INestApplication<App>;
  let dataSource: DataSource;

  const testUser = {
    username: 'users_e2e_user',
    password: 'UsersE2EPassword123',
    fullname: 'Users E2E User',
    roleId: 'KASIE_PG',
    plantationGroupId: null,
    isFirstTime: true,
  };

  const loginAndGetToken = async () => {
    const response = await request(app.getHttpServer())
      .post('/api/v1/auth/login')
      .send({
        username: testUser.username,
        password: testUser.password,
      })
      .expect(200);

    return response.body.accessToken as string;
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

    await dataSource.query('DELETE FROM users WHERE username = $1', [
      testUser.username,
    ]);

    const passwordHash = await bcrypt.hash(testUser.password, 10);
    await dataSource.query(
      `INSERT INTO users (username, password, fullname, role_id, plantation_group_id, is_first_time, failed_login_attempts, locked_until)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8)`,
      [
        testUser.username,
        passwordHash,
        testUser.fullname,
        testUser.roleId,
        testUser.plantationGroupId,
        testUser.isFirstTime,
        0,
        null,
      ],
    );
  });

  beforeEach(async () => {
    await dataSource.query(
      'UPDATE users SET is_first_time = $1 WHERE username = $2',
      [true, testUser.username],
    );
  });

  afterAll(async () => {
    await dataSource.query('DELETE FROM users WHERE username = $1', [
      testUser.username,
    ]);
    await app.close();
  });

  describe('PATCH /api/v1/users/me/first-time', () => {
    it('should return 200 with valid JWT and body', async () => {
      const token = await loginAndGetToken();

      const response = await request(app.getHttpServer())
        .patch('/api/v1/users/me/first-time')
        .set('Authorization', `Bearer ${token}`)
        .send({ isFirstTime: false })
        .expect(200);

      expect(response.body).toEqual({
        statusCode: 200,
        message: 'Status updated',
        data: { success: true },
      });

      const result = await dataSource.query(
        'SELECT is_first_time FROM users WHERE username = $1',
        [testUser.username],
      );
      expect(result[0].is_first_time).toBe(false);
    });

    it('should return 401 without JWT', async () => {
      await request(app.getHttpServer())
        .patch('/api/v1/users/me/first-time')
        .send({ isFirstTime: false })
        .expect(401);
    });

    it('should return 400 with invalid body', async () => {
      const token = await loginAndGetToken();

      const response = await request(app.getHttpServer())
        .patch('/api/v1/users/me/first-time')
        .set('Authorization', `Bearer ${token}`)
        .send({ isFirstTime: 'not-a-boolean' })
        .expect(400);

      expect(response.body.message).toEqual(
        expect.arrayContaining(['isFirstTime must be a boolean value']),
      );
    });
  });
});
