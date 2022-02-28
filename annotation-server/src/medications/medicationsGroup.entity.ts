import { Entity, Column, PrimaryGeneratedColumn, OneToMany } from 'typeorm';
import { Medication } from './medications.entity';

@Entity()
export class MedicationsGroup {
  @PrimaryGeneratedColumn()
  id: string;

  @Column()
  name: string;

  @OneToMany(() => Medication, (medication) => medication.group, {
    cascade: true,
  })
  medications: Medication[];
}