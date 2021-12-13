export class CreateClinicalAnnotation {
  clinicalAnnotationId: number;
  variants: string;
  genes: string;
  levelOfEvidence: string;
  levelOverride: boolean;
  levelModifiers: string;
  score: number;
  phenotypeCategory: string;
  pmidCount: number;
  evidenceCount: number;
  drugs: string;
  phenotypes: string;
  latestHistoryDate: Date;
  pharmkgbUrl: string;
  specialityPopulation: string;
}
