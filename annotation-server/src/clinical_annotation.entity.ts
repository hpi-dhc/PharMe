import { Entity, Column, PrimaryGeneratedColumn, PrimaryColumn } from 'typeorm';

@Entity()
export class ClinicalAnnotation {
  @PrimaryColumn()
  clinicalAnnotationId: string;

  @Column()
  variants: string;

  @Column()
  genes: string;

  @Column()
  levelOfEvidence: string;

  @Column()
  levelOverride: string;

  @Column()
  levelModifiers: string;

  @Column()
  score: string;

  @Column()
  phenotypeCategory: string;

  @Column()
  pmidCount: string;

  @Column()
  evidenceCount: string;

  @Column()
  drugs: string;

  @Column()
  phenotypes: string;

  @Column()
  latestHistoryDate: Date;

  @Column()
  pharmkgbUrl: string;

  @Column()
  specialityPopulation: string;
}
