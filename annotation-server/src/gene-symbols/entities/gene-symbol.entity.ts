import {
    Column,
    Entity,
    JoinTable,
    ManyToMany,
    PrimaryGeneratedColumn,
} from 'typeorm';

import { Phenotype } from './phenotype.entity';

@Entity()
export class GeneSymbol {
    @PrimaryGeneratedColumn()
    id: number;

    @Column()
    name: string;

    @ManyToMany(() => Phenotype, { eager: true })
    @JoinTable()
    phenotypes: Phenotype[];
}
