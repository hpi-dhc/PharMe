import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';

import { ClinicalAnnotationsController } from './clinical_annotation.controller';
import { ClinicalAnnotation } from './clinical_annotation.entity';
import { ClinicalAnnotationService } from './clinical_annotation.service';

@Module({
    imports: [TypeOrmModule.forFeature([ClinicalAnnotation])],
    providers: [ClinicalAnnotationService],
    controllers: [ClinicalAnnotationsController],
})
export class AnnotationsModule {}
