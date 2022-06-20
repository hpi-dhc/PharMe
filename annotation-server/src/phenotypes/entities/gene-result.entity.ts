import { Entity, Column } from 'typeorm';

import { BaseEntity } from '../../common/entities/base.entity';

@Entity()
export class GeneResult extends BaseEntity {
    @Column()
    name: string;
}
