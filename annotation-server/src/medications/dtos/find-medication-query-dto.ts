import { applyDecorators } from '@nestjs/common';
import { IsIn } from 'class-validator';

import {
    ApiQueryLimit,
    ApiQueryOffset,
    ApiQueryOrderby,
    ApiQuerySearch,
    ApiQuerySortby,
} from '../../common/api/queries';
import { FindSearchableQueryDto } from '../../common/dtos/find-searchable-query.dto';

export class FindMedicationQueryDto extends FindSearchableQueryDto {
    @IsIn(['name', 'rxcui', 'drugclass'])
    sortby: string;
}

export function ApiFindMedicationsQueries(): MethodDecorator {
    return applyDecorators(
        ApiQueryLimit('medication'),
        ApiQueryOffset('medication'),
        ApiQueryOrderby('medication'),
        ApiQuerySearch('medication'),
        ApiQuerySortby('medication'),
    );
}
