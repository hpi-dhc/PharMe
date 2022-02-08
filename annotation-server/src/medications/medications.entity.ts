import { Entity, Column, PrimaryGeneratedColumn, OneToMany } from 'typeorm';

import { Ingredient } from './ingredients.entity';
import { RxNormMapping } from './rxnormmappings.entity';

@Entity()
export class Medication {
  @PrimaryGeneratedColumn()
  id: string;

  @Column()
  name: string;

  @Column()
  manufacturer: string;

  @Column({ nullable: true })
  agents: string;

  @Column({ nullable: true })
  numeratorQuantity: number;

  @Column({ nullable: true })
  numeratorUnit: string;

  @Column({ nullable: true })
  denominatorQuantity: number;

  @Column({ nullable: true })
  denominatorUnit: string;

  @OneToMany(() => Ingredient, (ingredient) => ingredient.medication, {
    cascade: true,
  })
  ingredients: Ingredient[];

  @OneToMany(() => RxNormMapping, (rxNormMapping) => rxNormMapping.medication, {
    cascade: true,
  })
  rxNormMappings: RxNormMapping[];
}
