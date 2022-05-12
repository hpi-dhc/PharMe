import { Column, Entity, ManyToOne, PrimaryGeneratedColumn } from 'typeorm';

import { Guideline } from './guideline.entity';

export enum GuidelineErrorType {
    MEDICATION_NAME_NOT_FOUND = 'medication_name_not_found',
    MEDICATION_RXCUI_NOT_FOUND = 'medication_rxcui_not_found',
    GENEPHENOTYPE_NOT_FOUND = 'genephenotype_not_found',
    GENE_NOT_FOUND = 'gene_not_found',
    GUIDELINE_MISSING_FROM_SHEET = 'guideline_missing_from_sheet',
    GUIDELINE_MISSING_FROM_CPIC = 'guideline_missing_from_cpic',
}

export enum GuidelineErrorBlame {
    CPIC = 'cpic',
    DRUGBANK = 'drugbank',
    SHEET = 'sheet',
}

@Entity()
export class GuidelineError {
    @PrimaryGeneratedColumn()
    id: number;

    @Column({ type: 'enum', enum: GuidelineErrorType })
    type: GuidelineErrorType;

    @Column({ type: 'enum', enum: GuidelineErrorBlame })
    blame: GuidelineErrorBlame;

    @Column({ nullable: true })
    context: string;

    @ManyToOne(() => Guideline, (guideline) => guideline.errors, {
        onDelete: 'CASCADE',
    })
    guideline: Guideline;
}
