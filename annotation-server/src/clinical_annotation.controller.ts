import { Controller, Get, Post, Query } from '@nestjs/common';
import { ClinicalAnnotationService } from './clinical_annotation.service';
import { ClinicalAnnotation } from './clinical_annotation.entity';

@Controller('clinical_annotations')
export class ClinicalAnnotationsController {
  constructor(private clinicalAnnotationsService: ClinicalAnnotationService) {}

  @Get()
  async findAll(): Promise<ListableAnnotation[]> {
    return this.clinicalAnnotationsService.findAll();
  }

  @Post('sync')
  loadData() {
    this.clinicalAnnotationsService.synchronize();
  }
}
