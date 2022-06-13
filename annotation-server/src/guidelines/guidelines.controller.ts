import { Controller, Get, Param, Query } from '@nestjs/common';
import { ApiOperation, ApiParam, ApiTags } from '@nestjs/swagger';

import {
    ApiFindGuidelineErrorsQueries,
    FindGuidelineErrorQueryDto,
} from './dtos/find-guideline-error.dto';
import {
    ApiFindGuidelinesQueries,
    FindGuidelineQueryDto,
} from './dtos/find-guideline.dto';
import { GuidelineError } from './entities/guideline-error.entity';
import { Guideline } from './entities/guideline.entity';
import { GuidelinesService } from './guidelines.service';

@ApiTags('Guidelines')
@Controller('guidelines')
export class GuidelinesController {
    constructor(private guidelinesService: GuidelinesService) {}

    @ApiOperation({ summary: 'Fetch all guidelines' })
    @ApiFindGuidelinesQueries()
    @Get()
    async findAll(@Query() dto: FindGuidelineQueryDto): Promise<Guideline[]> {
        return await this.guidelinesService.findAll(
            dto.limit ?? 0,
            dto.offset ?? 0,
            FindGuidelineQueryDto.getFindOrder(dto),
        );
    }

    @ApiOperation({ summary: 'Get all guideline data errors' })
    @ApiFindGuidelineErrorsQueries()
    @Get('errors')
    async findAllErrors(
        @Query() dto: FindGuidelineErrorQueryDto,
    ): Promise<GuidelineError[]> {
        return await this.guidelinesService.findAllErrors(
            dto.limit ?? 0,
            dto.offset ?? 0,
            dto.sortby ?? 'blame',
            dto.orderby ?? 'asc',
        );
    }

    @ApiOperation({ summary: 'Fetch one guideline' })
    @ApiParam({
        name: 'id',
        description: 'ID of the guideline to fetch information for',
        example: '144',
        type: 'integer',
        required: true,
    })
    @Get(':id')
    async findOne(@Param('id') id: number): Promise<Guideline> {
        return await this.guidelinesService.findOne(id);
    }
}
