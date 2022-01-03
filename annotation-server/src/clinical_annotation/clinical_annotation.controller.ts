import { Controller, Get, Post } from '@nestjs/common';
import { ClinicalAnnotation } from './clinical_annotation.entity';
import { ClinicalAnnotationService } from './clinical_annotation.service';

@Controller('clinical_annotations')
export class ClinicalAnnotationsController {
  constructor(private clinicalAnnotationsService: ClinicalAnnotationService) {}

  @Get()
  async findAll(): Promise<ClinicalAnnotation[]> {
    return this.clinicalAnnotationsService.findAll();
  }

  @Get('sync')
  loadData() {
    this.clinicalAnnotationsService.synchronize();
  }
}
