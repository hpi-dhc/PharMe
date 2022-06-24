import { Controller, Get, Param, Query } from '@nestjs/common';
import { ApiOperation, ApiTags } from '@nestjs/swagger';

import { ApiParamGetById } from '../common/api/params';
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

    @ApiOperation({ summary: `Get the previous DrugBank data update's date` })
    @Get('last_update')
    getLastUpdate(): Promise<Date | undefined> {
        return this.medicationsService.getLastUpdate();
    }

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
            FindMedicationQueryDto.isTrueString(dto.withGuidelines),
            FindMedicationQueryDto.isTrueString(dto.getGuidelines),
            FindMedicationQueryDto.isTrueString(dto.onlyIds),
        );
    }

    @ApiOperation({ summary: 'Fetch one medication' })
    @ApiFindMedicationQueries()
    @ApiParamGetById('medication')
    @Get(':id')
    async findOne(
        @Param('id') id: number,
        @Query() dto: FindMedicationQueryDto,
    ): Promise<Medication> {
        return await this.medicationsService.findOne(
            id,
            FindMedicationQueryDto.isTrueString(dto.getGuidelines),
        );
    }
}
