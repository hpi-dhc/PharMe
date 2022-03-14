import { Controller, Get, Param, Delete, Post, Query } from '@nestjs/common'
import { ApiOperation, ApiParam, ApiQuery, ApiTags } from '@nestjs/swagger'
import { MedicationsService } from './medications.service'
import { MedicationsGroup } from './medicationsGroup.entity'

@ApiTags('Medications')
@Controller('medications')
export class MedicationsController {
  constructor(private medicationsService: MedicationsService) {}

  @ApiOperation({ summary: 'Fetch all medication groups' })
  @Get()
  async get(): Promise<MedicationsGroup[]> {
    return await this.medicationsService.getAll()
  }

  @ApiOperation({
    summary: 'Clear and update medication data from dailymed',
  })
  @ApiQuery({
    name: 'firstPage',
    description:
      'if provided, only the data from the specified page on (so data from pages after and including firstPage) is loaded into the database',
    example:
      'https://dailymed.nlm.nih.gov/dailymed/services/v2/spls.json?page=1432',
    required: false,
  })
  @Post()
  async create(@Query('firstPage') firstPage: string): Promise<void> {
    return this.medicationsService.fetchAllMedications(
      firstPage ??
        'https://dailymed.nlm.nih.gov/dailymed/services/v2/spls.json',
    )
  }

  @ApiOperation({
    summary: `Remove a specified medication from the server's database`,
  })
  @ApiParam({
    name: 'id',
    description:
      'Id of the medication that should be removed from the database of the annotation server.',
    example: '14432',
    type: 'integer',
    required: true,
  })
  @Delete(':id')
  remove(@Param('id') id: number) {
    return this.medicationsService.removeMedication(id)
  }
}
