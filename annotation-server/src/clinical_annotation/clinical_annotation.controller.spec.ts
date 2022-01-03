import { INestApplication } from '@nestjs/common';
import { Test, TestingModule } from '@nestjs/testing';
import * as request from 'supertest';
import { AppModule } from '../app.module';
import { ClinicalAnnotationService } from './clinical_annotation.service';

describe('ClinicalAnnotationsController (e2e)', () => {
  let app: INestApplication;
  let clinicalAnnotationsService = {
    findAll: () => {
      {
        clinicalAnnotationId: '981204774';
        variants: 'rs1799971';
        genes: 'OPRM1';
        levelOfEvidence: '4';
        score: '-2.0';
        phenotypeCategory: 'Efficacy';
        drugs: 'Drugs used in nicotine dependence;nicotine';
        phenotypes: 'Tobacco Use Disorder';
        pharmkgbUrl: 'https://www.pharmgkb.org/clinicalAnnotation/981204774';
      }
    },
    synchronize: () => {},
  };

  beforeEach(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    })
      .overrideProvider(ClinicalAnnotationService)
      .useValue(clinicalAnnotationsService)
      .compile();

    app = moduleFixture.createNestApplication();
    await app.init();
  });

  it('/clinical_annotations/sync (GET)', () => {
    return request(app.getHttpServer())
      .get('/clinical_annotations/sync')
      .expect(200);
  });

  it('/clinical_annotations (GET)', () => {
    return request(app.getHttpServer())
      .get('/clinical_annotations')
      .expect(200);
  });
});
