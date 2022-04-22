import { Controller, Post } from '@nestjs/common';
import { ApiTags } from '@nestjs/swagger';

import { GenePhenotypesService } from './gene-phenotypes.service';

@ApiTags('GenePhenotypes')
@Controller('genePhenotypes')
export class GenePhenotypesController {
    constructor(private genePhenotypesService: GenePhenotypesService) {}

    @Post()
    async fetchLookupKeys(): Promise<void> {
        return this.genePhenotypesService.fetchGenePhenotypes();
    }
}
