import { IsOptional, IsString } from 'class-validator';

import { FindQueryDto } from './find-query.dto';

export abstract class SearchableFindQueryDto extends FindQueryDto {
    @IsOptional()
    @IsString()
    search: string;
}
