import { applyDecorators } from '@nestjs/common';
import { ApiQuery } from '@nestjs/swagger';
import { IsBooleanString, IsIn, IsOptional } from 'class-validator';

import {
    ApiQueryLimit,
    ApiQueryOffset,
    ApiQueryOrderby,
    ApiQuerySearch,
    ApiQuerySortby,
} from '../../common/api/queries';
import { SearchableFindQueryDto } from '../../common/dtos/searchable-find-query.dto';

export class FindMedicationQueryDto extends SearchableFindQueryDto {
    @IsIn(['name', 'rxcui', 'drugclass'])
    sortby: string;

    @IsBooleanString()
    @IsOptional()
    withGuidelines?: string;

    @IsBooleanString()
    @IsOptional()
    getGuidelines?: string;

    @IsBooleanString()
    @IsOptional()
    onlyIds?: string;
}

export function ApiFindMedicationsQueries(): MethodDecorator {
    return applyDecorators(
        ApiQueryLimit('medication'),
        ApiQueryOffset('medication'),
        ApiQueryOrderby('medication'),
        ApiQuerySearch('medication'),
        ApiQuerySortby('medication'),
        ApiQueryWithGuidelines(),
        ApiQueryGetGuidelines(),
        ApiQueryOnlyIds(),
    );
}

export function ApiFindMedicationQueries(): MethodDecorator {
    return applyDecorators(ApiQueryGetGuidelines());
}

function ApiQueryWithGuidelines(): MethodDecorator {
    return ApiQuery({
        name: 'withGuidelines',
        description:
            'If set to true, this endpoint only returns medications that have corresponding guidelines. Defaults to "false"',
        type: 'boolean',
        required: false,
    });
}

function ApiQueryGetGuidelines(): MethodDecorator {
    return ApiQuery({
        name: 'getGuidelines',
        description:
            'Determines whether medications will be returned with their guidelines. Defaults to "false"',
        type: 'boolean',
        required: false,
    });
}

function ApiQueryOnlyIds(): MethodDecorator {
    return ApiQuery({
        name: 'onlyIds',
        description:
            'Determines whether only IDS of medications will be returned. If set to true, all other query parameters are ignored.',
        type: 'boolean',
        required: false,
    });
}
