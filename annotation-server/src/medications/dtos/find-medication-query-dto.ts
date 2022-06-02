import { applyDecorators } from '@nestjs/common';
import { ApiQuery } from '@nestjs/swagger';
import { IsBooleanString, IsIn } from 'class-validator';

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

    @IsBooleanString()
    withGuidelines: string;
}

export function ApiFindMedicationsQueries(): MethodDecorator {
    return applyDecorators(
        ApiQueryLimit('medication'),
        ApiQueryOffset('medication'),
        ApiQueryOrderby('medication'),
        ApiQuerySearch('medication'),
        ApiQuerySortby('medication'),
        ApiQueryWithGuidelines(),
    );
}

export function ApiFindMedicationQueries(): MethodDecorator {
    return applyDecorators(ApiQueryWithGuidelines());
}

function ApiQueryWithGuidelines(): MethodDecorator {
    return ApiQuery({
        name: 'withGuidelines',
        description:
            'Determines whether medications will be returned with their guidelines. If set to true, this endpoint only returns medications that have corresponding guidelines. Defaults to "false"',
        type: 'boolean',
        required: false,
    });
}
