import { Entity, Column } from 'typeorm';

import { BaseEntity } from '../../common/entities/base.entity';

@Entity()
export class Phenotype extends BaseEntity {
    @Column()
    name: string;
}
