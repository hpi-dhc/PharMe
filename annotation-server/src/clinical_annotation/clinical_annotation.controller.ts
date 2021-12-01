import { Controller, Get, Post } from '@nestjs/common';
import { ClinicalAnnotationService } from './clinical_annotation.service';

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
