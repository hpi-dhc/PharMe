import { ConfigModule } from '@nestjs/config';
import { Test, TestingModule } from '@nestjs/testing';
import { getRepositoryToken } from '@nestjs/typeorm';
import { Repository } from 'typeorm';

import { Medication } from './medication.entity';
import { MedicationsService } from './medications.service';

describe('MedicationsService', () => {
    let medicationsService: MedicationsService;
    let medicationRepo: Repository<Medication>;

    beforeEach(async () => {
        const modelFixture: TestingModule = await Test.createTestingModule({
            imports: [
                ConfigModule.forRoot({ envFilePath: ['test/.env', '.env'] }),
            ],
            providers: [
                MedicationsService,
                {
                    provide: getRepositoryToken(Medication),
                    useValue: {},
                },
            ],
        }).compile();

        medicationsService =
            modelFixture.get<MedicationsService>(MedicationsService);
        medicationRepo = modelFixture.get<Repository<Medication>>(
            getRepositoryToken(Medication),
        );
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

            expect(drugs.length).toBe(2);

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

    describe('findMatchingMedications', () => {
        it('should return matching entities in right order', async () => {
            const medication1 = new Medication();
            medication1.name = 'codeine';
            medication1.description = 'This is a pain relief';
            const medication2 = new Medication();
            medication2.name = 'unique medicine';
            medication1.drugclass = 'Codeine class';
            const medication3 = new Medication();
            medication3.name = 'something else';
            medication3.description = 'matches nothing';
            medication3.synonyms = ['codeine'];
            const medication4 = new Medication();
            medication4.name = 'Some other medicine';
            medication4.description =
                'This medicines description includes codeine';
            const medication5 = new Medication();
            medication5.name = 'some name';
            medication5.description = 'some description';
            console.log(medicationRepo);
            const savedResults = await medicationRepo.save([
                medication1,
                medication2,
                medication3,
                medication4,
                medication5,
            ]);
            const result = await medicationsService.findMatchingMedications(
                'co',
            );
            expect(result[0].name).toBe(medication1.name);
            expect(result[1].drugclass).toBe(medication2.description);
            expect(result[2].synonyms).toBe(medication3.synonyms);
            expect(result[3].description).toBe(medication4.description);
            //Tear off
            savedResults.forEach(
                async (el) => await medicationRepo.delete(el.id),
            );
        });
    });
});
