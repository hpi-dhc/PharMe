import { Controller, Get, Post } from '@nestjs/common';
import { Medication } from './medications.entity';
import { MedicationsService } from './medications.service';

@Controller('medications')
export class MedicationsController {
  constructor(private medicationsService: MedicationsService) {}
  @Get()
  async findAll(): Promise<Medication[]> {
    return this.medicationsService.findAll();
  }

  @Post()
  async create() {
    return this.medicationsService.fetchMedications();
  }
}
