import { Controller, Get, Param, Post, Query } from '@nestjs/common';
import { ApiOperation, ApiParam, ApiTags } from '@nestjs/swagger';
import { FindManyOptions } from 'typeorm';

import { Medication } from './medication.entity';
import { MedicationsService } from './medications.service';

@ApiTags('Medications')
@Controller('medications')
export class MedicationsController {
    constructor(private medicationsService: MedicationsService) {}

    @ApiOperation({ summary: 'Fetch all medications with optional search' })
    @Get()
    get(@Query() query: { search?: string }): Promise<Medication[]> {
        if (query.search) {
            return this.medicationsService.findMatchingMedications(
                query.search,
            );
        }
        return this.medicationsService.getAll();
    }

    @ApiOperation({ summary: 'Get all medication IDs' })
    @Get('ids')
    getIds(): Promise<Medication[]> {
        const options: FindManyOptions<Medication> = { select: ['id'] };
        return this.medicationsService.getAll(options);
    }

    @ApiOperation({
        summary:
            'Fetch all medications that have guidelines including corresponding guidelines',
    })
    @Get('report')
    getMedicationsWithGuidelines(): Promise<Medication[]> {
        return this.medicationsService.getWithGuidelines();
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
