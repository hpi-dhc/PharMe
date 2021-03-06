import { Column, Entity, ManyToOne, OneToMany } from 'typeorm';

import { BaseEntity } from '../../common/entities/base.entity';
import { Medication } from '../../medications/medication.entity';
import { Phenotype } from '../../phenotypes/entities/phenotype.entity';
import { CpicRecommendationDto } from '../dtos/cpic-recommendation.dto';
import { GuidelineError } from './guideline-error.entity';

export enum WarningLevel {
    GREEN = 'ok',
    YELLOW = 'warning',
    RED = 'danger',
}

@Entity()
export class Guideline extends BaseEntity {
    @Column({ nullable: true })
    implication: string;

    @Column({ nullable: true })
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

    @ManyToOne(() => Phenotype, { onDelete: 'CASCADE' })
    phenotype: Phenotype;

    @Column()
    cpicRecommendation: string;

    @Column()
    cpicImplication: string;

    @Column()
    cpicClassification: string;

    @Column({ nullable: true })
    cpicComment: string;

    @Column()
    cpicGuidelineId: number;

    @Column()
    cpicGuidelineUrl: string;

    @Column()
    cpicGuidelineName: string;

    @OneToMany(() => GuidelineError, (error) => error.guideline, {
        cascade: true,
    })
    errors: GuidelineError[];

    public get isIncomplete(): boolean {
        return !this.recommendation && !this.implication;
    }

    static fromCpicRecommendation(
        recommendation: CpicRecommendationDto,
        medication: Medication,
        phenotype: Phenotype,
    ): Guideline {
        const guideline = new Guideline();

        guideline.medication = medication;
        guideline.phenotype = phenotype;
        guideline.cpicRecommendation = recommendation.drugrecommendation;
        guideline.cpicClassification = recommendation.classification;
        if (recommendation.comments.toLowerCase() !== 'n/a')
            guideline.cpicComment = recommendation.comments;
        guideline.cpicImplication =
            recommendation.implications[phenotype.geneSymbol.name];
        guideline.cpicGuidelineId = recommendation.guidelineid;
        guideline.errors = [];

        return guideline;
    }
}
