import { INestApplication } from '@nestjs/common';
import { Test } from '@nestjs/testing';
import { MinioService } from 'nestjs-minio-client';
import * as request from 'supertest';

import { AppModule } from '../src/app.module';
import { mockedS3Files } from './helpers/contstants';
import { KeycloakMock } from './helpers/keycloak-mock';
import { MockS3Instance } from './helpers/s3-mock';

describe('StarAlleles', () => {
    let app: INestApplication;
    let keycloakMock: KeycloakMock;

    beforeAll(async () => {
        const moduleRef = await Test.createTestingModule({
            imports: [AppModule],
        })
            .overrideProvider(MinioService)
            .useValue(MockS3Instance(mockedS3Files))
            .compile();
        app = moduleRef.createNestApplication();
        await app.init();

        keycloakMock = KeycloakMock.getInstance();
        await keycloakMock.activate();
    });

    afterAll(async () => {
        keycloakMock.deactivate();
        await app.close();
    });

    it('/GET should return 401 when unauthenticated', () => {
        return request(app.getHttpServer()).get('/star-alleles').expect(401);
    });

    it('/GET should return the star alleles of a user', async () => {
        const expectedDiploTypeObject = {
            gene: expect.any(String),
            resultType: expect.any(String),
            genotype: expect.any(String),
            phenotype: expect.any(String),
            allelesTested: expect.any(String),
        };
        const response = await request(app.getHttpServer())
            .get('/star-alleles')
            .set({ Authorization: `Bearer ${keycloakMock.getExampleUser()}` })
            .expect(200);
        const data = response.body;
        expect(data).toHaveProperty('organizationId');
        expect(data).toHaveProperty('identifier');
        expect(data).toHaveProperty('knowledgeBase');
        expect(data).toHaveProperty('diplotypes');
        const diplotypes = data['diplotypes'] as Array<never>;
        diplotypes.forEach((e) =>
            expect(e).toEqual(expect.objectContaining(expectedDiploTypeObject)),
        );
    });

    it('/GET should return 404 when user has no alleles file', async () => {
        await request(app.getHttpServer())
            .get('/star-alleles')
            .set({
                Authorization: `Bearer ${keycloakMock.getExampleUserWithoutAllelesFile()}`,
            })
            .expect(404);
    });
});
