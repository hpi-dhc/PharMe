import { ConfigModule } from '@nestjs/config';
import { Test, TestingModule } from '@nestjs/testing';
import { getRepositoryToken } from '@nestjs/typeorm';

import { AppModule } from '../app.module';
import { FetchDate } from '../fetch-dates/fetch-date.entity';
import { FetchDatesService } from '../fetch-dates/fetch-dates.service';
import { Medication } from './medication.entity';
import { MedicationsService } from './medications.service';

describe('MedicationsService', () => {
    let medicationsService: MedicationsService;
    let app;

    beforeAll(async () => {
        const modelFixture: TestingModule = await Test.createTestingModule({
            imports: [
                ConfigModule.forRoot({ envFilePath: ['test/.env', '.env'] }),
                AppModule,
            ],
            providers: [
                MedicationsService,
                {
                    provide: getRepositoryToken(Medication),
                    useValue: {},
                },
                FetchDatesService,
                {
                    provide: getRepositoryToken(FetchDate),
                    useValue: {},
                },
            ],
        }).compile();

        medicationsService =
            modelFixture.get<MedicationsService>(MedicationsService);
        app = modelFixture.createNestApplication();
        await app.init();
    });

    afterAll(async () => {
        await app.close();
    });

    describe('test database', () => {
        it('should fetch meds', async () => {
            await medicationsService.clearAllMedicationData();
            expect(await medicationsService.getAllIds()).toStrictEqual([]);
            await medicationsService.fetchAllMedications();
            expect((await medicationsService.getAllIds()).length).toBe(3);
        });
    });

    describe('getJSONFromZip', () => {
        it('should return the json path', async () => {
            const returnString = await medicationsService.getJSONfromZip();
            expect(returnString.endsWith('.json')).toBe(true);
        });
    });

    describe('getDataFromJSON', () => {
        it('should return right drugs from example ZIP', async () => {
            const jsonPath = await medicationsService.getJSONfromZip();
            const drugs = await medicationsService.getDataFromJSON(jsonPath);

            expect(drugs.length).toBe(3);

            const drug1 = drugs[0];
            expect(drug1.name).toBe('Codeine');
            expect(drug1.description).toContain('Lorem ipsum');
            expect(
                drug1['international-brands']['international-brand'],
            ).toStrictEqual({
                company: 'COMPANY',
                name: 'Codeine BRAND',
            });
            expect(
                drug1['external-identifiers']['external-identifier'],
            ).toStrictEqual([
                { identifier: 'PA449088', resource: 'PharmGKB' },
                { identifier: '2670', resource: 'RxCUI' },
            ]);

            expect(drugs[1].name).toBe('Clopidogrel');
        });

        it('should throw an error without the right filepath', async () => {
            expect(
                medicationsService.getDataFromJSON('not-the-right-path.json'),
            ).rejects.toThrowError();
        });
    });
});
