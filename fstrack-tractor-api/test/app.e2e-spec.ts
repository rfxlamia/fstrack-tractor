import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication, ValidationPipe } from '@nestjs/common';
import request from 'supertest';
import { App } from 'supertest/types';
import { AppModule } from './../src/app.module';

describe('AppController (e2e)', () => {
  let app: INestApplication<App>;

  beforeEach(async () => {
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
  });

  afterEach(async () => {
    await app.close();
  });

  describe('Health Endpoint', () => {
    it('GET /api/health should return health status', () => {
      return request(app.getHttpServer())
        .get('/api/health')
        .expect(200)
        .expect((res) => {
          const body = res.body as { status: string; timestamp: string };
          expect(body).toHaveProperty('status', 'ok');
          expect(body).toHaveProperty('timestamp');
          expect(typeof body.timestamp).toBe('string');
        });
    });

    it('GET /api/health should return valid ISO timestamp', () => {
      return request(app.getHttpServer())
        .get('/api/health')
        .expect(200)
        .expect((res) => {
          const body = res.body as { status: string; timestamp: string };
          const timestamp = new Date(body.timestamp);
          expect(timestamp).toBeInstanceOf(Date);
          expect(isNaN(timestamp.getTime())).toBe(false);
        });
    });
  });
});
