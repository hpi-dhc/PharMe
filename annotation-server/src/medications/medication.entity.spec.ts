import { DrugDto } from './dtos/drugbank.dto';
import { Medication } from './medication.entity';

describe('Medication Entity', () => {
    const exampleName = 'Ibuprofen';
    const exampleDescription =
        'Ibuprofen is a medication in the nonsteroidal anti-inflammatory drug (NSAID) class that is used for treating pain, fever, and inflammation.[7] This includes painful menstrual periods, migraines, and rheumatoid arthritis.[7] It may also be used to close a patent ductus arteriosus in a premature baby.[7] It can be used by mouth or intravenously.[7] It typically begins working within an hour.';
    const exampleExternalIdentifierPharmGKB = {
        resource: 'PharmGKB',
        identifier: '123456789ABCDEF!',
    };
    const exampleExternalIdentifierDailyMed = {
        resource: 'DailyMed',
        identifier: 'foo-987654321',
    };
    const exampleExternalIdentifierWikipedia = {
        resource: 'Wikipedia',
        identifier: 'insalatamista999',
    };
    const exampleInternationalBrand1 = 'Advil Migraine';
    const exampleInternationalBrand2 = 'Medipren';

    describe('during creation', () => {
        it('should return a right entity from DTO', () => {
            const exampleDrug = new DrugDto();
            exampleDrug.name = exampleName;
            exampleDrug.description = exampleDescription;
            exampleDrug['external-identifiers'] = {
                'external-identifier': [
                    exampleExternalIdentifierPharmGKB,
                    exampleExternalIdentifierDailyMed,
                    exampleExternalIdentifierWikipedia,
                ],
            };
            exampleDrug['international-brands'] = {
                'international-brand': [
                    { name: exampleInternationalBrand1 },
                    { name: exampleInternationalBrand2 },
                ],
            };

            const medication = Medication.fromDrug(exampleDrug);

            expect(medication.name).toBe(exampleName);
            expect(medication.description).toBe(exampleDescription);
            expect(medication.id).toBeUndefined(); // check its not yet in the database
            expect(medication.pharmgkbId).toBe(
                exampleExternalIdentifierPharmGKB.identifier,
            );
            expect(medication.synonyms).toContain(exampleInternationalBrand1);
            expect(medication.synonyms).toContain(exampleInternationalBrand2);
            expect(medication.synonyms.length).toBe(2);
        });

        it('should handle only one external-identifier and international-brand', () => {
            const exampleDrug = new DrugDto();
            exampleDrug.name = exampleName;
            exampleDrug.description = exampleDescription;
            exampleDrug['external-identifiers'] = {
                'external-identifier': exampleExternalIdentifierPharmGKB,
            };
            exampleDrug['international-brands'] = {
                'international-brand': { name: exampleInternationalBrand1 },
            };

            const medication = Medication.fromDrug(exampleDrug);

            expect(medication.pharmgkbId).toBe(
                exampleExternalIdentifierPharmGKB.identifier,
            );
            expect(medication.synonyms).toStrictEqual([
                exampleInternationalBrand1,
            ]);
        });
    });
});
