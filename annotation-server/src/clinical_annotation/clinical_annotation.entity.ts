import { Column, Entity, PrimaryColumn } from 'typeorm'

@Entity()
export class ClinicalAnnotation {
  @PrimaryColumn()
  id: number

  @Column({ nullable: true })
  variants?: string

  @Column({ nullable: true })
  genes?: string

  @Column({ nullable: true })
  levelOfEvidence?: string

  @Column({ nullable: true })
  levelOverride?: string

  @Column({ nullable: true })
  levelModifiers?: string

  @Column({ type: 'real', nullable: true })
  score?: number

  @Column({ nullable: true })
  phenotypeCategory?: string

  @Column({ nullable: true })
  pmidCount?: number

  @Column({ nullable: true })
  evidenceCount?: number

  @Column({ nullable: true })
  drugs?: string

  @Column({ nullable: true })
  phenotypes?: string

  @Column({ nullable: true })
  latestHistoryDate?: Date

  @Column({ nullable: true })
  pharmkgbUrl?: string

  @Column({ nullable: true })
  specialityPopulation?: string
}
