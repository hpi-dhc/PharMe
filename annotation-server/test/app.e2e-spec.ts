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
    let guidelineId: number;

    beforeAll(async () => {
        const moduleFixture: TestingModule = await Test.createTestingModule({
            imports: [AppModule],
        }).compile();

        app = moduleFixture.createNestApplication();
        await app.init();

        medicationService =
            moduleFixture.get<MedicationsService>(MedicationsService);
        await medicationService.clearAllMedicationData();
    });

    describe('Pre-initialization', () => {
        it('should fail to load guidelines without medications', async () => {
            const createResponse = await request(app.getHttpServer()).post(
                '/guidelines',
            );
            expect(createResponse.status).toEqual(400);
        });

        it(`should verify guidelines haven't been fetched`, async () => {
            const getResponse = await request(app.getHttpServer()).get(
                '/guidelines/last_update',
            );
            expect(getResponse.status).toEqual(200);
            expect(new Date(getResponse.body).getTime()).toBeNaN();
        });

        it(`should verify medications haven't been fetched`, async () => {
            const getResponse = await request(app.getHttpServer()).get(
                '/medications/last_update',
            );
            expect(getResponse.status).toEqual(200);
            expect(new Date(getResponse.body).getTime()).toBeNaN();
        });
    });

    describe('Initialization', () => {
        it('should load all data', async () => {
            const createResponse = await request(app.getHttpServer()).post(
                '/init',
            );
            expect(createResponse.status).toEqual(201);
        }, 30000);
    });

    describe('Add sheet data', () => {
        it('should supplement medication data', async () => {
            const patchResponse = await request(app.getHttpServer()).patch(
                `/medications`,
            );
            expect(patchResponse.status).toEqual(200);
        }, 30000);
    });

    describe('Retrieve data for all medications & guidelines', () => {
        const verifyLastUpdate = (dateString: string) => {
            const lastUpdate = new Date(dateString).getTime();
            const now = new Date().getTime();
            const interval = now - lastUpdate;
            expect(interval).toBeGreaterThanOrEqual(0);
            expect(interval).toBeLessThanOrEqual(5 * 60 * 1000);
        };

        it('should verify guidelines have been fetched in the last 5 minutes', async () => {
            const getResponse = await request(app.getHttpServer()).get(
                '/guidelines/last_update',
            );
            expect(getResponse.status).toEqual(200);
            verifyLastUpdate(getResponse.body);
        });

        it('should verify medications have been fetched in the last 5 minutes', async () => {
            const getResponse = await request(app.getHttpServer()).get(
                '/medications/last_update',
            );
            expect(getResponse.status).toEqual(200);
            verifyLastUpdate(getResponse.body);
        });

        it('should verify that data errors have been saved', async () => {
            const getResponse = await request(app.getHttpServer()).get(
                '/guidelines/errors',
            );
            expect(getResponse.status).toEqual(200);
            expect(getResponse.body.length).toBeGreaterThan(0);
        });

        it('should get all 3 medications sorted ASCIIbetically by name', async () => {
            const getResponse = await request(app.getHttpServer())
                .get('/medications')
                .query({ sortby: 'name' });
            expect(getResponse.status).toEqual(200);
            expect(getResponse.body.length).toEqual(3);
            expect(
                getResponse.body[0].name < getResponse.body[1].name &&
                    getResponse.body[1].name < getResponse.body[2].name,
            ).toBe(true);

            // Clo..., Cod..., Not... --> Codeine is second
            codeineId = getResponse.body[1].id;
        });

        it('should return 3 medication ids', async () => {
            const getResponse = await request(app.getHttpServer())
                .get('/medications')
                .query({ onlyIds: true });
            expect(getResponse.status).toEqual(200);
            expect(getResponse.body.length).toEqual(3);
        });

        it('should get 2 medications with guidelines', async () => {
            const getResponse = await request(app.getHttpServer())
                .get('/medications')
                .query({ withGuidelines: true, getGuidelines: true });
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

        it('should return 1 medications matching a search query with guidelines', async () => {
            const getResponse = await request(app.getHttpServer())
                .get('/medications')
                .query({
                    search: 'cod',
                    withGuidelines: true,
                    getGuidelines: true,
                });
            expect(getResponse.status).toEqual(200);
            expect(getResponse.body.length).toEqual(1);
        });

        it('should get all guidelines', async () => {
            const getResponse = await request(app.getHttpServer()).get(
                '/guidelines',
            );
            expect(getResponse.status).toEqual(200);
            expect(getResponse.body.length).toBeGreaterThan(0);

            guidelineId = getResponse.body[0].id;
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

        it('should get details for one guideline', async () => {
            const getResponse = await request(app.getHttpServer()).get(
                '/guidelines/' + guidelineId,
            );
            expect(getResponse.status).toEqual(200);
        });

        it('should verify guidelines for one medication', async () => {
            const getResponse = await request(app.getHttpServer())
                .get('/medications/' + codeineId)
                .query({ getGuidelines: true });
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
