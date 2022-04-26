import { Column, Entity, ManyToOne, PrimaryGeneratedColumn } from 'typeorm';

import { GenePhenotype } from '../gene-phenotypes/entities/gene-phenotype.entity';
import { Medication } from '../medications/medication.entity';

export enum WarningLevel {
    GREEN = 'ok',
    YELLOW = 'warning',
    RED = 'danger',
}

@Entity()
export class Guideline {
    @PrimaryGeneratedColumn()
    id: number;

    @Column()
    implication: string;

    @Column()
    recommendation: string;

    @Column({
        type: 'enum',
        enum: WarningLevel,
        nullable: true,
    })
    warningLevel: WarningLevel;

    @ManyToOne(() => Medication, (medication) => medication.guidelines, {
        onDelete: 'CASCADE',
    })
    medication: Medication;

    @ManyToOne(() => GenePhenotype, { onDelete: 'CASCADE' })
    genePhenotype: GenePhenotype;
}
