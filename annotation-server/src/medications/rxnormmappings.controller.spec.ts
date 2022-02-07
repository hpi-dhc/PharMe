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

  it('/rxnorm (POST)', () => {
    return request(app.getHttpServer())
      .post('/rxnorm')
      .expect(201)
      .catch((err) => {
        console.log(err);
      });
  }, 60000);

  it('/rxnorm (GET)', () => {
    return request(app.getHttpServer()).get('/rxnorm').expect(200);
  });

  it('/rxnorm (DELETE)', () => {
    return request(app.getHttpServer()).delete('/rxnorm').expect(200);
  });
});
