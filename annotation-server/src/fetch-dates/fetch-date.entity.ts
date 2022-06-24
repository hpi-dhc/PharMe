import { Entity, PrimaryColumn, UpdateDateColumn } from 'typeorm';

export enum FetchTarget {
    MEDICATIONS = 'medications',
    GUIDELINES = 'guidelines',
}

@Entity()
export class FetchDate {
    @PrimaryColumn({ type: 'enum', enum: FetchTarget })
    target: FetchTarget;

    @UpdateDateColumn({ type: 'timestamp with time zone' })
    date: Date;
}
