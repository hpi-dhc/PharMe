import { INestApplication } from '@nestjs/common';
import { Test, TestingModule } from '@nestjs/testing';
import * as request from 'supertest';

import { Guideline } from 'src/guidelines/entities/guideline.entity';

import { AppModule } from '../src/app.module';
import { MedicationsService } from '../src/medications/medications.service';

describe('App (e2e)', () => {
    let app: INestApplication;
    let medicationService: MedicationsService;
    let codeineId: number;

    beforeAll(async () => {
        const moduleFixture: TestingModule = await Test.createTestingModule({
            imports: [AppModule],
        }).compile();

        app = moduleFixture.createNestApplication();
        await app.init();

        medicationService =
            moduleFixture.get<MedicationsService>(MedicationsService);
        medicationService.clearAllMedicationData();
    });

    describe('Initialize dependency data', () => {
        it('should load mocked DrugBank XML of 3 entries', async () => {
            const createResponse = await request(app.getHttpServer()).post(
                '/medications/',
            );
            expect(createResponse.status).toEqual(201);
        });

        it('should load gene phenotypes from CPIC API', async () => {
            const createResponse = await request(app.getHttpServer()).post(
                '/genephenotypes/',
            );
            expect(createResponse.status).toEqual(201);
        }, 10000);
    });

    describe('Initialize dependent data', () => {
        it('should load guidelines from mocked Google Sheet', async () => {
            const createResponse = await request(app.getHttpServer()).post(
                '/guidelines/',
            );
            expect(createResponse.status).toEqual(201);
        }, 20000);
    });

    describe('Retrieve data for all medications', () => {
        it('should get all 3 medications', async () => {
            const getResponse = await request(app.getHttpServer()).get(
                '/medications',
            );
            expect(getResponse.status).toEqual(200);
            expect(getResponse.body.length).toEqual(3);

            codeineId = getResponse.body[0].id;
        });

        it('should return 3 medication ids', async () => {
            const getResponse = await request(app.getHttpServer()).get(
                '/medications/ids',
            );
            expect(getResponse.status).toEqual(200);
            expect(getResponse.body.length).toEqual(3);
        });

        it('should get 2 medications with guidelines', async () => {
            const getResponse = await request(app.getHttpServer()).get(
                '/medications/report',
            );
            expect(getResponse.status).toEqual(200);
            expect(getResponse.body.length).toEqual(2);
        });

        it('should return 2 medications matching a search query', async () => {
            const getResponse = await request(app.getHttpServer())
                .get('/medications')
                .query({ search: 'cod' });
            expect(getResponse.status).toEqual(200);
            expect(getResponse.body.length).toEqual(2);
        });

        it('should verify that data errors have been saved', async () => {
            const getResponse = await request(app.getHttpServer()).get(
                '/guidelines/errors',
            );
            expect(getResponse.status).toEqual(200);
            expect(getResponse.body.length).toBeGreaterThan(0);
        });
    });

    describe('Retrieve data for a specific medication', () => {
        it('should verify details for one medication', async () => {
            const getResponse = await request(app.getHttpServer()).get(
                '/medications/' + codeineId,
            );
            expect(getResponse.status).toEqual(200);
            expect(getResponse.body.drugclass).toEqual('Pain killer');
            expect(getResponse.body.indication).toEqual('Codeine/indication');
        });

        it('should verify guidelines for one medication', async () => {
            const getResponse = await request(app.getHttpServer()).get(
                '/medications/' + codeineId,
            );
            expect(getResponse.status).toEqual(200);

            const guidelines: Guideline[] = getResponse.body.guidelines;

            expect(guidelines.length).toBeGreaterThan(0);

            for (const guideline of guidelines) {
                const implicationSegments = guideline.implication.split('/');
                const recommendationSegments =
                    guideline.recommendation.split('/');

                expect(implicationSegments[3]).toBe(recommendationSegments[3]);
                expect(recommendationSegments[4]).toEqual(
                    guideline.warningLevel ?? 'null',
                );
            }
        });
    });

    afterAll(async () => {
        await medicationService.clearAllMedicationData();
        await app.close();
    });
});
