import { Column, Entity, OneToMany } from 'typeorm';

import { BaseEntity } from '../../common/entities/base.entity';
import { GenePhenotype } from './gene-phenotype.entity';

@Entity()
export class GeneSymbol extends BaseEntity {
    @Column()
    name: string;

    @OneToMany(() => GenePhenotype, (genePhenotype) => genePhenotype.geneSymbol)
    genePhenotypes: GenePhenotype[];
}
