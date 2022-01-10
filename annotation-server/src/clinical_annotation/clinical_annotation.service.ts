import { HttpService } from '@nestjs/axios';
import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import * as path from 'path';
import { Repository } from 'typeorm';
import { ClinicalAnnotation } from './clinical_annotation.entity';
import * as os from 'os';
import * as http from 'http';
import * as https from 'https';
import * as fs from 'fs';
import * as unzip from 'extract-zip';
import { parse } from 'csv-parse';
import { AxiosResponse } from 'axios';
import { lastValueFrom, map } from 'rxjs';

@Injectable()
export class ClinicalAnnotationService {
  constructor(
    @InjectRepository(ClinicalAnnotation)
    private clinicalAnnotationRepository: Repository<ClinicalAnnotation>,
    private httpService: HttpService,
  ) {}

  async findAll(): Promise<ClinicalAnnotation[]> {
    return await this.clinicalAnnotationRepository.find();
  }

  async fetchAnnotations(): Promise<void> {
    const url = 'https://s3.pgkb.org/data/clinicalAnnotations.zip';
    const tmpPath = path.join(os.tmpdir(), 'clinical_annotations.zip');
    await this.download(url, tmpPath);
    await this.parseAndSaveData(tmpPath);
  }

  async download(url, filePath): Promise<void> {
    const file = fs.createWriteStream(filePath);
    const response = await lastValueFrom(
      this.httpService.get(url, {
        headers: {
          Accept: 'application/zip',
        },
        responseType: 'arraybuffer',
      }),
    );
    try {
      file.write(response.data);
    } catch (err) {
      console.log(err);
    }
  }

  async parseAndSaveData(filePath): Promise<void> {
    const extractedPath = path.join(os.tmpdir(), 'clinicalAnnotations');

    try {
      if (fs.existsSync(extractedPath)) {
        fs.rm(extractedPath, { recursive: true }, (err) => {
          if (err) {
            console.log(err);
          }
        });
      }
      await unzip(filePath, { dir: extractedPath });
    } catch (err) {
      // handle any errors
      console.log(err);
    }

    const tsvPath = path.join(
      os.tmpdir(),
      'clinicalAnnotations/clinical_annotations.tsv',
    );

    const annotations: ClinicalAnnotation[] = [];

    fs.createReadStream(tsvPath)
      .pipe(parse({ delimiter: '\t', from_line: 2 }))
      .on('data', (row) => {
        // it will start from 2nd row
        annotations.push(new ClinicalAnnotation(row));
      })
      .on('end', () => {
        //might need to set chunk-option, if errors occur
        this.clinicalAnnotationRepository.save<ClinicalAnnotation>(annotations);
      });
  }

  async remove(id: string): Promise<void> {
    await this.clinicalAnnotationRepository.delete(id);
  }
}
