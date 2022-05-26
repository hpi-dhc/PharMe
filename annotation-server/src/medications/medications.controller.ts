import { Controller, Get, Param, Query } from '@nestjs/common';
import { ApiOperation, ApiParam, ApiTags } from '@nestjs/swagger';

import {
    ApiFindMedicationsQueries,
    FindMedicationQueryDto,
} from './dtos/find-medication-query-dto';
import { MedicationPageDto } from './dtos/medication-page.dto';
import { Medication } from './medication.entity';
import { MedicationsService } from './medications.service';

@ApiTags('Medications')
@Controller('medications')
export class MedicationsController {
    constructor(private medicationsService: MedicationsService) {}

    @ApiOperation({ summary: 'Fetch all medications with optional search' })
    @ApiFindMedicationsQueries()
    @Get()
    async findAll(
        @Query() dto: FindMedicationQueryDto,
    ): Promise<MedicationPageDto> {
        const [medications, total] = await this.medicationsService.findAll(
            dto.limit ?? 0,
            dto.offset ?? 0,
            dto.search ?? '',
            dto.sortby ?? 'name',
            dto.orderby ?? 'asc',
        );
        return { medications: medications, total: total };
    }

    @ApiOperation({ summary: 'Get all medication IDs' })
    @Get('ids')
    getIds(): Promise<Medication[]> {
        return this.medicationsService.getAll({ select: ['id'] });
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
