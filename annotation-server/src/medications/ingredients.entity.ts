import { Entity, PrimaryColumn, ManyToOne, Column } from 'typeorm';
import { Medication } from './medications.entity';

@Entity()
export class Ingredient {
  @ManyToOne((type) => Medication, (medication) => medication.ingredients, {
    primary: true,
  })
  medication: Medication;

  @PrimaryColumn()
  ingredient: string;

  @Column()
  quantity: number;

  @Column()
  unit: string;
}
