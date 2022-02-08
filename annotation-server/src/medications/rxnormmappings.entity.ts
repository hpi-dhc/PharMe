import { Entity, PrimaryColumn, ManyToOne } from 'typeorm';

import { Medication } from './medications.entity';

@Entity()
export class RxNormMapping {
  constructor(entry?) {
    if (!entry) {
      return;
    }

    this.setid = entry[0];
    this.rxstring = entry[3];
  }

  @PrimaryColumn()
  setid: string;

  @PrimaryColumn()
  rxstring: string;

  @ManyToOne(() => Medication, (medication) => medication.rxNormMappings, {
    onDelete: 'SET NULL',
  })
  medication: Medication;
}
