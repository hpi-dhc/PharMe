import { Controller, Get, Post } from '@nestjs/common';
import { ApiOperation, ApiTags } from '@nestjs/swagger';

import { GuidelineError } from './entities/guideline-error.entity';
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
    @Get('errors')
    async getErrors(): Promise<GuidelineError[]> {
        return this.guidelinesService.getAllErrors();
    }
}
