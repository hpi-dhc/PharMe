import { INestApplication } from '@nestjs/common';
import { Test, TestingModule } from '@nestjs/testing';
import * as request from 'supertest';
import { AppModule } from '../app.module';

describe('ClinicalAnnotationsController (e2e)', () => {
  let app: INestApplication;

  beforeAll(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = moduleFixture.createNestApplication();
    await app.init();
  });

  it('/clinical_annotations/sync (POST)', () => {
    return request(app.getHttpServer())
      .post('/clinical_annotations/sync')
      .expect(201);
  });

  it('/clinical_annotations (GET)', () => {
    return request(app.getHttpServer())
      .get('/clinical_annotations')
      .expect(200);
  });
});
