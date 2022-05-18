import { Controller, Get, Post, Query } from '@nestjs/common';
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

    @ApiOperation({ summary: 'Clear and update Google Sheet guidelines' })
    @Post()
    async fetchGuidelines(): Promise<void> {
        return this.guidelinesService.fetchGuidelines();
    }

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
                dto.sortby ?? 'name',
                dto.orderby ?? 'asc',
            );

        return { guidelineErrors: guidelineErrors, total: total };
    }
}
