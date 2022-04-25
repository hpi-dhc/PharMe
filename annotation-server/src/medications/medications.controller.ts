import { Controller, Get, Post } from '@nestjs/common';
import { ApiOperation, ApiTags } from '@nestjs/swagger';

import { Medication } from './medication.entity';
import { MedicationsService } from './medications.service';

@ApiTags('Medications')
@Controller('medications')
export class MedicationsController {
    constructor(private medicationsService: MedicationsService) {}

    @ApiOperation({ summary: 'Fetch all medications' })
    @Get()
    async get(): Promise<Medication[]> {
        return await this.medicationsService.getAll();
    }

    @ApiOperation({
        summary:
            'Clear and update medication data from DrugBank and the Google Sheet',
    })
    @Post()
    async create(): Promise<void> {
        return this.medicationsService.fetchAllMedications();
    }
}
