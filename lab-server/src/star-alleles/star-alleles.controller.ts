import { Controller, Get } from '@nestjs/common';

import { StarAllelesService } from './star-alleles.service';

@Controller('star-alleles')
export class StarAllelesController {
    constructor(private readonly starAllelesService: StarAllelesService) {}

    @Get()
    async starAlleles(): Promise<string> {
        return await this.starAllelesService.getStarAlleles();
    }
}
