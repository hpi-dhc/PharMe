import {
    BadRequestException,
    Controller,
    Get,
    Param,
    Post,
    Req,
} from '@nestjs/common';
import { ApiOperation, ApiParam, ApiTags } from '@nestjs/swagger';
import { Request } from 'express';

import { PGxFinding } from './interfaces/pgxFinding.interface';
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
        summary:
            'Get clinical annotations for gene variants defined in a cookie.',
        description:
            'The provided cookie `variants` is expected to have a value of a stringified JSON array with elements `{ gene: string, variant1: string, variant2: string }` where `gene` is the gene\'s name, e.g. "CYP2D6" and `variant1` & `variant2` define the given diplotype, e.g. "\\*1" & "\\*2".',
    })
    @ApiParam({
        name: 'id',
        description: 'ID of the medication to fetch clinical annotations for',
        example: '14432',
        type: 'integer',
        required: true,
    })
    @Get(':id/annotations')
    async getAnnotations(
        @Req() request: Request,
        @Param('id') id: number,
    ): Promise<PGxFinding[]> {
        if (!request.cookies?.variants) {
            throw new BadRequestException({
                message: 'Missing cookie `variants`',
            });
        }
        return await this.medicationsService.getAnnotations(
            id,
            JSON.parse(request.cookies.variants),
        );
    }

    @ApiOperation({
        summary: 'Clear and update medication data from DrugBank',
    })
    @Post()
    async create(): Promise<void> {
        return this.medicationsService.fetchAllMedications();
    }
}
