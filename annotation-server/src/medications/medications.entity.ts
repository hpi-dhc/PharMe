import { Entity, Column, PrimaryGeneratedColumn } from 'typeorm';

@Entity()
export class Medication {
    @PrimaryGeneratedColumn()
    id: number;

    @Column()
    name: string;

    // add alternative names as separate table

    @Column()
    description: string;

    @Column({ nullable: true })
    pharmgkbId: string;
}
