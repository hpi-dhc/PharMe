import { Column, Entity } from 'typeorm';

import { BaseEntity } from '../../common/entities/base.entity';

@Entity()
export class User extends BaseEntity {
    @Column({ type: 'uuid', nullable: false })
    sub: string;

    @Column({ nullable: false })
    allelesFile: string;
}
