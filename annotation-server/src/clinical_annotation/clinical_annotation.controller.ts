import { Controller, Get, Patch } from '@nestjs/common'
import { ClinicalAnnotationService } from './clinical_annotation.service'

@Controller('clinical_annotations')
export class ClinicalAnnotationsController {
  constructor(private clinicalAnnotationsService: ClinicalAnnotationService) {}

  @Patch('sync')
  async syncData(): Promise<void> {
    return await this.clinicalAnnotationsService.syncAnnotations()
  }

  @Get()
  async findAll() {
    return this.clinicalAnnotationsService.findAll()
  }
}
