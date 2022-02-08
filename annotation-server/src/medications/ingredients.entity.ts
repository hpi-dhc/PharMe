import { Entity, PrimaryColumn, ManyToOne, Column } from 'typeorm';
import { Medication } from './medications.entity';

@Entity()
export class Ingredient {
  @ManyToOne(() => Medication, (medication) => medication.ingredients, {
    primary: true,
    onDelete: 'CASCADE',
  })
  medication: Medication;

  @PrimaryColumn()
  ingredient: string;

  @Column({ nullable: true })
  numeratorQuantity: number;

  @Column({ nullable: true })
  numeratorUnit: string;

  @Column({ nullable: true })
  denominatorQuantity: number;

  @Column({ nullable: true })
  denominatorUnit: string;
}
