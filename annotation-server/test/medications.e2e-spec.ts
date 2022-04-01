import { INestApplication } from '@nestjs/common';
import { Test, TestingModule } from '@nestjs/testing';
import * as request from 'supertest';

import { MedicationsService } from '../src/medications/medications.service';
import { AppModule } from './../src/app.module';

describe('MedicationsController (e2e)', () => {
    let app: INestApplication;
    let medicationService: MedicationsService;

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

    it('should load minimized DrugBank XML of 100 entries', async () => {
        const createResponse = request(app.getHttpServer()).post(
            '/medications/',
        );
        createResponse.expect(201);
        await createResponse;

        const getResponse = request(app.getHttpServer()).get('/medications');
        getResponse.expect(200);
        expect((await getResponse).body.length).toBe(100);
    }, 20000);

    afterAll(async () => {
        await medicationService.clearAllMedicationData();
    });
});
