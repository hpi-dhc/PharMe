import { IsOptional, IsString } from 'class-validator';

import { FindQueryDto } from './find-query.dto';

export abstract class FindSearchableQueryDto extends FindQueryDto {
    @IsOptional()
    @IsString()
    search: string;
}
