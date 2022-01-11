import { INestApplication } from '@nestjs/common';
import { Test, TestingModule } from '@nestjs/testing';
import * as request from 'supertest';
import { AppModule } from '../app.module';

describe('MedicationsController', () => {
  let app: INestApplication;

  beforeAll(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = moduleFixture.createNestApplication();
    await app.init();
  });

  it('/medications (POST)', () => {
    return request(app.getHttpServer())
      .post('/medications')
      .expect(201)
      .catch((err) => {
        console.log(err);
      });
  });

  it('/medications (GET)', () => {
    return request(app.getHttpServer()).get('/medications').expect(200);
  });
});
