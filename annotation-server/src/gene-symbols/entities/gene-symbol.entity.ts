import { Column, Entity, OneToMany, PrimaryGeneratedColumn } from 'typeorm';

import { GenePhenotype } from './gene-phenotype.entity';

@Entity()
export class GeneSymbol {
    @PrimaryGeneratedColumn()
    id: number;

    @Column()
    name: string;

    @OneToMany(
        () => GenePhenotype,
        (genePhenotype) => genePhenotype.geneSymbol,
        { cascade: true }, // create GenePhenotype entries with GeneSymbol
    )
    genePhenotypes: GenePhenotype[];
}
