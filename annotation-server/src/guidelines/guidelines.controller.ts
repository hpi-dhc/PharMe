import { Controller, Get, Query } from '@nestjs/common';
import { ApiOperation, ApiTags } from '@nestjs/swagger';

import {
    ApiFindGuidelineErrorsQueries,
    FindGuidelineErrorQueryDto,
} from './dtos/find-guideline-error.dto';
import { GuidelineErrorPageDto } from './dtos/guideline-error-page-dto';
import { GuidelinesService } from './guidelines.service';

@ApiTags('Guidelines')
@Controller('guidelines')
export class GuidelinesController {
    constructor(private guidelinesService: GuidelinesService) {}

    @ApiOperation({ summary: 'Get all guideline data errors' })
    @ApiFindGuidelineErrorsQueries()
    @Get('errors')
    async findAllErrors(
        @Query() dto: FindGuidelineErrorQueryDto,
    ): Promise<GuidelineErrorPageDto> {
        const [guidelineErrors, total] =
            await this.guidelinesService.findAllErrors(
                dto.limit ?? 0,
                dto.offset ?? 0,
                dto.sortby ?? 'blame',
                dto.orderby ?? 'asc',
            );

        return { guidelineErrors: guidelineErrors, total: total };
    }
}
