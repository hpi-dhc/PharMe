import { Entity, ManyToOne, PrimaryGeneratedColumn } from 'typeorm';

import { GeneSymbol } from './gene-symbol.entity';
import { Phenotype } from './phenotype.entity';

@Entity()
export class GenePhenotype {
    @PrimaryGeneratedColumn()
    id: number;

    // onDelete: 'CASCADE': delete Many when One is deleted
    @ManyToOne(() => GeneSymbol, (geneSymbol) => geneSymbol.genePhenotypes, {
        onDelete: 'CASCADE',
    })
    geneSymbol: GeneSymbol;

    @ManyToOne(() => Phenotype, { onDelete: 'CASCADE' })
    phenotype: Phenotype;
}
