import { Entity, Column, PrimaryGeneratedColumn, ManyToOne } from 'typeorm';

import { MedicationsGroup } from './medicationsGroup.entity';

@Entity()
export class Medication {
    @PrimaryGeneratedColumn()
    id: number;

    @Column()
    name: string;

    @Column()
    agents: string;

    @Column({ nullable: true })
    manufacturer: string;

    @ManyToOne(
        () => MedicationsGroup,
        (medicationsGroup) => medicationsGroup.medications,
    )
    group: MedicationsGroup;
}
