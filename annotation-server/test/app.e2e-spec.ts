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

        it(`should get null for last guideline update`, async () => {
            const getResponse = await request(app.getHttpServer()).get(
                '/guidelines/last_update',
            );
            expect(getResponse.status).toEqual(200);
            expect(new Date(getResponse.body).getTime()).toBeNaN();
        });

        it(`should get null for last medication update`, async () => {
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
                `/medications/sheet`,
            );
            expect(patchResponse.status).toEqual(200);
        }, 30000);

        it('should supplement guideline data', async () => {
            const patchResponse = await request(app.getHttpServer()).patch(
                `/guidelines/sheet`,
            );
            expect(patchResponse.status).toEqual(200);
        }, 30000);
    });

    describe('get data for all medications & guidelines', () => {
        const verifyLastUpdate = (dateString: string) => {
            const lastUpdate = new Date(dateString).getTime();
            const now = new Date().getTime();
            const interval = now - lastUpdate;
            expect(interval).toBeGreaterThanOrEqual(0);
            expect(interval).toBeLessThanOrEqual(5 * 60 * 1000);
        };

        it('should get last guideline update date within the last 5 minutes', async () => {
            const getResponse = await request(app.getHttpServer()).get(
                '/guidelines/last_update',
            );
            expect(getResponse.status).toEqual(200);
            verifyLastUpdate(getResponse.body);
        });

        it('should get last medication update date within the last 5 minutes', async () => {
            const getResponse = await request(app.getHttpServer()).get(
                '/medications/last_update',
            );
            expect(getResponse.status).toEqual(200);
            verifyLastUpdate(getResponse.body);
        });

        it('should get more than 0 data errors', async () => {
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

        it('should get 3 medication ids', async () => {
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

        it('should get 2 medications matching a search query', async () => {
            const getResponse = await request(app.getHttpServer())
                .get('/medications')
                .query({ search: 'cod' });
            expect(getResponse.status).toEqual(200);
            expect(getResponse.body.length).toEqual(2);
        });

        it('should get 1 medication matching a search query with guidelines', async () => {
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

    describe('Get data for a specific medication', () => {
        it('should get correct details for one medication', async () => {
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

        it('should get correct guidelines for one medication', async () => {
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

    describe('Modify data', () => {
        it('should patch details of one medication', async () => {
            const patchResponse = await request(app.getHttpServer())
                .patch('/medications/')
                .send([{ id: codeineId, drugclass: 'Not a pain killer' }]);
            expect(patchResponse.status).toEqual(200);
        });

        it('should patch details of one guideline', async () => {
            const patchResponse = await request(app.getHttpServer())
                .patch('/guidelines/')
                .send([
                    { id: guidelineId, recommendation: 'Some recommendation.' },
                ]);
            expect(patchResponse.status).toEqual(200);
        });
    });

    describe('Verify modified data', () => {
        it('should get correct details for one medication', async () => {
            const getResponse = await request(app.getHttpServer()).get(
                '/medications/' + codeineId,
            );
            expect(getResponse.status).toEqual(200);
            expect(getResponse.body.drugclass).toEqual('Not a pain killer');
            expect(getResponse.body.indication).toEqual('Codeine/indication');
        });

        it('should get correct details for one medication', async () => {
            const getResponse = await request(app.getHttpServer()).get(
                '/guidelines/' + guidelineId,
            );
            expect(getResponse.status).toEqual(200);
            expect(getResponse.body.recommendation).toEqual(
                'Some recommendation.',
            );
        });
    });

    afterAll(async () => {
        await medicationService.clearAllMedicationData();
        await app.close();
    });
});
