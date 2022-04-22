import { Controller, Post } from '@nestjs/common';
import { ApiTags } from '@nestjs/swagger';

import { GuidelinesService } from './guidelines.service';

@ApiTags('Guidelines')
@Controller('guidelines')
export class GuidelinesController {
    constructor(private guidelinesService: GuidelinesService) {}

    @Post()
    async fetchGuidelines(): Promise<void> {
        return this.guidelinesService.fetchGuidelines();
    }
}
