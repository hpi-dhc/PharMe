import { Controller, Get, Param, Post } from '@nestjs/common';
import { ApiOperation, ApiParam, ApiTags } from '@nestjs/swagger';

import { Medication } from './medication.entity';
import { MedicationsService } from './medications.service';

@ApiTags('Medications')
@Controller('medications')
export class MedicationsController {
    constructor(private medicationsService: MedicationsService) {}

    @ApiOperation({ summary: 'Fetch all medications' })
    @Get()
    get(): Promise<Medication[]> {
        return this.medicationsService.getAll();
    }

    @ApiOperation({
        summary:
            'Clear and update medication data from DrugBank and the Google Sheet',
    })
    @Post()
    create(): Promise<void> {
        return this.medicationsService.fetchAllMedications();
    }

    @ApiOperation({
        summary:
            'Get detailed information about a medication and all corresponding guidelines',
    })
    @ApiParam({
        name: 'id',
        description:
            'ID of the medication to fetch information and guidelines for',
        example: '144',
        type: 'integer',
        required: true,
    })
    @Get(':id')
    getDetails(@Param('id') id: number): Promise<Medication> {
        return this.medicationsService.getDetails(id);
    }
}
