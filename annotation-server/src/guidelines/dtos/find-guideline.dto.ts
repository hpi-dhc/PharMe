import { applyDecorators } from '@nestjs/common';
import { IsIn } from 'class-validator';
import { FindOptionsOrder } from 'typeorm';

import {
    ApiQueryLimit,
    ApiQueryOffset,
    ApiQueryOrderby,
    ApiQuerySortby,
} from '../../common/api/queries';
import { FindQueryDto } from '../../common/dtos/find-query.dto';
import { Guideline } from '../entities/guideline.entity';

const sortOptions = ['medicationName', 'geneSymbol'] as const;

export class FindGuidelineQueryDto extends FindQueryDto {
    @IsIn(sortOptions)
    sortby: typeof sortOptions[number];

    static getFindOrder(
        dto: FindGuidelineQueryDto,
    ): FindOptionsOrder<Guideline> {
        switch (dto.sortby) {
            case 'medicationName':
                return {
                    medication: {
                        name: dto.orderby === 'asc' ? 'ASC' : 'DESC',
                    },
                };
            default:
                return {
                    phenotype: {
                        geneSymbol: {
                            name: dto.orderby === 'asc' ? 'ASC' : 'DESC',
                        },
                    },
                };
        }
    }
}

export function ApiFindGuidelinesQueries(): MethodDecorator {
    return applyDecorators(
        ApiQueryLimit('guideline'),
        ApiQueryOffset('guideline'),
        ApiQueryOrderby('guideline'),
        ApiQuerySortby('guideline'),
    );
}
