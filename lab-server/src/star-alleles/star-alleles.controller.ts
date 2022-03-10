import { Controller, Get } from '@nestjs/common';
import { StarAllelesService } from './star-alleles.service';

@Controller('star-alleles')
export class StarAllelesController {
  constructor(private readonly starAllelesService: StarAllelesService) {}

  @Get()
  starAlleles() {
    return this.starAllelesService.getStarAlleles();
  }
}
