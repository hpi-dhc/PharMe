import { ConfigModule } from '@nestjs/config';
import { Test, TestingModule } from '@nestjs/testing';
import { getRepositoryToken } from '@nestjs/typeorm';

import { Medication } from './medication.entity';
import { MedicationsService } from './medications.service';

describe('MedicationsService', () => {
    let medicationsService: MedicationsService;

    beforeEach(async () => {
        const modelFixture: TestingModule = await Test.createTestingModule({
            imports: [ConfigModule.forRoot()], // needed for MedicationService
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
    });

    describe('getJSONFromZip', () => {
        it('should return the json path', async () => {
            const returnString = await medicationsService.getJSONfromZip();
            expect(returnString).toContain('.json');
        });
    });
});
