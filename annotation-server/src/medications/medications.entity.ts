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
  manifacturer: string;

  @Column()
  agents: string;

  @OneToMany((type) => Ingredient, (ingredient) => ingredient.medication)
  ingredients: Ingredient[];

  @OneToMany(
    (type) => RxNormMapping,
    (rxNormMapping) => rxNormMapping.medication,
  )
  rxNormMapping: RxNormMapping[];
}
