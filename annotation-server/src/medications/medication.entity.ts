import { Entity, Column, PrimaryGeneratedColumn } from 'typeorm';

export interface Drug {
    name: string;
    description?: string;
    'external-identifiers'?: {
        'external-identifier':
            | Array<{
                  resource: 'PharmGKB' | string;
                  identifier: string;
              }>
            | {
                  resource: 'PharmGKB' | string;
                  identifier: string;
              };
    };
    'international-brands'?: {
        'international-brand':
            | Array<{
                  name: string;
              }>
            | { name: string };
    };
}
export interface Drugbank {
    drugbank: {
        drug: Array<Drug>;
    };
}

@Entity()
export class Medication {
    static fromDrug(drug: Drug): Medication {
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
}
