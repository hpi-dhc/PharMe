import { Controller, Delete, Get, Patch } from '@nestjs/common'

import { ClinicalAnnotation } from './clinical_annotation.entity'
import { ClinicalAnnotationService } from './clinical_annotation.service'

@Controller('clinical_annotations')
export class ClinicalAnnotationsController {
  constructor(private clinicalAnnotationsService: ClinicalAnnotationService) {}

  @Patch('sync')
  async syncData(): Promise<void> {
    return await this.clinicalAnnotationsService.syncAnnotations()
  }

  @Get()
  async findAll(): Promise<ClinicalAnnotation[]> {
    return this.clinicalAnnotationsService.getAll()
  }

  @Delete()
  async deleteAll(): Promise<void> {
    await this.clinicalAnnotationsService.clearData()
  }
}
