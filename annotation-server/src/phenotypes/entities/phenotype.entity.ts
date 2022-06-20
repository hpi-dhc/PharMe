import { Column, Entity, ManyToOne } from 'typeorm';

import { BaseEntity } from '../../common/entities/base.entity';
import { GeneResult } from './gene-result.entity';
import { GeneSymbol } from './gene-symbol.entity';

@Entity()
export class Phenotype extends BaseEntity {
    @Column({ nullable: true })
    cpicConsultationText: string;
    // onDelete: 'CASCADE': delete Many when One is deleted
    @ManyToOne(() => GeneSymbol, (geneSymbol) => geneSymbol.phenotypes, {
        onDelete: 'CASCADE',
    })
    geneSymbol: GeneSymbol;

    @ManyToOne(() => GeneResult, { onDelete: 'CASCADE' })
    geneResult: GeneResult;
}
