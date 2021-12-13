import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ClinicalAnnotationService } from './clinical_annotation.service';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { ClinicalAnnotation } from './clinical_annotation.entity';
import { ClinicalAnnotationsController } from './clinical_annotation.controller';
import { HttpModule } from '@nestjs/axios';

@Module({
  imports: [TypeOrmModule.forFeature([ClinicalAnnotation]), HttpModule],
  providers: [ClinicalAnnotationService],
  controllers: [ClinicalAnnotationsController],
})
export class AnnotationsModule {}
