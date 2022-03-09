import { INestApplication } from '@nestjs/common';
import { Test } from '@nestjs/testing';
import * as KeycloakMock from 'keycloak-mock';
import * as request from 'supertest';
import { AppModule } from '../src/app.module';
import { getKeycloakMockHelper } from './helpers/keycloak-mock';

describe('Users', () => {
  let app: INestApplication;
  let keycloakMock: KeycloakMock.Mock;
  let keycloakToken: string;

  beforeAll(async () => {
    const moduleRef = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();
    app = moduleRef.createNestApplication();
    await app.init();

    const { mockInstance, mockToken } = await getKeycloakMockHelper();
    keycloakMock = KeycloakMock.activateMock(mockInstance);
    keycloakToken = mockToken;
  });

  afterAll(async () => {
    KeycloakMock.deactivateMock(keycloakMock);
    await app.close();
  });

  it(`/POST should return 401 when unauthenticated`, () => {
    return request(app.getHttpServer()).post('/users').expect(401);
  });

  it(`/POST should return star alleles`, () => {
    return request(app.getHttpServer())
      .post('/users')
      .set({ Authorization: `Bearer ${keycloakToken}` })
      .expect(200)
      .expect('Some star alleles');
  });
});
