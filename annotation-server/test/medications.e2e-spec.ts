import { INestApplication } from '@nestjs/common';
import { Test, TestingModule } from '@nestjs/testing';
import { getRepositoryToken } from '@nestjs/typeorm';
import * as cookieParser from 'cookie-parser';
import * as request from 'supertest';
import { Repository } from 'typeorm';

import { AppModule } from './../src/app.module';
import { GeneVariant } from './../src/medications/interfaces/geneVariant.interface';
import { Medication } from './../src/medications/medication.entity';
import { MedicationsService } from './../src/medications/medications.service';

describe('MedicationsController (e2e)', () => {
    let app: INestApplication;
    let medicationService: MedicationsService;
    let medicationRepository: Repository<Medication>;

    beforeAll(async () => {
        const moduleFixture: TestingModule = await Test.createTestingModule({
            imports: [AppModule],
        }).compile();

        app = moduleFixture.createNestApplication();
        app.use(cookieParser());
        await app.init();

        medicationRepository = moduleFixture.get<Repository<Medication>>(
            getRepositoryToken(Medication),
        );

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

    it('should return some annotations for Ibuprofen', (done) => {
        const mockMedication = new Medication();
        mockMedication.name = 'mock-ibuprofen';
        mockMedication.pharmgkbId = 'PA449957';
        mockMedication.synonyms = [];
        medicationRepository.save(mockMedication).then(({ id }) => {
            const geneVariants: Array<GeneVariant> = [
                {
                    gene: 'CYP2C9',
                    variant1: '*1',
                    variant2: '*3',
                },
            ];
            request(app.getHttpServer())
                .get(`/medications/${id}/annotations`)
                .set('Cookie', [`variants=${JSON.stringify(geneVariants)}`])
                .send()
                .expect(
                    200,
                    [
                        {
                            gene: 'CYP2C9',
                            description:
                                'The CYP2C9*1 allele is assigned as a normal function allele by CPIC. Patients carrying CYP2C9*1 allele in combination with another normal function allele may have increased metabolism of ibuprofen as compared to patients carrying at least one copy of a decreased or no function allele. However, conflicting evidence has been reported. Other genetic and clinical factors may also influence metabolism of ibuprofen. This annotation only covers the pharmacokinetic relationship between CYP2C9 and ibuprofen and does not include evidence about clinical outcomes.',
                        },
                        {
                            gene: 'CYP2C9',
                            description:
                                'The CYP2C9*3 allele is assigned as a no function allele by CPIC. Patients carrying the CYP2C9*3 allele in combination with a normal, decreased, or no function allele may have decreased metabolism of ibuprofen as compared to patients with two normal function alleles. Other genetic and clinical factors may also influence metabolism of ibuprofen. This annotation only covers the pharmacokinetic relationship between CYP2C9 and ibuprofen and does not include evidence about clinical outcomes.',
                        },
                    ],
                    done,
                );
        });
    });

    afterAll(async () => {
        await medicationService.clearAllMedicationData();
    });
});
