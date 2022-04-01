import { INestApplication } from '@nestjs/common';
import { Test } from '@nestjs/testing';
import * as KeycloakMock from 'keycloak-mock';
import * as request from 'supertest';

import { AppModule } from '../src/app.module';
import { S3Service } from '../src/s3/s3.service';
import { getKeycloakMockHelperForUser } from './helpers/keycloak-mock';

describe('StarAlleles', () => {
    let app: INestApplication;
    let keycloakMock: KeycloakMock.Mock;
    let keycloakToken: string;
    let invalidKeycloakToken: string;

    const mockS3Service = {
        getFile: () => [
            JSON.parse(
                Buffer.from(
                    'ewogICJvcmdhbml6YXRpb25JZCI6IDEsCiAgImlkZW50aWZpZXIiOiAic29tZSBkdW1teSBkYXRhIiwKICAia25vd2xlZGdlQmFzZSI6ICJzb21lIGR1bW15IGRhdGEiLAogICJkaXBsb3R5cGVzIjogWwogICAgewogICAgICAiZ2VuZSI6ICJzb21lIGR1bW15IGRhdGEiLAogICAgICAicmVzdWx0VHlwZSI6ICJzb21lIGR1bW15IGRhdGEiLAogICAgICAiZ2Vub3R5cGUiOiAic29tZSBkdW1teSBkYXRhIiwKICAgICAgInBoZW5vdHlwZSI6ICJzb21lIGR1bW15IGRhdGEiLAogICAgICAiYWxsZWxlc1Rlc3RlZCI6ICJzb21lIGR1bW15IGRhdGEiCiAgICB9LAogICAgewogICAgICAiZ2VuZSI6ICJzb21lIGR1bW15IGRhdGEiLAogICAgICAicmVzdWx0VHlwZSI6ICJzb21lIGR1bW15IGRhdGEiLAogICAgICAiZ2Vub3R5cGUiOiAic29tZSBkdW1teSBkYXRhIiwKICAgICAgInBoZW5vdHlwZSI6ICJzb21lIGR1bW15IGRhdGEiLAogICAgICAiYWxsZWxlc1Rlc3RlZCI6ICJzb21lIGR1bW15IGRhdGEiCiAgICB9LAogICAgewogICAgICAiZ2VuZSI6ICJzb21lIGR1bW15IGRhdGEiLAogICAgICAicmVzdWx0VHlwZSI6ICJzb21lIGR1bW15IGRhdGEiLAogICAgICAiZ2Vub3R5cGUiOiAic29tZSBkdW1teSBkYXRhIiwKICAgICAgInBoZW5vdHlwZSI6ICJzb21lIGR1bW15IGRhdGEiLAogICAgICAiYWxsZWxlc1Rlc3RlZCI6ICJzb21lIGR1bW15IGRhdGEiCiAgICB9LAogICAgewogICAgICAiZ2VuZSI6ICJzb21lIGR1bW15IGRhdGEiLAogICAgICAicmVzdWx0VHlwZSI6ICJzb21lIGR1bW15IGRhdGEiLAogICAgICAiZ2Vub3R5cGUiOiAic29tZSBkdW1teSBkYXRhIiwKICAgICAgInBoZW5vdHlwZSI6ICJzb21lIGR1bW15IGRhdGEiLAogICAgICAiYWxsZWxlc1Rlc3RlZCI6ICJzb21lIGR1bW15IGRhdGEiCiAgICB9CiAgXQp9Cg==',
                    'base64',
                ).toString(),
            ),
        ],
    };

    beforeAll(async () => {
        const moduleRef = await Test.createTestingModule({
            imports: [AppModule],
        })
            .overrideProvider(S3Service)
            .useValue(mockS3Service)
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
        const data = response.body[0];
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
