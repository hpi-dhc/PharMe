import { INestApplication } from '@nestjs/common';
import { Test } from '@nestjs/testing';
import * as KeycloakMock from 'keycloak-mock';
import { MinioService } from 'nestjs-minio-client';
import * as request from 'supertest';

import { AppModule } from '../src/app.module';
import { getKeycloakMockHelperForUser } from './helpers/keycloak-mock';
import { MockS3Instance } from './helpers/s3-mock';

describe('StarAlleles', () => {
    let app: INestApplication;
    let keycloakMock: KeycloakMock.Mock;
    let keycloakToken: string;
    let invalidKeycloakToken: string;

    beforeAll(async () => {
        const moduleRef = await Test.createTestingModule({
            imports: [AppModule],
        })
            .overrideProvider(MinioService)
            .useValue(MockS3Instance)
            .compile();
        app = moduleRef.createNestApplication();
        await app.init();

        const { mockInstance, mockToken } =
            await getKeycloakMockHelperForUser();
        const invalidMockHelper = await getKeycloakMockHelperForUser(false);
        keycloakMock = KeycloakMock.activateMock(mockInstance);
        keycloakToken = mockToken;
        invalidKeycloakToken = invalidMockHelper.mockToken;
    });

    afterAll(async () => {
        KeycloakMock.deactivateMock(keycloakMock);
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
            .set({ Authorization: `Bearer ${keycloakToken}` })
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

    it('/GET should fail when user without alleles file makes request', async () => {
        await request(app.getHttpServer())
            .get('/star-alleles')
            .set({ Authorization: `Bearer ${invalidKeycloakToken}` })
            .expect(401);
    });
});
