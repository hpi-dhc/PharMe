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
        return medication;
    }

    @PrimaryGeneratedColumn()
    id: number;

    @Column()
    name: string;

    // add alternative names as separate table

    @Column()
    description: string;

    @Column({ nullable: true })
    pharmgkbId: string;
}
