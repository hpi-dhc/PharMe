import { Controller, Get, Param, Query } from '@nestjs/common';
import { ApiOperation, ApiParam, ApiTags } from '@nestjs/swagger';

import {
    ApiFindMedicationsQueries,
    ApiFindMedicationQueries,
    FindMedicationQueryDto,
} from './dtos/find-medication-query-dto';
import { Medication } from './medication.entity';
import { MedicationsService } from './medications.service';

@ApiTags('Medications')
@Controller('medications')
export class MedicationsController {
    constructor(private medicationsService: MedicationsService) {}

    @ApiOperation({ summary: 'Fetch all medications' })
    @ApiFindMedicationsQueries()
    @Get()
    async findAll(@Query() dto: FindMedicationQueryDto): Promise<Medication[]> {
        return await this.medicationsService.findAll(
            dto.limit ?? 0,
            dto.offset ?? 0,
            dto.search ?? '',
            dto.sortby ?? 'name',
            dto.orderby ?? 'asc',
            dto.withGuidelines === 'true' ? true : false,
        );
    }

    @ApiOperation({ summary: 'Fetch one medication' })
    @ApiFindMedicationQueries()
    @ApiParam({
        name: 'id',
        description:
            'ID of the medication to fetch information and guidelines for',
        example: '144',
        type: 'integer',
        required: true,
    })
    @Get(':id')
    async findOne(
        @Param() id: number,
        @Query() dto: FindMedicationQueryDto,
    ): Promise<Medication> {
        return await this.medicationsService.findOne(
            id,
            dto.withGuidelines === 'true' ? true : false,
        );
    }

    @ApiOperation({ summary: 'Get all medication IDs' })
    @Get('ids')
    findAllIds(): Promise<Medication[]> {
        return this.medicationsService.getAllIds();
    }
}
