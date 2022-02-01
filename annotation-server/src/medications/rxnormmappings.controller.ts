import { Controller, Get, Post, Query } from '@nestjs/common';
import { RxNormMapping } from './rxnormmappings.entity';
import { RxNormMappingsService } from './rxnormmappings.service';

@Controller('rxnorm')
export class RxNormMappingsController {
  constructor(private rxNormMappingsService: RxNormMappingsService) {}
  @Get()
  async findAll(@Query('query') query: string): Promise<RxNormMapping[]> {
    return this.rxNormMappingsService.findAll(query);
  }

  @Post()
  async create() {
    return this.rxNormMappingsService.fetchMedications();
  }
}