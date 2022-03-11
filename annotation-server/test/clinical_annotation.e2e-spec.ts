import * as request from 'supertest';
import { Test } from '@nestjs/testing';
import { INestApplication } from '@nestjs/common';
import { AppModule } from '../src/app.module';
import { ClinicalAnnotationService } from '../src/clinical_annotation/clinical_annotation.service';
import { downloadAndUnzip } from 'src/common/utils/download-unzip';
import path from 'path';
import os from 'os';
import util from 'util';
import { ClinicalAnnotation } from 'src/clinical_annotation/clinical_annotation.entity';
import fs from 'fs';

describe('Clinical annotations', () => {
  let app: INestApplication;
  let service: ClinicalAnnotationService;
  jest.setTimeout(300000);

  beforeAll(async () => {
    const moduleRef = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = moduleRef.createNestApplication();
    service = moduleRef.get<ClinicalAnnotationService>(
      ClinicalAnnotationService,
    );
    await app.init();
  });

  it(`/PATCH clinical_annotations/sync`, async () => {
    await request(app.getHttpServer())
      .patch('/clinical_annotations/sync')
      .expect(200);
  });

  it(`should call parseAnnotations and receive clinical annotations`, async () => {
    const response = request(app.getHttpServer()).get('/clinical_annotations');
    response.expect(200);
    expect((await response).body.length).toBeGreaterThan(0);
  });

  afterAll(async () => {
    await app.close();
  });
});
