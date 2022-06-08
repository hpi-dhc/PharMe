import { applyDecorators } from '@nestjs/common';
import { IsIn } from 'class-validator';

import {
    ApiQueryLimit,
    ApiQueryOffset,
    ApiQueryOrderby,
    ApiQuerySortby,
} from '../../common/api/queries';
import { FindQueryDto } from '../../common/dtos/find-query.dto';

export class FindGuidelineErrorQueryDto extends FindQueryDto {
    @IsIn(['type', 'blame', 'guidelines'])
    sortby: string;
}

export function ApiFindGuidelineErrorsQueries(): MethodDecorator {
    return applyDecorators(
        ApiQueryLimit('guideline error'),
        ApiQueryOffset('guideline error'),
        ApiQueryOrderby('guideline error'),
        ApiQuerySortby('guideline error'),
    );
}
