import { Controller, Get, Post, Param } from '@nestjs/common';
import { Medication } from './medications.entity';
import { MedicationsService } from './medications.service';
import { RxNormMapping } from './rxnormmappings.entity';

@Controller('medications')
export class MedicationsController {
  constructor(private medicationsService: MedicationsService) {}
  @Get()
  async findAll(): Promise<RxNormMapping[]> {
    return this.medicationsService.findAll();
  }

  @Get(':id')
  async findOne(@Param() params): Promise<Medication> {
    return this.medicationsService.findOne(params.id);
  }

  @Post()
  async create() {
    return this.medicationsService.fetchMedications();
  }
}
