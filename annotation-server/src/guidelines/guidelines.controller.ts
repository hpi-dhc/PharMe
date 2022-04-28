import { Controller, Post } from '@nestjs/common';
import { ApiOperation, ApiTags } from '@nestjs/swagger';

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
}
