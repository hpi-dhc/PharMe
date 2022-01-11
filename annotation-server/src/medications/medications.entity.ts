import { Entity, Column, PrimaryColumn } from 'typeorm';

@Entity()
export class Medication {
  constructor(entry?) {
    if (!entry) {
      return;
    }

    this.setid = entry[0];
    this.spl_version = parseInt(entry[1]);
    this.rxcui = parseInt(entry[2]);
    this.rxstring = entry[3];
    this.rxtty = entry[4];
  }

  @PrimaryColumn()
  setid: string;

  @Column()
  spl_version: number;

  @PrimaryColumn()
  rxcui: number;

  @PrimaryColumn()
  rxstring: string;

  @PrimaryColumn()
  rxtty: string;
}
