import { Entity, Column, PrimaryGeneratedColumn, OneToMany } from 'typeorm';

import { Ingredient } from './ingredients.entity';

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
  numeratorQuantity: string;

  @Column({ nullable: true })
  numeratorUnit: string;

  @Column({ nullable: true })
  denominatorQuantity: string;

  @Column({ nullable: true })
  denominatorUnit: string;

  @OneToMany(() => Ingredient, (ingredient) => ingredient.medication, {
    cascade: true,
  })
  ingredients: Ingredient[];
}
