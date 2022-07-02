import { BaseEntity } from '../entities/base.entity';

export type PatchBodyDto<T extends BaseEntity> = (Pick<T, 'id'> &
    Partial<Omit<T, 'id'>>)[];
