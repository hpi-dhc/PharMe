import { Entity, Column, PrimaryGeneratedColumn } from 'typeorm';

@Entity()
export class Phenotype {
    @PrimaryGeneratedColumn()
    id: number;

    @Column()
    lookupkey: string;

    @Column()
    name: string;
}
