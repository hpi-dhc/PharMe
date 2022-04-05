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
    async find(): Promise<Medication[]> {
        return await this.medicationsService.findAll();
    }

    @ApiOperation({
        summary: 'Get summary information and relevant gene-variants',
    })
    @ApiParam({
        name: 'id',
        description: 'ID of the medication to fetch information for.',
        example: '14432',
        type: 'integer',
        required: true,
    })
    @Get(':id')
    async findOne(@Param('id') id: number): Promise<Medication> {
        return await this.medicationsService.findOne(id);
    }

    @ApiOperation({
        summary: 'Clear and update medication data from DrugBank',
    })
    @Post()
    async create(): Promise<void> {
        return this.medicationsService.fetchAllMedications();
    }
}
