import { Entity, Column, PrimaryColumn } from 'typeorm';

@Entity()
export class ClinicalAnnotation {
  constructor(entry?) {
    if (!entry) {
      return;
    }

    this.clinicalAnnotationId = parseInt(entry[0]);
    this.variants = entry[1];
    this.genes = entry[2];
    this.levelOfEvidence = entry[3];
    this.levelOverride = entry[4];
    this.levelModifiers = entry[5];
    this.score = entry[6];
    this.phenotypeCategory = entry[7];
    this.pmidCount = parseInt(entry[8]);
    this.evidenceCount = parseInt(entry[9]);
    this.drugs = entry[10];
    this.phenotypes = entry[11];
    this.latestHistoryDate = new Date(entry[12]);
    this.pharmkgbUrl = entry[13];
    this.specialityPopulation = entry[14];
  }

  @PrimaryColumn()
  clinicalAnnotationId: number;

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
  pmidCount: number;

  @Column()
  evidenceCount: number;

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
