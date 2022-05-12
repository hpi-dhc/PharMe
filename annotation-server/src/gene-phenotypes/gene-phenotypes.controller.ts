import { Controller, Post } from '@nestjs/common';
import { ApiOperation, ApiTags } from '@nestjs/swagger';

import { GenePhenotypesService } from './gene-phenotypes.service';

@ApiTags('GenePhenotypes')
@Controller('genePhenotypes')
export class GenePhenotypesController {
    constructor(private genePhenotypesService: GenePhenotypesService) {}

    @ApiOperation({
        summary:
            'Clear and update CPIC gene-phenotype combinations needed to match CPIC and Google Sheet data',
    })
    @Post()
    async fetchGenePhenotypes(): Promise<void> {
        return this.genePhenotypesService.fetchGenePhenotypes();
    }
}
