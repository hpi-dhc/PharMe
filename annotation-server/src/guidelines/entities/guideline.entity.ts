import {
    Column,
    Entity,
    ManyToOne,
    OneToMany,
    PrimaryGeneratedColumn,
} from 'typeorm';

import { GenePhenotype } from '../../gene-phenotypes/entities/gene-phenotype.entity';
import { Medication } from '../../medications/medication.entity';
import { CpicRecommendationDto } from '../dtos/cpic-recommendation.dto';
import { GuidelineError } from './guideline-error.entity';

export enum WarningLevel {
    GREEN = 'ok',
    YELLOW = 'warning',
    RED = 'danger',
}

@Entity()
export class Guideline {
    static fromCpicRecommendation(
        recommendation: CpicRecommendationDto,
        medication: Medication,
        genePhenotype: GenePhenotype,
    ): Guideline {
        const guideline = new Guideline();

        guideline.medication = medication;
        guideline.genePhenotype = genePhenotype;
        guideline.cpicRecommendation = recommendation.drugrecommendation;
        guideline.cpicClassification = recommendation.classification;
        if (recommendation.comments.toLowerCase() !== 'n/a')
            guideline.cpicComment = recommendation.comments;
        guideline.cpicImplication =
            recommendation.implications[genePhenotype.geneSymbol.name];
        guideline.errors = [];

        return guideline;
    }
    @PrimaryGeneratedColumn()
    id: number;

    @Column({
        nullable: true,
    })
    implication: string;

    @Column({
        nullable: true,
    })
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

    @Column()
    cpicRecommendation: string;

    @Column()
    cpicImplication: string;

    @Column()
    cpicClassification: string;

    @Column({
        nullable: true,
    })
    cpicComment: string;

    public get isComplete(): boolean {
        return !!this.recommendation || !!this.implication;
    }

    @OneToMany(() => GuidelineError, (error) => error.guideline, {
        cascade: true,
    })
    errors: GuidelineError[];
}
