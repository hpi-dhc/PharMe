import { Entity, Column, PrimaryGeneratedColumn } from 'typeorm';

import { DrugDto } from './dtos/drugbank.dto';

@Entity()
export class Medication {
    static fromDrug(drug: DrugDto): Medication {
        const medication = new Medication();
        medication.name = drug.name;
        medication.description = drug.description;

        let externalIdentifier =
            drug['external-identifiers']?.['external-identifier'];
        if (externalIdentifier) {
            externalIdentifier = Array.isArray(externalIdentifier)
                ? externalIdentifier
                : [externalIdentifier];
            medication.pharmgkbId = externalIdentifier.find(
                (id) => id.resource === 'PharmGKB',
            )?.identifier;
        }

        let internationalBrand =
            drug['international-brands']?.['international-brand'];
        if (internationalBrand) {
            internationalBrand = Array.isArray(internationalBrand)
                ? internationalBrand
                : [internationalBrand];
            medication.synonyms = internationalBrand.map((brand) => brand.name);
        } else medication.synonyms = [];

        return medication;
    }

    @PrimaryGeneratedColumn()
    id: number;

    @Column()
    name: string;

    @Column({ nullable: true })
    description: string;

    @Column({ nullable: true })
    pharmgkbId: string;

    @Column('text', { array: true })
    synonyms: string[];

    @Column({ nullable: true })
    drugclass: string;

    @Column({ nullable: true })
    indication: string;
}
