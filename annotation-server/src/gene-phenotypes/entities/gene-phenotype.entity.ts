import { Column, Entity, ManyToOne } from 'typeorm';

import { BaseEntity } from '../../common/entities/base.entity';
import { GeneSymbol } from './gene-symbol.entity';
import { Phenotype } from './phenotype.entity';

@Entity()
export class GenePhenotype extends BaseEntity {
    @Column({ nullable: true })
    cpicConsultationText: string;
    // onDelete: 'CASCADE': delete Many when One is deleted
    @ManyToOne(() => GeneSymbol, (geneSymbol) => geneSymbol.genePhenotypes, {
        onDelete: 'CASCADE',
    })
    geneSymbol: GeneSymbol;

    @ManyToOne(() => Phenotype, { onDelete: 'CASCADE' })
    phenotype: Phenotype;
}
