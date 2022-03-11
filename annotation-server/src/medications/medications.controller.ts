import { Controller, Get, Param, Delete, Post } from '@nestjs/common';
import { MedicationsService } from './medications.service';
import { MedicationsGroup } from './medicationsGroup.entity';

@Controller('medications')
export class MedicationsController {
  constructor(private medicationsService: MedicationsService) {}

  /*
  @Get()
  async getAll(): Promise<void> {
    return this.medicationsService.getAll();
  }
  */

  @Get()
  async get(): Promise<MedicationsGroup[]> {
    return await this.medicationsService.getAll();
  }

  @Post()
  async create(): Promise<void> {
    return this.medicationsService.fetchMedications();
  }

  // @Get(':id')
  // async findOne(@Param('id') id: string): Promise<Medication> {
  //   return this.medicationsService.findOne(id);
  // }

  @Delete(':id')
  remove(@Param('id') id: string) {
    return this.medicationsService.removeMedication(id);
  }
}
