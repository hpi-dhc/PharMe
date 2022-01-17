import {
  Controller,
  Delete,
  Get,
  Param,
  ParseIntPipe,
  Patch,
} from '@nestjs/common';
import { ClinicalAnnotationService } from './clinical_annotation.service';

@Controller('clinical_annotations')
export class ClinicalAnnotationsController {
  constructor(private clinicalAnnotationsService: ClinicalAnnotationService) {}

  @Get()
  findAll() {
    return this.clinicalAnnotationsService.findAll();
  }

  @Patch('sync')
  syncData() {
    return this.clinicalAnnotationsService.fetchAnnotations();
  }

  @Delete(':id')
  remove(@Param('id', ParseIntPipe) id: number) {
    return this.clinicalAnnotationsService.remove(id);
  }
}
