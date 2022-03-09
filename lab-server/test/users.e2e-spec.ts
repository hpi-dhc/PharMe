import { INestApplication } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { Test } from '@nestjs/testing';
import * as request from 'supertest';
import {
  KeycloakModule,
  KeycloakProviders,
} from '../src/configs/keycloak.config';
import { OrmModule } from '../src/configs/orm.config';
import { UsersModule } from '../src/users/users.module';

describe('Users', () => {
  let app: INestApplication;

  beforeAll(async () => {
    const moduleRef = await Test.createTestingModule({
      imports: [
        ConfigModule.forRoot({
          isGlobal: true,
          envFilePath: '.env.test',
        }),
        OrmModule,
        KeycloakModule,
        UsersModule,
      ],
      providers: [...KeycloakProviders],
    }).compile();

    app = moduleRef.createNestApplication();
    await app.init();
  });

  it(`/POST should return 401 when unauthenticated`, () => {
    return request(app.getHttpServer()).post('/users').expect(401);
  });

  // it(`/POST authenticate`, () => {
  //   return request(app.getHttpServer()).post('/users').expect(200).expect({
  //     data: usersService.authenticateUser(),
  //   });
  // });

  afterAll(async () => {
    await app.close();
  });
});
