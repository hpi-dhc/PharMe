import { Column, Entity, OneToMany } from 'typeorm';

import { BaseEntity } from '../../common/entities/base.entity';
import { Phenotype } from './phenotype.entity';

@Entity()
export class GeneSymbol extends BaseEntity {
    @Column()
    name: string;

    @OneToMany(() => Phenotype, (phenotype) => phenotype.geneSymbol)
    phenotypes: Phenotype[];
}
