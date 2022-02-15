import { Controller, Get, Param, Delete } from '@nestjs/common';
import { Medication } from './medications.entity';
import { MedicationsService } from './medications.service';

@Controller('medications')
export class MedicationsController {
  constructor(private medicationsService: MedicationsService) {}

  @Get()
  async getAll(): Promise<void> {
    return this.medicationsService.getAll();
  }

  @Get(':id')
  async findOne(@Param('id') id: string): Promise<Medication> {
    return this.medicationsService.findOne(id);
  }

  @Delete(':id')
  remove(@Param('id') id: string) {
    return this.medicationsService.removeMedication(id);
  }
}
