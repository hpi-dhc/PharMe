import {
    Body,
    Controller,
    Get,
    Param,
    Patch,
    Post,
    Query,
} from '@nestjs/common';
import { ApiOperation, ApiTags } from '@nestjs/swagger';

import { ApiBodyPatch } from '../common/api/bodies';
import { ApiParamGetById } from '../common/api/params';
import { PatchBodyDto } from '../common/dtos/patch-body.dto';
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

    @ApiOperation({ summary: 'Clear and update all data from CPIC' })
    @Post()
    initializeDatabase(): Promise<void> {
        return this.guidelinesService.fetchGuidelines();
    }

    @ApiOperation({ summary: `Get the previous CPIC data update's date` })
    @Get('last_update')
    getLastUpdate(): Promise<Date | undefined> {
        return this.guidelinesService.getLastUpdate();
    }

    @ApiOperation({
        summary: 'Supplement matching guideline data from a Google Sheet',
    })
    @Patch('sheet')
    async supplementSheetData(): Promise<void> {
        return this.guidelinesService.supplementSheetData();
    }

    @ApiOperation({ summary: 'Patch medications' })
    @ApiBodyPatch('guideline')
    @Patch()
    async patchGuidelines(
        @Body() patch: PatchBodyDto<Guideline>,
    ): Promise<void> {
        return this.guidelinesService.patch(patch);
    }

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
    @ApiParamGetById('guideline')
    @Get(':id')
    async findOne(@Param('id') id: number): Promise<Guideline> {
        return await this.guidelinesService.findOne(id);
    }
}
