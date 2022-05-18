import {
    Entity,
    Column,
    PrimaryGeneratedColumn,
    OneToMany,
    ViewEntity,
    ViewColumn,
} from 'typeorm';

import { Guideline } from '../guidelines/entities/guideline.entity';
import { DrugDto } from './dtos/drugbank.dto';

@Entity()
export class Medication {
    @PrimaryGeneratedColumn()
    id: number;

    @Column()
    name: string;

    @Column({ nullable: true })
    description: string;

    @Column({ nullable: true })
    pharmgkbId: string;

    @Column({ nullable: true })
    rxcui: string;

    @Column('text', { array: true })
    synonyms: string[];

    @Column({ nullable: true })
    drugclass: string;

    @Column({ nullable: true })
    indication: string;

    @OneToMany(() => Guideline, (guideline) => guideline.medication)
    guidelines: Guideline[];

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
            medication.rxcui = externalIdentifier.find(
                (id) => id.resource === 'RxCUI',
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
}

@ViewEntity({
    expression: `
        select id, name             as "searchString", 1 as priority from medication union
        select id, drugclass        as "searchString", 2 as priority from medication union
        select id, unnest(synonyms) as "searchString", 3 as priority from medication union
        select id, description      as "searchString", 4 as priority from medication
    `,
})
export class MedicationSearchView {
    @ViewColumn()
    id: number;

    @ViewColumn()
    searchString: string;

    @ViewColumn()
    priority: number;
}
