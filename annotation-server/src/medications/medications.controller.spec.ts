/* import { INestApplication } from '@nestjs/common';
import { Test, TestingModule } from '@nestjs/testing';
import * as request from 'supertest';
import { RxNormMappingsService } from './rxnormmappings.service';
import { AppModule } from '../app.module';

describe('MedicationsController', () => {
  let app: INestApplication;
  let rxNormMappingsService;

  beforeAll(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = moduleFixture.createNestApplication();
    await app.init();

    rxNormMappingsService = moduleFixture.get<RxNormMappingsService>(
      RxNormMappingsService,
    );

    await rxNormMappingsService.fetchMedications();
  }, 60000);

  it('should return medication data', () => {
    // as Dailymed might change the entry, you might have to change the test later
    return request(app.getHttpServer())
      .get('/medications/b9ff2469-22c7-fc70-e053-2a95a90abc49')
      .expect(200);
  });

  it('should return a 404 error', () => {
    // as Dailymed might change the entry, you might have to change the test later
    return request(app.getHttpServer()).get('/medications/1').expect(404);
  });

  afterAll(async () => {
    await rxNormMappingsService.deleteAll();
  });
}); */
