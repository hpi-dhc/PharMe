import { Controller, Post } from '@nestjs/common';
import { ApiTags } from '@nestjs/swagger';

import { GeneSymbolsService } from './gene-symbols.service';

@ApiTags('GeneSymbols')
@Controller('geneSymbols')
export class GeneSymbolsController {
    constructor(private geneSymbolsService: GeneSymbolsService) {}

    @Post()
    async fetchLookupKeys(): Promise<void> {
        return this.geneSymbolsService.fetchLookupKeys();
    }
}
