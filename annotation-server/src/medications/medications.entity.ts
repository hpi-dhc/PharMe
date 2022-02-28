import { Entity, Column, PrimaryGeneratedColumn, ManyToOne } from 'typeorm';
import { MedicationsGroup } from './medicationsGroup.entity';

@Entity()
export class Medication {
  @PrimaryGeneratedColumn()
  id: string;

  @Column()
  name: string;

  @Column()
  agents: string;

  @ManyToOne(() => MedicationsGroup, (medicationsGroup) => medicationsGroup.medications)
  group: MedicationsGroup;
}
