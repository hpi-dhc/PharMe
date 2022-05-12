import { Entity, Column, PrimaryGeneratedColumn } from 'typeorm';

@Entity()
export class Phenotype {
    @PrimaryGeneratedColumn()
    id: number;

    @Column()
    name: string;
}
