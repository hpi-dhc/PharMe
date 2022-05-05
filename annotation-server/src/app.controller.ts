import { Controller, Post } from '@nestjs/common';
import { ApiOperation } from '@nestjs/swagger';

import { AppService } from './app.service';

@Controller()
export class AppController {
    constructor(private readonly appService: AppService) {}

    @ApiOperation({
        summary:
            'Clear and update all data from DrugBank, the Google Sheet & CPIC',
    })
    @Post('init')
    initializeDatabase(): Promise<void> {
        return this.appService.initializeDatabase();
    }
}
