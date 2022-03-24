import { Entity, Column, PrimaryGeneratedColumn } from 'typeorm';

export interface Drug {
    name: string;
    description: string;
    'external-identifiers': {
        'external-identifier': Array<{
            resource: 'PharmGKB' | string;
            identifier: string;
        }>;
    };
    'international-brands': {
        'international-brand'?:
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
        medication.pharmgkbId = drug['external-identifiers'][
            'external-identifier'
        ].find(
            (externalIdentifier) => externalIdentifier.resource === 'PharmGKB',
        )?.identifier;
        const internationalBrand =
            drug['international-brands']['international-brand'];
        if (Array.isArray(internationalBrand)) {
            medication.synonyms = internationalBrand.map((brand) => brand.name);
        } else if (internationalBrand) {
            medication.synonyms = [internationalBrand.name];
        } else {
            medication.synonyms = [];
        }

        return medication;
    }

    @PrimaryGeneratedColumn()
    id: number;

    @Column()
    name: string;

    @Column()
    description: string;

    @Column({ nullable: true })
    pharmgkbId: string;

    @Column('text', { array: true })
    synonyms: string[];
}
